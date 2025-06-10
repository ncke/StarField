import SwiftUI

// MARK: - Name Fitting Style

extension StarField {

    protocol NameStyleable {
        var nameStyle: NameStyle { get }
    }

    struct NameStyle: @unchecked Sendable {

        enum FittingStyle {
            /// The name should be strictly outside the graphics.
            case exterior
            /// The name may be inside the graphics.
            case interior
            /// The name should be placed at the view boundary, if possible.
            case boundary
        }

        let fittingStyle: FittingStyle
        let textColor: KeyPath<ColorScheme, Color>
        let textBackground: KeyPath<ColorScheme, Color>?
    }

}
