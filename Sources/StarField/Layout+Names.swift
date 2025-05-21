import SwiftUI

// MARK: - Plot Names

extension StarField.Layout {

    func plotNames(
        avoiding: [UUID: [StarField.Graphic]],
        using textResolver: TextResolver
    ) -> [StarField.Graphic] {
        let obscurements = avoiding.values.flatMap { $0 }
        return objects
            .sorted { s1, s2 in s1.magnitude < s2.magnitude }
            .compactMap { object in
                guard
                    let name = object.names.first,
                    !name.isEmpty,
                    let graphics = avoiding[object.id],
                    let resolvedText = textResolver(name.capitalized),
                    let rect = positionText(
                        resolvedText,
                        forObject: object,
                        withGraphics: graphics,
                        obscurements: obscurements)
                else {
                    return nil
                }

                let nameGraphic = StarField.Graphic.resolvedText(rect: rect, text: resolvedText)
                self.nameGraphics.append(nameGraphic)
                print("ng count: ", self.nameGraphics.count)
                return nameGraphic
            }

    }

    private func positionText(
        _ resolvedText: GraphicsContext.ResolvedText,
        forObject object: StarField.Object,
        withGraphics objectGraphics: [StarField.Graphic],
        obscurements: [StarField.Graphic]
    ) -> CGRect? {
        print(object.names.first ?? "nil")
        if object.names.first?.capitalized == "Achird" {
            print("It's Achird!")
        }

        if object.names.first?.capitalized == "Shedir" {
            print("It's Shedir!")
        }

        guard
            let (center, radius) = slotParameters(
                object: object,
                objectGraphics: objectGraphics)
        else {
            return nil
        }

        let nameSize = resolvedText.measure(in: viewSize)

        for degrees in Self.slotAngles {
            guard
                let nameRect = nameRectForAngle(
                    degrees,
                    nameSize: nameSize,
                    relativeTo: center,
                    radius: radius),
                !hasOverlaps(nameRect: nameRect, graphics: objectGraphics),
                !hasOverlaps(nameRect: nameRect, graphics: nameGraphics),
                !hasOverlaps(nameRect: nameRect, graphics: obscurements)
            else {
                continue
            }

            return nameRect
        }

        return nil
    }

    func hasOverlaps(nameRect: CGRect, graphics: [StarField.Graphic]) -> Bool {
        for graphic in graphics {
            switch graphic {
            case .coordinateLine(let start, let finish):
                if lineIntersectsRect(start: start, finish: finish, rect: nameRect) {
                    return true
                }
            case .resolvedText(let rect, let text):
                if rect.intersects(nameRect) { return true }
            case .starCircle(let center, let radius):
                if circleIntersectsRect(center: center, radius: radius, rect: nameRect) {
                    return true
                }
            case .starInscribedCircle(let center, let radius):
                if circleIntersectsRect(center: center, radius: radius, rect: nameRect) {
                    return true
                }
            case .starWingLine(let start, let finish):
                if lineIntersectsRect(start: start, finish: finish, rect: nameRect) {
                    return true
                }
            }
        }

        return false
    }

    func circleIntersectsRect(center: CGPoint, radius: CGFloat, rect: CGRect) -> Bool {
        let closestX = max(rect.minX, min(center.x, rect.maxX))
        let closestY = max(rect.minY, min(center.y, rect.maxY))
        let dx = center.x - closestX
        let dy = center.y - closestY

        return (dx * dx + dy * dy) <= (radius * radius)
    }

    func lineIntersectsRect(start: CGPoint, finish: CGPoint, rect: CGRect) -> Bool {
        if start.x < rect.minX && finish.x < rect.minX { return false }
        if start.x > rect.maxX && finish.x > rect.maxX { return false }
        if start.y < rect.minY && finish.y < rect.minY { return false }
        if start.y > rect.maxY && finish.y > rect.maxY { return false }

        if rect.contains(start) || rect.contains(finish) {
            return true
        }

        let rectEdges = [
            (rect.origin, CGPoint(x: rect.maxX, y: rect.minY)),
            (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)),
            (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY)),
            (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.minY))
        ]

        for (edgeStart, edgeEnd) in rectEdges {
            if lineSegmentsIntersect(start1: start, end1: finish, start2: edgeStart, end2: edgeEnd) {
                return true
            }
        }

        return false
    }

    func lineSegmentsIntersect(start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> Bool {
        func ccw(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
            return (c.y - a.y) * (b.x - a.x) > (b.y - a.y) * (c.x - a.x)
        }

        return ccw(start1, start2, end2) != ccw(end1, start2, end2) &&
               ccw(start1, end1, start2) != ccw(start1, end1, end2)
    }

    func nameRectForAngle(
        _ degrees: Int,
        nameSize: CGSize,
        relativeTo targetCenter: CGPoint,
        radius: CGFloat
    ) -> CGRect? {
        var anchor: (Double, Double)?
        if degrees == 0 { anchor = (0.5, 1.0) }
        else if degrees == 30 || degrees == 45 || degrees == 60 { anchor = (0.0, 1.0) }
        else if degrees == 90 { anchor = (0.0, 0.5) }
        else if degrees == 120 || degrees == 135 || degrees == 150 { anchor = (0.0, 0.0) }
        else if degrees == 180 { anchor = (0.5, 0.0) }
        else if degrees == 210 || degrees == 225 || degrees == 240 { anchor = (1.0, 0.0) }
        else if degrees == 270 { anchor = (1.0, 0.5) }
        else if degrees == 300 || degrees == 315 || degrees == 330 { anchor = (1.0, 1.0) }

        guard let (ax, ay) = anchor else { return nil }

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

    private func slotParameters(
        object: StarField.Object,
        objectGraphics: [StarField.Graphic]
    ) -> (CGPoint, CGFloat)? {
        switch object.type {
        case .star:
            for graphic in objectGraphics {
                if case .starCircle(let center, let radius) = graphic {
                    return (center, radius + Self.slotDistance)
                }
                if case .starInscribedCircle(let center, let radius) = graphic {
                    return (center, radius + Self.slotDistance)
                }
            }
            return nil
        default:
            return nil
        }
    }

    private static let slotDistance: CGFloat = 1.0

    private static let slotAngles = [
        0, 30, 45, 60, 90, 120, 135, 150, 180, 210, 225, 240, 270, 300, 315, 330
    ]

}
