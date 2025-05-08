import SwiftUI

// MARK: - StarField

public extension StarField {

    public struct Content: SwiftUI.View {
        public var viewCenter: (Angle, Angle)
        public var diameter: Angle
        public var size: CGSize? = nil
        @ObservedObject public var configuration: StarField.Configuration

        public var stars: [Star]

        public init(
            viewCenter: (Angle, Angle),
            diameter: Angle,
            stars: [Star],
            configuration: StarField.Configuration = StarField.Configuration()
        ) {
            self.viewCenter = viewCenter
            self.diameter = diameter
            self.stars = stars
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
                    CoordinateLinesView(
                        configuration: configuration,
                        plotter: plotter)

                    StarsView(
                        stars: stars,
                        configuration: configuration,
                        plotter: plotter)

                    NamesView(
                        stars: stars,
                        configuration: configuration,
                        plotter: plotter)
                }
            }
            .frame(width: size?.width, height: size?.height)
            .background(configuration.colorScheme.fieldBackground)
        }

    }

}
