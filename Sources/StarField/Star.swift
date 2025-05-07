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
            let plot = plotter.plot(position)
        else { return }

        let radius = max(1.0, 10.0 - magnitude) * 10.0 * plotter.minuteScale()
        let hradius = 0.5 * radius
        let starEllipse = CGRect(
            x: plot.x - hradius,
            y: plot.y - hradius,
            width: radius,
            height: radius)

        let aura: CGFloat = 2
        let auraEllipse = CGRect(
            x: plot.x - (hradius + aura),
            y: plot.y - (hradius + aura),
            width: radius + 2 * aura,
            height: radius + 2 * aura)

        context.fill(Path(ellipseIn: auraEllipse), with: auraShading)
        context.fill(Path(ellipseIn: starEllipse), with: starShading)

        if isDoubleStar {
            let wingLength = 0.8 * hradius

            var leftWing = Path()
            let lx = plot.x - hradius
            leftWing.move(to: CGPoint(x: lx, y: plot.y))
            leftWing.addLine(to: CGPoint(x: lx - wingLength, y: plot.y))
            context.stroke(leftWing, with: starShading)

            var rightWing = Path()
            let rx = plot.x + hradius
            rightWing.move(to: CGPoint(x: rx, y: plot.y))
            rightWing.addLine(to: CGPoint(x: rx + wingLength, y: plot.y))
            context.stroke(rightWing, with: starShading)
        }
    }

}
