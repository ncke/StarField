import Combine
import SwiftUI

// MARK: - Layout

typealias TextResolver = (String) -> GraphicsContext.ResolvedText?

extension StarField {

    class Layout: ObservableObject {
        let objects: [any StarFieldObject]
        let configuration: Configuration
        let viewCenter: (Angle, Angle)
        let viewDiameter: Angle
        let viewSize: CGSize
        let projector: Projector
        let minuteScale: CGFloat
        //private var visibleObjects = [any PlottableObject]()
        //private(set) var objectPlots = [UUID: CGPoint]()
        private var cancellables = Set<AnyCancellable>()
        // TODO: We only need a single [UUID: Graphic] now.
        //private var obscuringGraphics = [UUID: [Graphic]]()
        private var furnitureDone = CurrentValueSubject<Bool, Never>(false)
        private var objectsDone = CurrentValueSubject<Bool, Never>(false)

        @Published var furnitureGraphics = [Graphic]()
        @Published var objectGraphics = [Graphic]()
        //var nameGraphics = [Graphic]()
        @Published var isReadyForNames = false

        init(
            objects: [any StarFieldObject],
            configuration: Configuration,
            viewCenter: (Angle, Angle),
            viewDiameter: Angle,
            viewSize: CGSize
        ) {
            self.objects = objects
            self.configuration = configuration
            self.viewCenter = viewCenter
            self.viewDiameter = viewDiameter
            self.viewSize = viewSize
            self.projector = configuration.projection.makeProjector(
                viewCenter: viewCenter,
                viewDiameter: viewDiameter,
                viewSize: viewSize)
            self.minuteScale = Self.computeMinuteLength(
                viewCenter: viewCenter,
                projector: projector)
        }

    }
}

// MARK: - Build

extension StarField.Layout {

    func build() {
        clearExistingBuiltProducts()
        buildCoordinateLines()
        buildObjectPlots()
    }

    func clearExistingBuiltProducts() {
        cancellables.forEach { c in c.cancel() }
        cancellables.removeAll()

        // TODO: We no longer need this much state, simplify.
        furnitureGraphics = []
        objectGraphics = []
        //nameGraphics = []
        //obscuringGraphics = [:]
        //visibleObjects = []
    }

    func buildCoordinateLines() {
        let lats = configuration.showLinesOfLatitude.enumerateForLatitude()
        let lons = configuration.showLinesOfLongitude.enumerateForLongitude()
        StarField.CoordinateLines(latitudes: lats, longitudes: lons)
            .plotGraphics(using: projector, configuration: configuration)
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
                    //self?.obscuringGraphics[UUID()] = [graphic]
                }
            )
            .store(in: &cancellables)
    }

    func buildObjectPlots() {
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

    func plotAndRecordObject(
        _ object: any PlottableObject
    ) -> [StarField.Graphic] {
        let graphics = object.plotGraphics(
            using: projector,
            configuration: configuration)

        if let g = graphics {
            //obscuringGraphics[object.id] = [g]
            //visibleObjects.append(object)
            return [g]
        }

        return []
    }

    func checkNameReadiness() {
        isReadyForNames = furnitureDone.value && objectsDone.value
    }

    func layoutNames(
        using textResolver: TextResolver
    ) -> [StarField.Graphic] {
        let fitter = StarField.NamesFitter(
            objects: objects,
            graphics: furnitureGraphics + objectGraphics,
            viewSize: viewSize)

        return fitter.fit(textResolver: textResolver)
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
