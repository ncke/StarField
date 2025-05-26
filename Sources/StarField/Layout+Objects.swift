import SwiftUI

// MARK: - Plot Objects

extension StarField.Layout {

    func plotObject(_ object: StarField.Object) -> [StarField.Graphic] {
        switch object.type {
            
        case .star(let isDouble, let isVariable):
            return plotStar(object, isDouble: isDouble, isVariable: isVariable)
        }
    }

}

// MARK: - Plot Star

private extension StarField.Layout {

    func plotStar(
        _ star: StarField.Object,
        isDouble: Bool,
        isVariable: Bool
    ) -> [StarField.Graphic] {
        guard
            let plot = projector.plot(star.position),
            projector.isPlotNearView(plot)
        else {
            return []
        }

        var graphics = [StarField.Graphic]()
        let radius = radiusForMagnitude(star.magnitude, projector: projector)

        if isDouble {
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
        let sized = max(1.0, 10.0 - magnitude) * 1.0 * minuteScale
        return (0.5 * sized).rounded(.up)
    }

    func wingLength(radius: CGFloat) -> CGFloat {
        return max(0.7 * radius, 1.0)
    }

}
