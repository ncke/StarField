import SwiftUI

// MARK: - ColorScheme

public extension StarField {

    public protocol ColorScheme {
        var colorForCoordinateLines: Color { get }
        var colorForStars: Color { get }
        var fieldBackground: Color { get }
    }

}

// MARK: - StandardColorScheme

public extension StarField {

    public struct StandardColorScheme: ColorScheme {
        public let colorForCoordinateLines = Color.rgb(128, 128, 128)
        public let colorForStars = Color.rgb(0, 0, 0)
        public let fieldBackground: Color = Color.rgb(224, 255, 255)

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
