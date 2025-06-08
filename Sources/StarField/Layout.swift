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
            self.objects = objects
            self.objectsIndex = Dictionary(
                uniqueKeysWithValues: objects.map { obj in (obj.id, obj) })
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

    }
}

// MARK: - Build Graphics

extension StarField.Layout {

    func build() {
        clearExistingBuiltProducts()
        buildFurniturePlots()
        buildObjectPlots()
    }

    private func clearExistingBuiltProducts() {
        cancellables.forEach { c in c.cancel() }
        cancellables.removeAll()
        furnitureGraphics = []
        objectGraphics = []
    }

    private func buildFurniturePlots() {
        furniture
            .compactMap { item in
                guard let item = item as? Plottable else { return nil }
                return item.plotGraphics(
                    using: projector,
                    configuration: configuration)
            }
            .publisher
            .sink(
                receiveCompletion: {
                    [weak self] _ in
                    self?.furnitureDone.send(true)
                    self?.checkNameReadiness()
                },
                receiveValue: {
                    [weak self] graphic in
                    self?.furnitureGraphics.append(graphic)
                }
            )
            .store(in: &cancellables)
    }

    private func buildObjectPlots() {
        objects
            .compactMap {
                obj in obj as? (any PlottableObject)
            }
            .sorted { s1, s2 in
                s1.magnitude < s2.magnitude
            }
            .publisher
            .flatMap {
                [weak self] object in
                (self?.plotAndRecordObject(object)).publisher
            }
            .sink(
                receiveCompletion: {
                    [weak self] _ in
                    self?.objectsDone.send(true)
                    self?.checkNameReadiness()
                },
                receiveValue: { [weak self] graphic in
                    self?.objectGraphics.append(contentsOf: graphic)
                }
            )
            .store(in: &cancellables)
    }

    // TODO: This doesn't need to return an array now.
    private func plotAndRecordObject(
        _ object: any PlottableObject
    ) -> [StarField.Graphic] {
        let graphics = object.plotGraphics(
            using: projector,
            configuration: configuration)

        if let g = graphics {
            return [g]
        }

        return []
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
        using textResolver: TextResolver
    ) -> [StarField.Graphic] {
        let nameables = objects.sorted { obj1, obj2 in
            obj1.magnitude < obj2.magnitude
        }
            .compactMap { obj in
            obj as? StarField.Nameable
        }

        let fitter = StarField.NamesFitter(
            nameables: nameables,
            graphics: furnitureGraphics + objectGraphics,
            viewSize: viewSize)

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
            let objectId = nearestGraphic?.objectId,
            let object = objectsIndex[objectId]
        else {
            return nil
        }

        let rootDistance = sqrt(nearestDistance)
        return (object, rootDistance)
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
