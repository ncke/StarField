import SwiftUI

// MARK: - Nameable

extension StarField {

    public protocol Nameable {
        var id: UUID { get }
        var names: [String] { get }
    }

}
