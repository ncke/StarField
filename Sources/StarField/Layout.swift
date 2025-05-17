import SwiftUI

// MARK: - Layout

extension StarField {

    class Layout: ObservableObject {
        let objects: [Object]
        let configuration: Configuration
        let viewCenter: (Angle, Angle)
        let viewDiameter: Angle
        let viewSize: CGSize
        let projector: Projector

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
        }

        func build() {
            plotCoordinateLines()
            plotObjects()
            plotNames()
        }

    }

}
