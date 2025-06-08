import SwiftUI

// MARK: - CoordinateLines

extension StarField {

    public struct CoordinateLines: Furniture, Sendable, Identifiable {
        public let id = UUID()

        public enum Sense: Sendable {
            case latitude, longitude
        }

        public let sense: Sense
        public let coordinates: [Angle]
    }

}

// MARK: - Standard Coordinate Lines

extension StarField.CoordinateLines {

    public static let standardLatitudes: StarField.CoordinateLines = {
        let coordinateAngles = [
            -90.0, -80.0, -70.0, -60.0, -50.0, -40.0,
            -30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0,
             40.0, 50.0, 60.0, 70.0, 80.0, 90.0
        ].map { degs in Angle(degrees: degs) }

        return Self.init(sense: .latitude, coordinates: coordinateAngles)
    }()

    public static let standardLongitudes: StarField.CoordinateLines = {
        let coordinateAngles = [
            0.0, 15.0, 30.0, 45.0, 60.0, 75.0, 90.0, 105.0, 120.0,
            135.0, 150.0, 165.0, 180.0, 195.0, 210.0, 225.0, 240.0,
            255.0, 270.0, 285.0, 300.0, 315.0, 330.0, 345.0
        ].map { degs in Angle(degrees: degs) }

        return Self.init(sense: .longitude, coordinates: coordinateAngles)
    }()

}

// MARK: - Plottable

extension StarField.CoordinateLines: Plottable {

    func plotGraphics(
        using projector: any StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        let graphics: [StarField.Graphic] = coordinates
            .compactMap { angle in
                StarField.GreatCircle(angle: angle, sense: sense)
                    .plotGraphics(
                        using: projector,
                        configuration: configuration)
            }

        let combinedShapes = graphics.flatMap { graphic in graphic.shapes }
        return StarField.Graphic(objectId: id, shapes: combinedShapes)
    }

}
