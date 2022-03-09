#if canImport(UIKit)
import UIKit

extension UIView {
    var smallestFittingSize: CGSize { sizeThatFits(.zero) }
}
#endif
