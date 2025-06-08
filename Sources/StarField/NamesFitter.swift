import SwiftUI

// MARK: - StarField Nameable

extension StarField {

    public protocol Nameable {
        var id: UUID { get }
        var names: [String] { get }
    }

}

// MARK: - Text Resolver

typealias TextResolver = (String) -> GraphicsContext.ResolvedText?

// MARK: - Names Fitter

extension StarField {

    class NamesFitter {
        private let nameableLookup: [UUID: any Nameable]
        private var graphicsLookup: [UUID: StarField.Graphic]
        private let viewSize: CGSize

        init(
            nameables: [any Nameable],
            graphics: [StarField.Graphic],
            viewSize: CGSize
        ) {
            self.viewSize = viewSize

            let graphicsLookup = Dictionary(
                uniqueKeysWithValues: graphics.map { g in (g.objectId, g) })
            self.graphicsLookup = graphicsLookup

            let visibleIds = Set(graphicsLookup.keys)
            self.nameableLookup = Dictionary(
                uniqueKeysWithValues: nameables.compactMap {
                    n in visibleIds.contains(n.id) ? (n.id, n) : nil })
        }

        func fit(textResolver: TextResolver) -> [StarField.Graphic] {
            let names = nameableLookup
                .keys
                .compactMap { id in nameableLookup[id] }
                .compactMap { nameable in
                    fitNames(for: nameable, textResolver: textResolver)
                }
                .flatMap { $0 }

            return names
        }

        private func fitNames(
            for nameable: any Nameable,
            textResolver: TextResolver
        ) -> [StarField.Graphic]? {
            let nameGraphics: [StarField.Graphic] = nameable.names.compactMap {
                name in

                guard let resolved = textResolver(name) else { return nil }
                let nameSize = resolved.measure(in: viewSize)

                guard let graphic = fitName(
                    for: nameable,
                    resolvedName: resolved,
                    nameSize: nameSize)
                else {
                    return nil
                }

                graphicsLookup[graphic.objectId] = graphic
                return graphic
            }

            return nameGraphics.isEmpty ? nil : nameGraphics
        }

        private func fitName(
            for nameable: any Nameable,
            resolvedName: GraphicsContext.ResolvedText,
            nameSize: CGSize
        ) -> StarField.Graphic? {
            guard
                let graphic = graphicsLookup[nameable.id],
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
                    by: Array(graphicsLookup.values))

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

            for (_, graphic) in graphicsLookup {
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
