import SwiftUI

// MARK: - Configuration

public extension StarField {

    public class Configuration: ObservableObject {
        public var projection: Projection
        public var showLinesOfLatitude: CoordinateLines
        public var showLinesOfLongitude: CoordinateLines
        public var showStarAura: Bool
        public var colorScheme: ColorScheme

        public init(
            projection: Projection = .gnomonic,
            showLinesOfLatitude: CoordinateLines = .standard,
            showLinesOfLongitude: CoordinateLines = .standard,
            showStarAura: Bool = true,
            colorScheme: StarField.ColorScheme = StandardColorScheme()
        ) {
            self.projection = projection
            self.showLinesOfLatitude = showLinesOfLatitude
            self.showLinesOfLongitude = showLinesOfLongitude
            self.showStarAura = showStarAura
            self.colorScheme = colorScheme
        }
    }

}

// MARK: - Coordinate Lines

public extension StarField.Configuration {

    public enum CoordinateLines {
        case none
        case standard
        case custom(angles: [Angle])

        func enumerateForLatitude() -> [Angle] {
            switch self {

            case .none: return []

            case .standard:
                return [
                    0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0,
                    80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 140.0,
                    150.0, 160.0, 170.0
                ].map { degs in Angle(degrees: degs) }

            case .custom(let angles):
                return angles

            }
        }

        func enumerateForLongitude() -> [Angle] {
            switch self {

            case .none: return []

            case .standard:
                return [
                    0.0, 15.0, 30.0, 45.0, 60.0, 75.0, 90.0, 105.0, 120.0,
                    135.0, 150.0, 165.0, 180.0, 195.0, 210.0, 225.0, 240.0,
                    255.0, 270.0, 285.0, 300.0, 315.0, 330.0
                ].map { degs in Angle(degrees: degs) }

            case .custom(let angles):
                return angles

            }
        }
    }

}
