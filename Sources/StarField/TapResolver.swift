import SwiftUI

// MARK: - StarField Tap Handler

extension StarField {

    public typealias TapHandler =
    (StarField.Position, (any Object)?) -> Void

}

// MARK: - Nearest Object Provider

extension StarField {

    protocol NearestObjectProvider {

        func nearestObject(
            to location: CGPoint
        ) -> (any Object, CGFloat)?

    }

}

// MARK: - Tap Resolver

extension StarField {

    struct TapResolver {

        struct Resolution {
            let position: StarField.Position
            let nearestObject: (any Object)?
        }

        let effectiveRadius: CGFloat
        let reversibleProjector: ReversibleProjector
        let nearestObjectProvider: NearestObjectProvider

        init?(
            effectiveRadius: CGFloat?,
            projector: Projector,
            nearestObjectProvider: NearestObjectProvider
        ) {
            guard
                let effectiveRadius = effectiveRadius,
                let reversibleProjector = projector as? ReversibleProjector
            else {
                return nil
            }

            self.effectiveRadius = effectiveRadius
            self.reversibleProjector = reversibleProjector
            self.nearestObjectProvider = nearestObjectProvider
        }

        func resolveTap(at location: CGPoint) -> Resolution? {
            guard let reverse = reversibleProjector.reversePlot(location) else {
                return nil
            }

            let nearestObject = determineNearestObject(to: location)
            return Resolution(
                position: reverse,
                nearestObject: nearestObject)
        }

        private func determineNearestObject(
            to location: CGPoint
        ) -> (any Object)? {
            let nearest = nearestObjectProvider.nearestObject(to: location)
            guard
                let (object, distance) = nearest,
                distance <= effectiveRadius
            else {
                return nil
            }

            return object
        }

    }

}
