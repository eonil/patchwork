#if canImport(UIKit)
import UIKit

/// Abstracted common interface to pieces.
/// - Though this is openly defined, piece is not supposed to be extensible.
/// - Do not define your own type of piece user code. It won't work.
public protocol Piece {
    var id: AnyHashable? { get }
    var version: AnyHashable? { get }
    var layout: Layout { get }
}
public struct Layout: Equatable {
    var defaultWidth = CGFloat?.none
    var defaultHeight = CGFloat?.none
    var minWidth = CGFloat?.none
    var minHeight = CGFloat?.none
    var maxWidth = CGFloat?.none
    var maxHeight = CGFloat?.none
}
public extension Layout {
    func spawn(for v:UIView) -> [NSLayoutConstraint] {
        func constrain(_ a:NSLayoutConstraint.Attribute, _ r:NSLayoutConstraint.Relation, _ c:CGFloat, _ p:UILayoutPriority) -> NSLayoutConstraint {
            let z = NSLayoutConstraint(item: v, attribute: a, relatedBy: r, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: c)
            z.priority = p
            return z
        }
        var cs = [NSLayoutConstraint]()
        if let x = defaultWidth { cs.append(constrain(.width, .equal, x, .defaultHigh)) }
        if let x = defaultHeight { cs.append(constrain(.height, .equal, x, .defaultHigh)) }
        if let x = minWidth { cs.append(constrain(.width, .greaterThanOrEqual, x, .defaultHigh)) }
        if let x = minHeight { cs.append(constrain(.height, .greaterThanOrEqual, x, .defaultHigh)) }
        if let x = maxWidth { cs.append(constrain(.width, .lessThanOrEqual, x, .defaultHigh)) }
        if let x = maxHeight { cs.append(constrain(.height, .lessThanOrEqual, x, .defaultHigh)) }
        return cs
    }
}

public struct Space: Piece {
    public var id = AnyHashable?.none
    public var version = AnyHashable?.none
    public var layout = Layout()
}

public struct Color: Piece {
    public var id = AnyHashable?.none
    public var version = AnyHashable?.none
    public var layout = Layout()
    public var content: UIColor
}

public struct Text: Piece {
    public var id = AnyHashable?.none
    public var version = AnyHashable?.none
    public var layout = Layout()
    public var content = [Section]()
}

public struct Image: Piece {
    public var id = AnyHashable?.none
    public var version = AnyHashable?.none
    public var layout = Layout()
    public var content: UIImage
}

public struct Stack: Piece {
    public var id = AnyHashable?.none
    public var version = AnyHashable?.none
    public var layout = Layout()
    public var axis: NSLayoutConstraint.Axis
    public var subpieces: [Piece]
}

/// Represents lazily loaded list.
/// - `List` assumes that you have huge amount of item in source data.
/// - And loads only a small subset of them.
/// - `List` performs diff to find out duplicated portions.
///   - Diff is performed based on ID & version.
/// - If there's any change in on-screen rendered items,
///   - List performs nice animations automatically designted in `transition` property.
/// - Otherwise, list replaces changed items under-the-hood silently.
public struct List: Piece {
    public var id = AnyHashable?.none
    public var version = AnyHashable?.none
    public var layout = Layout()
    public var items = [Piece]()
    public var transition = Transition.animation
    public enum Transition {
        case none
        case animation
    }
}

private struct ImplicitPieceID: Hashable {
    private static var seed = 0
    private var num: Int
    init() {
        let x = NSLock()
        x.lock()
        ImplicitPieceID.seed += 1
        num = ImplicitPieceID.seed
        x.unlock()
    }
}
#endif
