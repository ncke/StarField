import SwiftUI

public protocol StarFieldNameable {
    var names: [String] { get }
}

// MARK: - Plot Names

extension StarField.Layout {

    func plotNames(
        for visibleObjects: [any PlottableObject],
        avoiding: [UUID: [StarField.Graphic]],
        using textResolver: TextResolver
    ) -> [StarField.Graphic] {
        let obscurements = avoiding.values.flatMap { $0 }
        return visibleObjects
            .sorted { s1, s2 in s1.magnitude < s2.magnitude }
            .flatMap { object in
                let names = (object as? StarFieldNameable)?.names ?? []

                let graphics: [StarField.Graphic] = names.compactMap { name in
                    guard
                        !name.isEmpty,
                        let graphics = avoiding[object.id],
                        let resolvedText = textResolver(name),
                        let rect = positionText(
                            resolvedText,
                            name: name,
                            forObject: object,
                            withGraphics: graphics,
                            obscurements: obscurements)
                    else {
                        return nil
                    }

                    let nameGraphic = StarField.Graphic.resolvedText(
                        rect: rect,
                        text: resolvedText)
                    
                    self.nameGraphics.append(nameGraphic)
                    return nameGraphic
                }

                return graphics
            }

    }

    private func positionText(
        _ resolvedText: GraphicsContext.ResolvedText,
        name: String,
        forObject object: any PlottableObject,
        withGraphics objectGraphics: [StarField.Graphic],
        obscurements: [StarField.Graphic]
    ) -> CGRect? {
        guard
            let (center, radius) = slotParameters(
                object: object,
                objectGraphics: objectGraphics)
        else {
            return nil
        }

        let nameSize = resolvedText.measure(in: viewSize)

        for degrees in stableShuffledAngles(for: name) {
            let nameRects = nameRectsForAngle(
                degrees,
                nameSize: nameSize,
                relativeTo: center,
                radius: radius)

            for nameRect in nameRects {
                guard
                    isWithinView(nameRect),
                    !hasOverlaps(nameRect: nameRect, graphics: objectGraphics),
                    !hasOverlaps(nameRect: nameRect, graphics: nameGraphics),
                    !hasOverlaps(nameRect: nameRect, graphics: obscurements)
                else {
                    continue
                }

                return nameRect
            }
        }

        return nil
    }

    func isWithinView(_ nameRect: CGRect) -> Bool {
        guard
            nameRect.minX >= 0.0,
            nameRect.minY >= 0.0,
            nameRect.maxX <= viewSize.width,
            nameRect.maxY <= viewSize.height
        else {
            return false
        }

        return true
    }

    func hasOverlaps(
        nameRect: CGRect,
        graphics: [StarField.Graphic]
    ) -> Bool {
        for graphic in graphics {
            switch graphic {
            case .coordinateLine(let start, let finish):
                if lineIntersectsRect(
                    start: start,
                    finish: finish,
                    rect: nameRect
                ) {
                    return true
                }

            case .resolvedText(let rect, let text):
                if rect.intersects(nameRect) { return true }

            case .starCircle(let center, let radius):
                if circleIntersectsRect(
                    center: center,
                    radius: radius,
                    rect: nameRect
                ) {
                    return true
                }

            case .starInscribedCircle(let center, let radius):
                if circleIntersectsRect(
                    center: center,
                    radius: radius,
                    rect: nameRect
                ) {
                    return true
                }

            case .starWingLine(let start, let finish):
                if lineIntersectsRect(
                    start: start,
                    finish: finish,
                    rect: nameRect
                ) {
                    return true
                }
            }
        }

        return false
    }

    func circleIntersectsRect(
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

    func lineIntersectsRect(
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

    func lineSegmentsIntersect(
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

    func nameRectsForAngle(
        _ degrees: Int,
        nameSize: CGSize,
        relativeTo targetCenter: CGPoint,
        radius: CGFloat
    ) -> [CGRect] {
        var anchors: [(Double, Double)]?

        switch degrees {
        case 0:
            anchors = [(0.25, 1.0), (0.75, 1.0), (0.5, 1.0)]
        case 30, 45, 60:
            anchors = [(0.0, 1.0), (0.0, 0.75)]
        case 90:
            anchors = [(0.0, 0.5)]
        case 120, 135, 150:
            anchors = [(0.0, 0.0), (0.0, 0.25)]
        case 180:
            anchors = [(0.25, 0.0), (0.75, 0.0), (0.5, 0.0)]
        case 210, 225, 240:
            anchors = [(1.0, 0.25), (1.0, 0.0)]
        case 270:
            anchors = [(1.0, 0.5)]
        case 300, 315, 330:
            anchors = [(1.0, 0.75), (1.0, 1.0)]
        default:
            return []
        }

        let rects = anchors?.map { anchor in
            let (ax, ay) = anchor
            let ox = nameSize.width * ax
            let oy = nameSize.height * ay
            let hookAngle = Angle(degrees: Double(degrees - 90))
            let xHook = radius * cos(hookAngle.radians)
            let yHook = radius * sin(hookAngle.radians)

            return CGRect(
                x: targetCenter.x + xHook - ox,
                y: targetCenter.y + yHook - oy,
                width: nameSize.width,
                height: nameSize.height)
        }

        return rects ?? []
    }

    private func slotParameters(
        object: any PlottableObject,
        objectGraphics: [StarField.Graphic]
    ) -> (CGPoint, CGFloat)? {
        if object is StarField.Star {
            for graphic in objectGraphics {
                if case .starCircle(let center, let radius) = graphic {
                    return (center, radius + Self.slotDistance)
                }
                if case .starInscribedCircle(let center, let radius) = graphic {
                    return (center, radius + Self.slotDistance)
                }
            }
            return nil
        }


        return nil
    }

    private func stableShuffledAngles(for name: String) -> [Int] {
        let h = abs(name.hashValue)
        let angles = Self.slotAngles
        let i = h % angles.count
        let pre = angles[0..<i]
        let suf = angles[i..<angles.count]

        return Array(suf + pre)
    }

    private static let slotDistance: CGFloat = 1.0

    private static let slotAngles = [
        0, 30, 45, 60, 90, 120, 135, 150, 180,
        210, 225, 240, 270, 300, 315, 330
    ]

}
