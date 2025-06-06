import SwiftUI

// MARK: - Graphics View

extension StarField {

    struct GraphicsView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        @Binding var graphics: [Graphic]

        var body: some View {
            Canvas { context, _ in
                let artist = GraphicsArtist(
                    context: context,
                    colorScheme: configuration.colorScheme)

                graphics.forEach { graphic in
                    artist.drawGraphic(graphic)
                }
            }
        }
    }

}
