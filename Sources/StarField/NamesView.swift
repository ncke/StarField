import SwiftUI

extension StarField {

    struct NamesView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        @ObservedObject var layout: Layout

        var body: some View {
            let nameFont = configuration.nameFont
            let nameColor = configuration.colorScheme.nameColor

            Canvas { context, size in
                let resolver: TextResolver = { string in
                    let text = Text(verbatim: string)
                        .font(nameFont)
                        .foregroundStyle(nameColor)

                    return context.resolve(text)
                }

                let namesArtist = StarField.GraphicsArtist(
                    context: context,
                    colorScheme: configuration.colorScheme)

                let nameGraphics = layout.layoutNames(using: resolver)
                nameGraphics.forEach { graphic in
                    namesArtist.drawGraphic(graphic)
                }
            }
        }

    }

}
