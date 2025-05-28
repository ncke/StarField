import Foundation

// MARK: - StarFieldObject

public protocol StarFieldObject: Identifiable {
    var id: UUID { get }
    var position: StarField.Position { get }
    var magnitude: Double { get }
}

// MARK: - PlottableObject

protocol PlottableObject: StarFieldObject, Plottable {}
