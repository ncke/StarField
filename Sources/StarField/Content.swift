import SwiftUI

// MARK: - StarField

extension StarField {

    public struct Content: SwiftUI.View {
        public var viewCenter: (Angle, Angle)
        public var diameter: Angle
        public var objects: [any Object]
        public var furniture: [any Furniture]
        public var configuration: Configuration
        public var size: CGSize? = nil
        public let tapHandler: TapHandler?

        public init(
            viewCenter: (Angle, Angle),
            diameter: Angle,
            objects: [any Object],
            furniture: [any Furniture],
            configuration: Configuration = Configuration(),
            tapHandler: TapHandler? = nil
        ) {
            self.viewCenter = viewCenter
            self.diameter = diameter
            self.objects = objects
            self.furniture = furniture
            self.configuration = configuration
            self.tapHandler = tapHandler
        }

        public var body: some View {
            GeometryReader { geometry in
                let viewSize = size ?? geometry.size
                let projector = configuration.projection.makeProjector(
                    viewCenter: viewCenter,
                    viewDiameter: diameter,
                    viewSize: viewSize)
                let layout = Layout(
                    objects: objects,
                    furniture: furniture,
                    configuration: configuration,
                    viewCenter: viewCenter,
                    viewDiameter: diameter,
                    viewSize: viewSize,
                    projector: projector)
                let tapResolver = TapResolver(
                    effectiveRadius: configuration.tapEffectiveRadius,
                    projector: projector,
                    nearestObjectProvider: layout)

                GraphicsStack(layout: layout)
                    .onTapGesture { location in
                        if  let tapHandler = tapHandler,
                            let result = tapResolver?.resolveTap(at: location)
                        {
                            tapHandler(result.position, result.nearestObject)
                        }
                    }
                    .onAppear { layout.build() }
                    .environmentObject(configuration)
            }
            .frame(width: size?.width, height: size?.height)
            .background(configuration.colorScheme.backgroundColor)
        }

    }

}

// MARK: - GraphicsStack

private extension StarField {

    struct GraphicsStack: SwiftUI.View {
        @StateObject var layout: Layout

        var body: some View {
            ZStack {
                GraphicsView(graphics: $layout.furnitureGraphics)
                GraphicsView(graphics: $layout.objectGraphics)
                if layout.isReadyForNames { NamesView(layout: layout) }
            }
        }

    }

}
