import SwiftUI

// MARK: - StarsView

extension StarField {

    struct StarsView: SwiftUI.View {
        let stars: [Star]
        let configuration: StarField.Configuration
        let plotter: StarField.Plotter

        public var body: some View {
            Canvas { context, _ in
                stars.forEach { star in
                    star.draw(
                        in: context,
                        plotter: plotter,
                        configuration: configuration)
                }
            }
        }

    }

}
