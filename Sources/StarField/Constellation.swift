import SwiftUI

// MARK: - ConstellationPattern

extension StarField {

    public struct ConstellationPattern: StarFieldFurniture {
        public let id: UUID
        public let pattern: [(Star, Star)]

        public init(id: UUID, pattern: [(Star, Star)]) {
            self.id = id
            self.pattern = pattern
        }
    }

}

extension StarField.ConstellationPattern: Plottable {

    func plotGraphics(
        using projector: any StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        var shapes = [StarField.Graphic.Shape]()

        for (star1, star2) in pattern {
            guard
                let p1 = projector.plot(star1.position),
                let p2 = projector.plot(star2.position),
                projector.isPlotNearView(p1) || projector.isPlotNearView(p2)
            else {
                continue
            }

            let start = CGPoint(x: Int(p1.x), y: Int(p1.y))
            let finish = CGPoint(x: Int(p2.x), y: Int(p2.y))
            let color = \StarField.ColorScheme.constellationPatternColor

            let shape = StarField.Graphic.Shape.line(
                start: start,
                finish: finish,
                styles: [.stroke(width: 1.0, color: color)],
                obscurement: .preferred)

            shapes.append(shape)
        }

        guard !shapes.isEmpty else { return nil }
        return StarField.Graphic(objectId: id, shapes: shapes)
    }

}
