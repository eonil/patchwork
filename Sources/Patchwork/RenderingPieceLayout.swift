import Foundation
import CoreGraphics

struct RenderingPieceLayout {
    var frame: CGRect
    var content: RenderingPieceContent
}
enum RenderingPieceContent {
    case stitch([RenderingPieceLayout])
    case stack([RenderingPieceLayout])
    case view(OSView)
    case text(NSAttributedString)
    case image(OSImage)
    case color(OSColor)
    case space
}



extension ResolvedPiece {
    /// Internal only function to place piece in a piece-view.
    func layout(in bounds:CGRect) -> RenderingPieceLayout {
        let x = ResolvedStitch(
            version: AnyHashable(AlwaysDifferent()), 
            axis: .x,
            segments: [self])
        return x.layout(in: bounds)[0]
    }
}
extension ResolvedPieceContent {
    var fittingSize: CGSize {
        switch self {
        case let .stitch(x):    return x.fittingSize
        case let .stack(x):     return x.fittingSize
        case let .view(x):      return x.sizeThatFits(.zero)
        case let .text(x):      return x.size()
        case let .image(x):     return x.size
        case let .color(x):     return x.size
        case let .space(x):     return x
        }
    }
}
extension ResolvedStitch {
    var fittingSize: CGSize {
        switch axis {
        case .x:    return segments.lazy.map(\.content.fittingSize).reduce(.zero, composeX)
        case .y:    return segments.lazy.map(\.content.fittingSize).reduce(.zero, composeY)
        }
    }
}
extension ResolvedStack {
    var fittingSize: CGSize {
        slices.map(\.content.fittingSize).reduce(.zero, perAxisMax)
    }
}



extension ResolvedStitch {
    func layout(in bounds:CGRect) -> [RenderingPieceLayout] {
        let segmentSizes: [CGSize]
        let segmentFrames: [CGRect]
        switch axis {
        case .x:
            segmentSizes = horizontalStitchSizes(of: segments, in: bounds)
            segmentFrames = horizontalStitchingFrame(of: segmentSizes, in: bounds)
            
        case .y:
            segmentSizes = verticalStitchSizes(of: segments, in: bounds)
            segmentFrames = verticalStitchingFrame(of: segmentSizes, in: bounds)
        }
        return zip(segments,segmentFrames).map({ (p,f) in
            switch p.content {
            case let .stitch(x):
                return RenderingPieceLayout(frame: f, content: .stitch(x.layout(in: f.withOrigin(.zero))))
                
            case let .stack(x):
                return RenderingPieceLayout(frame: f, content: .stack(x.layout(in: f.withOrigin(.zero))))
                
            case let .view(x):
                return RenderingPieceLayout(frame: f, content: .view(x))
                
            case let .text(x):
                return RenderingPieceLayout(frame: f, content: .text(x))
                
            case let .image(x):
                return RenderingPieceLayout(frame: f, content: .image(x))
                
            case let .color(x):
                return RenderingPieceLayout(frame: f, content: .color(x.color))
                
            case .space:
                return RenderingPieceLayout(frame: f, content: .space)
            }
        })
    }
}

/// Resolves sizes of `segments` in `bounds`.
/// - Rigid segments will remain as they are.
/// - Flex segments with non-zero size will be scaled to fill the extra space.
/// - Flex segments with zero size will take equally portion of extra space.
///   - So, if there's any non-zero size segment, zero size segment won't be expanded.
private func horizontalStitchSizes(of segments:[ResolvedPiece], in bounds:CGRect) -> [CGSize] {
    var segmentSizes = segments.map(\.content.fittingSize)
    let sumX = segmentSizes.lazy.map(\.width).reduce(0, +)
    let extraX = bounds.width - sumX
    let flexIndicesX = segments.enumerated().filter({ _,p in p.sizing.width == .fillContainer }).map(\.offset)
    let flexSumX = flexIndicesX.lazy.map({ i in segmentSizes[i].width }).reduce(0, +)
    if flexSumX == 0 {
        /// All zero sized segment. Distribute extra space to all flex segments evenly.
        let perSegmentExtraX = extraX / CGFloat(flexIndicesX.count)
        for i in flexIndicesX {
            segmentSizes[i].width += perSegmentExtraX
        }
    }
    else {
        let flexScaleX = max(0, (flexSumX + extraX) / flexSumX)
        for (i,segment) in segments.enumerated() {
            if segment.sizing.width == .fillContainer {
                segmentSizes[i].width *= flexScaleX
            }
        }
    }
    for i in segments.indices {
        if segments[i].sizing.height == .fillContainer {
            segmentSizes[i].height = bounds.height
        }
    }
    return segmentSizes
}
/// See `horizontalStitchSizes`.
private func verticalStitchSizes(of segments:[ResolvedPiece], in bounds:CGRect) -> [CGSize] {
    var segmentSizes = segments.map(\.content.fittingSize)
    let sumY = segmentSizes.lazy.map(\.height).reduce(0, +)
    let extraY = bounds.height - sumY
    let flexIndicesY = segments.enumerated().filter({ _,p in p.sizing.height == .fillContainer }).map(\.offset)
    let flexSumY = flexIndicesY.lazy.map({ i in segmentSizes[i].height }).reduce(0, +)
    if flexSumY == 0 {
        /// All zero sized segment. Distribute extra space to all flex segments evenly.
        let perSegmentExtraY = extraY / CGFloat(flexIndicesY.count)
        for i in flexIndicesY {
            segmentSizes[i].height += perSegmentExtraY
        }
    }
    else {
        let flexScaleY = max(0, (flexSumY + extraY) / flexSumY)
        for (i,segment) in segments.enumerated() {
            if segment.sizing.height == .fillContainer {
                segmentSizes[i].height *= flexScaleY
            }
        }
    }
    for i in segments.indices {
        if segments[i].sizing.width == .fillContainer {
            segmentSizes[i].width = bounds.width
        }
    }
    return segmentSizes
}

private func horizontalStitchingFrame(of sizes:[CGSize], in bounds:CGRect) -> [CGRect] {
    let sumX = sizes.lazy.map(\.width).reduce(0, +)
    var x = bounds.minX + (bounds.width - sumX) / 2
    let y = bounds.midY
    var frames = [CGRect]()
    for size in sizes {
        let frame = CGRect(x: x, y: y - (size.height/2), width: size.width, height: size.height)
        frames.append(frame)
        x += size.width
    }
    return frames
}
private func verticalStitchingFrame(of sizes:[CGSize], in bounds:CGRect) -> [CGRect] {
    let sumY = sizes.lazy.map(\.height).reduce(0, +)
    var y = bounds.minY + (bounds.height - sumY) / 2
    let x = bounds.midX
    var frames = [CGRect]()
    for size in sizes {
        let frame = CGRect(x: x - (size.width/2), y: y, width: size.width, height: size.height)
        frames.append(frame)
        y += size.height
    }
    return frames
}








extension ResolvedStack {
    func layout(in bounds:CGRect) -> [RenderingPieceLayout] {
        let frames = slices.map { p -> CGRect in
            let fittingSize = p.content.fittingSize
            let w = p.sizing.width == .fitContent ? fittingSize.width : bounds.width
            let h = p.sizing.height == .fitContent ? fittingSize.height : bounds.height
            let v = CGVector(dx: w, dy: h)
            return bounds.midPoint.rect.inset(by: v.scaled(-0.5))
        }
        return zip(slices,frames).map({ (p,f) in
            switch p.content {
            case let .stitch(x):
                return RenderingPieceLayout(frame: f, content: .stitch(x.layout(in: f.withOrigin(.zero))))
                
            case let .stack(x):
                return RenderingPieceLayout(frame: f, content: .stack(x.layout(in: f.withOrigin(.zero))))
                
            case let .view(x):
                return RenderingPieceLayout(frame: f, content: .view(x))
                
            case let .text(x):
                return RenderingPieceLayout(frame: f, content: .text(x))
                
            case let .image(x):
                return RenderingPieceLayout(frame: f, content: .image(x))
                
            case let .color(x):
                return RenderingPieceLayout(frame: f, content: .color(x.color))
                
            case .space:
                return RenderingPieceLayout(frame: f, content: .space)
            }
        })
    }
}
