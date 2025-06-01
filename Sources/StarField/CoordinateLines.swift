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
        using projector: StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        let latShapes = latitudes.flatMap { angle in
            StarField.GreatCircle(
                angle: angle,
                sense: .latitude
            )
            .plotGraphics(using: projector, configuration: configuration)!
            .shapes
        }

        let lonShapes = longitudes.flatMap { angle in
            StarField.GreatCircle(
                angle: angle,
                sense: .longitude
            )
            .plotGraphics(using: projector, configuration: configuration)!
            .shapes
        }

        return StarField.Graphic(
            objectId: UUID(),
            shapes: latShapes + lonShapes)
    }
}
