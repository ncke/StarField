import SwiftUI

extension StarField {

    struct NamesView: SwiftUI.View {
        let stars: [StarField.Star]
        let configuration: StarField.Configuration
        let plotter: StarField.Plotter

        var body: some View {
            Canvas { context, _ in
                let placer = Placer(
                    stars: stars,
                    plotter: plotter,
                    context: context)
            }
        }

    }

}

extension StarField {

    private struct Placer {
        private let stars: [UUID: StarField.Star]
        private let plotter: StarField.Plotter
        private let starObscurements: [UUID: Obscurement]
        private let nameObscurements: [UUID: Obscurement]
        private let priorityList: [UUID]
        private let context: GraphicsContext

        init(
            stars: [StarField.Star],
            plotter: StarField.Plotter,
            context: GraphicsContext
        ) {
            let starsLookup = stars.map { s in (s.id, s) }
            let obsLookup: [(UUID, Obscurement)] = stars.compactMap { s in
                guard let obs = s.obscures(plotter: plotter) else { return nil }
                return (s.id, obs)
            }

            self.stars = Dictionary(uniqueKeysWithValues: starsLookup)
            self.plotter = plotter
            self.context = context
            self.starObscurements = Dictionary(uniqueKeysWithValues: obsLookup)
            self.nameObscurements = [:]
            self.priorityList = stars
                .sorted(by: { s1, s2 in s1.magnitude < s2.magnitude })
                .map { s in s.id }
        }

        func place(nameForStar: Star, in context: GraphicsContext) {
            
        }

    }

}
