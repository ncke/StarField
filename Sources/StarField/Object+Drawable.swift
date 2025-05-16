import SwiftUI

extension StarField.Object: Drawable {

    func obscures(projector: StarField.Projector) -> StarField.Obscurement? {
        guard
            let plot = projector.plot(position),
            projector.isPlotNearView(plot)
        else { return nil }

        let yRadius = radius(projector: projector)
        var xRadius = yRadius

        if case let .star(isDouble, _) = self.type {
            xRadius += wingLength(radius: yRadius)
        }

        let boundingRect = CGRect(
            x: plot.x - xRadius,
            y: plot.y - yRadius,
            width: 2 * xRadius,
            height: 2 * yRadius)

        return .ellipse(rect: boundingRect)
    }

    func draw(
        in context: GraphicsContext,
        projector: StarField.Projector,
        configuration: StarField.Configuration
    ) {
        let starShading = GraphicsContext.Shading.color(
            configuration.colorScheme.colorForStars
        )

        let auraShading = GraphicsContext.Shading.color (
            configuration.colorScheme.fieldBackground
        )

        guard
            let plot = projector.plot(position),
            projector.isPlotNearView(plot)
        else { return }

        let sized = max(1.0, 10.0 - magnitude) * 10.0 * projector.minuteScale()
        let radius = radius(projector: projector)
        let diameter  = 2.0 * radius

        let starEllipse = CGRect(
            x: plot.x - radius,
            y: plot.y - radius,
            width: diameter,
            height: diameter)

        let aura: CGFloat = 2
        let auraEllipse = CGRect(
            x: plot.x - (radius + aura),
            y: plot.y - (radius + aura),
            width: diameter + 2 * aura,
            height: diameter + 2 * aura)

        context.fill(Path(ellipseIn: auraEllipse), with: auraShading)
        context.fill(Path(ellipseIn: starEllipse), with: starShading)

        if hasWings {
            drawDoubleStarWings(
                in: context,
                with: starShading,
                plot: plot,
                radius: radius)
        }

        if hasInnerCircle {
            drawVariableStarShell(
                in: context,
                with: auraShading,
                plot: plot,
                radius: radius)
        }
    }

    private var hasWings: Bool {
        if case let .star(isDouble, _) = self.type { return isDouble }
        return false
    }

    private var hasInnerCircle: Bool {
        if case let .star(_, isVariable) = self.type { return isVariable }
        return false
    }

    private func drawDoubleStarWings(
        in context: GraphicsContext,
        with shading: GraphicsContext.Shading,
        plot: CGPoint,
        radius: CGFloat
    ) {
        let wingLength = wingLength(radius: radius)
        var wings = Path()

        func drawLine(_ x1: CGFloat, _ x2: CGFloat) {
            wings.move(to: CGPoint(x: x1, y: plot.y))
            wings.addLine(to: CGPoint(x: x2, y: plot.y))
        }

        drawLine(plot.x - radius, plot.x - radius - wingLength)
        drawLine(plot.x + radius, plot.x + radius + wingLength)
        context.stroke(wings, with: shading)
    }

    private func drawVariableStarShell(
        in context: GraphicsContext,
        with shading: GraphicsContext.Shading,
        plot: CGPoint,
        radius: CGFloat
    ) {
        let shellHalfWidth = max((0.1 * radius).rounded(.down), 0.5)
        let shellLineWidth = 2 * shellHalfWidth
        let shellRadius = max(radius - shellLineWidth - shellHalfWidth, 0)
        let shellDiameter = 2 * shellRadius

        let shellEllipse = CGRect(
            x: plot.x - shellRadius,
            y: plot.y - shellRadius,
            width: shellDiameter,
            height: shellDiameter)

        context.stroke(
            Path(ellipseIn: shellEllipse),
            with: shading,
            lineWidth: shellLineWidth)
    }

    private func radius(projector: StarField.Projector) -> CGFloat {
        let sized = max(1.0, 10.0 - magnitude) * 10.0 * projector.minuteScale()
        return (0.5 * sized).rounded(.up)
    }

    private func wingLength(radius: CGFloat) -> CGFloat {
        return max(0.7 * radius, 1.0)
    }

}
