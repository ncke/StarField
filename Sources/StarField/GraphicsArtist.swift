import SwiftUI

// MARK: - Graphics Artist

extension StarField {

    struct GraphicsArtist {
        private typealias Styles = [StarField.Graphic.Shape.Style]
        private let context: GraphicsContext
        private let colorScheme: any StarField.ColorScheme

        init(
            context: GraphicsContext,
            colorScheme: any StarField.ColorScheme
        ) {
            self.context = context
            self.colorScheme = colorScheme
        }

        func drawGraphic(_ graphic: StarField.Graphic) {
            graphic.shapes.forEach { shape in drawShape(shape) }
        }

        private func drawShape(_ shape: StarField.Graphic.Shape) {
            switch shape {
            case .rectangle(let rect, let styles, _):
                drawRectangle(rect: rect, styles: styles)
            case .line(let start, let finish, let styles, _):
                drawLine(start: start, finish: finish, styles: styles)
            case .circle(let center, let radius, let styles, _):
                drawCircle(center: center, radius: radius, styles: styles)
            case .text(let rect, let text, let styles, _):
                drawText(rect: rect, text: text, styles: styles)
            }
        }

        private func drawRectangle(
            rect: CGRect,
            styles: Styles
        ) {
            drawPath(Path(rect), with: styles)
        }

        private func drawLine(
            start: CGPoint,
            finish: CGPoint,
            styles: Styles
        ) {
            var path = Path()
            path.move(to: start)
            path.addLine(to: finish)
            drawPath(path, with: styles)
        }

        private func drawCircle(
            center: CGPoint,
            radius: CGFloat,
            styles: Styles
        ) {
            let rect = CGRect(enclosingCircleAt: center, radius: radius)
            drawPath(Path(ellipseIn: rect), with: styles)
        }

        private func drawText(
            rect: CGRect,
            text: GraphicsContext.ResolvedText,
            styles: Styles
        ) {
            context.draw(
                text,
                at: CGPoint(x: rect.midX, y: rect.midY),
                anchor: .center)
        }

        private func drawPath(_ path: Path, with styles: Styles) {
            styles.forEach { style in
                if case .fill(let color) = style {
                    let schemeColor = colorScheme[keyPath: color]
                    let shading = GraphicsContext.Shading.color(schemeColor)
                    context.fill(path, with: shading)
                }
            }

            styles.forEach { style in
                if case .stroke(let width, let color) = style {
                    let schemeColor = colorScheme[keyPath: color]
                    let shading = GraphicsContext.Shading.color(schemeColor)
                    context.stroke(path, with: shading, lineWidth: width)
                }
            }
        }

    }

}
