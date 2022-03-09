#if canImport(UIKit)
import UIKit
/// - For manual layout, this view does not resize itself automatically. You need to call `setNeedsLayout()` to reposition subpieces.
/// - For Auto Layout, this view invalidates intrinsic size automatically. Because it's "auto" layout.
public final class LazyPieceView: UIView, LazyResizingView {
    public override init(frame x: CGRect) {
        super.init(frame: x)
        prep()
    }
    public required init?(coder x: NSCoder) {
        super.init(coder: x)
        prep()
    }
    private func prep() {
        addSubview(contentView)
        recalcSmallestFittingSize()
    }
    
    public var piece = LazyPiece.content(.space(.zero)) { didSet(x) { applyPiece(from: x, to: piece) } }
    private var contentView = LazyPieceContent.space(.zero).make()
    private var subpieceViews = [LazyPieceView]()
    private func applyPiece(from old:LazyPiece, to new:LazyPiece) {
        switch (old, new) {
        case let (.content(a), .content(b)):
            if a.typeID == b.typeID {
                /// Keep instance, update in place.
                b.update(contentView)
            }
            else {
                applyContent(b)
            }
        case let (.stitch(_), .content(b)):
            for v in subpieceViews { v.removeFromSuperview() }
            applyContent(b)
        case let (.content(_), .stitch(b)):
            contentView.removeFromSuperview()
            applyStitch(b)
        case let (.stitch(_), .stitch(b)):
            applyStitch(b)
        }
        recalcSmallestFittingSize()
    }
    private func applyContent(_ new:LazyPieceContent) {
        /// Replace with new instance.
        contentView.removeFromSuperview()
        let v = new.make()
        v.delegate = { [weak self] note in self?.process(note: note) }
        new.update(v)
        addSubview(v)
        contentView = v
    }
    private func applyStitch(_ new:LazyPieceStitch) {
        while subpieceViews.count < new.items.count {
            let v = LazyPieceView()
            v.delegate = { [weak self] note in self?.process(note: note) }
            addSubview(v)
            subpieceViews.append(v)
        }
        while subpieceViews.count > new.items.count {
            let v = subpieceViews.removeLast()
            v.removeFromSuperview()
        }
        for (v,p) in zip(subpieceViews,new.items) {
            v.piece = p
        }
    }
    
    private var cachedLayout = CachedLayout()
    private struct CachedLayout {
        var smallestFittingSize = CGSize.zero
        var contentSize = CGSize.zero
        var subpieceSizes = [CGSize]()
    }
    private func recalcSmallestFittingSize() {
        switch piece {
        case .content:
            let z = contentView.sizeThatFits(.zero)
            cachedLayout = CachedLayout(
                smallestFittingSize: z,
                contentSize: z,
                subpieceSizes: [])
        case let .stitch(stitch):
            let subpieceFittingSizes = subpieceViews.map(\.smallestFittingSize)
            let fittingSize = stitch.layout.measureFittingSize(
                stitch.axis,
                subpieceFittingSizes)
            cachedLayout = CachedLayout(
                smallestFittingSize: fittingSize,
                contentSize: fittingSize,
                subpieceSizes: subpieceFittingSizes)
        }
    }
    private func repositionPieceComponents(in bounds:CGRect) {
        switch piece {
        case .content:
            contentView.frame = bounds.midPoint.rect.insetBy(
                dx: -cachedLayout.contentSize.width / 2,
                dy: -cachedLayout.contentSize.height / 2)
        case let .stitch(stitch):
            let subpieceFrames = stitch.layout.repositionSubpieces(
                stitch.axis,
                cachedLayout.smallestFittingSize,
                cachedLayout.subpieceSizes,
                bounds)
            assert(subpieceViews.count == subpieceFrames.count)
            for (v,f) in zip(subpieceViews, subpieceFrames) {
                v.frame = f
            }
        }
    }
    public override func sizeThatFits(_: CGSize) -> CGSize { cachedLayout.smallestFittingSize }
    public override var intrinsicContentSize: CGSize { cachedLayout.smallestFittingSize }
    public override func layoutSubviews() {
        super.layoutSubviews()
        repositionPieceComponents(in: bounds)
    }
    
    private func process(note:LazyResizingViewNote) {
        switch note {
        case .needsResizing:
            recalcSmallestFittingSize()
            invalidateIntrinsicContentSize()
            delegate?(.needsResizing)
        }
    }
    
    public var delegate = nil as Delegate?
}
#endif

