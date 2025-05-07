import SwiftUI

// MARK: - Projection

public extension StarField {

    public enum Projection {
        case gnomonic
    }

}

// MARK: - Plotter Factory

extension StarField.Projection {

    func makePlotter(
        viewCenter: (Angle, Angle),
        viewDiameter: Angle,
        viewSize: CGSize
    ) -> StarField.Plotter {
        switch self {

        case .gnomonic:
            return StarField.GnomonicPlotter(
                viewCenter: viewCenter,
                viewDiameter: viewDiameter,
                viewSize: viewSize)
        }
    }

}
