import SwiftUI

// MARK: - Configuration

extension StarField {

    public class Configuration: ObservableObject {
        public var projection: Projection
        public var showStarAura: Bool
        public var colorScheme: ColorScheme
        public var showNames: Bool
        public var nameFont: Font
        public var showPlanetsOnTop: Bool
        public var showMilkyWayBorder: Bool
        public var tapEffectiveRadius: CGFloat?

        public init(
            projection: Projection = .gnomonic,
            showStarAura: Bool = true,
            colorScheme: StarField.ColorScheme = StandardColorScheme(),
            showNames: Bool = true,
            nameFont: Font = Font.system(size: 10.0),
            showPlanetsOnTop: Bool = true,
            showMilkyWayBorder: Bool = false,
            tapEffectiveRadius: CGFloat = 24.0
        ) {
            self.projection = projection
            self.showStarAura = showStarAura
            self.colorScheme = colorScheme
            self.showNames = showNames
            self.nameFont = nameFont
            self.showPlanetsOnTop = showPlanetsOnTop
            self.showMilkyWayBorder = showMilkyWayBorder
            self.tapEffectiveRadius = tapEffectiveRadius
        }
    }

}
