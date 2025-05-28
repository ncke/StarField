import SwiftUI

// MARK: - Projector

extension StarField {

    protocol Projector {
        func plot(_ position: StarField.Position) -> CGPoint?
        func isPlotNearView(_ plot: CGPoint) -> Bool
    }

}

// MARK: - Gnomonic Projector

extension StarField {

    struct GnomonicProjector: Projector {
        private let viewCenter: (Angle, Angle)
        private let viewDiameter: Angle
        private let viewSize: CGSize
        private let xMid: CGFloat
        private let yMid: CGFloat
        private let k: CGFloat
        private let a0: Double
        private let d0: Double
        private let flip: Double

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
            self.k = min(xMid, yMid) / viewDiameter.radians
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

    }

}
