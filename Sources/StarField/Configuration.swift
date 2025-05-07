import Combine

public extension StarField {

    public class Configuration: ObservableObject {
        public var projection: StarField.Projection

        public init(
            projection: StarField.Projection = .gnomonic
        ) {
            self.projection = projection
        }
    }

}
