#if DEBUG
extension Piece {
    func assertValidity() {
        switch content {
        case let .text(x):
            for i in 0..<x.length {
                let attrs = x.attributes(at: i, effectiveRange: nil)
                let font = attrs[.font]
                assert(font != nil, "all characters must be covered by `.font` attribute")
            }
        default:
            break
        }
    }
}
#endif
