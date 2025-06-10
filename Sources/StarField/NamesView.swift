import SwiftUI

// MARK: - Names View

extension StarField {

    struct NamesView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        @ObservedObject var layout: Layout

        var body: some View {
            let nameFont = configuration.nameFont
            let cs = configuration.colorScheme

            Canvas { context, size in
                let resolver: TextResolver = { string, colorKeyPath in
                    let color = cs[keyPath: colorKeyPath]
                    let text = Text(verbatim: string)
                        .font(nameFont)
                        .foregroundStyle(color)

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
