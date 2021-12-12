#if canImport(UIKit)
import UIKit

/// A view hosting piece tree.
/// - This view renders piece tree as is.
/// - You can render different piece trees.
/// - This view infers continuitiy of pieces by type, ID, and topology.
///   - If ID and version are same, underlying instance will be kept and continues.
///   - Otherwise, existing instance will be deleted and a new one will be created.
///   - ID and version will not be considered in continuity comparison if set to `nil`.
public final class PieceView: UIView {
    private var root = PieceSpaceView() as PieceNodeView
    private var localConstraints = [NSLayoutConstraint]()
    public convenience init(with p:Piece) {
        self.init()
        addSubview(root)
        piece = p
    }
    public func view(for id:AnyHashable) -> UIView? {
        root.findView(for: id)
    }
    var piece: Piece {
        get { root.piece }
        set(p) {
            let newRoot = rendered(p, onto: root)
            if newRoot !== root {
                NSLayoutConstraint.deactivate(localConstraints)
                localConstraints.removeAll()
                root.removeFromSuperview()
                root = newRoot
                addSubview(root)
                root.translatesAutoresizingMaskIntoConstraints = false
                localConstraints = [
                    root.leadingAnchor.constraint(equalTo: leadingAnchor),
                    root.trailingAnchor.constraint(equalTo: trailingAnchor),
                    root.topAnchor.constraint(equalTo: topAnchor),
                    root.bottomAnchor.constraint(equalTo: bottomAnchor),
                ]
                NSLayoutConstraint.activate(localConstraints)
            }
        }
    }
}

/// Renderes a piece to onto current view.
/// - If current view is a proper type view, current view will be rendered and returned.
/// - If current view is not proper type view, a new view will be created, rendered and returned.
private func rendered(_ p:Piece, onto v:PieceNodeView?) -> PieceNodeView {
    let vty = matchingViewType(for: p)
    let v = { () -> PieceNodeView in
        if let v = v {
            if type(of: v) === vty { return v }
        }
        return vty.init()
    }()
    if let p = p as? Space {
        var v = v as! PieceSpaceView
        if needsObjectReinstantiation(old: v.source, new: p) { v = .init() }
        if needsDataReassignment(old: v.source, new: p) {
            v.source = p
        }
        return v
    }
    if let p = p as? Color {
        var v = v as! PieceColorView
        if needsObjectReinstantiation(old: v.source, new: p) { v = .init() }
        if needsDataReassignment(old: v.source, new: p) {
            v.source = p
            v.backgroundColor = p.content
        }
        return v
    }
    if let p = p as? Text {
        var v = v as! PieceTextView
        if needsObjectReinstantiation(old: v.source, new: p) { v = .init() }
        if needsDataReassignment(old: v.source, new: p) {
            v.source = p
            v.attributedText = p.spawn()
        }
        return v
    }
    if let p = p as? Image {
        var v = v as! PieceImageView
        if needsObjectReinstantiation(old: v.source, new: p) { v = .init() }
        if needsDataReassignment(old: v.source, new: p) {
            v.source = p
            v.image = p.content
        }
        return v
    }
    if let p = p as? Stack {
        var v = v as! PieceStackView
        if needsObjectReinstantiation(old: v.source, new: p) { v = .init() }
        if needsDataReassignment(old: v.source, new: p) {
            for sv in v.arrangedSubviews {
                v.removeArrangedSubview(sv)
            }
            v.source = p
            v.axis = p.axis
            v.alignment = .center
            for sp in p.subpieces {
                let sv = rendered(sp, onto: nil)
                v.addArrangedSubview(sv)
            }
        }
        return v
    }
    fatalError("Unknown type piece.")
}

private func matchingViewType(for p:Piece) -> PieceNodeView.Type {
    if p is Space { return PieceSpaceView.self }
    if p is Color { return PieceColorView.self }
    if p is Text { return PieceTextView.self }
    if p is Image { return PieceImageView.self }
    if p is Stack { return PieceStackView.self }
    if p is List { return PieceListView.self }
    fatalError("Cannot find a matching view type for the piece.")
}
private func needsObjectReinstantiation(old a:Piece, new b:Piece) -> Bool {
    if let id1 = a.id, let id2 = b.id, id1 != id2 { return true }
    return false
}
private func needsDataReassignment(old a:Piece, new b:Piece) -> Bool {
    a.id == nil || b.id == nil || !(a.version != nil && b.version != nil && a.version == b.version)
}
#endif
