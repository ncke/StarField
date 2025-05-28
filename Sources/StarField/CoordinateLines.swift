import SwiftUI

// MARK: - CoordinateLines

extension StarField {

    struct CoordinateLines {
        let latitudes: [Angle]
        let longitudes: [Angle]

        init(latitudes: [Angle], longitudes: [Angle]) {
            self.latitudes = latitudes
            self.longitudes = longitudes
        }
    }

}

// MARK: - Plottable

extension StarField.CoordinateLines: Plottable {

    func plotGraphics(
        using projector: StarField.Projector
    ) -> [StarField.Graphic] {
        let latGraphics = latitudes.flatMap { angle in
            StarField.GreatCircle(
                angle: angle,
                sense: .latitude
            )
            .plotGraphics(using: projector)
        }

        let lonGraphics = longitudes.flatMap { angle in
            StarField.GreatCircle(
                angle: angle,
                sense: .longitude
            )
            .plotGraphics(using: projector)
        }

        return latGraphics + lonGraphics
    }
}
