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

                    case .starCircle(let center, let radius):
                        fillStarForRadius(
                            radius,
                            center: center,
                            context: context)

                    case .starInscribedCircle(let center, let radius):
                        fillInscribedStarForRadius(
                            radius,
                            center: center,
                            context: context)

                    default:
                        break
                    }
                }

                graphics.forEach { graphic in
                    switch graphic {

                    case .starWingLine(let start, let finish):
                        fillWingLine(
                            start: start,
                            finish: finish,
                            context: context)

                    default:
                        break
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

        func fillStarForRadius(
            _ radius: CGFloat,
            center: CGPoint,
            context: GraphicsContext
        ) {
            let cs = configuration.colorScheme
            let ss = GraphicsContext.Shading.color(cs.starColor)
            let diameter = 2 * radius

            if configuration.showStarAura {
                let au = GraphicsContext.Shading.color(cs.backgroundColor)
                let aura: CGFloat = 1.0
                let auraDiameter = 2 * (radius + aura)
                let auraEllipse = CGRect(
                    x: center.x - radius - aura,
                    y: center.y - radius - aura,
                    width: auraDiameter,
                    height: auraDiameter)

                let path = Path(ellipseIn: auraEllipse)
                context.fill(path, with: au)
            }

            let starEllipse = CGRect(
                origin: CGPoint(x: center.x - radius, y: center.y - radius),
                size: CGSize(width: diameter, height: diameter))

            let path = Path(ellipseIn: starEllipse)
            context.fill(path, with: ss)
        }

        func fillInscribedStarForRadius(
            _ radius: CGFloat,
            center: CGPoint,
            context: GraphicsContext
        ) {
            let cs = configuration.colorScheme
            let bg = GraphicsContext.Shading.color(cs.backgroundColor)
            fillStarForRadius(radius, center: center, context: context)

            let shellHalfWidth = max((0.1 * radius).rounded(.down), 0.5)
            let shellLineWidth = 2 * shellHalfWidth
            let shellRadius = max(radius - shellLineWidth - shellHalfWidth, 0)
            let shellDiameter = 2 * shellRadius

            let shellEllipse = CGRect(
                x: center.x - shellRadius,
                y: center.y - shellRadius,
                width: shellDiameter,
                height: shellDiameter)

            context.stroke(
                Path(ellipseIn: shellEllipse),
                with: bg,
                lineWidth: shellLineWidth)
        }

    }

}
