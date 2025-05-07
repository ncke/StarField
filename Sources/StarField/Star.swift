import SwiftUI

extension StarField {

    public struct Star: Identifiable {
        public let id: UUID
        let position: Position
        let magnitude: Double
        let isDoubleStar: Bool
        let isVariableStar: Bool
        let names: [String]

        public init(id: UUID, position: Position, magnitude: Double, isDoubleStar: Bool, isVariableStar: Bool, names: [String]) {
            self.id = id
            self.position = position
            self.magnitude = magnitude
            self.isDoubleStar = isDoubleStar
            self.isVariableStar = isVariableStar
            self.names = names
        }
    }

}

//extension StarField.Star: StarFieldEntity {}

extension StarField.Star: View {

    public var body: some View {
        Circle()
            .frame(width: radiusForMagnitude)
            .foregroundStyle(.black)
    }

    private var radiusForMagnitude: Double {
        2.0 * min(max(magnitude + 8.0, 1.0), 8.0)
    }

}
