import SwiftUI

// MARK: - Plot Coordinate Lines

extension StarField.Layout {

    func plotCoordinateLines() -> [StarField.Graphic] {
        let shading = GraphicsContext.Shading.color(
            configuration.colorScheme.coordinateLinesColor
        )

        let latLines = configuration.showLinesOfLatitude
        let latGraphics = makeGraphics(
            projector: projector,
            angles: latLines.enumerateForLatitude(),
            greatCircle: Self.latitudeGreatCircle) {
                lat, gc in
                StarField.Position(
                    rightAscension: gc,
                    declination: lat)
            }

        let lonLines = configuration.showLinesOfLongitude
        let lonGraphics = makeGraphics(
            projector: projector,
            angles: lonLines.enumerateForLongitude(),
            greatCircle: Self.longitudeGreatCircle) {
                lon, gc in
                StarField.Position(
                    rightAscension: lon,
                    declination: gc)
            }

        return latGraphics + lonGraphics
    }

}

// MARK: - Great Circle Path Factory

private extension StarField.Layout {

    static let latitudeGreatCircle: [Double] = {
        (0...120).map { i in Double(3 * i) }
    }()

    static let longitudeGreatCircle: [Double] = {
        (-8...8).map { i in Double(10 * i) }
    }()

    func makeGraphics(
        projector: StarField.Projector,
        angles: [Angle],
        greatCircle: [Double],
        positioner: (Angle, Angle) -> StarField.Position
    ) -> [StarField.Graphic] {
        var graphics = [StarField.Graphic]()

        for angle in angles {
            var pts = greatCircle.map { gcDegs in
                projector.plot(positioner(angle, Angle(degrees: gcDegs)))
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
                guard
                    segment.count > 1,
                    var start = segment[0]
                else {
                    continue
                }

                for pt in segment.dropFirst() {
                    guard let finish = pt else { break }
                    graphics.append(
                        .coordinateLine(start: start, finish: finish))
                    start = finish
                }
            }
        }

        return graphics
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
