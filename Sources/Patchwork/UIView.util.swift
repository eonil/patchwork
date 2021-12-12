#if canImport(UIKit)
import UIKit

extension UIView {
    func setSubviews(_ vs:[UIView]) {
        for v in subviews {
            v.removeFromSuperview()
        }
        for v in vs {
            addSubview(v)
        }
    }
}
#endif
