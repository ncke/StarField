import SwiftUI

extension StarField {

    struct NamesView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        @ObservedObject var layout: Layout

        var body: some View {
            if layout.isReadyForNames {

                let nameFont = configuration.nameFont
                let nameColor = configuration.colorScheme.nameColor

                Canvas { context, size in
                    let resolver: TextResolver = { string in
                        let text = Text(verbatim: string)
                            .font(nameFont)
                            .foregroundStyle(nameColor)

                        return context.resolve(text)
                    }

                    let nameGraphics = layout.layoutNames(using: resolver)
                    nameGraphics.forEach { graphic in
                        switch graphic {

                        case .resolvedText(let rect, let resolvedText):
                            context.draw(
                                resolvedText,
                                at: CGPoint(x: rect.midX, y: rect.midY),
                                anchor: .center)

                        default:
                            break
                        }
                    }
                }
            } else {
                Text("")
            }
        }

    }

}
