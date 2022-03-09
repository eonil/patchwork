public struct LazyPieceContent {
    public var typeID: AnyHashable
    public var make: () -> LazyResizingView
    public var update: (LazyResizingView) -> Void
    public init(typeID ty:AnyHashable, make c:@escaping() -> LazyResizingView, update x:@escaping(LazyResizingView) -> Void) {
        typeID = ty
        make = c
        update = x
    }
}

#if canImport(UIKit)
import UIKit
public extension LazyPieceContent {
    static func space(_ z:CGSize) -> LazyPieceContent {
        color(.clear, size: z, cornerRadius: 0)
    }
    static func color(_ c:UIColor, size z:CGSize, cornerRadius r:CGFloat = 0) -> LazyPieceContent {
        final class LazyPieceColorContentView: UIView, LazyResizingView {
            var definedSize = CGSize.zero
            convenience init(backgroundColor c:UIColor, size z:CGSize, cornerRadius r:CGFloat) {
                self.init(frame: .zero)
                backgroundColor = c
                definedSize = z
                layer.cornerRadius = r
            }
            override func sizeThatFits(_ size: CGSize) -> CGSize { definedSize }
            var delegate = nil as Delegate?
        }
        return LazyPieceContent(
            typeID: ObjectIdentifier(LazyPieceColorContentView.self),
            make: { LazyPieceColorContentView(backgroundColor: c, size: z, cornerRadius: r) },
            update: { view in
                assert(view is LazyPieceColorContentView)
                guard let view = view as? LazyPieceColorContentView else { return }
                view.backgroundColor = c
                view.definedSize = z
                view.layer.cornerRadius = r
            })
    }
    static func image(_ g:UIImage, size z:CGSize? = nil, mode m:UIView.ContentMode = .center, cornerRadius r:CGFloat = 0) -> LazyPieceContent {
        let z = z ?? g.size
        final class LazyPieceImageContentView: UIImageView, LazyResizingView {
            var definedSize = CGSize.zero
            convenience init(image g:UIImage, size z:CGSize, cornerRadius r:CGFloat) {
                self.init(frame: .zero)
                image = g
                definedSize = z
                layer.cornerRadius = r
            }
            override func sizeThatFits(_ size: CGSize) -> CGSize { definedSize }
            var delegate = nil as Delegate?
        }
        return LazyPieceContent(
            typeID: ObjectIdentifier(LazyPieceImageContentView.self),
            make: { LazyPieceImageContentView(image: g, size: z, cornerRadius: r) },
            update: { view in
                assert(view is LazyPieceImageContentView)
                guard let view = view as? LazyPieceImageContentView else { return }
                view.image = g
                view.definedSize = z
                view.layer.cornerRadius = r
            })
    }
    static func text(_ s:String, alignment a:NSTextAlignment, font f:UIFont, color c:UIColor) -> LazyPieceContent {
        return LazyPieceContent(
            typeID: ObjectIdentifier(LazyTextView.self),
            make: { LazyTextView() },
            update: { view in
                assert(view is LazyTextView)
                guard let view = view as? LazyTextView else { return }
                let ps = NSMutableParagraphStyle()
                ps.alignment = a
                view.text = NSAttributedString(string: s, attributes: [
                    .font: f,
                    .foregroundColor: c,
                    .paragraphStyle: ps,
                ])
            })
    }
}
#endif
