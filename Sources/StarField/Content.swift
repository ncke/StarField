import SwiftUI

// MARK: - StarField

public extension StarField {

    public struct Content: SwiftUI.View {
        public var viewCenter: (Angle, Angle)
        public var diameter: Angle
        public var size: CGSize? = nil
        public var configuration: Configuration

        public var objects: [Object]

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
                let plotter = configuration.projection.makePlotter(
                    viewCenter: viewCenter,
                    viewDiameter: diameter,
                    viewSize: drawSize)

                ZStack {
                    CoordinateLinesView(plotter: plotter)
                    ObjectsView(objects: objects, plotter: plotter)
                    NamesView(objects: objects, plotter: plotter)
                }
                .environmentObject(configuration)

            }
            .frame(width: size?.width, height: size?.height)
            .background(configuration.colorScheme.fieldBackground)
        }

    }

}
