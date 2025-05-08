import SwiftUI

extension StarField {

    struct NamesView: SwiftUI.View {
        let stars: [StarField.Star]
        let configuration: StarField.Configuration
        let plotter: StarField.Plotter

        var body: some View {
            Canvas { context, size in
                let placer = Placer(
                    stars: stars,
                    plotter: plotter,
                    context: context,
                    size: size)
            }
        }

    }

}

extension StarField {

    private struct Placer {
        private let stars: [UUID: StarField.Star]
        private let plotter: StarField.Plotter
        private let starObscurements: [UUID: Obscurement]
        private var nameObscurements: [UUID: Obscurement]
        private let priorityList: [UUID]
        private let context: GraphicsContext
        private let size: CGSize

        init(
            stars: [StarField.Star],
            plotter: StarField.Plotter,
            context: GraphicsContext,
            size: CGSize
        ) {
            let starsLookup = stars.map { s in (s.id, s) }
            let obsLookup: [(UUID, Obscurement)] = stars.compactMap { s in
                guard let obs = s.obscures(plotter: plotter) else { return nil }
                return (s.id, obs)
            }

            print("obs: ", obsLookup)

            self.stars = Dictionary(uniqueKeysWithValues: starsLookup)
            self.plotter = plotter
            self.context = context
            self.size = size
            self.starObscurements = Dictionary(uniqueKeysWithValues: obsLookup)
            self.nameObscurements = [:]
            self.priorityList = stars
                .sorted(by: { s1, s2 in s1.magnitude < s2.magnitude })
                .map { s in s.id }

            for star in stars {
                place(nameForStar: star)
            }
        }

        mutating func place(nameForStar star: Star) {
            guard
                let name = star.names.first,
                !name.isEmpty,
                let starObs = starObscurements[star.id]
            else {
                return
            }

            context.stroke(Path(ellipseIn: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)), with: .color(.red))

            let text = Text(name).font(.system(size: 12))
            let resolved = context.resolve(text)
            let nameSize = resolved.measure(in: size)

            for degrees in Self.placementAngles {
                guard let nameRect = nameRectForAngle(
                    degrees,
                    nameSize: nameSize,
                    relativeTo: starObs.coarseRectangle())
                else { continue }

                let starObs = obscurementIntersections(
                    rect: nameRect,
                    in: starObscurements)

                guard starObs.isEmpty else { continue }

                let nameObs = obscurementIntersections(
                    rect: nameRect,
                    in: nameObscurements)

                guard nameObs.isEmpty else { continue }

                nameObscurements[star.id] = .rect(rect: nameRect)

                context.draw(
                    resolved,
                    at: CGPoint(x: nameRect.midX, y: nameRect.midY),
                    anchor: .center)
            }

        }

        func obscurementIntersections(
            rect: CGRect,
            in obscurements: [UUID: Obscurement]
        ) -> [UUID] {
            obscurements.keys.compactMap { obsId in
                guard
                    let obs = obscurements[obsId],
                    obs.hasCoarseIntersection(with: rect)
                else { return nil }

                return obsId
            }
        }

        func nameRectForAngle(
            _ degrees: Int,
            nameSize: CGSize,
            relativeTo targetRect: CGRect
        ) -> CGRect? {
            var anchor: (Double, Double)?
            if degrees == 0 { anchor = (0.5, 1.0) }
            else if degrees == 30 || degrees == 60 { anchor = (0.0, 1.0) }
            else if degrees == 90 { anchor = (0.0, 0.5) }
            else if degrees == 120 || degrees == 150 { anchor = (0.0, 0.0) }
            else if degrees == 180 { anchor = (0.5, 0.0) }
            else if degrees == 210 || degrees == 240 { anchor = (1.0, 0.0) }
            else if degrees == 270 { anchor = (1.0, 0.5) }
            else if degrees == 300 || degrees == 330 { anchor = (1.0, 1.0) }

            guard let (ax, ay) = anchor else { return nil }

            let ox = nameSize.width * ax
            let oy = nameSize.height * ay

            let targetRadius = max(targetRect.width, targetRect.height)
            let hookAngle = Angle(degrees: Double(degrees))
            let xHook = targetRadius * cos(hookAngle.radians)
            let yHook = targetRadius * sin(hookAngle.radians)

            return CGRect(
                x: xHook - ox,
                y: yHook - oy,
                width: nameSize.width,
                height: nameSize.height)
        }

        static let placementAngles = [
            0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330
        ]

    }

}
