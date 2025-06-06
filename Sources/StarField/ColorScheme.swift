import SwiftUI

// MARK: - ColorScheme

public extension StarField {

    public protocol ColorScheme {
        var backgroundColor: Color { get }
        var constellationPatternColor: Color { get }
        var coordinateLinesColor: Color { get }
        var nameColor: Color { get }
        var starColor: Color { get }
    }

}

// MARK: - Standard Color Scheme

public extension StarField {

    public struct StandardColorScheme: ColorScheme {
        public let backgroundColor: Color = Color.rgb(240, 255, 255)
        public let constellationPatternColor = Color.rgb(192, 192, 216)
        public let coordinateLinesColor = Color.rgb(128, 128, 128)
        public let nameColor = Color.rgb(32, 32, 32)
        public let starColor = Color.rgb(0, 0, 0)

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
