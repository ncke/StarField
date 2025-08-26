import SwiftUI

// MARK: - CGRect Helpers

extension CGRect {

    init(enclosingCircleAt center: CGPoint, radius: CGFloat) {
        let origin = CGPoint(x: center.x - radius, y: center.y - radius)
        let diameter = 2.0 * radius
        let size = CGSize(width: diameter, height: diameter)
        self.init(origin: origin, size: size)
    }

    func enlarged(delta: CGFloat) -> CGRect {
        CGRect(
            x: Int(self.minX - delta),
            y: Int(self.minY - delta),
            width: Int(self.width + 2.0 * delta),
            height: Int(self.height + 2.0 * delta))
    }

}

// MARK: - CGRect Line Intersections

extension CGRect {

    typealias LinearIntersection = (Wall, CGPoint)

    enum Wall {
        case north, east, south, west
    }

    func linearIntersections(
        lineStart start: CGPoint,
        finish: CGPoint
    ) -> [LinearIntersection] {
        let rect = self.standardized
        if start.x < rect.minX && finish.x < rect.minX { return [] }
        if start.x > rect.maxX && finish.x > rect.maxX { return [] }
        if start.y < rect.minY && finish.y < rect.minY { return [] }
        if start.y > rect.maxY && finish.y > rect.maxY { return [] }

        let dx = finish.x - start.x
        let dy = finish.y - start.y

        func hIntersect(y: CGFloat, wall: Wall) -> (Wall, CGPoint)? {
            guard dy != 0 else { return nil }
            let t = (y - start.y) / dy
            guard t >= 0.0, t <= 1.0 else { return nil }
            let x = start.x + t * dx
            guard x >= self.minX, x <= self.maxX else { return nil }
            return (wall, CGPoint(x: x, y: y))
        }

        func vIntersect(x: CGFloat, wall: Wall) -> (Wall, CGPoint)? {
            guard dx != 0 else { return nil }
            let t = (x - start.x) / dx
            guard t >= 0.0, t <= 1.0 else { return nil }
            let y = start.y + t * dy
            guard y >= self.minY, y <= self.maxY else { return nil }
            return (wall, CGPoint(x: x, y: y))
        }

        return [
            hIntersect(y: self.maxY, wall: .north),
            vIntersect(x: self.maxX, wall: .east),
            hIntersect(y: self.minY, wall: .south),
            vIntersect(x: self.minX, wall: .west)
        ].compactMap(\.self)
    }

    func verticallyInvert(point: CGPoint) -> CGPoint {
        CGPoint(x: point.x, y: height - point.y)
    }

}
