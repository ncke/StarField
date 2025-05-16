import SwiftUI

// MARK: - StarsView

extension StarField {

    struct ObjectsView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        let objects: [Object]
        let plotter: StarField.Plotter

        public var body: some View {
            Canvas { context, _ in
                objects.forEach { object in
                    object.draw(
                        in: context,
                        plotter: plotter,
                        configuration: configuration)
                }
            }
        }

    }

}
