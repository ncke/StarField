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
                let viewSize = size ?? geometry.size
                let layout = Layout(
                    objects: objects,
                    configuration: configuration,
                    viewCenter: viewCenter,
                    viewDiameter: diameter,
                    viewSize: viewSize)

                GraphicsStack(layout: layout)
                    .task { await layout.build() }
                    .environmentObject(configuration)
            }
            .frame(width: size?.width, height: size?.height)
            .background(configuration.colorScheme.fieldBackground)
        }

    }

}

// MARK: - GraphicsStack

private extension StarField {

    struct GraphicsStack: SwiftUI.View {
        @StateObject var layout: Layout

        var body: some View {
            ZStack {
                FurnitureView(graphics: $layout.furnitureGraphics)
                ObjectsView(graphics: $layout.objectGraphics)
                NamesView(layout: layout, graphics: $layout.nameGraphics)
            }
        }

    }

}
