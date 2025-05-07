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

public enum StarField {}
