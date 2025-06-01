import SwiftUI

// MARK: - CGRect Helpers

extension CGRect {

    init(enclosingCircleAt center: CGPoint, radius: CGFloat) {
        let origin = CGPoint(x: center.x - radius, y: center.y - radius)
        let diameter = 2.0 * radius
        let size = CGSize(width: diameter, height: diameter)
        self.init(origin: origin, size: size)
    }

    func enlarge(delta: CGFloat) -> CGRect {
        CGRect(
            x: Int(self.minX - delta),
            y: Int(self.minY - delta),
            width: Int(self.width + 2.0 * delta),
            height: Int(self.height + 2.0 * delta))
    }

}
