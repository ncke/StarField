import SwiftUI

// MARK: - Planetary Nebula

extension StarField {

    public struct PlanetaryNebula: Object, Nameable, NameStyleable {
        public let id: UUID
        public let position: Position
        public let magnitude: Double
        public let names: [String]

        let nameStyle = StarField.NameStyle(
            fittingStyle: .exterior,
            textColor: \ColorScheme.clusterNameTextColor,
            textBackground: nil)

        public init(
            id: UUID,
            position: Position,
            magnitude: Double,
            names: [String]
        ) {
            self.id = id
            self.position = position
            self.magnitude = magnitude
            self.names = names
        }

    }

}

// MARK: - Plottable Object

extension StarField.PlanetaryNebula: PlottableObject {}

// MARK: - Plottable

extension StarField.PlanetaryNebula: Plottable {

    func plotGraphics(
        using projector: any StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        guard
            let plotAsFloat = projector.plot(position),
            projector.isPlotNearView(plotAsFloat)
        else {
            return nil
        }

        let plot = CGPoint(
            x: plotAsFloat.x.rounded(),
            y: plotAsFloat.y.rounded())

        let radius = radiusForMagnitude(magnitude, projector: projector)
        let wing = max(0.5 * radius.rounded(), 1.0)
        let pnColor = \StarField.ColorScheme.planetaryNebulaColor
        var shapes = [StarField.Graphic.Shape]()

        let mainCircle = StarField.Graphic.Shape.circle(
            center: plot,
            radius: radius,
            styles: [ .stroke(width: 0.5, color: pnColor) ],
            obscurement: .always)

        shapes.append(mainCircle)

        func makeWing(dx: CGFloat, dy: CGFloat) -> StarField.Graphic.Shape {
            let start = CGPoint(
                x: plot.x + dx * radius,
                y: plot.y + dy * radius)
            let finish = CGPoint(
                x: start.x + dx * wing,
                y: start.y + dy * wing)

            return StarField.Graphic.Shape.line(
                start: start,
                finish: finish,
                styles: [ .stroke(width: 0.5, color: pnColor) ],
                obscurement: .always)
        }

        shapes += [
            makeWing(dx: -1.0, dy: .zero),
            makeWing(dx: +1.0, dy: .zero),
            makeWing(dx: .zero, dy: -1.0),
            makeWing(dx: .zero, dy: +1.0)
        ]

        let graphic = StarField.Graphic(id: self.id, shapes: shapes)
        return graphic
    }

}

