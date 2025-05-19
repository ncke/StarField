import Combine
import SwiftUI

// MARK: - Layout

protocol TextResolver: AnyObject {
    func resolve(_ text: Text) -> GraphicsContext.ResolvedText
}

extension StarField {

    class Layout: ObservableObject {
        let objects: [Object]
        let configuration: Configuration
        let viewCenter: (Angle, Angle)
        let viewDiameter: Angle
        let viewSize: CGSize
        let projector: Projector
        let minuteScale: CGFloat
        weak var textResolver: TextResolver?
        private(set) var objectPlots = [UUID: CGPoint]()
        private var cancellables = Set<AnyCancellable>()
        private var obscuringGraphics = [Graphic]()
        private var furnitureDone = PassthroughSubject<Void, Never>()
        private var objectsDone = PassthroughSubject<Void, Never>()
        private var resolverReady = CurrentValueSubject<Bool, Never>(false)

        @Published var furnitureGraphics = [Graphic]()
        @Published var objectGraphics = [Graphic]()
        @Published var nameGraphics = [Graphic]()

        init(
            objects: [Object],
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

        func setTextResolver(_ resolver: TextResolver) {
            self.textResolver = resolver
            resolverReady.send(true)
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
        obscuringGraphics = []

        plotCoordinateLines()
            .publisher
            .handleEvents(receiveCompletion: {
                [weak self] _ in self?.furnitureDone.send()
            })
            .sink {
                [weak self] graphic in

                self?.furnitureGraphics.append(graphic)
                self?.obscuringGraphics.append(graphic)
            }
            .store(in: &cancellables)

        objects
            .publisher
            .flatMap { object in self.plotObject(object).publisher }
            .handleEvents(receiveCompletion: {
                [weak self] _ in self?.objectsDone.send()
            })
            .sink {
                [weak self] graphic in

                self?.objectGraphics.append(graphic)
                self?.obscuringGraphics.append(graphic)
            }
            .store(in: &cancellables)

        furnitureDone
            .combineLatest(objectsDone, resolverReady)
            .filter { _, _, isReady in isReady }
            .prefix(1)
            .flatMap { [weak self] (_, _, _) in
                guard let self = self else {
                    return Empty<[StarField.Graphic], Never>()
                        .eraseToAnyPublisher()
                }

                let avoiding = self.obscuringGraphics
                return Just(self.plotNames(avoiding: avoiding))
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] nameGraphics in
                self?.nameGraphics = nameGraphics
            }
            .store(in: &cancellables)
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
