import SwiftUI

// MARK: - StarField

public extension StarField {

    public struct Content: SwiftUI.View {
        public var viewCenter: (Angle, Angle)
        public var diameter: Angle
        public var objects: [Object]
        public var configuration: Configuration
        public var size: CGSize? = nil

        public init(
            viewCenter: (Angle, Angle),
            diameter: Angle,
            objects: [Object],
            configuration: Configuration = Configuration()
        ) {
            self.viewCenter = viewCenter
            self.diameter = diameter
            self.objects = objects
            self.configuration = configuration
        }

        public var body: some View {
            GeometryReader { geometry in
                let drawSize = size ?? geometry.size
                let projection = configuration.projection
                let projector = projection.makeProjector(
                    viewCenter: viewCenter,
                    viewDiameter: diameter,
                    viewSize: drawSize)

                ZStack {
                    CoordinateLinesView(projector: projector)
                    ObjectsView(objects: objects, projector: projector)
                    NamesView(objects: objects, projector: projector)
                }
                .environmentObject(configuration)

            }
            .frame(width: size?.width, height: size?.height)
            .background(configuration.colorScheme.fieldBackground)
        }

    }

}
