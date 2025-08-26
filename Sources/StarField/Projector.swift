import SwiftUI

// MARK: - Projector

extension StarField {

    protocol Projector {
        func plot(_ position: StarField.Position) -> CGPoint?
        func isPlotNearView(_ plot: CGPoint) -> Bool
    }

}

// MARK: - Reversible Projector

extension StarField {

    protocol ReversibleProjector {
        func reversePlot(_ plot: CGPoint) -> StarField.Position?
    }

}

// MARK: - Apparent Diameter

extension StarField.Projector {

    func sizeOfApparentDiameter(
        _ diameter: Angle,
        at position: StarField.Position
    ) -> CGFloat? {
        let decl2 = position.declination + diameter
        let posn2 = StarField.Position(
            rightAscension: position.rightAscension,
            declination: decl2)

        guard let plot1 = plot(position), let plot2 = plot(posn2) else {
            return nil
        }

        let dx = plot1.x - plot2.x
        let dy = plot1.y - plot2.y
        return sqrt(dx * dx + dy * dy)
    }

}
