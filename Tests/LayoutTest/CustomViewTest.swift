#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class CustomViewTest: XCTestCase {
    func test1() {
        let a = PieceView()
        a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        a.piece = red()
        
        assertSnapshot(matching: a, as: .image)
    }
}

private func red() -> Piece {
    enum Marker {}
    typealias RedInstance = UIView & RedProtocol
    return Piece(horizontal: .fillContainer, vertical: .fillContainer, content: .custom(CustomPieceContent(
        kind: ObjectIdentifier(Marker.self),
        instantiate: makeRed,
        update: { instance in (instance as! RedInstance).red = true })))
    
    /// Below code doesn't work. Throws run-time error.
//    return Piece(horizontal: .fillContainer, vertical: .fillContainer, content: .view(
//        kind: ObjectIdentifier(Marker.self),
//        make: makeRed,
//        step: { instance in instance.red = true }))
}

private func makeRed() -> UIView & RedProtocol {
    RedView()
}
private protocol RedProtocol: AnyObject {
    var red: Bool { get set }
}
private final class RedView: UIView, RedProtocol {
    var red = false
}

#endif
