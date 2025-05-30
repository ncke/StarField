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

        let radius = radiusForMagnitude(magnitude, projector: projector)
        let starGraphic = StarField.Graphic.starCircle(
            center: plot,
            radius: radius,
            isInscribed: isVariable,
            hasWings: isMultiple)

        return [starGraphic]
    }

    func radiusForMagnitude(
        _ magnitude: Double,
        projector: StarField.Projector
    ) -> CGFloat {
        let sized = max(1.0, 10.0 - magnitude) * 2.0 // * minuteScale
        return (0.5 * sized).rounded(.up)
    }

}
