import Foundation

extension StarField {

    public struct Object: Identifiable {

        public enum ObjectType {
            case star(isDouble: Bool, isVariable: Bool)
        }

        public let id: UUID
        public let position: Position
        public let magnitude: Double
        public let type: ObjectType
        public let names: [String]

        public init(
            id: UUID,
            position: Position,
            magnitude: Double,
            type: ObjectType,
            names: [String]
        ) {
            self.id = id
            self.position = position
            self.magnitude = magnitude
            self.type = type
            self.names = names
        }
    }

}
