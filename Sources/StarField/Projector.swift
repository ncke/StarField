import SwiftUI

// MARK: - Projector

extension StarField {

    protocol Projector {
        func plot(_ position: StarField.Position) -> CGPoint?
        func isPlotNearView(_ plot: CGPoint) -> Bool
    }

    protocol ReversibleProjector {
        func reversePlot(_ plot: CGPoint) -> StarField.Position?
    }

}
