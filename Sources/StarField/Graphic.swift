import SwiftUI

// MARK: - Plottable

protocol Plottable {

    func plotGraphics(
        using projector: StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic?
    
}

// MARK: - Graphic

extension StarField {

    struct Graphic {
        let objectId: UUID
        let shapes: [Shape]
        var obscurements: [Shape] { shapes.filter { shape in
            let obscurement = shape.obscurement
            return obscurement == .always || obscurement == .preferred
        } }
    }

}

// MARK: - Graphic.Shape

extension StarField.Graphic {

    enum Shape {

        enum Obscurement {
            case always
            case preferred
            case never
        }

        enum Style {
            case stroke(
                width: CGFloat,
                color: KeyPath<StarField.ColorScheme, Color>)
            case fill(
                color: KeyPath<StarField.ColorScheme, Color>)
        }

        case rectangle(
            rect: CGRect,
            styles: [Style],
            obscurement: Obscurement)

        case line(
            start: CGPoint,
            finish: CGPoint,
            styles: [Style],
            obscurement: Obscurement)

        case circle(
            center: CGPoint,
            radius: CGFloat,
            styles: [Style],
            obscurement: Obscurement)

        case text(
            rect: CGRect,
            text: GraphicsContext.ResolvedText,
            styles: [Style],
            obscurement: Obscurement)

        var obscurement: Obscurement {
            switch self {
            case .rectangle(_, _, let obscurement): return obscurement
            case .line(_, _, _, let obscurement): return obscurement
            case .circle(_, _, _, let obscurement): return obscurement
            case .text(_, _, _, let obscurement): return obscurement
            }
        }

        var styles: [Style] {
            switch self {
            case .rectangle(_, let styles, _): return styles
            case .line(_, _, let styles, _): return styles
            case .circle(_, _, let styles, _): return styles
            case .text(_, _, let styles, _): return styles
            }
        }
    }

}
