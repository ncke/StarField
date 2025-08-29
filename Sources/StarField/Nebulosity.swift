import SwiftUI

// MARK: - Nebulosity

extension StarField {

    public struct Nebulosity: Object, Nameable, NameStyleable {
        public let id: UUID
        public let position: Position
        public let magnitude: Double
        public let apparentDiameter: Angle
        public let boundary: [Position]
        public let holes: [[Position]]
        public let names: [String]

        let nameStyle = StarField.NameStyle(
            fittingStyle: .exterior,
            textColor: \ColorScheme.starNameTextColor,
            textBackground: nil)

        public init(
            id: UUID,
            position: StarField.Position,
            magnitude: Double,
            apparentDiameter: Angle,
            boundary: [Position],
            holes: [[Position]],
            names: [String]
        ) {
            self.id = id
            self.position = position
            self.magnitude = magnitude
            self.apparentDiameter = apparentDiameter
            self.boundary = boundary
            self.holes = holes
            self.names = names
        }

    }

}

// MARK: - Plottable Object

extension StarField.Nebulosity: PlottableObject {}

// MARK: - Plottable

extension StarField.Nebulosity: Plottable {

    func plotGraphics(
        using projector: any StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        let borderColor = \StarField.ColorScheme.milkyWayBorderColor
        let interiorColor = interiorColorForMagnitude(magnitude)
        let vertices = pointsForPositions(boundary, using: projector)
        let cutouts = holes.map { positions in
            pointsForPositions(positions, using: projector)
        }

        var styles = [
            StarField.Graphic.Shape.Style.fill(color: interiorColor)
        ]
        if configuration.showMilkyWayBorder {
            styles += [
                StarField.Graphic.Shape.Style.stroke(width: 0.5, color: borderColor)
            ]
        }

        let shape = StarField.Graphic.Shape.cutout(
            vertices: vertices,
            cutouts: cutouts,
            styles: styles,
            obscurement: .never)

        let graphic = StarField.Graphic(id: self.id, shapes: [shape])
        return graphic
    }

    private func interiorColorForMagnitude(
        _ magnitude: Double
    ) -> KeyPath<StarField.ColorScheme, Color> {
        switch magnitude {
        case 0.0: return \StarField.ColorScheme.milkyWayInteriorZeroColor
        case 1.0: return \StarField.ColorScheme.milkyWayInteriorOneColor
        case 2.0: return \StarField.ColorScheme.milkyWayInteriorTwoColor
        case 3.0: return \StarField.ColorScheme.milkyWayInteriorThreeColor
        case 4.0: return \StarField.ColorScheme.milkyWayInteriorFourColor
        default: fatalError()
        }
    }

    private func pointsForPositions(
        _ positions: [StarField.Position],
        using projector: any StarField.Projector
    ) -> [CGPoint] {
        positions.compactMap { position in
            guard let plotAsFloat = projector.plot(position) else {
                return nil
            }

            return CGPoint(
                x: plotAsFloat.x.rounded(),
                y: plotAsFloat.y.rounded())
        }
    }

}
