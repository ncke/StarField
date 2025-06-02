import SwiftUI

extension StarField {

    public protocol StarFieldFurniture: Identifiable {
        var id: UUID { get }
    }

}
