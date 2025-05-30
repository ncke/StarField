import SwiftUI

// MARK: - StarsView

extension StarField {

    struct ObjectsView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        @Binding var graphics: [Graphic]

        public var body: some View {
            let cs = configuration.colorScheme
            let ss = GraphicsContext.Shading.color(cs.starColor)
            let au = GraphicsContext.Shading.color(cs.backgroundColor)

            Canvas { context, _ in
                graphics.forEach { graphic in
                    switch graphic {
                    case .starCircle: drawStarGraphic(graphic, context: context)
                    default: break
                    }
                }
            }
        }

        func fillWingLine(
            start: CGPoint,
            finish: CGPoint,
            context: GraphicsContext
        ) {
            let cs = configuration.colorScheme
            let ss = GraphicsContext.Shading.color(cs.starColor)

            var wingPath = Path()
            wingPath.move(to: start)
            wingPath.addLine(to: finish)
            context.stroke(wingPath, with: ss)
        }

        func drawStarGraphic(
            _ graphic: StarField.Graphic,
            context: GraphicsContext
        ) {
            guard
                case .starCircle(
                    center: let center,
                    radius: let radius,
                    isInscribed: let isInscribed,
                    hasWings: let hasWings
                ) = graphic
            else {
                return
            }

            let cs = configuration.colorScheme
            let ss = GraphicsContext.Shading.color(cs.starColor)
            let bg = GraphicsContext.Shading.color(cs.backgroundColor)

            let starRect = rectWithCenter(center, radius: radius)

            var wingRects = [CGRect]()
            if hasWings {
                let wingLength = max(radius * 0.7, 1.0)
                let right = rectForWingOnRect(starRect, length: wingLength, height: 1.0)
                let left = rectForWingOnRect(starRect, length: -wingLength, height: 1.0)
                wingRects = [left, right]
            }

            if configuration.showStarAura {
                let aura: CGFloat = 1.0
                let auraRect = enlargeRect(starRect, delta: aura)
                let path = Path(ellipseIn: auraRect)
                context.fill(path, with: bg)

                wingRects.forEach { wingRect in
                    let wingAuraRect = enlargeRect(wingRect, delta: aura)
                    let path = Path(wingAuraRect)
                    context.fill(path, with: bg)
                }
            }

            var starPath = Path(ellipseIn: starRect)
            wingRects.forEach { wingRect in starPath.addRect(wingRect) }
            context.fill(starPath, with: ss)

            if isInscribed {
                let (width, halfWidth) = (CGFloat(1.0), CGFloat(0.5))
                let scribedRadius = max(radius - width - halfWidth, 1.0)
                let scribedRect = rectWithCenter(center, radius: scribedRadius)
                let scribedPath = Path(ellipseIn: scribedRect)
                context.stroke(scribedPath, with: bg, lineWidth: width)
            }
        }

        func rectWithCenter(_ center: CGPoint, radius: CGFloat) -> CGRect {
            CGRect(
                x: center.x.rounded() - radius,
                y: center.y.rounded() - radius,
                width: 2.0 * radius,
                height: 2.0 * radius)
        }

        func enlargeRect(_ rect: CGRect, delta: CGFloat) -> CGRect {
            CGRect(
                x: Int(rect.minX - delta),
                y: Int(rect.minY - delta),
                width: Int(rect.width + 2.0 * delta),
                height: Int(rect.height + 2.0 * delta))
        }

        func rectForWingOnRect(
            _ rect: CGRect,
            length: CGFloat,
            height: CGFloat
        ) -> CGRect {
            let root = length > 0 ? rect.maxX : rect.minX
            return CGRect(
                x: Int(root),
                y: Int(rect.midY),
                width: Int(length),
                height: Int(height))
        }

    }

}
