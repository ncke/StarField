import SwiftUI

// MARK: - Plotter

extension StarField {

    protocol Plotter {
        func minuteScale() -> CGFloat
        func plot(_ position: StarField.Position) -> CGPoint?
        func isPlotNearView(_ plot: CGPoint) -> Bool
    }

}

// MARK: - Gnomonic Plotter

extension StarField {

    class GnomonicPlotter: Plotter {
        private let viewCenter: (Angle, Angle)
        private let viewDiameter: Angle
        private let viewSize: CGSize
        private let xMid: CGFloat
        private let yMid: CGFloat
        private let k: CGFloat
        private let a0: Double
        private let d0: Double
        private let flip: Double
        private var _minuteScale: CGFloat?

        init(
            viewCenter: (Angle, Angle),
            viewDiameter: Angle,
            viewSize: CGSize
        ) {
            self.viewCenter = viewCenter
            self.viewDiameter = viewDiameter
            self.viewSize = viewSize
            self.xMid = 0.5 * viewSize.width
            self.yMid = 0.5 * viewSize.height
            self.k = yMid / viewDiameter.radians
            self.a0 = viewCenter.0.radians
            self.d0 = viewCenter.1.radians
            self.flip = -1 // Flip to match charting convention.
        }

        func plot(_ position: StarField.Position) -> CGPoint? {
            let a = position.rightAscension.radians
            let d = position.declination.radians

            let dd = sin(d0) * sin(d) + cos(d0) * cos(d) * cos(a - a0)
            guard dd > -0.5 else {
                // Object is behind the view plane.
                return nil
            }

            let dx = flip * (cos(d) * sin(a - a0)) / dd
            let dy = (cos(d0) * sin(d) - sin(d0) * cos(d) * cos(a - a0)) / dd
            let px = xMid + (k * dx)
            let py = yMid - (k * dy)

            return CGPoint(x: px, y: py)
        }

        private static let nearViewMargin: CGFloat = 30.0

        func isPlotNearView(_ plot: CGPoint) -> Bool {
            guard
                plot.x >= -Self.nearViewMargin,
                plot.x <= viewSize.width + Self.nearViewMargin,
                plot.y >= -Self.nearViewMargin,
                plot.y <= viewSize.height + Self.nearViewMargin
            else {
                return false
            }

            return true
        }

        func minuteScale() -> CGFloat {
            if let scale = _minuteScale { return scale }
            let scale = computeOneMinuteLength()
            _minuteScale = scale

            return scale
        }

        private static let oneMinuteAngle = Angle(radians: 0.000290888)

        private func computeOneMinuteLength() -> CGFloat {
            let p1 = plot(
                StarField.Position(
                    rightAscension: viewCenter.0,
                    declination: viewCenter.1)
            ) ?? CGPointZero

            let p2 = plot(
                StarField.Position(
                    rightAscension: viewCenter.0 + Self.oneMinuteAngle,
                    declination: viewCenter.1)
            ) ?? CGPointZero

            return abs(p2.x - p1.x)
        }

    }

}
