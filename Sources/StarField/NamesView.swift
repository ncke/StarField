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
                        let text = Text(string)
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
                Text("Waiting!!!")
            }
        }

    }

}

// Will probably reuse this implementation initially for name placement.

// extension StarField {
//
//    private struct Placer {
//        private let objects: [UUID: StarField.Object]
//        private let projector: Projector
//        private let starObscurements: [UUID: Obscurement]
//        private var nameObscurements: [UUID: Obscurement]
//        private let priorityList: [UUID]
//        private let context: GraphicsContext
//        private let size: CGSize
//
//        init(
//            objects: [StarField.Object],
//            projector: Projector,
//            context: GraphicsContext,
//            size: CGSize
//        ) {
//            let starsLookup = objects.map { s in (s.id, s) }
//            let obsLookup: [(UUID, Obscurement)] = objects.compactMap { s in
//                guard let obs = s.obscures(projector: projector) else { return nil }
//                return (s.id, obs)
//            }
//
//            self.objects = Dictionary(uniqueKeysWithValues: starsLookup)
//            self.projector = projector
//            self.context = context
//            self.size = size
//            self.starObscurements = Dictionary(uniqueKeysWithValues: obsLookup)
//            self.nameObscurements = [:]
//            self.priorityList = objects
//                .sorted(by: { s1, s2 in s1.magnitude < s2.magnitude })
//                .map { s in s.id }
//
//            for starId in priorityList {
//                guard let star = self.objects[starId] else {
//                    continue
//                }
//
//                place(nameForObject: star)
//            }
//        }
//
//        mutating func place(nameForObject object: Object) {
//            guard
//                let name = object.names.first,
//                !name.isEmpty,
//                let starObs = starObscurements[object.id]
//            else {
//                return
//            }
//
//            print(object)
//
//            let text = Text(name).font(.system(size: 12))
//            let resolved = context.resolve(text)
//            let nameSize = resolved.measure(in: size)
//
//            for degrees in Self.placementAngles {
//                guard let nameRect = nameRectForAngle(
//                    degrees,
//                    nameSize: nameSize,
//                    relativeTo: starObs.coarseRectangle())
//                else { continue }
//
//                let starObs = obscurementIntersections(
//                    rect: nameRect,
//                    in: starObscurements)
//
//                guard starObs.isEmpty else { continue }
//
//                let nameObs = obscurementIntersections(
//                    rect: nameRect,
//                    in: nameObscurements)
//
//                guard nameObs.isEmpty else { continue }
//
//                nameObscurements[object.id] = .rect(rect: nameRect)
//
//                print(name, nameRect)
//
//                context.draw(
//                    resolved,
//                    at: CGPoint(x: nameRect.midX, y: nameRect.midY),
//                    anchor: .center)
//
//                break
//            }
//
//        }
//
//        func obscurementIntersections(
//            rect: CGRect,
//            in obscurements: [UUID: Obscurement]
//        ) -> [UUID] {
//            obscurements.keys.compactMap { obsId in
//                guard
//                    let obs = obscurements[obsId],
//                    obs.hasCoarseIntersection(with: rect)
//                else { return nil }
//
//                return obsId
//            }
//        }
//
//        func nameRectForAngle(
//            _ degrees: Int,
//            nameSize: CGSize,
//            relativeTo targetRect: CGRect
//        ) -> CGRect? {
//            var anchor: (Double, Double)?
//            if degrees == 0 { anchor = (0.5, 1.0) }
//            else if degrees == 30 || degrees == 60 { anchor = (0.0, 1.0) }
//            else if degrees == 90 { anchor = (0.0, 0.5) }
//            else if degrees == 120 || degrees == 150 { anchor = (0.0, 0.0) }
//            else if degrees == 180 { anchor = (0.5, 0.0) }
//            else if degrees == 210 || degrees == 240 { anchor = (1.0, 0.0) }
//            else if degrees == 270 { anchor = (1.0, 0.5) }
//            else if degrees == 300 || degrees == 330 { anchor = (1.0, 1.0) }
//
//            guard let (ax, ay) = anchor else { return nil }
//
//            let ox = nameSize.width * ax
//            let oy = nameSize.height * ay
//
//            let targetRadius = max(targetRect.width, targetRect.height)
//            let hookAngle = Angle(degrees: Double(degrees))
//            let xHook = targetRadius * cos(hookAngle.radians)
//            let yHook = targetRadius * sin(hookAngle.radians)
//
//            //context.fill(Path(targetRect), with: .color(.red))
//
//            return CGRect(
//                x: targetRect.midX + xHook - ox,
//                y: targetRect.midY + yHook - oy,
//                width: nameSize.width,
//                height: nameSize.height)
//        }
//
//        static let placementAngles = [
//            0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330
//        ]
//
//    }
//
//}
