import SwiftUI

extension StarField {

    public protocol Furniture: Identifiable {
        var id: UUID { get }
    }

}
