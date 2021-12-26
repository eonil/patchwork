#if canImport(UIKit)
import UIKit
extension NSLayoutDimension {
    func constraint(equalToConstant c: CGFloat, priority p:UILayoutPriority) -> NSLayoutConstraint {
        let z = constraint(equalToConstant: c)
        z.priority = p
        return z
    }
}
extension NSLayoutXAxisAnchor {
    func constraint(equalTo a:NSLayoutXAxisAnchor, priority p:UILayoutPriority) -> NSLayoutConstraint {
        let z = constraint(equalTo: a)
        z.priority = p
        return z
    }
}
extension NSLayoutYAxisAnchor {
    func constraint(equalTo a:NSLayoutYAxisAnchor, priority p:UILayoutPriority) -> NSLayoutConstraint {
        let z = constraint(equalTo: a)
        z.priority = p
        return z
    }
}
#endif
