#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class UIStackViewTest: XCTestCase {
    /// Though `UIStackView` claims to support content-defined self-sizing,
    /// it will remain as **ambiguous** without extra constraints.
    /// That means there's no way to verify ambiguity of layout.
    /// Therefore we regard `UIStackView` not supporting content-defined self-sizing.
    /// - Note: Tested on iOS 15 Simulator.
    func testContentDefinedSizeUnsupported() {
        /// https://stackoverflow.com/a/34855001/246776
        let w = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        let a = UIStackView()
        let b = UIView()
        let c = UIView()
        XCTAssertFalse(w.hasAmbiguousLayout)
        XCTAssertFalse(a.hasAmbiguousLayout)
        XCTAssertFalse(b.hasAmbiguousLayout)
        XCTAssertFalse(c.hasAmbiguousLayout)
        
        w.translatesAutoresizingMaskIntoConstraints = true
        w.addSubview(a)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.axis = .vertical
        a.spacing = 0
        a.distribution = .equalSpacing
        a.alignment = .center
        a.addArrangedSubview(b)
        a.addArrangedSubview(c)
        b.translatesAutoresizingMaskIntoConstraints = false
        c.translatesAutoresizingMaskIntoConstraints = false
        /// You need all commented constraints to make `UIStackView` to support content-defined self-sizing.
        NSLayoutConstraint.activate([
            a.leadingAnchor.constraint(equalTo: w.leadingAnchor),
            a.topAnchor.constraint(equalTo: w.topAnchor),
//            b.topAnchor.constraint(equalTo: a.topAnchor),
//            b.leadingAnchor.constraint(equalTo: a.leadingAnchor),
//            b.trailingAnchor.constraint(equalTo: a.trailingAnchor),
            b.widthAnchor.constraint(equalToConstant: 100),
            b.heightAnchor.constraint(equalToConstant: 50),
//            b.bottomAnchor.constraint(equalTo: c.topAnchor),
            c.widthAnchor.constraint(equalToConstant: 100),
            c.heightAnchor.constraint(equalToConstant: 200),
//            c.leadingAnchor.constraint(equalTo: a.leadingAnchor),
//            c.trailingAnchor.constraint(equalTo: a.trailingAnchor),
//            c.bottomAnchor.constraint(equalTo: a.bottomAnchor),
        ])
        print(w.traceAutoLayout())
        XCTAssertTrue(w.hasAmbiguousLayout)
        XCTAssertTrue(a.hasAmbiguousLayout)
        XCTAssertTrue(b.hasAmbiguousLayout)
        XCTAssertTrue(c.hasAmbiguousLayout)
        XCTAssertEqual(a.systemLayoutSizeFitting(.zero), CGSize(width: 100, height: 250))
    }
}
#endif

//#if canImport(AppKit)
//#error("macOS is not supported.")
//#endif
