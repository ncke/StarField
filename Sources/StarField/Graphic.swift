import SwiftUI

// MARK: - Plottable

protocol Plottable {
    func plotGraphics() -> [StarField.Graphic]
}

// MARK: - Graphic

extension StarField {

    enum Graphic {

        case coordinateLine(start: CGPoint, finish: CGPoint)
        case starCircle(center: CGPoint, radius: CGFloat)
        case starInscribedCircle(center: CGPoint, radius: CGFloat)
        case starWingLine(start: CGPoint, finish: CGPoint)
        case resolvedText(
            rect: CGRect,
            text: GraphicsContext.ResolvedText)

    }

}
