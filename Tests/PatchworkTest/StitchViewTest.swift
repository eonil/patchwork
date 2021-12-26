#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class StitchViewTest: XCTestCase {
    func testProofOfConcept() {
        let w = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        let a = UIView()
        let b = UIView()
        let g = UILayoutGuide()
        let c = UIView()
        w.addSubview(a)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.addSubview(b)
        a.addLayoutGuide(g)
        a.addSubview(c)
        b.translatesAutoresizingMaskIntoConstraints = false
        c.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            a.leadingAnchor.constraint(equalTo: w.leadingAnchor, priority: UILayoutPriority(1)),
            a.topAnchor.constraint(equalTo: w.topAnchor, priority: UILayoutPriority(1)),
            
            a.leadingAnchor.constraint(equalTo: b.leadingAnchor, priority: UILayoutPriority(1)),
            b.trailingAnchor.constraint(equalTo: g.leadingAnchor, priority: UILayoutPriority(1)),
            g.widthAnchor.constraint(equalToConstant: 10, priority: UILayoutPriority(1)),
            g.heightAnchor.constraint(equalToConstant: 0, priority: UILayoutPriority(1)),
            g.trailingAnchor.constraint(equalTo: c.leadingAnchor, priority: UILayoutPriority(1)),
            c.trailingAnchor.constraint(equalTo: a.trailingAnchor, priority: UILayoutPriority(1)),
            
            a.topAnchor.constraint(equalTo: b.topAnchor, priority: UILayoutPriority(1)),
            a.bottomAnchor.constraint(equalTo: b.bottomAnchor, priority: UILayoutPriority(1)),
            g.centerYAnchor.constraint(equalTo: a.centerYAnchor, priority: UILayoutPriority(1)),
            a.topAnchor.constraint(equalTo: c.topAnchor, priority: UILayoutPriority(1)),
            a.bottomAnchor.constraint(equalTo: c.bottomAnchor, priority: UILayoutPriority(1)),
            
            b.widthAnchor.constraint(equalToConstant: 100),
            b.heightAnchor.constraint(equalToConstant: 100),
            c.widthAnchor.constraint(equalToConstant: 100),
            c.heightAnchor.constraint(equalToConstant: 100),
        ])
        XCTAssertFalse(w.hasAmbiguousLayout)
    }
    func testSelfSizingWithNoAmbiguity() {
        let w = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        let a = StitchView()
        let b = UIView()
        let c = UIView()
        w.addSubview(a)
        a.axis = .horizontal
        a.spacing = 10
        a.segmentViews = [b,c]
        b.translatesAutoresizingMaskIntoConstraints = false
        c.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            a.leadingAnchor.constraint(equalTo: w.leadingAnchor),
            a.topAnchor.constraint(equalTo: w.topAnchor),
            b.widthAnchor.constraint(equalToConstant: 100),
            b.heightAnchor.constraint(equalToConstant: 100),
            c.widthAnchor.constraint(equalToConstant: 100),
            c.heightAnchor.constraint(equalToConstant: 100),
        ])
        XCTAssertFalse(a.hasAmbiguousLayout)
    }
}
#endif
