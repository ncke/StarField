import SwiftUI

// MARK: - ColorScheme

extension StarField {

    public protocol ColorScheme {
        var backgroundColor: Color { get }
        var constellationPatternColor: Color { get }
        var coordinateLinesColor: Color { get }
        var coordinateTextColor: Color { get }
        var coordinateTextBackgroundColor: Color { get }
        var starColor: Color { get }
        var planetColor: Color { get }
        var starNameTextColor: Color { get }
        var clusterNameTextColor: Color { get }
        var clusterBorderColor: Color { get }
        var clusterInteriorColor: Color { get }
        var planetaryNebulaNameColor: Color { get }
        var planetaryNebulaColor: Color { get }
        var milkyWayBorderColor: Color { get }
        var milkyWayInteriorZeroColor: Color { get }
        var milkyWayInteriorOneColor: Color { get }
        var milkyWayInteriorTwoColor: Color { get }
        var milkyWayInteriorThreeColor: Color { get }
        var milkyWayInteriorFourColor: Color { get }
        var nebulaNameColor: Color { get }
        var diffuseNebulaBorderColor: Color { get }
        var diffuseNebulaInteriorColor: Color { get }
        var darkNebulaBorderColor: Color { get }
        var darkNebulaInteriorColor: Color { get }
    }

}

// MARK: - Standard Color Scheme

extension StarField {

    public struct StandardColorScheme: ColorScheme {
        public let backgroundColor: Color = Color.rgb(240, 255, 255)
        public let constellationPatternColor = Color.rgb(192, 192, 216)
        public let coordinateLinesColor = Color.rgb(182, 182, 182)
        public let coordinateTextColor = Color.rgb(182, 182, 182)
        public let coordinateTextBackgroundColor = Color.rgb(240, 255, 255)
        public let starColor = Color.rgb(0, 0, 0)
        public let planetColor = Color.rgb(48, 48, 48)
        public let starNameTextColor = Color.rgb(32, 32, 32)
        public let clusterNameTextColor = Color.rgb(32, 32, 32)
        public let clusterBorderColor = Color.rgb(0, 0, 0)
        public let clusterInteriorColor = Color.rgb(240, 230, 130)
        public let planetaryNebulaNameColor = Color.rgb(32, 32, 32)
        public let planetaryNebulaColor = Color.rgb(0, 0, 0)
//        public let milkyWayBorderColor = Color.rgb(128, 128, 128)
//        public let milkyWayInteriorZeroColor = Color.rgb(225, 255, 255)
//        public let milkyWayInteriorOneColor = Color.rgb(210, 255, 255)
//        public let milkyWayInteriorTwoColor = Color.rgb(195, 255, 255)
//        public let milkyWayInteriorThreeColor = Color.rgb(180, 255, 255)
//        public let milkyWayInteriorFourColor = Color.rgb(165, 255, 255)
        public let nebulaNameColor = Color.rgb(32, 32, 32)
        public let diffuseNebulaBorderColor = Color.rgb(0, 0, 0)
        public let diffuseNebulaInteriorColor = Color.rgb(240, 230, 130)
        public let darkNebulaBorderColor = Color.rgb(0, 0, 0)
        public let darkNebulaInteriorColor = Color.rgb(255, 255, 255)

        public let milkyWayBorderColor = Color.rgb(128, 128, 128)
        public let milkyWayInteriorZeroColor = Color.rgb(240, 230, 130)
        public let milkyWayInteriorOneColor = Color.rgb(200, 230, 130)
        public let milkyWayInteriorTwoColor = Color.rgb(160, 230, 130)
        public let milkyWayInteriorThreeColor = Color.rgb(120, 230, 130)
        public let milkyWayInteriorFourColor = Color.rgb(80, 230, 130)

        public init() {}
    }

}

// MARK: - RGB Color Helpers

private extension Color {

    static func rgba(
        _ red: Int,
        _ green: Int,
        _ blue: Int,
        _ alpha: Int
    ) -> Color {
        Color(
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha / 255))
    }

    static func rgb(
        _ red: Int,
        _ green: Int,
        _ blue: Int
    ) -> Color {
        rgba(red, green, blue, 255)
    }

}
