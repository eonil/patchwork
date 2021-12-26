#if canImport(UIKit)
import UIKit
import ObjectiveC

extension UIView {
    func assertNoCommonIssue() {
        assertNoAmbiguity()
        assertNoAutoresizingMaskConstraints()
    }
    func assertNoAmbiguity() {
        assert(!hasAmbiguousLayout)
        for v in subviews {
            v.assertNoAmbiguity()
        }
    }
    func assertNoAutoresizingMaskConstraints() {
        for c in constraints {
            let name = NSStringFromClass(type(of: c))
            assert(name != "NSAutoresizingMaskLayoutConstraint")
        }
        for v in subviews {
            v.assertNoAutoresizingMaskConstraints()
        }
    }
    func traceAutoLayout() -> String {
        let x = self as NSObject
        let s = Selector(("_autolayoutTrace"))
        let r = x.perform(s)!
        return r.takeUnretainedValue() as! String
    }
}
#endif
