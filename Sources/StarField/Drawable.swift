import SwiftUI

// MARK: - Drawable

protocol Drawable {

    func draw(
        in context: GraphicsContext,
        plotter: StarField.Plotter,
        configuration: StarField.Configuration)

    func obscures(plotter: StarField.Plotter) -> StarField.Obscurement?

}

// MARK: - Obscurement

extension StarField {

    enum Obscurement {
        case ellipse(rect: CGRect)
        case rect(rect: CGRect)
    }

}

extension StarField.Obscurement {

    func coarseRectangle() -> CGRect {
        switch self {
        case .ellipse(let rect): return rect
        case .rect(let rect): return rect
        }
    }

    func hasCoarseIntersection(with other: CGRect) -> Bool {
        coarseRectangle().intersects(other)
    }

    func squareDistance(to other: CGRect) -> CGFloat {
        let coarse = coarseRectangle()
        let (cx, cy) = (coarse.midX, coarse.midY)
        let (ox, oy) = (other.midX, other.midY)
        let (dx, dy) = (cx - ox, cy - oy)

        return dx * dx + dy * dy
    }

}
