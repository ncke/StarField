
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

public extension StarField {

    public struct Content: SwiftUI.View {
        public var viewCenter: (Angle, Angle)
        public var diameter: Angle
        public var size: CGSize? = nil

        public var stars: [Star]

        public init(
            viewCenter: (Angle, Angle),
            diameter: Angle,
            stars: [Star]
        ) {
            self.viewCenter = viewCenter
            self.diameter = diameter
            self.stars = stars
        }

        public var body: some View {
            GeometryReader { geometry in
                let drawSize = size ?? geometry.size
                let plotter = makePlotter(drawSize: drawSize)
                Canvas { context, _ in
                    stars.forEach { star in
                        guard let plot = plotter(star.position) else { return }

                        let radius = max(1.0, 10.0 - star.magnitude)
                        let hradius = 0.5 * radius

                        let c = CGRect(x: plot.x - hradius, y: plot.y - hradius, width: radius, height: radius)
                        context.fill(Path(ellipseIn: c), with: .color(.black))
                    }

                    [0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 140.0, 150.0, 160.0, 170.0].forEach { degs in
                        let ps = latitudePaths(Angle(degrees: degs), plotter: plotter)
                        for p in ps {
                            context.stroke(p, with: .color(Color(red: 128/255.0, green: 128/255.0, blue: 128/255.0)))
                        }
                    }

                    [0.0, 15.0, 30.0, 45.0, 60.0, 75.0, 90.0, 105.0, 120.0, 135.0, 150.0, 165.0, 180.0, 195.0, 210.0, 225.0, 240.0, 255.0, 270.0, 285.0, 300.0, 315.0, 330.0].forEach { degs in
                        let ps = longitudePaths(Angle(degrees: degs), plotter: plotter)
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

        private typealias Plotter = (Position) -> CGPoint?

        private func makePlotter(
            drawSize: CGSize
        ) -> Plotter {
            //let ratio = drawSize.height / diameter.radians
            let xmid = 0.5 * drawSize.width
            let ymid = 0.5 * drawSize.height
            let k = ymid / self.diameter.radians
            //let d = ymid / tan(0.5 * diameter.radians)

            return { position in
                let a0 = viewCenter.0.radians
                let d0 = viewCenter.1.radians
                let a = position.rightAscension.radians
                let d = position.declination.radians

                let dd = sin(d0) * sin(d) + cos(d0) * cos(d) * cos(a - a0)
                guard dd > 0.01 else {
                    return nil
                }

                let dx = -(cos(d) * sin(a - a0)) / dd // Note negated to flip.
                let dy = (cos(d0) * sin(d) - sin(d0) * cos(d) * cos(a - a0)) / dd


                let px = xmid + (k * dx)
                let py = ymid - (k * dy)

                return CGPoint(x: px, y: py)
            }
        }

        private func latitudePaths(_ lat: Angle, plotter: Plotter) -> [Path] {
            var plots = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 140.0, 150.0, 160.0, 170.0, 180.0, 190.0, 200.0, 210.0, 220.0, 230.0, 240.0, 250.0, 260.0, 270.0, 280.0, 290.0, 300.0, 310.0, 320.0, 330.0, 340.0, 350.0, 360.0].map { degs in

                let lon = Angle(degrees: degs)
                let pos = Position(rightAscension: lon, declination: lat)
                return plotter(pos)
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

        private func longitudePaths(_ lon: Angle, plotter: Plotter) -> [Path] {
            var plots = [-20.0, -10.0, 0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0].map { degs in

                let lat = Angle(degrees: degs)
                let pos = Position(rightAscension: lon, declination: lat)
                return plotter(pos)
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
