#if canImport(UIKit)
import UIKit

final class LazyTextView: UIImageView, LazyResizingView {
    var text = Content() { didSet { applyText() } }
    typealias Content = NSAttributedString
    private var queue = DiscardingQueue<Content>()
    private func applyText() {
        queue.enqueue(text)
        startRendering()
    }

    private var isRendering = false
    private func startRendering() {
        assert(Thread.isMainThread)
        if !isRendering {
            isRendering = true
            if let content = queue.dequeue() {
                let s = window?.screen.scale ?? 1
                let x = { content }
                Task { [weak self] in
                    assert(Thread.isMainThread)
                    let result = await TextRendering.run(params: TextRendering.Params(
                        pointScaleInPixels: s,
                        containerSize: nil,
                        lazyTextContent: x))
                    self?.endRendering(result: result)
                }
            }
        }
    }
    private func endRendering(result:Result<TextRendering.Product, TextRendering.Issue>) {
        assert(Thread.isMainThread)
        contentMode = .center
        switch result {
        case let .failure(issue):
            image = nil
            Report.delegate?(issue)
            #if DEBUG
            assert(false, issue.localizedDescription)
            #endif
        case let .success(product):
            if let bitmapImage = product.bitmapImage {
                image = UIImage(cgImage: bitmapImage, scale: product.params.pointScaleInPixels, orientation: .up)
            }
            else {
                image = UIImage()
            }
        }
        delegate?(.needsResizing)
        isRendering = false
        startRendering()
    }
    override func sizeThatFits(_: CGSize) -> CGSize {
        image?.size ?? .zero
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyText()
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        applyText()
    }
    
    var delegate = nil as Delegate?
}
extension LazyTextView {
    enum Report {
        static var delegate = nil as Delegate?
        typealias Delegate = (TextRendering.Issue) -> Void
    }
}
#endif
