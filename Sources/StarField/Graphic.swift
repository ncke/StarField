import SwiftUI

extension StarField {

    enum Graphic {

        case coordinateLine(start: CGPoint, finish: CGPoint)
        case starCircle(center: CGPoint, radius: CGFloat)
        case starInscribedCircle(center: CGPoint, radius: CGFloat)
        case starWingLine(start: CGPoint, finish: CGPoint)
        case resolvedText(
            midpoint: CGPoint,
            text: GraphicsContext.ResolvedText)

    }

}
