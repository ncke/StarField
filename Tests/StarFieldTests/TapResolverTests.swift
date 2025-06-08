import SwiftUI
import Testing
@testable import StarField

struct MockStraightThroughProjector: StarField.Projector {
    let viewRect: CGRect

    func plot(_ position: StarField.Position) -> CGPoint? {
        return CGPoint(
            x: position.rightAscension.degrees,
            y: position.declination.degrees)
    }
    
    func isPlotNearView(_ plot: CGPoint) -> Bool {
        viewRect.contains(plot)
    }

}

struct MockReversibleStraightThroughProjector:
    StarField.Projector,
    StarField.ReversibleProjector
{
    let viewRect: CGRect

    func plot(_ position: StarField.Position) -> CGPoint? {
        return CGPoint(
            x: position.rightAscension.degrees,
            y: position.declination.degrees)
    }
    
    func isPlotNearView(_ plot: CGPoint) -> Bool {
        viewRect.contains(plot)
    }

    func reversePlot(_ plot: CGPoint) -> StarField.Position? {
        return StarField.Position(
            rightAscension: Angle(degrees: plot.x),
            declination: Angle(degrees: plot.y))
    }

}

struct MockNearestObjectProvider: StarField.NearestObjectProvider {
    var nearestObject: (any StarField.Object)?
    var nearestDistance: CGFloat?

    func nearestObject(
        to location: CGPoint
    ) -> (any StarField.Object, CGFloat)? {
        guard
            let object = nearestObject,
            let distance = nearestDistance
        else {
            return nil
        }

        return (object, distance)
    }

}

@Test func testTapResolverInitialisation() async throws {
    let square100 = CGRect(
        origin: CGPoint.zero,
        size: CGSize(width: 100.0, height: 100.0))

    // Test for initialisation success.
    #expect(nil != StarField.TapResolver(
        effectiveRadius: 20.0,
        projector: MockReversibleStraightThroughProjector(viewRect: square100),
        nearestObjectProvider: MockNearestObjectProvider())
    )

    // Test that initialisation fails if effective radius is nil.
    #expect(nil == StarField.TapResolver(
        effectiveRadius: nil,
        projector: MockReversibleStraightThroughProjector(viewRect: square100),
        nearestObjectProvider: MockNearestObjectProvider())
    )

    // Test that initialisation fails if projector is not reversible.
    #expect(nil == StarField.TapResolver(
        effectiveRadius: nil,
        projector: MockStraightThroughProjector(viewRect: square100),
        nearestObjectProvider: MockNearestObjectProvider())
    )
}

@Test func testResolutionOfTapLocation() async throws {
    let square100 = CGRect(
        origin: CGPoint.zero,
        size: CGSize(width: 100.0, height: 100.0))
    let mockReversibleProjector = MockReversibleStraightThroughProjector(
        viewRect: square100)
    let mockNearestProvider = MockNearestObjectProvider()

    let sut = StarField.TapResolver(
        effectiveRadius: 20.0,
        projector: mockReversibleProjector,
        nearestObjectProvider: mockNearestProvider)

    // Test that a location resolves.
    let res = try #require(sut?.resolveTap(at: CGPoint(x: 45.0, y: 70.0)))
    #expect(res.position.rightAscension.degrees == 45.0)
    #expect(res.position.declination.degrees == 70.0)
    #expect(res.nearestObject == nil)
}

@Test func testResolutionWithANearestObject() async throws {
    let square100 = CGRect(
        origin: CGPoint.zero,
        size: CGSize(width: 100.0, height: 100.0))
    let mockReversibleProjector = MockReversibleStraightThroughProjector(
        viewRect: square100)
    let mockStarId = UUID()
    let mockStarPosition = StarField.Position(
        rightAscension: Angle(degrees: 32.0),
        declination: Angle(degrees: 90.0))
    let mockStar = StarField.Star(
        id: mockStarId,
        position: mockStarPosition,
        magnitude: 5.5,
        isVariable: false,
        isMultiple: true,
        names: ["MockStar"])
    let mockDistance: CGFloat = 3.2
    let mockNearestProvider = MockNearestObjectProvider(
        nearestObject: mockStar,
        nearestDistance: mockDistance)

    let sut = StarField.TapResolver(
        effectiveRadius: 20.0,
        projector: mockReversibleProjector,
        nearestObjectProvider: mockNearestProvider)

    // Test resolution with a nearest object.

    let res = try #require(sut?.resolveTap(at: CGPoint(x: 28.0, y: 82.0)))
    #expect(res.position.rightAscension.degrees == 28.0)
    #expect(res.position.declination.degrees == 82.0)

    let resStar = try #require(res.nearestObject)
    #expect(resStar.id == mockStarId)
    #expect(resStar.position.rightAscension.degrees == 32.0)
    #expect(resStar.position.declination.degrees == 90.0)
}

@Test func testResolutionWithNearestObjectOutOfRange() async throws {
    let square100 = CGRect(
        origin: CGPoint.zero,
        size: CGSize(width: 100.0, height: 100.0))
    let mockReversibleProjector = MockReversibleStraightThroughProjector(
        viewRect: square100)
    let mockStarId = UUID()
    let mockStarPosition = StarField.Position(
        rightAscension: Angle(degrees: 32.0),
        declination: Angle(degrees: 90.0))
    let mockStar = StarField.Star(
        id: mockStarId,
        position: mockStarPosition,
        magnitude: 5.5,
        isVariable: false,
        isMultiple: true,
        names: ["MockStar"])
    let mockNearestProvider = MockNearestObjectProvider(
        nearestObject: mockStar,
        nearestDistance: 1000.0)

    let sut = StarField.TapResolver(
        effectiveRadius: 20.0,
        projector: mockReversibleProjector,
        nearestObjectProvider: mockNearestProvider)

    // Test resolution with a nearest object that is out of range.

    let res = try #require(sut?.resolveTap(at: CGPoint(x: 28.0, y: 82.0)))
    #expect(res.position.rightAscension.degrees == 28.0)
    #expect(res.position.declination.degrees == 82.0)
    #expect(res.nearestObject == nil)
}
