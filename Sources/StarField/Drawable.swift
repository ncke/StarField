import SwiftUI

protocol Drawable {

    func draw(
        in context: GraphicsContext,
        plotter: StarField.Plotter,
        configuration: StarField.Configuration)

}
