import SwiftUI

// MARK: - CoordinateLine

extension StarField {

    public struct CoordinateLine: Furniture, Sendable, Identifiable {
        public let id = UUID()

        public enum Sense: Sendable {
            case latitude, longitude
        }

        public let sense: Sense
        public let coordinate: Angle
    }

}

// MARK: - Standard Coordinate Lines

extension StarField.CoordinateLine {

    public static let standardLatitudes: [StarField.CoordinateLine] = {
        [
            -90.0, -80.0, -70.0, -60.0, -50.0, -40.0,
            -30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0,
             40.0, 50.0, 60.0, 70.0, 80.0, 90.0
        ].map { degs in
            Self.init(sense: .latitude, coordinate: Angle(degrees: degs))
        }
    }()

    public static let standardLongitudes: [StarField.CoordinateLine] = {
        [
            0.0, 15.0, 30.0, 45.0, 60.0, 75.0, 90.0, 105.0, 120.0,
            135.0, 150.0, 165.0, 180.0, 195.0, 210.0, 225.0, 240.0,
            255.0, 270.0, 285.0, 300.0, 315.0, 330.0, 345.0
        ].map { degs in
            Self.init(sense: .longitude, coordinate: Angle(degrees: degs))
        }
    }()

}

// MARK: - Plottable

extension StarField.CoordinateLine: Plottable {

    func plotGraphics(
        using projector: any StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        StarField.GreatCircle(angle: coordinate, sense: sense)
            .plotGraphics(using: projector, configuration: configuration)
    }

}
