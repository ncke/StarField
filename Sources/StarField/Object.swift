import Foundation

// MARK: - Object

extension StarField {

    public protocol Object: Identifiable {
        var id: UUID { get }
        var position: StarField.Position { get }
        var magnitude: Double { get }
    }

}

// MARK: - Plottable Object

protocol PlottableObject: StarField.Object, Plottable {}
