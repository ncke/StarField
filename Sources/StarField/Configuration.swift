import SwiftUI

// MARK: - Configuration

public extension StarField {

    public class Configuration: ObservableObject {
        public var projection: Projection
        public var showLinesOfLatitude: CoordinateLines
        public var showLinesOfLongitude: CoordinateLines
        public var showStarAura: Bool
        public var colorScheme: ColorScheme
        public var showNames: Bool
        public var nameFont: Font
        public var tapEffectiveRadius: CGFloat?

        public init(
            projection: Projection = .gnomonic,
            showLinesOfLatitude: CoordinateLines = .standard,
            showLinesOfLongitude: CoordinateLines = .standard,
            showStarAura: Bool = true,
            colorScheme: StarField.ColorScheme = StandardColorScheme(),
            showNames: Bool = true,
            nameFont: Font = Font.system(size: 10.0),
            tapEffectiveRadius: CGFloat = 24.0
        ) {
            self.projection = projection
            self.showLinesOfLatitude = showLinesOfLatitude
            self.showLinesOfLongitude = showLinesOfLongitude
            self.showStarAura = showStarAura
            self.colorScheme = colorScheme
            self.showNames = showNames
            self.nameFont = nameFont
            self.tapEffectiveRadius = tapEffectiveRadius
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
                    -90.0, -80.0, -70.0, -60.0, -50.0, -40.0,
                    -30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0,
                     40.0, 50.0, 60.0, 70.0, 80.0, 90.0
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
                    255.0, 270.0, 285.0, 300.0, 315.0, 330.0, 345.0
                ].map { degs in Angle(degrees: degs) }

            case .custom(let angles):
                return angles

            }
        }
    }

}
