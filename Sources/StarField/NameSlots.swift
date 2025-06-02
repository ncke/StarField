import SwiftUI

// MARK: - Name Slots

extension StarField {

    struct NameSlots {

        private static let angles = [
            0, 30, 45, 60, 90, 120, 135, 150, 180,
            210, 225, 240, 270, 300, 315, 330
        ]

        private static let distance: CGFloat = 1.0

        static func slotsForName(
            graphic: Graphic,
            nameSize: CGSize
        ) -> [CGRect]? {
            guard
                let (center, radius) = findCenterAndRadiusOfGraphic(graphic)
            else {
                return nil
            }

            let shuffledAngles = angles.shuffled()
            let slots = shuffledAngles.flatMap { angle in
                let anchors = anchorsForAngle(angle)
                let rects = anchors?.map { anchor in
                    calculateRectForNameSize(
                        nameSize,
                        objectCenter: center,
                        objectRadius: radius,
                        angle: angle,
                        anchor: anchor)
                } ?? []

                return rects
            }

            return slots.isEmpty ? nil : slots
        }

        private static func calculateRectForNameSize(
            _ nameSize: CGSize,
            objectCenter: CGPoint,
            objectRadius: CGFloat,
            angle: Int,
            anchor: (CGFloat, CGFloat)
        ) -> CGRect {
            let (ax, ay) = anchor
            let (axName, ayName) = (nameSize.width * ax, nameSize.height * ay)
            let alpha = Angle(degrees: Double(angle - 90))
            let radiusName = objectRadius + distance
            let axRelative = radiusName * cos(alpha.radians)
            let ayRelative = radiusName * sin(alpha.radians)
            let x = objectCenter.x + axRelative - axName
            let y = objectCenter.y + ayRelative - ayName

            return CGRect(origin: CGPoint(x: x, y: y), size: nameSize)
        }

        private static func findCenterAndRadiusOfGraphic(
            _ graphic: Graphic
        ) -> (CGPoint, CGFloat)? {
            let allCircles: [(CGPoint, CGFloat)] = graphic.shapes.compactMap {
                shape in

                guard case .circle(let center, let radius, _, _) = shape else {
                    return nil
                }

                return (center, radius)
            }

            let biggestCircle = allCircles.max { car1, car2 in
                let (_, radius1) = car1
                let (_, radius2) = car2
                return radius1 < radius2
            }

            return biggestCircle
        }

        private static func anchorsForAngle(
            _ degrees: Int
        ) -> [(CGFloat, CGFloat)]? {
            switch degrees {
            case 0: return [(0.25, 1.0), (0.75, 1.0), (0.5, 1.0)]
            case 30, 45, 60: return [(0.0, 1.0), (0.0, 0.75)]
            case 90: return [(0.0, 0.5)]
            case 120, 135, 150: return [(0.0, 0.0), (0.0, 0.25)]
            case 180: return [(0.25, 0.0), (0.75, 0.0), (0.5, 0.0)]
            case 210, 225, 240: return [(1.0, 0.25), (1.0, 0.0)]
            case 270: return [(1.0, 0.5)]
            case 300, 315, 330: return [(1.0, 0.75), (1.0, 1.0)]
            default: return []
            }
        }

    }

}
