import SwiftUI

// MARK: - Coordinate Lines View

extension StarField {

    struct CoordinateLinesView: SwiftUI.View {
        @EnvironmentObject var configuration: Configuration
        let plotter: StarField.Plotter

        public var body: some View {
            let cs = configuration.colorScheme

            Canvas { context, _ in
                let shading = GraphicsContext.Shading.color(
                    cs.colorForCoordinateLines
                )

                let latLines = configuration.showLinesOfLatitude
                let latPaths = makePaths(
                    plotter: plotter,
                    angles: latLines.enumerateForLatitude(),
                    greatCircle: Self.latitudeGreatCircle) {
                        lat, gc in
                        StarField.Position(
                            rightAscension: gc,
                            declination: lat)
                    }

                let lonLines = configuration.showLinesOfLongitude
                let lonPaths = makePaths(
                    plotter: plotter,
                    angles: lonLines.enumerateForLongitude(),
                    greatCircle: Self.longitudeGreatCircle) {
                        lon, gc in
                        StarField.Position(
                            rightAscension: lon,
                            declination: gc)
                    }

                for p in latPaths + lonPaths {
                    context.stroke(p, with: shading)
                }
            }
        }

    }

}

// MARK: - Great Circle Path Factory

extension StarField.CoordinateLinesView {

    private static let latitudeGreatCircle: [Double] = {
        (0...120).map { i in Double(3 * i) }
    }()

    private static let longitudeGreatCircle: [Double] = {
        (-8...8).map { i in Double(10 * i) }
    }()

    private func makePaths(
        plotter: StarField.Plotter,
        angles: [Angle],
        greatCircle: [Double],
        positioner: (Angle, Angle) -> StarField.Position
    ) -> [Path] {
        var paths = [Path]()

        for angle in angles {
            var pts = greatCircle.map { gcDegs in
                plotter.plot(positioner(angle, Angle(degrees: gcDegs)))
            }

            func stripLeadingNils() {
                let nils = pts.take { pt in pt == nil }
                if nils.count > 0 {
                    pts = Array(pts.dropFirst(nils.count))
                }
            }

            func stripSegment() -> [CGPoint?] {
                let segment = pts.take { pt in pt != nil }
                if segment.count > 0 {
                    pts = Array(pts.dropFirst(segment.count))
                }

                return segment
            }

            while !pts.isEmpty {
                stripLeadingNils()
                let segment = stripSegment()
                guard segment.count > 1 else { continue }

                var path = Path()
                path.move(to: segment[0]!)
                for pt in segment.dropFirst() {
                    path.addLine(to: pt!)
                }

                paths.append(path)
            }
        }

        return paths
    }

}

// MARK: - Array Helper

private extension Array {

    func take(while predicate: (Element) -> Bool) -> [Element] {
        var taken = [Element]()
        var cursor = self.startIndex
        while cursor < self.endIndex && predicate(self[cursor]) {
            taken.append(self[cursor])
            cursor = cursor.advanced(by: 1)
        }

        return taken
    }

}
