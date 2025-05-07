import SwiftUI

public extension StarField {

    public struct Content: SwiftUI.View {
        public var viewCenter: (Angle, Angle)
        public var diameter: Angle
        public var size: CGSize? = nil
        @ObservedObject public var configuration: StarField.Configuration

        public var stars: [Star]

        public init(
            viewCenter: (Angle, Angle),
            diameter: Angle,
            stars: [Star],
            configuration: StarField.Configuration = StarField.Configuration()
        ) {
            self.viewCenter = viewCenter
            self.diameter = diameter
            self.stars = stars
            self.configuration = configuration
        }

        public var body: some View {
            GeometryReader { geometry in
                let drawSize = size ?? geometry.size
                let plotter = configuration.projection.makePlotter(
                    viewCenter: viewCenter,
                    viewDiameter: diameter,
                    viewSize: drawSize)

                Canvas { context, _ in

                    // Draw stars (to do: abstract visual representation).
                    stars.forEach { star in
                        guard
                            let plot = plotter.plot(star.position)
                        else { return }

                        let radius = max(1.0, 10.0 - star.magnitude)
                        let hradius = 0.5 * radius
                        let c = CGRect(
                            x: plot.x - hradius,
                            y: plot.y - hradius,
                            width: radius,
                            height: radius)

                        context.fill(Path(ellipseIn: c), with: .color(.black))
                    }

                    // Draw lines of latitude.
                    configuration
                        .showLinesOfLatitude
                        .enumerateForLatitude()
                        .forEach { angle in
                            let ps = latitudePaths(angle, plotter: plotter)

                            for p in ps {
                                context.stroke(p, with: .color(Color(red: 128/255.0, green: 128/255.0, blue: 128/255.0)))
                            }
                    }

                    // Draw lines of longitude.
                    configuration
                        .showLinesOfLongitude
                        .enumerateForLongitude()
                        .forEach { angle in
                            let ps = longitudePaths(angle, plotter: plotter)
                            for p in ps {
                            context.stroke(p, with: .color(Color(red: 128/255.0, green: 128/255.0, blue: 128/255.0)))
                            }
                    }

                }

                Text("hello")
            }
            .frame(width: size?.width, height: size?.height)
            .background(Color(red: 224/255.0, green: 255/255.0, blue: 255/255.0))
        }

        private func latitudePaths(_ lat: Angle, plotter: StarField.Plotter) -> [Path] {
            var plots = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 140.0, 150.0, 160.0, 170.0, 180.0, 190.0, 200.0, 210.0, 220.0, 230.0, 240.0, 250.0, 260.0, 270.0, 280.0, 290.0, 300.0, 310.0, 320.0, 330.0, 340.0, 350.0, 360.0].map { degs in

                let lon = Angle(degrees: degs)
                let pos = Position(rightAscension: lon, declination: lat)
                return plotter.plot(pos)
            }

            var paths = [Path]()

            while !plots.isEmpty {
                let nils = plots.take { pt in pt == nil }
                if nils.count > 0 {
                    plots = Array(plots.dropFirst(nils.count))
                }

                let segment = plots.take { pt in pt != nil }
                if segment.count > 0 {
                    plots = Array(plots.dropFirst(segment.count))
                    var path = Path()
                    path.move(to: segment[0]!)
                    for pt in segment.dropFirst() {
                        path.addLine(to: pt!)
                    }
                    paths.append(path)
                }
            }

            return paths
        }

        private func longitudePaths(_ lon: Angle, plotter: StarField.Plotter) -> [Path] {
            var plots = [-20.0, -10.0, 0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0].map { degs in

                let lat = Angle(degrees: degs)
                let pos = Position(rightAscension: lon, declination: lat)
                return plotter.plot(pos)
            }

            var paths = [Path]()

            while !plots.isEmpty {
                let nils = plots.take { pt in pt == nil }
                if nils.count > 0 {
                    plots = Array(plots.dropFirst(nils.count))
                }

                let segment = plots.take { pt in pt != nil }
                if segment.count > 0 {
                    plots = Array(plots.dropFirst(segment.count))
                    var path = Path()
                    path.move(to: segment[0]!)
                    for pt in segment.dropFirst() {
                        path.addLine(to: pt!)
                    }
                    paths.append(path)
                }
            }

            return paths

        }

    }

}

extension Array {

    func take(while predicate: (Element) -> Bool) -> [Element] {
        var taken = [Element]()
        var cursor = self.startIndex
        while cursor < self.endIndex && predicate(self[cursor]) {
            taken.append(self[cursor])
            cursor = cursor.advanced(by: 1)
        }

        return taken
    }

}

