#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class CustomPieceTest: XCTestCase {
    func test1() {
        Test.reset()
        let p = PieceView()
        p.piece = divY {
            myLabel("AAA", .green)
            myLabel("BBB", .brown)
            color(.red)
        }
        XCTAssertEqual(Test.stat.customViewInstantiationCount, 2)
        XCTAssertEqual(Test.stat.customViewInstallationCount, 2)
        XCTAssertEqual(Test.stat.customViewDeinstallationCount, 0)
        p.piece = divY {
            myLabel("CCC", .green)
            myLabel("DDD", .brown)
            color(.red)
        }
        XCTAssertEqual(Test.stat.customViewInstantiationCount, 2)
        XCTAssertEqual(Test.stat.customViewInstallationCount, 2)
        XCTAssertEqual(Test.stat.customViewDeinstallationCount, 0)
        p.backgroundColor = .gray
        p.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        assertSnapshot(matching: p, as: .image)
    }
}

private func myLabel(_ s:String, _ bg:UIColor) -> Piece {
    final class MyLabel: UIView {
        let impl = UILabel()
        override func didMoveToWindow() {
            super.didMoveToWindow()
            addSubview(impl)
            impl.clipsToBounds = true
            impl.textColor = .blue
        }
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            CGSize(width: 40, height: 10)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            impl.frame = bounds
        }
    }
    return Piece(horizontal: .fitContent, vertical: .fitContent, content: .view(content: ViewPieceContent<MyLabel>(
        instantiate: { MyLabel() },
        step: { label in
            label.impl.text = s
            label.backgroundColor = bg
        })))
}

#endif
