#if canImport(UIKit)
import UIKit

/// Content-defined self-sizing with no ambiguity.
///
/// Supports these features with no layout ambiguity.
/// - Content-defined self-sizing.
/// - Container-defined stretching.
///   - Content views are constrained to have equal sized at very low priority. (`1`)
///   - If they have defined size at higher priority, they will keep their own size.
///   - Otherwise, they will be sized equally.
/// - Self-size can be defined only in one axis.
///   - Size of size-undefined axis will be set to `0` at no priority.
///   - You can set size of the axis yourself by adding more constraints.
///   - Don't forget that you can stretch `StitchView` in any axis at any time.
/// - Perpendicular axis sizing is constrained to be stitched to both edges at `.defaultLow` priority.
///   - If your segment view has defined size at stronger priority, it will be respected.
/// - Smooth animation.
///   - Coordinates are well adjusted for proper animation support.
///
public class StitchView: UIView {
    private var state = State()
    private struct State {
        var axis = .vertical as NSLayoutConstraint.Axis
        var spacing = 0 as CGFloat
        var segmentViews = [UIView]()
    }
    private var derivation = Derivation()
    private struct Derivation {
        var interSegmentSpaceGuides = [UILayoutGuide]()
        var interSegmentSpaceGuideLengthConstraints = [NSLayoutConstraint]()
        var containerEdgeSegmentStitchingConstraints = [NSLayoutConstraint]()
    }
    
    public override init(frame x: CGRect) {
        super.init(frame: x)
        translatesAutoresizingMaskIntoConstraints = false
    }
    public required init?(coder: NSCoder) {
        unsupported()
    }
    public override class var requiresConstraintBasedLayout: Bool { true }
}
extension StitchView {
    public var axis: NSLayoutConstraint.Axis {
        get { state.axis }
        set(x) {
            let old = state
            var new = old
            new.axis = x
            performTransition(from: old, to: new)
            state = new
        }
    }
    public var spacing: CGFloat {
        get { state.spacing }
        set(x) {
            let old = state
            var new = old
            new.spacing = x
            performTransition(from: old, to: new)
            state = new
        }
    }
    public var segmentViews: [UIView] {
        get { state.segmentViews }
        set(x) {
            let old = state
            var new = old
            new.segmentViews = x
            performTransition(from: old, to: new)
            state = new
        }
    }
}
extension StitchView {
    private func performTransition(from old:State, to new:State) {
        let requiresFullRemake = old.axis != new.axis || !Array.equalRefs(old.segmentViews, new.segmentViews)
        if requiresFullRemake {
            /// Replace evrything.
            NSLayoutConstraint.deactivate(derivation.interSegmentSpaceGuideLengthConstraints)
            NSLayoutConstraint.deactivate(derivation.containerEdgeSegmentStitchingConstraints)
            for g in derivation.interSegmentSpaceGuides { removeLayoutGuide(g) }
            for v in old.segmentViews { v.removeFromSuperview() }
            
            if !new.segmentViews.isEmpty {
                derivation = Derivation()
                switch new.axis {
                case .horizontal:
                    for (a,b) in zip(new.segmentViews.dropLast(), new.segmentViews.dropFirst()) {
                        let g = UILayoutGuide()
                        let cs = [
                            g.leadingAnchor.constraint(equalTo: a.trailingAnchor),
                            g.widthAnchor.constraint(greaterThanOrEqualToConstant: new.spacing),
                            g.widthAnchor.constraint(equalToConstant: new.spacing, priority: UILayoutPriority(1)),
                            g.heightAnchor.constraint(equalToConstant: 0),
                            g.trailingAnchor.constraint(equalTo: b.leadingAnchor),
                            g.centerYAnchor.constraint(equalTo: centerYAnchor),
                        ]
                        derivation.interSegmentSpaceGuides.append(g)
                        derivation.interSegmentSpaceGuideLengthConstraints.append(contentsOf: cs)
                    }
                    derivation.containerEdgeSegmentStitchingConstraints.append(contentsOf: [
                        new.segmentViews.first!.leadingAnchor.constraint(equalTo: leadingAnchor),
                        new.segmentViews.last!.trailingAnchor.constraint(equalTo: trailingAnchor),
                    ])
                    for v in new.segmentViews {
                        derivation.containerEdgeSegmentStitchingConstraints.append(contentsOf: [
                            v.topAnchor.constraint(equalTo: topAnchor, priority: .defaultLow),
                            v.bottomAnchor.constraint(equalTo: bottomAnchor, priority: .defaultLow),
                        ])
                    }
                    for v in new.segmentViews { addSubview(v) }
                    for g in derivation.interSegmentSpaceGuides { addLayoutGuide(g) }
                    NSLayoutConstraint.activate(derivation.containerEdgeSegmentStitchingConstraints)
                    NSLayoutConstraint.activate(derivation.interSegmentSpaceGuideLengthConstraints)
                case .vertical:
                    for (a,b) in zip(new.segmentViews.dropLast(), new.segmentViews.dropFirst()) {
                        let g = UILayoutGuide()
                        let cs = [
                            g.topAnchor.constraint(equalTo: a.bottomAnchor),
                            g.heightAnchor.constraint(greaterThanOrEqualToConstant: new.spacing),
                            g.heightAnchor.constraint(equalToConstant: new.spacing, priority: UILayoutPriority(1)),
                            g.widthAnchor.constraint(equalToConstant: 0),
                            g.bottomAnchor.constraint(equalTo: b.topAnchor),
                            g.centerXAnchor.constraint(equalTo: centerXAnchor),
                        ]
                        derivation.interSegmentSpaceGuides.append(g)
                        derivation.interSegmentSpaceGuideLengthConstraints.append(contentsOf: cs)
                    }
                    derivation.containerEdgeSegmentStitchingConstraints.append(contentsOf: [
                        new.segmentViews.first!.topAnchor.constraint(equalTo: topAnchor),
                        new.segmentViews.last!.bottomAnchor.constraint(equalTo: bottomAnchor),
                    ])
                    for v in new.segmentViews {
                        let cs = [
                            v.leadingAnchor.constraint(equalTo: leadingAnchor, priority: .defaultLow),
                            v.trailingAnchor.constraint(equalTo: trailingAnchor, priority: .defaultLow),
                        ]
                        derivation.containerEdgeSegmentStitchingConstraints.append(contentsOf: cs)
                    }
                    for v in new.segmentViews { addSubview(v) }
                    for g in derivation.interSegmentSpaceGuides { addLayoutGuide(g) }
                    NSLayoutConstraint.activate(derivation.containerEdgeSegmentStitchingConstraints)
                    NSLayoutConstraint.activate(derivation.interSegmentSpaceGuideLengthConstraints)
                default:
                    assertionFailure("Unknown axis value is not supported.")
                    break
                }
            }
        }
        else {
            /// Perform partial/optimized update.
            if old.spacing != new.spacing {
                for c in derivation.interSegmentSpaceGuideLengthConstraints {
                    c.constant = new.spacing
                }
            }
        }
    }
}
private extension Array where Element == UIView {
    static func equalRefs(_ a:Self, _ b:Self) -> Bool {
        guard a.count == b.count else { return false }
        for (aa,bb) in zip(a,b) {
            guard aa === bb else { return false }
        }
        return true
    }
}
#endif
