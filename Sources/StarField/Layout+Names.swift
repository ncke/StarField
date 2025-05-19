import SwiftUI

// MARK: - Plot Names

extension StarField.Layout {

    func plotNames(avoiding: [StarField.Graphic]) -> [StarField.Graphic] {
        objects
            .sorted { s1, s2 in s1.magnitude < s2.magnitude }
            .compactMap { object in
                guard
                    let plot = objectPlots[object.id],
                    let name = nameForObject(object)
                else {
                    return nil
                }

                return nil
            }

    }

    private func nameForObject(_ object: StarField.Object) -> String? {
        guard
            let resolver = self.textResolver,
            let name = object.names.first,
            !name.isEmpty
        else {
            return nil
        }

        let text = textForName(name)
        let resolved = resolver.resolve(text)

        return name.capitalized
    }

    private func textForName(_ name: String) -> Text {
        Text(name)
    }

}
