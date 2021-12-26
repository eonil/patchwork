import Foundation
import UIKit

/// Renders a `Piece`.
///
/// Please note that this view won't update embedded `UIView`/`NSView` frames automatically.
/// If you need to update their frames, you need to call `setNeedsLayout` here.
open class PieceView: UIView {
    private let stitchView = PieceStitchView()
    open var piece = Piece() {
        didSet {
            if stitchView.superview == nil {
                addSubview(stitchView)
            }
            let root = Piece(
                sizing: .flex,
                content: .stitch(Stitch(
                    version: AnyHashable(AlwaysDifferent()),
                    content: { [piece] in
                        StitchContent(axis: .x, segments: [
                            piece,
                        ])
                    })))
            let resolved = ResolvedPiece(from: root)
            guard case let .stitch(x) = resolved.content else { return }
            stitchView.render(x)
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        stitchView.frame = bounds
    }
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        stitchView.sizeThatFits(size)
    }
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}









private final class PieceStitchView: UIView {
    private var resolvedStitch: ResolvedStitch
    private var segmentLayouts = [RenderingPieceLayout]()
    private var segmentViews = [UIView?]()
    
    override init(frame x: CGRect) {
        resolvedStitch = ResolvedStitch(
            version: AnyHashable(AlwaysDifferent()),
            axis: .x,
            segments: [])
        super.init(frame: x)
    }
    required init?(coder: NSCoder) {
        unsupported()
    }
    func render(_ x:ResolvedStitch) {
        let oldResolvedStitch = resolvedStitch
        let newResolvedStitch = x
        guard oldResolvedStitch.version != newResolvedStitch.version else { return }

        /// Match segment view holding array length.
        for v in segmentViews[min(segmentViews.count,newResolvedStitch.segments.count)...] { v?.removeFromSuperview() }
        segmentViews.setLength(newResolvedStitch.segments.count)
        
        /// Build up.
        for i in newResolvedStitch.segments.indices {
            let a = oldResolvedStitch.segments.at(i)
            let b = newResolvedStitch.segments[i]
            updateContent(from: a?.content, to: b.content, at: i, in: &segmentViews)
        }
        resolvedStitch = newResolvedStitch
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = resolvedStitch.layout(in: bounds)
        assert(layout.count == segmentViews.count)
        
        for (layout,view) in zip(layout,segmentViews) {
            view?.frame = layout.frame
        }
    }
}

private final class PieceStackView: UIView {
    private var resolvedStack: ResolvedStack
    private var sliceLayouts = [RenderingPieceLayout]()
    private var sliceViews = [UIView?]()
    
    override init(frame x: CGRect) {
        resolvedStack = ResolvedStack(
            version: AnyHashable(AlwaysDifferent()),
            slices: [])
        super.init(frame: x)
    }
    required init?(coder: NSCoder) {
        unsupported()
    }
    func render(_ x:ResolvedStack) {
        let oldResolvedStack = resolvedStack
        let newResolvedStack = x
        guard oldResolvedStack.version != newResolvedStack.version else { return }

        /// Match segment view holding array length.
        for v in sliceViews[min(sliceViews.count,newResolvedStack.slices.count)...] { v?.removeFromSuperview() }
        sliceViews.setLength(newResolvedStack.slices.count)
        
        /// Build up.
        for i in newResolvedStack.slices.indices {
            let a = oldResolvedStack.slices.at(i)
            let b = newResolvedStack.slices[i]
            updateContent(from: a?.content, to: b.content, at: i, in: &sliceViews)
        }
        resolvedStack = newResolvedStack
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = resolvedStack.layout(in: bounds)
        assert(layout.count == sliceViews.count)
        
        for (layout,view) in zip(layout,sliceViews) {
            view?.frame = layout.frame
        }
    }
}








private extension UIView {
    func updateContent(from old:ResolvedPieceContent?, to new:ResolvedPieceContent, at i:Int, in segmentViews: inout [UIView?]) {
        switch (old, new) {
        case let (.some(.stitch(_)), .stitch(bb)):
            assert(segmentViews.at(i) is PieceStitchView)
            guard let v = segmentViews.at(i) as? PieceStitchView else { return }
            v.render(bb)
        case let (_, .stitch(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = PieceStitchView()
            addSubview(v)
            segmentViews[i] = v
            v.render(bb)
        
        case let (.some(.stack(_)), .stack(bb)):
            assert(segmentViews.at(i) is PieceStackView)
            guard let v = segmentViews.at(i) as? PieceStackView else { return }
            v.render(bb)
        case let (_, .stack(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = PieceStackView()
            addSubview(v)
            segmentViews[i] = v
            v.render(bb)
        
        case let (.some(.view(aa)), .view(bb)):
            assert(segmentViews.at(i) is UIView)
            if aa !== bb {
                aa.removeFromSuperview()
                addSubview(bb)
            }
        case let (_, .view(bb)):
            segmentViews[i]?.removeFromSuperview()
            addSubview(bb)
            segmentViews[i] = bb
            
        case let (.some(.image(_)), .image(bb)):
            assert(segmentViews.at(i) is UIImageView)
            guard let v = segmentViews.at(i) as? UIImageView else { return }
            v.image = bb
        case let (_, .image(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = UIImageView()
            addSubview(v)
            segmentViews[i] = v
            v.image = bb
            
        case let (.some(.text(_)), .text(bb)):
            assert(segmentViews.at(i) is UILabel)
            guard let v = segmentViews.at(i) as? UILabel else { return }
            v.attributedText = bb
        case let (_, .text(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = UILabel()
            addSubview(v)
            segmentViews[i] = v
            v.attributedText = bb
            
        case let (.some(.color(_)), .color(bb)):
            assert(segmentViews.at(i) is UIView)
            guard let v = segmentViews.at(i) as? UIView else { return }
            v.backgroundColor = bb.color
        case let (_, .color(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = UIView()
            addSubview(v)
            segmentViews[i] = v
            v.backgroundColor = bb.color

        case (.some(.space), .space):
            assert(segmentViews.at(i) == nil)
        case (_, .space):
            segmentViews[i]?.removeFromSuperview()
            segmentViews[i] = nil
        }
    }
}
private extension Array {
    func at(_ i:Int) -> Element? {
        guard indices.contains(i) else { return nil }
        return self[i]
    }
    mutating func removeIfAvailable(at i:Int) {
        guard indices.contains(i) else { return }
        remove(at: i)
    }
}
private extension Array where Element == UIView? {
    mutating func setLength(_ c:Int) {
        if c < count {
            removeSubrange(c...)
        }
        else {
            append(contentsOf: repeatElement(nil, count: c - count))
        }
    }
}
