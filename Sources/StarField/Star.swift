import SwiftUI

// MARK: - Star

extension StarField {

    public struct Star: StarFieldObject, StarFieldNameable {
        public let id: UUID
        public let position: Position
        public let magnitude: Double
        public let isVariable: Bool
        public let isMultiple: Bool
        public let names: [String]

        public init(
            id: UUID,
            position: Position,
            magnitude: Double,
            isVariable: Bool,
            isMultiple: Bool,
            names: [String]
        ) {
            self.id = id
            self.position = position
            self.magnitude = magnitude
            self.isVariable = isVariable
            self.isMultiple = isMultiple
            self.names = names
        }
    }

}

// MARK: - PlottableObject

extension StarField.Star: PlottableObject {}

// MARK: - Plottable

extension StarField.Star: Plottable {

    private static let auraWidth = 1.0

    // TODO: Refactor to reduce function length.
    
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
        let starColor = \StarField.ColorScheme.starColor
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

        if isMultiple {
            let wingLength = max(radius * 0.7, 1.0).rounded()
            let wings = [
                makeWing(plot, radius, wingLength, 1.0),
                makeWing(plot, radius, -wingLength, 1.0)
            ]

            if hasAura {
                wings.forEach { wing in
                    let aura = wing.enlarge(delta: Self.auraWidth)
                    let auraRect = StarField.Graphic.Shape.rectangle(
                        rect: aura,
                        styles: [.fill(color: backgroundColor)],
                        obscurement: .always)
                    shapes.append(auraRect)
                }
            }

            wings.forEach { wing in
                let wingRect = StarField.Graphic.Shape.rectangle(
                    rect: wing,
                    styles: [.fill(color: starColor)],
                    obscurement: .always)
                shapes.append(wingRect)
            }
        }

        let mainCircle = StarField.Graphic.Shape.circle(
            center: plot,
            radius: radius,
            styles: [.fill(color: starColor)],
            obscurement: .always)
        shapes.append(mainCircle)

        if isVariable {
            let (width, halfWidth) = (CGFloat(1.0), CGFloat(0.5))
            let scribedRadius = max(radius - width - halfWidth, 1.0)
            let scribedCircle = StarField.Graphic.Shape.circle(
                center: plot,
                radius: scribedRadius,
                styles: [.stroke(width: width, color: backgroundColor)],
                obscurement: .never)
            shapes.append(scribedCircle)
        }

        let graphic = StarField.Graphic(objectId: self.id, shapes: shapes)
        return graphic
    }

    func makeWing(
        _ center: CGPoint,
        _ radius: CGFloat,
        _ width: CGFloat,
        _ height: CGFloat
    ) -> CGRect {
        let root = width > 0 ? center.x + radius : center.x - radius + width
        return CGRect(
            x: Int(root),
            y: Int(center.y),
            width: Int(abs(width)),
            height: Int(height))
    }

    func radiusForMagnitude(
        _ magnitude: Double,
        projector: StarField.Projector
    ) -> CGFloat {
        let sized = max(1.0, 8.0 - magnitude) * 1.6 // * minuteScale
        return (0.5 * sized).rounded(.up)
    }

}
