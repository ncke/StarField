import Combine
import SwiftUI

// MARK: - Layout

typealias TextResolver = (String) -> GraphicsContext.ResolvedText?

extension StarField {

    class Layout: ObservableObject {
        let objects: [any PlottableObject]
        let configuration: Configuration
        let viewCenter: (Angle, Angle)
        let viewDiameter: Angle
        let viewSize: CGSize
        let projector: Projector
        let minuteScale: CGFloat
        let obscurementsRegistry: ObscurementsRegistry
        private var visibleObjects = [any PlottableObject]()
        private(set) var objectPlots = [UUID: CGPoint]()
        private var cancellables = Set<AnyCancellable>()
        private var obscuringGraphics = [UUID: [Graphic]]()
        private var furnitureDone = CurrentValueSubject<Bool, Never>(false)
        private var objectsDone = CurrentValueSubject<Bool, Never>(false)

        @Published var furnitureGraphics = [Graphic]()
        @Published var objectGraphics = [Graphic]()
        var nameGraphics = [Graphic]()
        @Published var isReadyForNames = false

        init(
            objects: [any PlottableObject],
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
            self.obscurementsRegistry = ObscurementsRegistry()
            self.minuteScale = Self.computeMinuteLength(
                viewCenter: viewCenter,
                projector: projector)
        }

    }
}

// MARK: - Build

extension StarField.Layout {

    func build() {
        cancellables.forEach { c in c.cancel() }
        cancellables.removeAll()

        furnitureGraphics = []
        objectGraphics = []
        nameGraphics = []
        obscuringGraphics = [:]
        visibleObjects = []

        let lats = configuration.showLinesOfLatitude.enumerateForLatitude()
        let lons = configuration.showLinesOfLongitude.enumerateForLongitude()
        StarField.CoordinateLines(latitudes: lats, longitudes: lons)
            .plotGraphics(using: projector)
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
                    self?.obscuringGraphics[UUID()] = [graphic]
                }
            )
            .store(in: &cancellables)

        objects.sorted(by: { s1, s2 in
            s1.magnitude < s2.magnitude
        })
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

    func plotAndRecordObject(_ object: PlottableObject) -> [StarField.Graphic] {
        let graphics = object.plotGraphics(using: projector)

        if !graphics.isEmpty {
            obscuringGraphics[object.id] = graphics
            visibleObjects.append(object)
        }

        return graphics
    }

    func checkNameReadiness() {
        isReadyForNames = furnitureDone.value && objectsDone.value
    }

    func layoutNames(using textResolver: TextResolver) -> [StarField.Graphic] {
        return plotNames(for: visibleObjects, avoiding: obscuringGraphics, using: textResolver)
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
