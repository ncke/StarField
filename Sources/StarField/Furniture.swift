import SwiftUI

// MARK: - Furniture

extension StarField {

    public protocol Furniture: Identifiable {
        var id: UUID { get }
    }

}
