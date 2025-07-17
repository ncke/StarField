import SwiftUI

// MARK: - Planet

extension StarField {

    public struct Planet: Object, Nameable, NameStyleable {
        public let id: UUID
        public let position: Position
        public let magnitude: Double
        public let names: [String]

        let nameStyle = StarField.NameStyle(
            fittingStyle: .exterior,
            textColor: \ColorScheme.starNameTextColor,
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

// MARK: - Plottable Object Conformance

extension StarField.Planet: PlottableObject {}

// MARK: - Plottable Conformance

extension StarField.Planet: Plottable {

    private static let auraWidth = 1.0

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
        let planetColor = \StarField.ColorScheme.planetColor
        let backgroundColor = \StarField.ColorScheme.backgroundColor
        let hasAura = configuration.showStarAura
        var shapes = [StarField.Graphic.Shape]()

        if hasAura {
            let auraCircle = StarField.Graphic.Shape.circle(
                center: plot,
                radius: radius + Self.auraWidth,
                styles: [.fill(color: backgroundColor)],
                obscurement: .never)
            shapes.append(auraCircle)
        }

        let planetCircle = StarField.Graphic.Shape.circle(
            center: plot,
            radius: radius,
            styles: [.fill(color: planetColor)],
            obscurement: .always)
        shapes.append(planetCircle)

        let graphic = StarField.Graphic(objectId: self.id, shapes: shapes)
        return graphic
    }

}
