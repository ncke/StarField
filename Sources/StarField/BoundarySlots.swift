import SwiftUI

extension StarField {

    /// Boundary slots are name position rectangles that are tied to
    /// points of intersection between lines within the graphic and
    /// the view bounds. The purpose of boundary slots is to
    /// facilitate labelling of coordinate lines at the view boundary.
    struct BoundarySlots {

        /// Returns name position rectangles (slots) for a given graphic,
        /// size of name, and size of view. Boundary slots have at least
        /// one edge that is colinear with the view bounds in the
        /// constrained axis (they run along the relevant all). Boundary
        /// slots are also centered on the point of intersection in
        /// the unconstrained axis to the extent possible within the
        /// given view.
        static func slotsForName(
            graphic: Graphic,
            nameSize: CGSize,
            viewSize: CGSize
        ) -> [CGRect]? {
            // Find the points of intersection between the graphic and
            // the view bounds.
            let viewRect = CGRect(origin: CGPoint.zero, size: viewSize)
            let intersects = findBoundaryIntersections(
                graphic: graphic,
                viewRect: viewRect)

            // Generate slots around each point of intersection.
            let slots = intersects.compactMap {
                intersection in

                slotForIntersection(
                    intersection,
                    nameSize: nameSize,
                    viewRect: viewRect)
            }

            return slots.count > 0 ? slots : nil
        }

        /// Find all intersections of lines within the graphic respective
        /// to the view boundaries.
        private static func findBoundaryIntersections(
            graphic: Graphic,
            viewRect: CGRect
        ) -> [CGRect.LinearIntersection] {
            graphic
                .shapes
                // Find the start and finish point of all lines within
                // the given graphic in screen coordinates.
                .compactMap { shape in
                    guard case .line(let start, let finish, _, _) = shape else {
                        // Other shapes may intersect the view bounds, but
                        // those have no use-case for labelling.
                        return nil
                    }

                    // Lines are plotted in screen coordinates, so invert
                    // y-coordinates to orientate with the rect.
                    return (
                        viewRect.verticallyInvert(point: start),
                        viewRect.verticallyInvert(point: finish)
                    )
                }
                .flatMap { $0 }
                // Enumerate intersections with the view boundary for
                // each line.
                .compactMap { (start, finish) in
                    viewRect.linearIntersections(
                        lineStart: start,
                        finish: finish)
                }.flatMap { $0 }
        }

        /// Generate the name position rectangle to accompany
        /// an intersection.
        private static func slotForIntersection(
            _ intersection: CGRect.LinearIntersection,
            nameSize: CGSize,
            viewRect: CGRect
        ) -> CGRect {
            let (wall, point) = intersection
            switch wall {

            case .north:
                // Position the slot at the top edge of the view.
                let xSlot = position(
                    n: point.x,
                    extent: nameSize.width,
                    minimum: viewRect.minX,
                    maximum: viewRect.maxX)
                let origin = CGPoint(x: xSlot, y: viewRect.minY)
                return CGRect(origin: origin, size: nameSize)

            case .east:
                // Position the slot at the left edge of the view.
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
                // Position the slot at the bottom edge of the view.
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
                // Position the slot at the right edge of the view.
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

        /// Returns an offset along some arbitrary axis, ideally centered
        /// on a position `n`, such that a length `extent` along that
        /// axis would be contained within a `minimum` and `maximum`.
        /// - Note: no effort is made to cater for the degenerate cases in which
        /// the `minimum` and `maximum` do not afford enough space for
        /// the `extent`.
        private static func position(
            n: CGFloat,
            extent: CGFloat,
            minimum: CGFloat,
            maximum: CGFloat
        ) -> CGFloat {
            // Center the extent to suggest a position.
            var posn = n - extent * 0.5

            // Move the position to accomodate limits, if necessary.
            if posn + extent > maximum { posn = maximum - extent }
            if posn < minimum { posn = minimum }

            return posn
        }

    }

}
