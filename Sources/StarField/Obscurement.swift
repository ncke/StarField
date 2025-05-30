import SwiftUI

extension StarField {

    actor ObscurementsRegistry {
        private var obscurements: [UUID: Obscurement] = [:]

        enum Priority { case required, optional }

        enum Shape {
            case rect(rect: CGRect, priority: Priority)
            case circle(rect: CGRect, priority: Priority)
            case line(start: CGPoint, finish: CGPoint, priority: Priority)
        }

        private class Obscurement {
            private(set) var shapes: [Shape]

            init(shapes: [Shape]) {
                self.shapes = shapes
            }

            func addShapes(_ shapes: [Shape]) {
                self.shapes.append(contentsOf: shapes)
            }
        }

        func registerShapes(
            _ shapes: [Shape],
            identifier: UUID
        ) {
            if var existing = obscurements[identifier] {
                existing.addShapes(shapes)
            } else {
                obscurements[identifier] = Obscurement(shapes: shapes)
            }
        }

        /// Removes all obscurements from the registry.
        func clearAllObscurements() {
            obscurements = [:]
        }

        /// Returns nil if the `rect` is not obscured by any registered
        /// shape. Otherwise, returns the highest priority among the
        /// actual obscurements.
        func isObscured(rect: CGRect) -> Priority? {
            var result: Priority?

            for (_, obscurement) in obscurements {
                let priority = checkObscurement(obscurement, rect: rect)
                if let priority = priority { result = priority }
                if case priority = .required { break }
            }

            return result
        }

        /// Returns nil if the `rect` is not obscured by a registered
        /// shape with the given identity. Otherwise, returns the highest
        /// priority among the actual obscurements.
        func isObscured(rect: CGRect, by id: UUID) -> Priority? {
            guard let obscurement = obscurements[id] else { return nil }
            return checkObscurement(obscurement, rect: rect)
        }

        private func checkObscurement(
            _ obscurement: Obscurement,
            rect: CGRect
        ) -> Priority? {
            var result: Priority?

            for shape in obscurement.shapes {
                let priority = checkShape(shape, rect: rect)
                if let priority = priority { result = priority }
                if case priority = .required { break }
            }

            return result
        }

        private func checkShape(_ shape: Shape, rect: CGRect) -> Priority? {
            switch shape {
            case .rect(let shapeRect, let priority):
                return hasOverlap(rect, other: shapeRect) ? priority : nil
            case .circle(let shapeRect, let priority):
                return hasOverlap(rect, circle: shapeRect) ? priority : nil
            case .line(let start, let finish, let priority):
                return hasOverlap(rect, lineStart: start, finish: finish)
                ? priority
                : nil
            }
        }

        private func hasOverlap(_ rect: CGRect, other: CGRect) -> Bool {
            rect.intersects(other)
        }

        private func hasOverlap(_ rect: CGRect, circle: CGRect) -> Bool {
            let center = CGPoint(x: circle.midX, y: circle.midY)
            let radius: CGFloat = 0.5 * circle.width
            let closestX = max(rect.minX, min(center.x, rect.maxX))
            let closestY = max(rect.minY, min(center.y, rect.maxY))
            let dx = center.x - closestX
            let dy = center.y - closestY

            return (dx * dx + dy * dy) <= (radius * radius)
        }

        private func hasOverlap(
            _ rect: CGRect,
            lineStart start: CGPoint,
            finish: CGPoint
        ) -> Bool {
            if start.x < rect.minX && finish.x < rect.minX { return false }
            if start.x > rect.maxX && finish.x > rect.maxX { return false }
            if start.y < rect.minY && finish.y < rect.minY { return false }
            if start.y > rect.maxY && finish.y > rect.maxY { return false }
            if rect.contains(start) || rect.contains(finish) {
                return true
            }

            let walls = [
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

            for wall in walls {
                if doLinesOverlap(wall, (start, finish)) {
                    return true
                }
            }

            return false
        }

        private func doLinesOverlap(
            _ line1: (CGPoint, CGPoint),
            _ line2: (CGPoint, CGPoint)
        ) -> Bool {
            let (start1, finish1) = line1
            let (start2, finish2) = line2

            func ccw(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
                return (c.y - a.y) * (b.x - a.x) > (b.y - a.y) * (c.x - a.x)
            }

            return ccw(start1, start2, finish2) != ccw(finish1, start2, finish2)
                && ccw(start1, finish1, start2) != ccw(start1, finish1, finish2)
        }

    }

}
