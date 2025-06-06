import Foundation

// MARK: - StarFieldObject

extension StarField {

    public protocol Object: Identifiable {
        var id: UUID { get }
        var position: StarField.Position { get }
        var magnitude: Double { get }
    }

}

// MARK: - PlottableObject

protocol PlottableObject: StarField.Object, Plottable {}
