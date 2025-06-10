import SwiftUI

// MARK: - Text Resolver

extension StarField {

    typealias TextResolver
    = (String, KeyPath<ColorScheme, Color>) -> GraphicsContext.ResolvedText?

}

// MARK: - Names Fitter

extension StarField {

    class NamesFitter {
        private let nameableOrdering: [UUID]
        private let nameableLookup: [UUID: any Nameable]
        private var graphicsLookup: [UUID: StarField.Graphic]
        private let viewSize: CGSize

        init(
            nameables: [any Nameable],
            graphics: [StarField.Graphic],
            viewSize: CGSize
        ) {
            self.viewSize = viewSize
            self.nameableOrdering = nameables.map { n in n.id }

            let graphicsLookup = Dictionary(
                uniqueKeysWithValues: graphics.map { g in (g.objectId, g) })
            self.graphicsLookup = graphicsLookup

            let visibleIds = Set(graphicsLookup.keys)
            self.nameableLookup = Dictionary(
                uniqueKeysWithValues: nameables.compactMap {
                    n in visibleIds.contains(n.id) ? (n.id, n) : nil })
        }

        func fit(textResolver: TextResolver) -> [StarField.Graphic] {
            let names = nameableOrdering
                .compactMap { id in nameableLookup[id] }
                .compactMap { nameable in
                    fitNames(
                        for: nameable,
                        textResolver: textResolver)
                }
                .flatMap { $0 }

            return names
        }

        private func fitNames(
            for nameable: any Nameable,
            textResolver: TextResolver
        ) -> [StarField.Graphic]? {
            guard let nameStyle = nameStyle(forNameable: nameable) else {
                return nil
            }

            let nameGraphics: [StarField.Graphic] = nameable.names.compactMap {
                name in

                guard
                    let resolved = textResolver(name, nameStyle.textColor)
                else {
                    return nil
                }

                let nameSize = resolved.measure(in: viewSize)

                guard let graphic = fitName(
                    for: nameable,
                    resolvedName: resolved,
                    nameStyle: nameStyle,
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
            nameStyle: NameStyle,
            nameSize: CGSize
        ) -> StarField.Graphic? {
            guard let graphic = graphicsLookup[nameable.id] else {
                return nil
            }

            switch nameStyle.fittingStyle {

            case .interior, .exterior:
                let slots = NameSlots.slotsForName(
                    graphic: graphic,
                    nameSize: nameSize)

                return fitInFieldName(
                    slots: slots,
                    nameStyle: nameStyle,
                    resolvedName: resolvedName,
                    graphic: graphic)

            case .boundary:
                let slots = BoundarySlots.slotsForName(
                    graphic: graphic,
                    nameSize: nameSize,
                    viewSize: viewSize)

                return fitBoundaryName(
                    slots: slots,
                    resolvedName: resolvedName,
                    nameStyle: nameStyle)
            }
        }

        private func fitBoundaryName(
            slots: [CGRect]?,
            resolvedName: GraphicsContext.ResolvedText,
            nameStyle: NameStyle
        ) -> StarField.Graphic? {
            guard let slot = slots?.first else { return nil }

            return makeGraphic(
                rect: slot,
                text: resolvedName,
                nameStyle: nameStyle)
        }

        private func makeGraphic(
            rect: CGRect,
            text: GraphicsContext.ResolvedText,
            nameStyle: NameStyle
        ) -> Graphic {
            var shapes = [Graphic.Shape]()

            let bg = nameStyle.textBackground ?? \ColorScheme.backgroundColor
            let backgroundShape = Graphic.Shape.rectangle(
                rect: rect.enlarge(delta: 1.0),
                styles: [.fill(color: bg)],
                obscurement: .always)
            shapes.append(backgroundShape)

            let textShape = Graphic.Shape.text(
                rect: rect,
                text: text,
                styles: [],
                obscurement: .always)
            shapes.append(textShape)

            return Graphic(objectId: UUID(), shapes: shapes)
        }

        private func fitInFieldName(
            slots: [CGRect]?,
            nameStyle: NameStyle,
            resolvedName: GraphicsContext.ResolvedText,
            graphic: Graphic
        ) -> StarField.Graphic? {
            guard let slots = slots else { return nil }

            let (primaryFits, secondaryFits) = findPrimaryAndSecondaryFits(
                slots: slots,
                graphic: graphic,
                fittingStyle: nameStyle.fittingStyle)

            guard
                let selected = selectFit(slots: primaryFits, graphic: graphic)
                    ?? selectFit(slots: secondaryFits, graphic: graphic)
            else {
                return nil
            }

            return makeGraphic(
                rect: selected,
                text: resolvedName,
                nameStyle: nameStyle)
        }

        private func findPrimaryAndSecondaryFits(
            slots: [CGRect],
            graphic: Graphic,
            fittingStyle: NameStyle.FittingStyle
        ) -> ([CGRect], [CGRect]) {
            var primaryFits = [CGRect]()
            var secondaryFits = [CGRect]()

            for slot in slots {
                // In the exterior fitting style, the slot cannot be
                // obscured by its own graphic. This is the most likely
                // obscurement, so pre-check before considering
                // other graphics.
                if  fittingStyle == .exterior,
                    isSlotObscured(slot, by: [graphic]) != .never
                {
                    continue
                }

                let generalObscurement = isSlotObscured(
                    slot,
                    by: Array(graphicsLookup.values),
                    excluding: graphic.objectId)

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
            by graphics: [StarField.Graphic],
            excluding excludedId: UUID? = nil
        ) -> StarField.Graphic.Shape.Obscurement {
            var result = StarField.Graphic.Shape.Obscurement.never

            for graphic in graphics {
                guard graphic.objectId != excludedId else {
                    continue
                }

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

        private func nameStyle(
            forNameable nameable: Nameable
        ) -> NameStyle? {
            guard let styleable = nameable as? NameStyleable else {
                return nil
            }

            return styleable.nameStyle
        }

    }

}
