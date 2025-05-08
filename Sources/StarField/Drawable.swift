import SwiftUI

protocol Drawable {

    func draw(
        in context: GraphicsContext,
        plotter: StarField.Plotter,
        configuration: StarField.Configuration)

    func obscures(plotter: StarField.Plotter) -> StarField.Obscurement?

}

extension StarField {

    enum Obscurement {
        case ellipse(rect: CGRect)
    }

}
