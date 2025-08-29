import SwiftUI

// MARK: - Cluster

extension StarField {

    public struct Cluster: Object, Nameable, NameStyleable {
        public enum ClusterType {
            case open, globular
        }

        public let id: UUID
        public let position: Position
        public let magnitude: Double
        public let apparentDiameter: Angle
        public let type: ClusterType
        public let names: [String]

        let nameStyle = StarField.NameStyle(
            fittingStyle: .exterior,
            textColor: \ColorScheme.clusterNameTextColor,
            textBackground: nil)

        public init(
            id: UUID,
            position: Position,
            magnitude: Double,
            apparentDiameter: Angle,
            type: ClusterType,
            names: [String]
        ) {
            self.id = id
            self.position = position
            self.magnitude = magnitude
            self.apparentDiameter = apparentDiameter
            self.type = type
            self.names = names
        }

    }

}

// MARK: - Plottable Object

extension StarField.Cluster: PlottableObject {}

// MARK: - Plottable

extension StarField.Cluster: Plottable {

    func plotGraphics(
        using projector: any StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        guard
            let plotAsFloat = projector.plot(position),
            projector.isPlotNearView(plotAsFloat),
            let apparentSize = projector.sizeOfApparentDiameter(
                apparentDiameter,
                at: position)
        else {
            return nil
        }

        let plot = CGPoint(
            x: plotAsFloat.x.rounded(),
            y: plotAsFloat.y.rounded())

        let radius = max((0.5 * apparentSize).rounded(), 4.0)
        let borderColor = \StarField.ColorScheme.clusterBorderColor
        let interiorColor = \StarField.ColorScheme.clusterInteriorColor
        var shapes = [StarField.Graphic.Shape]()

        let mainCircle = StarField.Graphic.Shape.circle(
            center: plot,
            radius: radius,
            styles: [
                .fill(color: interiorColor),
                .stroke(width: 0.5, color: borderColor)
            ],
            obscurement: .always)

        shapes.append(mainCircle)

        if type == .globular {
            let h = StarField.Graphic.Shape.line(
                start: CGPoint(x: plot.x - radius, y: plot.y),
                finish: CGPoint(x: plot.x + radius, y: plot.y),
                styles: [.stroke(width: 0.5, color: borderColor)],
                obscurement: .always)

            let v = StarField.Graphic.Shape.line(
                start: CGPoint(x: plot.x, y: plot.y + radius),
                finish: CGPoint(x: plot.x, y: plot.y - radius),
                styles: [.stroke(width: 0.5, color: borderColor)],
                obscurement: .always)

            shapes += [h, v]
        }

        let graphic = StarField.Graphic(id: self.id, shapes: shapes)
        return graphic
    }

}
