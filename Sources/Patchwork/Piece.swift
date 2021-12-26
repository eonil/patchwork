//#if canImport(UIKit)
//import UIKit
//
//struct Piece {
//    var width = CGFloat?.none
//    var height = CGFloat?.none
//    var content = PieceContent.space
//}
//enum PieceContent {
//    case space
//    case color(UIColor)
//    case text(NSAttributedString)
//    case image(UIImage)
//    case button(UIButton, action:() -> Void)
//    
//    case stitch([Piece])
//    case division(distribution:UIStackView.Distribution, alignment:UIStackView.Alignment)
//    
//    case version(AnyHashable, rendition:() -> Void)
//    case view(UIView, reload:() -> Void)
//}
//
//final class PieceView: UIView {
//    private var renderedPiece = Piece(content: .space)
//    func set(piece p:Piece) {
//        
//    }
//}
//
//
//final class PieceViewHost {
//    var contentView = UIView()
//    func set(piece p:Piece) {
//        
//    }
//    private func renderTransition(from old:Piece, to new:Piece) {
//        switch (old.content, new.content) {
//        case (.space, .space):
//            break
//        case let (.color(_), .color(b)):
//            assert(contentView is PieceColorView)
//            guard let v = contentView as? PieceColorView else { break }
//            v.set(content: b)
//            
//        case let (_, .color(b)):
//            contentView?.removeFromSuperview()
//            contentView = nil
//            let v = PieceColorView()
//            v.set(content: b)
//            contentView = v
//            
//        case let (_, .division(distribution, alignment)):
//            contentView?.removeFromSuperview()
//            contentView = nil
//            let v = PieceStitchView()
//            v.set(content: <#T##[Piece]#>)
//            v.set(content: )
//            contentView = v
//        }
//    }
//}
//
//protocol PieceContentView: UIView {
//    associatedtype Content
//    func set(content c:Content)
//}
//final class PieceColorView: UIView {
//    func set(content c:UIColor) {
//        backgroundColor = c
//    }
//}
//final class PieceTextView: UILabel, PieceContentView {
//    func set(content c:NSAttributedString) {
//        attributedText = c
//    }
//}
//final class PieceStitchView: StitchView {
//    private var renderedPieces = [Piece]()
//    private var subpieceHosts = [PieceViewHost]()
//    func set(content ps:[Piece]) {
//        let old = renderedPieces
//        let new = ps
//        if old.isEmpty && new.isEmpty { return }
//        
//        for i in 0..<min(old.count, new.count) {
//            subpieceHosts[i].set(piece: ps[i])
//        }
//        if old.count < new.count {
//            /// Appended.
//            for i in old.count..<new.count {
//                let h = PieceViewHost()
//                h.set(piece: ps[i])
//                subpieceHosts.append(h)
//            }
//        }
//        if new.count < old.count {
//            /// Removed.
//            subpieceHosts.removeSubrange(new.count..<old.count)
//        }
//        set(segments: subpieceHosts.map(\.contentView))
//    }
//}
//final class PieceDivisionView: UIStackView {
//    
//}
//
//
//private func makePieceContentView(from c:PieceContent) -> UIView {
//    switch c {
//    case .space:
//    case let .color(x):
//    }
//}
//
//#endif
