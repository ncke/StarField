import SwiftUI

// MARK: - Plottable

protocol Plottable {

    func plotGraphics(
        using projector: StarField.Projector
    ) -> [StarField.Graphic]
    
}

// MARK: - Graphic

extension StarField {

    enum Graphic {
        case coordinateLine(start: CGPoint, finish: CGPoint)
        case starCircle(center: CGPoint, radius: CGFloat, isInscribed: Bool, hasWings: Bool)
        case resolvedText(
            rect: CGRect,
            text: GraphicsContext.ResolvedText)
    }

}
