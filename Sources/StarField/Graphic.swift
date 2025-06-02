import SwiftUI

// MARK: - Plottable

protocol Plottable {

    func plotGraphics(
        using projector: StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic?
    
}

// MARK: - Graphic

extension StarField {

    struct Graphic {
        let objectId: UUID
        let shapes: [Shape]
        var obscurements: [Shape] { shapes.filter { shape in
            let obscurement = shape.obscurement
            return obscurement == .always || obscurement == .preferred
        } }
    }

}

// MARK: - Graphic.Shape

extension StarField.Graphic {

    enum Shape {

        enum Obscurement {
            case always
            case preferred
            case never
        }

        enum Style {
            case stroke(
                width: CGFloat,
                color: KeyPath<StarField.ColorScheme, Color>)
            case fill(
                color: KeyPath<StarField.ColorScheme, Color>)
        }

        case rectangle(
            rect: CGRect,
            styles: [Style],
            obscurement: Obscurement)

        case line(
            start: CGPoint,
            finish: CGPoint,
            styles: [Style],
            obscurement: Obscurement)

        case circle(
            center: CGPoint,
            radius: CGFloat,
            styles: [Style],
            obscurement: Obscurement)

        case text(
            rect: CGRect,
            text: GraphicsContext.ResolvedText,
            styles: [Style],
            obscurement: Obscurement)

        var obscurement: Obscurement {
            switch self {
            case .rectangle(_, _, let obscurement): return obscurement
            case .line(_, _, _, let obscurement): return obscurement
            case .circle(_, _, _, let obscurement): return obscurement
            case .text(_, _, _, let obscurement): return obscurement
            }
        }

        var styles: [Style] {
            switch self {
            case .rectangle(_, let styles, _): return styles
            case .line(_, _, let styles, _): return styles
            case .circle(_, _, let styles, _): return styles
            case .text(_, _, let styles, _): return styles
            }
        }

        var midpoint: CGPoint {
            switch self {
            case .rectangle(let rect, _, _):
                return CGPoint(x: rect.midX, y: rect.midY)
            case .line(let start, let finish, _, _):
                return CGPoint(
                    x: 0.5 * (start.x + finish.x),
                    y: 0.5 * (start.y + finish.y))
            case .circle(let center, _, _, _):
                return center
            case .text(let rect, _, _, _):
                return CGPoint(x: rect.midX, y: rect.midY)
            }
        }
    }

}

// MARK: - Overlap Detection

extension StarField.Graphic.Shape {

    func hasOverlapWithRect(_ rect: CGRect) -> Bool {
        switch self {

        case .rectangle(let shapeRect, _, _):
            return rect.intersects(shapeRect)

        case .line(let start, let finish, _, _):
            return lineIntersectsRect(
                start: start,
                finish: finish,
                rect: rect)

        case .circle(let center, let radius, _, _):
            return circleIntersectsRect(
                center: center,
                radius: radius,
                rect: rect)

        case .text(let shapeRect, _, _, _):
            return rect.intersects(shapeRect)
        }
    }

    private func lineIntersectsRect(
        start: CGPoint,
        finish: CGPoint,
        rect: CGRect
    ) -> Bool {
        if start.x < rect.minX && finish.x < rect.minX { return false }
        if start.x > rect.maxX && finish.x > rect.maxX { return false }
        if start.y < rect.minY && finish.y < rect.minY { return false }
        if start.y > rect.maxY && finish.y > rect.maxY { return false }

        if rect.contains(start) || rect.contains(finish) {
            return true
        }

        let rectEdges = [
            (rect.origin, CGPoint(x: rect.maxX, y: rect.minY)),
            (
                CGPoint(x: rect.maxX, y: rect.minY),
                CGPoint(x: rect.maxX, y: rect.maxY)
            ),
            (
                CGPoint(x: rect.maxX, y: rect.maxY),
                CGPoint(x: rect.minX, y: rect.maxY)
            ),
            (
                CGPoint(x: rect.minX, y: rect.maxY),
                CGPoint(x: rect.minX, y: rect.minY)
            )
        ]

        for (edgeStart, edgeEnd) in rectEdges {
            if lineSegmentsIntersect(
                start1: start,
                end1: finish,
                start2: edgeStart,
                end2: edgeEnd
            ) {
                return true
            }
        }

        return false
    }

    private func lineSegmentsIntersect(
        start1: CGPoint,
        end1: CGPoint,
        start2: CGPoint,
        end2: CGPoint
    ) -> Bool {
        func ccw(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
            return (c.y - a.y) * (b.x - a.x) > (b.y - a.y) * (c.x - a.x)
        }

        return ccw(start1, start2, end2) != ccw(end1, start2, end2) &&
               ccw(start1, end1, start2) != ccw(start1, end1, end2)
    }

    private func circleIntersectsRect(
        center: CGPoint,
        radius: CGFloat,
        rect: CGRect
    ) -> Bool {
        let closestX = max(rect.minX, min(center.x, rect.maxX))
        let closestY = max(rect.minY, min(center.y, rect.maxY))
        let dx = center.x - closestX
        let dy = center.y - closestY

        return (dx * dx + dy * dy) <= (radius * radius)
    }

}
