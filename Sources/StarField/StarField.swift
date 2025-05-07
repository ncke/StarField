
import SwiftUI

extension StarField {

    public struct Position {
        let rightAscension: Angle
        let declination: Angle

        public init(rightAscension: Angle, declination: Angle) {
            self.rightAscension = rightAscension
            self.declination = declination
        }
    }

}


//public struct StarFieldEntity: Identifiable {
//    public let id = UUID()
//}

public enum StarField {


}
