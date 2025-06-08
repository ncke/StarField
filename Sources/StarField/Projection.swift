import SwiftUI

// MARK: - Projection

extension StarField {

    public enum Projection {
        case gnomonic
    }

}

// MARK: - Projector Factory

extension StarField.Projection {

    func makeProjector(
        viewCenter: (Angle, Angle),
        viewDiameter: Angle,
        viewSize: CGSize
    ) -> StarField.Projector {
        switch self {

        case .gnomonic:
            return StarField.GnomonicProjector(
                viewCenter: viewCenter,
                viewDiameter: viewDiameter,
                viewSize: viewSize)
        }
    }

}
