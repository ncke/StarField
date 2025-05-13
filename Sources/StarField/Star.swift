import SwiftUI

// MARK: - Star

extension StarField {

    public struct Star: Identifiable {
        public let id: UUID
        let position: Position
        let magnitude: Double
        let isDoubleStar: Bool
        let isVariableStar: Bool
        let names: [String]

        public init(
            id: UUID,
            position: Position,
            magnitude: Double,
            isDoubleStar: Bool,
            isVariableStar: Bool,
            names: [String]
        ) {
            self.id = id
            self.position = position
            self.magnitude = magnitude
            self.isDoubleStar = isDoubleStar
            self.isVariableStar = isVariableStar
            self.names = names
        }
    }

}

// MARK: - Star Drawable

extension StarField.Star: Drawable {

    private func radius(plotter: StarField.Plotter) -> CGFloat {
        let sized = max(1.0, 10.0 - magnitude) * 10.0 * plotter.minuteScale()
        return (0.5 * sized).rounded(.up)
    }

    private func wingLength(radius: CGFloat) -> CGFloat {
        return max(0.7 * radius, 1.0)
    }

    func obscures(plotter: StarField.Plotter) -> StarField.Obscurement? {
        guard
            let plot = plotter.plot(position),
            plotter.isPlotNearView(plot)
        else { return nil }

        let radius = radius(plotter: plotter)
        let wing = isDoubleStar ? wingLength(radius: radius) : 0
        let boundingRect = CGRect(
            x: plot.x - radius - wing,
            y: plot.y - radius,
            width: 2 * (radius + wing),
            height: 2 * radius)

        return .ellipse(rect: boundingRect)
    }

    func draw(
        in context: GraphicsContext,
        plotter: StarField.Plotter,
        configuration: StarField.Configuration
    ) {
        let starShading = GraphicsContext.Shading.color( configuration.colorScheme.colorForStars
        )

        let auraShading = GraphicsContext.Shading.color (
            configuration.colorScheme.fieldBackground
        )

        guard
            let plot = plotter.plot(position),
            plotter.isPlotNearView(plot)
        else { return }

        let sized = max(1.0, 10.0 - magnitude) * 10.0 * plotter.minuteScale()
        let radius = radius(plotter: plotter)
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

        if isDoubleStar {
            drawDoubleStarWings(
                in: context,
                with: starShading,
                plot: plot,
                radius: radius)
        }

        if isVariableStar {
            drawVariableStarShell(
                in: context,
                with: auraShading,
                plot: plot,
                radius: radius)
        }
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

}
