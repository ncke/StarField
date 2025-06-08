import SwiftUI

// MARK: - Great Circle

extension StarField {

    // A structure that models a great circle. A great circle is a line that
    // wraps around the entire celestial sphere at some angle.
    struct GreatCircle {

        // A function type that takes two angles and constructs a Position.
        // This construction differs between great circles of latitude and
        // great circles on longitude.
        fileprivate typealias Positioner = (Angle, Angle) -> StarField.Position

        let angle: Angle
        let sense: CoordinateLine.Sense
        private let wrap: [Angle]
        private let positioner: Positioner

        init(angle: Angle, sense: CoordinateLine.Sense) {
            self.angle = angle
            self.sense = sense
            self.wrap = sense.wrappingAngles
            self.positioner = sense.positioner
        }

    }

}

// MARK: - Plottable Conformation

extension StarField.GreatCircle: Plottable {

    func plotGraphics(
        using projector: StarField.Projector,
        configuration: StarField.Configuration
    ) -> StarField.Graphic? {
        plotCircle(using: projector)
    }

    private func plotCircle(
        using projector: StarField.Projector
    ) -> StarField.Graphic {
        // Plot all points on the great circle for this angle, some may
        // be nil if not visible in a specific star field.
        var points = wrap.map { wrappingAngle in
            projector.plot(positioner(angle, wrappingAngle))
        }

        // Extract segments from the points. A segment is any
        // continuous run of non-nil points.
        points.append(nil)
        let segments = extractSegments(from: points)

        // Convert segments into graphics representing the visible
        // parts of the great circle.
        let shapes = segments.compactMap { segment in
            convertSegmentToLines(segment)
        }.flatMap { lines in lines }

        return StarField.Graphic(objectId: UUID(), shapes: shapes)
    }

    private func extractSegments(
        from points: [CGPoint?]
    ) -> [[CGPoint]] {
        assert((points.last ?? nil) == nil) // Must be nil terminated.

        var segments: [[CGPoint]] = []
        var current: [CGPoint] = []

        for pt in points {
            if let pt = pt {
                current.append(pt)
                continue
            }

            if current.count > 1 { segments.append(current) }
            current = []
        }

        return segments
    }

    private func convertSegmentToLines(
        _ segment: [CGPoint]
    ) -> [StarField.Graphic.Shape]? {
        guard segment.count >= 2 else { return nil }
        var start = segment[0]
        var lines: [StarField.Graphic.Shape] = []
        let color = \StarField.ColorScheme.coordinateLinesColor

        for pt in segment[1...] {
            let line = StarField.Graphic.Shape.line(
                start: start,
                finish: pt,
                styles: [.stroke(width: 1.0, color: color)],
                obscurement: .preferred)

            lines.append(line)
            start = pt
        }

        return lines
    }

}

// MARK: - Sense Helpers

fileprivate extension StarField.CoordinateLine.Sense {

    var wrappingAngles: [Angle] {
        switch self {
        case .latitude:
            return (0...120).map { i in Angle(degrees: Double(3 * i)) }
        case .longitude:
            return (-8...8).map { i in Angle(degrees: Double(10 * i)) }
        }
    }

    var positioner: StarField.GreatCircle.Positioner {
        switch self {
        case .latitude:
            return { a1, a2 in
                StarField.Position(rightAscension: a2, declination: a1)
            }
        case .longitude:
            return { a1, a2 in
                StarField.Position(rightAscension: a1, declination: a2)
            }
        }
    }

}
