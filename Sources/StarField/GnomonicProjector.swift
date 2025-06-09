import SwiftUI

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
            self.k = min(xMid, yMid) / (0.5 * viewDiameter.radians)
            self.a0 = viewCenter.0.radians
            self.d0 = viewCenter.1.radians
            self.flip = -1 // Flip to match charting convention.
        }

        func plot(_ position: StarField.Position) -> CGPoint? {
            let a = position.rightAscension.radians
            let d = position.declination.radians

            let dd = sin(d0) * sin(d) + cos(d0) * cos(d) * cos(a - a0)
            guard dd >= 0 else {
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

// MARK: - Reversible Projector

extension StarField.GnomonicProjector: StarField.ReversibleProjector {

    func reversePlot(_ plot: CGPoint) -> StarField.Position? {
        let dx = (plot.x - xMid) / k
        let dy = (yMid - plot.y) / k

        let rho = sqrt(dx * dx + dy * dy)
        let c = atan(rho)

        let sinC = sin(c)
        let cosC = cos(c)

        let safeRho = (rho == 0 ? 1.0 : rho)
        let dec1 = cosC * sin(d0)
        let dec2 = dy * sinC * cos(d0) / safeRho
        let dec = asin(dec1 + dec2)

        let num = dx * sinC
        let num1 = rho * cos(d0)
        let num2 = num1 * cosC
        let num3 = dy * sin(d0)
        let num4 = num3 * sinC
        let den = num2 - num4

        var ra = a0 + atan2(flip * num, den)

        if ra < 0 { ra += 2 * .pi }
        if ra >= 2 * .pi { ra -= 2 * .pi }

        let position = StarField.Position(
            rightAscension: Angle(radians: ra),
            declination: Angle(radians: dec))

        return position
    }

}
