import SwiftUI

extension StarField {

    /// Boundary slots are tied to points of intersection between lines
    /// within the graphic and the view walls.
    struct BoundarySlots {

        static func slotsForName(
            graphic: Graphic,
            nameSize: CGSize,
            viewSize: CGSize
        ) -> [CGRect]? {
            let viewRect = CGRect(origin: CGPoint.zero, size: viewSize)
            let intersects = findIntersections(
                graphic: graphic,
                viewRect: viewRect)

            let slots = intersects.compactMap { intersection in
                slotForIntersection(
                    intersection,
                    nameSize: nameSize,
                    viewRect: viewRect)
            }

            return slots.count > 0 ? slots : nil
        }

        private static func findIntersections(
            graphic: Graphic,
            viewRect: CGRect
        ) -> [CGRect.LinearIntersection] {
            let intersects = graphic.shapes
                .compactMap { shape in
                    guard case .line(let start, let finish, _, _) = shape else {
                        return nil
                    }

                    // Lines are plotted in screen coordinates, so invert
                    // y-coordinates to orientate with the rect.
                    let invertedStart = CGPoint(
                        x: start.x,
                        y: viewRect.size.height - start.y)

                    let invertedFinish = CGPoint(
                        x: finish.x,
                        y: viewRect.size.height - finish.y)

                    return (invertedStart, invertedFinish)
                }
                .flatMap { $0 }
                .compactMap { (start, finish) in
                    viewRect.linearIntersections(
                        lineStart: start,
                        finish: finish)
                }.flatMap { $0 }

            return intersects
        }

        private static func slotForIntersection(
            _ intersection: CGRect.LinearIntersection,
            nameSize: CGSize,
            viewRect: CGRect
        ) -> CGRect {
            let (wall, point) = intersection
            switch wall {

            case .north:
                let xSlot = position(
                    n: point.x,
                    extent: nameSize.width,
                    minimum: viewRect.minX,
                    maximum: viewRect.maxX)
                let origin = CGPoint(x: xSlot, y: viewRect.minY)
                return CGRect(origin: origin, size: nameSize)

            case .east:
                let ySlot = position(
                    n: point.y,
                    extent: nameSize.height,
                    minimum: viewRect.minY,
                    maximum: viewRect.maxY)
                let origin = CGPoint(
                    x: viewRect.maxX - nameSize.width,
                    y: viewRect.maxY - ySlot - nameSize.height)
                return CGRect(origin: origin, size: nameSize)

            case .south:
                let xSlot = position(
                    n: point.x,
                    extent: nameSize.width,
                    minimum: viewRect.minX,
                    maximum: viewRect.maxX)
                let origin = CGPoint(
                    x: xSlot,
                    y: viewRect.maxY - nameSize.height)
                return CGRect(origin: origin, size: nameSize)

            case .west:
                let ySlot = position(
                    n: point.y,
                    extent: nameSize.height,
                    minimum: viewRect.minY,
                    maximum: viewRect.maxY)
                let origin = CGPoint(
                    x: viewRect.minX,
                    y: viewRect.maxY - ySlot - nameSize.height)
                return CGRect(origin: origin, size: nameSize)
            }
        }

        private static func position(
            n: CGFloat,
            extent: CGFloat,
            minimum: CGFloat,
            maximum: CGFloat
        ) -> CGFloat {
            var result = n - extent * 0.5
            if result + extent > maximum { result = maximum - extent }
            if result < minimum { result = minimum }

            return result
        }

    }

}
