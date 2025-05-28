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

    func plotGraphics(
        using projector: any StarField.Projector
    ) -> [StarField.Graphic] {
        guard
            let plot = projector.plot(position),
            projector.isPlotNearView(plot)
        else {
            return []
        }

        var graphics = [StarField.Graphic]()
        let radius = radiusForMagnitude(magnitude, projector: projector)

        if isMultiple {
            let wingLength = wingLength(radius: radius)
            let left1 = CGPoint(x: plot.x - radius, y: plot.y)
            let left2 = CGPoint(x: left1.x - wingLength, y: plot.y)
            let right1 = CGPoint(x: plot.x + radius, y: plot.y)
            let right2 = CGPoint(x: right1.x + wingLength, y: plot.y)

            graphics.append(.starWingLine(start: left1, finish: left2))
            graphics.append(.starWingLine(start: right1, finish: right2))
        }

        if isVariable {
            let graphic = StarField.Graphic.starInscribedCircle(
                center: plot,
                radius: radius)
            graphics.append(graphic)
        } else {
            let graphic = StarField.Graphic.starCircle(
                center: plot,
                radius: radius)
            graphics.append(graphic)
        }

        return graphics
    }

    func radiusForMagnitude(
        _ magnitude: Double,
        projector: StarField.Projector
    ) -> CGFloat {
        let sized = max(1.0, 10.0 - magnitude) * 1.0// * minuteScale
        return (0.5 * sized).rounded(.up)
    }

    func wingLength(radius: CGFloat) -> CGFloat {
        return max(0.7 * radius, 1.0)
    }
}
