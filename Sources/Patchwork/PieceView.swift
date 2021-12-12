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
    private var root = PieceStackView() as PieceNodeView
    private var viewTable = [AnyHashable: PieceNodeView]()
    public convenience init(source:Piece) {
        self.init()
        addSubview(root)
    }
    public func view(for id:AnyHashable) -> UIView? {
        viewTable[id]
    }
    var piece: Piece {
        get { root.piece }
        set(p) {
            let newRoot = rendered(p, onto: root, with: &viewTable)
            if newRoot !== root {
                root.removeFromSuperview()
                addSubview(root)
            }
        }
    }
}

/// Renderes a piece to onto current view.
/// - If current view is a proper type view, current view will be rendered and returned.
/// - If current view is not proper type view, a new view will be created, rendered and returned.
private func rendered(_ p:Piece, onto v:PieceNodeView?, with table: inout [AnyHashable:PieceNodeView]) -> PieceNodeView {
    let vty = matchingViewType(for: p)
    let v = { () -> PieceNodeView in
        if let v = v {
            if type(of: v) === vty { return v }
        }
        return vty.init()
    }()
    if let p = p as? Color {
        let v = v as! PieceColorView
        if v.source.id != p.id || v.source.version != p.version {
            v.source = p
            v.backgroundColor = p.content
        }
        if let id = p.id {
            table[id] = v
        }
        return v
    }
    if let p = p as? Text {
        let v = v as! PieceTextView
        if v.source.id != p.id || v.source.version != p.version {
            v.source = p
            v.attributedText = p.spawn()
        }
        if let id = p.id {
            table[id] = v
        }
    }
    if let p = p as? Image {
        let v = v as! PieceImageView
        if v.source.id != p.id || v.source.version != p.version {
            v.source = p
            v.image = p.content
        }
        if let id = p.id {
            table[id] = v
        }
    }
    if let p = p as? Stack {
        let v = v as! PieceStackView
        if v.source.id != p.id || v.source.version != p.version {
            v.setSubviews([])
            v.source = p
            v.axis = p.axis
            for sp in p.subpieces {
                let sv = rendered(sp, onto: nil, with: &table)
                v.addSubview(sv)
            }
        }
        if let id = p.id {
            table[id] = v
        }
    }
    fatalError("Unknown type piece.")
}

private func matchingViewType(for p:Piece) -> PieceNodeView.Type {
    if p is Color { return PieceColorView.self }
    if p is Text { return PieceTextView.self }
    if p is Image { return PieceImageView.self }
    if p is Stack { return PieceStackView.self }
    if p is List { return PieceListView.self }
    fatalError("Cannot find a matching view type for the piece.")
}
#endif
