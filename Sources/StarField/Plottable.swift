import SwiftUI

// MARK: - Plottable

protocol Plottable {

    func plotGraphics(
        using projector: StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic?

    func plottingLayer() -> PlottingLayer

}

// MARK: Radius For Magnitude

extension Plottable {

    func radiusForMagnitude(
        _ magnitude: Double,
        projector: StarField.Projector
    ) -> CGFloat {
        let sized = max(1.0, 8.0 - magnitude) * 1.6 // * minuteScale
        return (0.5 * sized).rounded(.up)
    }

}

// MARK: - Plotting Layer

enum PlottingLayer {
    case milkyway, object
}

extension Plottable {

    func plottingLayer() -> PlottingLayer { .object }

}
