#if canImport(UIKit)
import Foundation
import UIKit

/// Renders a `Piece`.
///
/// Please note that this view won't update embedded `UIView`/`NSView` frames automatically.
/// If you need to update their frames, you need to call `setNeedsLayout` here.
open class PieceView: UIView {
    private let stitchView = PieceStitchView()
    private var resolvedPiece = ResolvedPiece(sizing: .init(horizontal: .fitContent, vertical: .fitContent), content: .space(.zero))
    
    /// Rendering configuration.
    /// - Complexity: O(n) where n is number of view in this view tree.
    /// - Note:
    ///     Setting this property is very expensive as it invalidates all existing renderings.
    ///     Call this only if absolutely needed.
    public var config = PieceViewConfig.default {
        didSet {
            let x = piece
            piece = x
        }
    }
    
    open var piece = Piece(sizing: .fillContainer, content: .space(.zero)) {
        didSet {
            if stitchView.superview == nil {
                stitchView.hostPieceView = Weak(self)
                addSubview(stitchView)
            }
            let root = Piece(
                sizing: .fillContainer,
                content: .stitch(Stitch(
                    version: AnyHashable(AlwaysDifferent()),
                    content: { [piece] in
                        StitchContent(axis: .horizontal, segments: [
                            piece,
                        ])
                    })))
            resolvedPiece = resolvedPiece.updated(with: root, config: config)
            guard case let .stitch(x) = resolvedPiece.content else { return }
            stitchView.render(x)
            setNeedsLayout()
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
public struct PieceViewConfig {
    public var frameRounding = false
    /// Enlarges text to fit point grid.
    public var textSizeCeiling = false
    
    /// Global default value for piece view config.
    /// - You can change this value. New value will be applied to all subsequenty created `PieceView` instances.
    public static var `default` = PieceViewConfig() {
        willSet { assert(Thread.isMainThread) }
    }
    public static var pointGridFitting: PieceViewConfig {
        PieceViewConfig(
            frameRounding: true,
            textSizeCeiling: true)
    }
}






private protocol PieceContentViewProtocol: AnyObject {
    var hostPieceView: Weak<PieceView> { get set }
}
private final class PieceStitchView: UIView, PieceContentViewProtocol {
    var hostPieceView = Weak<PieceView>()
    
    private var resolvedStitch: ResolvedStitch
    private var segmentLayouts = [RenderingPieceLayout]()
    private var segmentViews = [UIView?]()
    
    private var lastLayoutBounds = CGRect.zero
    private var lastLayout = [RenderingPieceLayout]()
    private var sourceRendered = false
    
    override init(frame x: CGRect) {
        resolvedStitch = ResolvedStitch(
            version: AnyHashable(AlwaysDifferent()),
            axis: .horizontal,
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
            updateContent(host: hostPieceView, from: a?.content, to: b.content, at: i, in: &segmentViews)
        }
        resolvedStitch = newResolvedStitch
        sourceRendered = false
        setNeedsLayout()
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        resolvedStitch.precomputedFittingSize
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        guard !sourceRendered || lastLayoutBounds != bounds else { return }
        
        let layout = resolvedStitch.layout(in: bounds)
        assert(layout.count == segmentViews.count)
        
        for (layout,view) in zip(layout,segmentViews) {
            view?.frame = (hostPieceView.object?.config.frameRounding ?? false)
                ? layout.frame.rounding
                : layout.frame
        }
        
        sourceRendered = true
        lastLayoutBounds = bounds
        lastLayout = layout
    }
}

private final class PieceStackView: UIView, PieceContentViewProtocol {
    var hostPieceView = Weak<PieceView>()
    
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
            updateContent(host: hostPieceView, from: a?.content, to: b.content, at: i, in: &sliceViews)
        }
        resolvedStack = newResolvedStack
        setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = resolvedStack.layout(in: bounds)
        assert(layout.count == sliceViews.count)
        
        for (layout,view) in zip(layout,sliceViews) {
            view?.frame = (hostPieceView.object?.config.frameRounding ?? false)
                ? layout.frame.rounding
                : layout.frame
        }
    }
}








private extension UIView {
    func updateContent(host:Weak<PieceView>, from old:ResolvedPieceContent?, to new:ResolvedPieceContent, at i:Int, in segmentViews: inout [UIView?]) {
        switch (old, new) {
        case let (.some(.stitch(_)), .stitch(bb)):
            assert(segmentViews.at(i) is PieceStitchView)
            guard let v = segmentViews.at(i) as? PieceStitchView else { return }
            v.hostPieceView = host
            v.render(bb)
        case let (_, .stitch(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = PieceStitchView()
            v.hostPieceView = host
            addSubview(v)
            segmentViews[i] = v
            v.render(bb)
        
        case let (.some(.stack(_)), .stack(bb)):
            assert(segmentViews.at(i) is PieceStackView)
            guard let v = segmentViews.at(i) as? PieceStackView else { return }
            v.hostPieceView = host
            v.render(bb)
        case let (_, .stack(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = PieceStackView()
            v.hostPieceView = host
            addSubview(v)
            segmentViews[i] = v
            v.render(bb)
        
        case let (.some(.view(aa)), .view(bb)):
            assert(segmentViews.at(i) is UIView)
            if aa.view !== bb.view {
                aa.view.removeFromSuperview()
                addSubview(bb.view)
                segmentViews[i] = bb.view
            }
        case let (_, .view(bb)):
            segmentViews[i]?.removeFromSuperview()
            addSubview(bb.view)
            segmentViews[i] = bb.view
            
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
            v.attributedText = bb.text
        case let (_, .text(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = UILabel()
            addSubview(v)
            segmentViews[i] = v
            v.attributedText = bb.text
            
        case let (.some(.color(_)), .color(bb)):
            assert(segmentViews.at(i) is UIView)
            guard let v = segmentViews.at(i) as? UIView else { return }
            if v.backgroundColor != bb.color {
                v.backgroundColor = bb.color
            }
            if v.layer.cornerRadius != bb.cornerRadius {
                v.layer.cornerRadius = bb.cornerRadius
            }
            
        case let (_, .color(bb)):
            segmentViews[i]?.removeFromSuperview()
            let v = UIView()
            addSubview(v)
            segmentViews[i] = v
            v.backgroundColor = bb.color
            v.layer.cornerRadius = bb.cornerRadius

        case (.some(.space), .space):
            assert(segmentViews.at(i) == .some(nil))
        case (_, .space):
            segmentViews[i]?.removeFromSuperview()
            segmentViews[i] = nil
            
        case let (.some(.custom(aa)), .custom(bb)):
            assert(segmentViews.at(i) is UIView)
            if aa.view !== bb.view {
                aa.view.removeFromSuperview()
                addSubview(bb.view)
                segmentViews[i] = bb.view
                Test.increment(path: \.customViewDeinstallationCount)
                Test.increment(path: \.customViewInstallationCount)
            }
        case let (_, .custom(bb)):
            segmentViews[i]?.removeFromSuperview()
            addSubview(bb.view)
            segmentViews[i] = bb.view
            Test.increment(path: \.customViewInstallationCount)
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
#endif
