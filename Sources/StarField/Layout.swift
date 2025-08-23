import Combine
import SwiftUI

// MARK: - Layout

extension StarField {

    final class Layout: ObservableObject {
        let objects: [any Object]
        let objectsIndex: [UUID: any Object]
        let furniture: [any Furniture]
        let configuration: Configuration
        let viewCenter: (Angle, Angle)
        let viewDiameter: Angle
        let viewSize: CGSize
        let projector: Projector
        let minuteScale: CGFloat

        private var cancellables = Set<AnyCancellable>()
        private var objectsDone = CurrentValueSubject<Bool, Never>(false)
        private var furnitureDone = CurrentValueSubject<Bool, Never>(false)

        @Published var furnitureGraphics = [Graphic]()
        @Published var objectGraphics = [Graphic]()
        @Published var isReadyForNames = false

        init(
            objects: [any Object],
            furniture: [any Furniture],
            configuration: Configuration,
            viewCenter: (Angle, Angle),
            viewDiameter: Angle,
            viewSize: CGSize,
            projector: Projector
        ) {
            self.objects = Self.sortObjectsForDrawing(
                objects,
                configuration: configuration)
            self.objectsIndex = Dictionary(
                uniqueKeysWithValues: objects.map { obj in (obj.id, obj) }
            )
            self.furniture = furniture
            self.configuration = configuration
            self.viewCenter = viewCenter
            self.viewDiameter = viewDiameter
            self.viewSize = viewSize
            self.projector = projector
            self.minuteScale = Self.computeMinuteLength(
                viewCenter: viewCenter,
                projector: projector)
        }

        deinit {
            clearExistingBuiltProducts()
        }

    }
}

// MARK: - Build Graphics

extension StarField.Layout {

    func build() {
        print(Date.timeIntervalSinceReferenceDate, "ALL START")
        clearExistingBuiltProducts()
        buildFurniturePlots()
        buildObjectPlots()
        print(Date.timeIntervalSinceReferenceDate, "ALL DONE")
    }

    private func clearExistingBuiltProducts() {
        print(Date.timeIntervalSinceReferenceDate, "CANCELLING")
        cancellables.forEach { c in c.cancel() }
        cancellables.removeAll()
        furnitureGraphics = []
        objectGraphics = []
    }

    private func buildFurniturePlots() {
        furniture
            .publisher
            .compactMap { item in
                (item as? Plottable)?.plotGraphics(
                    using: projector,
                    configuration: configuration)
            }
            .collect()
            .sink { [weak self] _ in
                self?.furnitureDone.send(true)
                self?.checkNameReadiness()
            } receiveValue: { [weak self] graphics in
                self?.furnitureGraphics = graphics
            }
            .store(in: &cancellables)
    }

    private func buildObjectPlots() {
        objects
            .publisher
            .compactMap { object in
                (object as? PlottableObject)?.plotGraphics(
                    using: projector,
                    configuration: configuration)
            }
            .collect()
            .sink(
                receiveCompletion: { _ in
                    print(Date.timeIntervalSinceReferenceDate, "OBS DONE")
                    self.objectsDone.send(true)
                    self.checkNameReadiness()
                },
                receiveValue: { graphics in
                    self.objectGraphics = graphics
                }
            )
            .store(in: &cancellables)
    }

    private func checkNameReadiness() {
        isReadyForNames = configuration.showNames
        && objectsDone.value
        && furnitureDone.value
    }

}

// MARK: - Name Layout

extension StarField.Layout {

    func layoutNames(
        using textResolver: StarField.TextResolver
    ) -> [StarField.Graphic] {
        print(Date.timeIntervalSinceReferenceDate, "NAMES START")
        let nameableFurniture = furniture.compactMap {
            furn in furn as? StarField.Nameable
        }

        let nameableObjects = objects.compactMap {
            obj in obj as? StarField.Nameable
        }

        let fitter = StarField.NamesFitter(
            nameables: nameableFurniture +  nameableObjects,
            graphics: furnitureGraphics + objectGraphics,
            viewSize: viewSize)

        print(Date.timeIntervalSinceReferenceDate, "NAMES DONE")
        return fitter.fit(textResolver: textResolver)
    }

}

// MARK: - Nearest Object

extension StarField.Layout: StarField.NearestObjectProvider {

    func nearestObject(
        to location: CGPoint
    ) -> (any StarField.Object, CGFloat)? {
        guard objectsDone.value else { return nil }

        let (lx, ly) = (location.x, location.y)
        var nearestGraphic: StarField.Graphic? = nil
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

        for graphic in self.objectGraphics {
            for shape in graphic.shapes {
                let midpoint = shape.midpoint
                let (dx, dy) = (lx - midpoint.x, ly - midpoint.y)
                let distance = dx * dx + dy * dy

                if distance < nearestDistance {
                    nearestGraphic = graphic
                    nearestDistance = distance
                }
            }
        }

        guard
            let objectId = nearestGraphic?.id,
            let object = objectsIndex[objectId]
        else {
            return nil
        }

        let rootDistance = sqrt(nearestDistance)
        return (object, rootDistance)
    }

}

// MARK: - Drawing Order

private extension StarField.Layout {

    static func sortObjectsForDrawing(
        _ objects: [any StarField.Object],
        configuration: StarField.Configuration
    ) -> [any StarField.Object] {
        objects.sorted { obj1, obj2 in
            if !configuration.showPlanetsOnTop {
                return obj1.magnitude < obj2.magnitude
            }

            let isPlanetObj1 = obj1 is StarField.Planet
            let isPlanetObj2 = obj2 is StarField.Planet

            if (isPlanetObj1 && isPlanetObj2)
                || (!isPlanetObj1 && !isPlanetObj2)
            {
                return obj1.magnitude < obj2.magnitude
            }

            return isPlanetObj1 ? true : false
        }
    }

}

// MARK: - Minute Scale

private extension StarField.Layout {

    static let oneMinuteAngle = Angle(radians: 0.000290888)

    static func computeMinuteLength(
        viewCenter: (Angle, Angle),
        projector: StarField.Projector
    ) -> CGFloat {
        let p1 = projector.plot(
            StarField.Position(
                rightAscension: viewCenter.0,
                declination: viewCenter.1)
        ) ?? CGPointZero

        let p2 = projector.plot(
            StarField.Position(
                rightAscension: viewCenter.0 + Self.oneMinuteAngle,
                declination: viewCenter.1)
        ) ?? CGPointZero

        return abs(p2.x - p1.x)
    }

}
