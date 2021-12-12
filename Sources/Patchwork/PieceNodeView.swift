#if canImport(UIKit)
import UIKit

protocol PieceNodeView: UIView {
    init()
    var piece: Piece { get }
}
extension PieceNodeView {
    /// DFS. O(n) at worst.
    func findView(for id:AnyHashable) -> UIView? {
        if piece.id == id { return self }
        for sv in subviews {
            if let sv = sv as? PieceNodeView {
                if let z = sv.findView(for: id) {
                    return z
                }
            }
        }
        return nil
    }
}

final class PieceSpaceView: UIView, PieceNodeView {
    private var localConstraints = [NSLayoutConstraint]()
    var source = Space() {
        didSet(old) {
            if old.layout != source.layout {
                NSLayoutConstraint.deactivate(localConstraints)
                localConstraints = source.layout.spawn(for: self)
                NSLayoutConstraint.activate(localConstraints)
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    var piece: Piece { source }
}
final class PieceColorView: UIView, PieceNodeView {
    private var localConstraints = [NSLayoutConstraint]()
    var source = Color(content: .clear) {
        didSet(old) {
            if old.layout != source.layout {
                NSLayoutConstraint.deactivate(localConstraints)
                localConstraints = source.layout.spawn(for: self)
                NSLayoutConstraint.activate(localConstraints)
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    var piece: Piece { source }
}

final class PieceImageView: UIImageView, PieceNodeView {
    private var localConstraints = [NSLayoutConstraint]()
    var source = Image(content: UIImage()) {
        didSet(old) {
            if old.layout != source.layout {
                NSLayoutConstraint.deactivate(localConstraints)
                localConstraints = source.layout.spawn(for: self)
                NSLayoutConstraint.activate(localConstraints)
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    var piece: Piece { source }
}

final class PieceTextView: UITextView, PieceNodeView {
    private var localConstraints = [NSLayoutConstraint]()
    var source = Text() {
        didSet(old) {
            if old.layout != source.layout {
                NSLayoutConstraint.deactivate(localConstraints)
                localConstraints = source.layout.spawn(for: self)
                NSLayoutConstraint.activate(localConstraints)
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    var piece: Piece { source }
}

final class PieceStackView: UIStackView, PieceNodeView {
    private var localConstraints = [NSLayoutConstraint]()
    var source = Stack(axis: .vertical, subpieces: []) {
        didSet(old) {
            if old.layout != source.layout {
                NSLayoutConstraint.deactivate(localConstraints)
                localConstraints = source.layout.spawn(for: self)
                NSLayoutConstraint.activate(localConstraints)
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    var piece: Piece { source }
}

final class PieceListView: UIStackView, PieceNodeView {
    private var localConstraints = [NSLayoutConstraint]()
    var source = List() {
        didSet(old) {
            if old.layout != source.layout {
                NSLayoutConstraint.deactivate(localConstraints)
                localConstraints = source.layout.spawn(for: self)
                NSLayoutConstraint.activate(localConstraints)
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    var piece: Piece { source }
}
#endif
