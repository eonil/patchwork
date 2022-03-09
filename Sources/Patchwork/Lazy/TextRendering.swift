import Foundation
import CoreGraphics
import CoreText

enum TextRendering {
    struct Params {
        var pointScaleInPixels: CGFloat
        var containerSize: CGSize?
        var lazyTextContent: Text
        typealias Text = @TextRenderingContext () -> NSAttributedString
    }
    struct Product {
        var params: Params
        /// Produced bitmap image.
        /// - This can be `nil` only if bitmap is zero sized. 
        var bitmapImage: CGImage?
    }
    enum Issue: Error {
        case graphicsContextCreationFailure
        case graphicsContextMakeImageFailure
    }
    
    @TextRenderingContext
    static func run(params:Params) -> Result<Product,Issue> {
        assert(!Thread.isMainThread)
        let text = params.lazyTextContent()
        let framesetter = CTFramesetterCreateWithAttributedString(text)
        let preciseTextSize = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0, length: text.length),
            nil,
            CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            nil)
        let imageBoxRect = CGRect(
            x: 0,
            y: 0,
            width: ceil(preciseTextSize.width),
            height: ceil(preciseTextSize.height))
        /// Note that CoreText will respect alignment defined in paragraph-styles,
        /// and it requires empty area to adjust drawing locations.
        /// So we use full point width rather than sub-point positions in X-axis.
        /// CoreText does not have anything for vertical alignment.
        /// So we narrow down height to actual point height to keep it at center.
        let textBoundingRect = CGRect(
            x: 0,
            y: (imageBoxRect.height - preciseTextSize.height) / 2,
            width: imageBoxRect.width,
            height: preciseTextSize.height)
        let textBoundingPath = CGPath(rect: textBoundingRect, transform: nil)
        let frame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: text.length),
            textBoundingPath,
            nil)

        let transformScale: CGFloat
        if let z = params.containerSize {
            let transformScaleX = z.width / imageBoxRect.width
            let transformScaleY = z.height / imageBoxRect.height
            transformScale = min(transformScaleX, transformScaleY)
        }
        else {
            transformScale = 1
        }
        let bitmapWidthInPixels = Int(ceil(imageBoxRect.width * params.pointScaleInPixels))
        let bitmapHeightInPixels = Int(ceil(imageBoxRect.height * params.pointScaleInPixels))
        guard bitmapWidthInPixels > 0 && bitmapHeightInPixels > 0 else { return .success(Product(
            params: params,
            bitmapImage: nil)) }
        let context = CGContext(
            data: nil,
            width: bitmapWidthInPixels,
            height: bitmapHeightInPixels,
            bitsPerComponent: 8,
            bytesPerRow: bitmapWidthInPixels * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = context else { return .failure(.graphicsContextCreationFailure) }
        context.scaleBy(x: params.pointScaleInPixels, y: params.pointScaleInPixels)
        context.scaleBy(x: transformScale, y: transformScale)
        CTFrameDraw(frame, context)
        guard let image = context.makeImage() else { return .failure(.graphicsContextMakeImageFailure) }
        return .success(Product(
            params: params,
            bitmapImage: image))
    }
}

@globalActor
struct TextRenderingContext {
    static var shared = ActorType()
    actor ActorType {}
}
