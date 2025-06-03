import SwiftUI

// MARK: - StarFieldNameable

public protocol StarFieldNameable {
    var names: [String] { get }
}

// MARK: - TextResolver

typealias TextResolver = (String) -> GraphicsContext.ResolvedText?

// MARK: - Names Fitter

extension StarField {

    class NamesFitter {
        private let visibleObjectIds: Set<UUID>
        private let objectLookup: [UUID: any StarFieldObject]
        private let viewSize: CGSize
        private var graphicLookup: [UUID: StarField.Graphic]

        init(
            objects: [any StarFieldObject],
            graphics: [StarField.Graphic],
            viewSize: CGSize
        ) {
            self.viewSize = viewSize

            var visibleIds = Set<UUID>()
            var graphicLookup = [UUID: StarField.Graphic]()
            graphics.forEach { graphic in
                visibleIds.insert(graphic.objectId)
                graphicLookup[graphic.objectId] = graphic
            }
            self.visibleObjectIds = visibleIds
            self.graphicLookup = graphicLookup

            var objectLookup = [UUID: any StarFieldObject]()
            objects.forEach { object in
                if visibleIds.contains(object.id) {
                    objectLookup[object.id] = object
                }
            }
            self.objectLookup = objectLookup
        }

        func fit(textResolver: TextResolver) -> [StarField.Graphic] {
            let names = visibleObjectIds.compactMap { objectId in
                objectLookup[objectId]
            }.sorted { object1, object2 in
                object1.magnitude < object2.magnitude
            }.compactMap { object in
                fitNamesForObject(object, textResolver: textResolver)
            }.flatMap { $0 }

            return names
        }

        private func fitNamesForObject(
            _ object: any StarFieldObject,
            textResolver: TextResolver
        ) -> [StarField.Graphic]? {
            guard
                let nameable = object as? StarFieldNameable
            else {
                return nil
            }

            let nameGraphics: [StarField.Graphic] = nameable.names.compactMap {
                name in

                guard let resolved = textResolver(name) else { return nil }
                let nameSize = resolved.measure(in: viewSize)

                guard let graphic = fitNameForObject(
                    object,
                    resolvedName: resolved,
                    nameSize: nameSize)
                else {
                    return nil
                }

                graphicLookup[graphic.objectId] = graphic
                return graphic
            }

            return nameGraphics.isEmpty ? nil : nameGraphics
        }

        private func fitNameForObject(
            _ object: any StarFieldObject,
            resolvedName: GraphicsContext.ResolvedText,
            nameSize: CGSize
        ) -> StarField.Graphic? {
            guard
                let graphic = graphicLookup[object.id],
                let slots = NameSlots.slotsForName(
                    graphic: graphic,
                    nameSize: nameSize)
            else {
                return nil
            }

            let (primaryFits, secondaryFits) = findPrimaryAndSecondaryFits(
                slots: slots,
                graphic: graphic)

            guard
                let selected = selectFit(slots: primaryFits, graphic: graphic)
                    ?? selectFit(slots: secondaryFits, graphic: graphic)
            else {
                return nil
            }

            let shape = Graphic.Shape.text(
                rect: selected,
                text: resolvedName,
                styles: [],
                obscurement: .always)

            return Graphic(objectId: UUID(), shapes: [shape])
        }

        private func findPrimaryAndSecondaryFits(
            slots: [CGRect],
            graphic: Graphic
        ) -> ([CGRect], [CGRect]) {
            var primaryFits = [CGRect]()
            var secondaryFits = [CGRect]()

            for slot in slots {
                guard isSlotObscured(slot, by: [graphic]) == .never else {
                    continue
                }

                let generalObscurement = isSlotObscured(
                    slot,
                    by: Array(graphicLookup.values))

                switch generalObscurement {
                case .always: continue
                case .preferred: secondaryFits.append(slot)
                case .never: primaryFits.append(slot)
                }
            }

            return (primaryFits, secondaryFits)
        }

        private func selectFit(
            slots: [CGRect],
            graphic: Graphic
        ) -> CGRect? {
            guard slots.count > 1 else {
                return slots.isEmpty ? nil : slots[0]
            }

            return findMostDistantFit(slots: slots, excludingGraphic: graphic)
        }

        private func findMostDistantFit(
            slots: [CGRect],
            excludingGraphic: Graphic
        ) -> CGRect? {
            var mostDistant: CGRect?
            var mostDistance = CGFloat.zero

            slots.forEach { slot in
                let nearestDistance = findDistanceToNearestGraphic(
                    slot: slot,
                    excludingGraphic: excludingGraphic)

                if let nd = nearestDistance, nd > mostDistance {
                    mostDistant = slot
                    mostDistance = nd
                }
            }

            return mostDistant
        }

        private func findDistanceToNearestGraphic(
            slot: CGRect,
            excludingGraphic: Graphic
        ) -> CGFloat? {
            let (xSlot, ySlot) = (slot.midX, slot.midY)
            var nearestDistance: CGFloat?

            for (key, graphic) in graphicLookup {
                if graphic.objectId == excludingGraphic.objectId {
                    continue
                }

                for shape in graphic.shapes {
                    let midpoint = shape.midpoint
                    let xd = xSlot - midpoint.x
                    let yd = ySlot - midpoint.y
                    let distance = xd * xd + yd * yd

                    let nd = nearestDistance ?? CGFloat.greatestFiniteMagnitude
                    if distance < nd {
                        nearestDistance = distance
                    }
                }
            }

            return nearestDistance
        }

        private func isSlotObscured(
            _ slot: CGRect,
            by graphics: [StarField.Graphic]
        ) -> StarField.Graphic.Shape.Obscurement {
            var result = StarField.Graphic.Shape.Obscurement.never

            for graphic in graphics {
                for shape in graphic.shapes {
                    guard shape.hasOverlapWithRect(slot) else { continue }

                    if shape.obscurement == .preferred {
                        result = .preferred
                        continue
                    }

                    if shape.obscurement == .always {
                        return .always
                    }
                }
            }

            return result
        }

        private func isWithinView(_ nameRect: CGRect) -> Bool {
            guard
                nameRect.minX >= 0.0,
                nameRect.minY >= 0.0,
                nameRect.maxX <= viewSize.width,
                nameRect.maxY <= viewSize.height
            else {
                return false
            }

            return true
        }

    }

}
