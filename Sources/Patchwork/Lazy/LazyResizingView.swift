public protocol LazyResizingView: OSView {
    var delegate: Delegate? { get set }
    typealias Delegate = (LazyResizingViewNote) -> Void
}
public enum LazyResizingViewNote {
    case needsResizing
}
