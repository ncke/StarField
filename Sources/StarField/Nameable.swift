import SwiftUI

// MARK: - Nameable

extension StarField {

    public protocol Nameable: Identifiable {
        var id: UUID { get }
        var names: [String] { get }
    }

}
