import SwiftUI

// MARK: - Coordinate Lines View

extension StarField {

    struct FurnitureView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        @Binding var graphics: [Graphic]

        public var body: some View {
            let cs = configuration.colorScheme

            Canvas { context, _ in
                let coordinateLineShading = GraphicsContext.Shading.color(
                    cs.colorForCoordinateLines
                )

                for graphic in graphics {
                    switch graphic {

                    case .coordinateLine(let start, let finish):
                        var path = Path()
                        path.move(to: start)
                        path.addLine(to: finish)
                        context.stroke(path, with: coordinateLineShading)

                    default:
                        break
                    }
                }

            }
        }

    }

}
