import CoreGraphics

public struct LazyPieceStitch {
    public var axis: Axis
    public enum Axis { case x, y }
    
    public var layout = LazyPieceStitchLayout.tightCentering
    public var items: [LazyPiece]
    public init(axis a:Axis, layout l:LazyPieceStitchLayout, items xs:[LazyPiece]) {
        axis = a
        layout = l
        items = xs
    }
}

public struct LazyPieceStitchLayout {
    public var measureFittingSize: Measure
    public typealias Measure = (_ axis:LazyPieceStitch.Axis, _ subpieceFittingSizes:[CGSize]) -> CGSize
    public var repositionSubpieces: Reposition
    public typealias Reposition = (_ axis:LazyPieceStitch.Axis, _ fittingSize:CGSize, _ subpieceFittingSizes:[CGSize], _ bounds:CGRect) -> [CGRect]
    public init(measure m:@escaping Measure, reposition p:@escaping Reposition) {
        measureFittingSize = m
        repositionSubpieces = p
    }
}
public extension LazyPieceStitchLayout {
    static let tightCentering = LazyPieceStitchLayout(measure: measureTight, reposition: repositionCenter)
    static let tightLeading = LazyPieceStitchLayout(measure: measureTight, reposition: repositionLeading)
    static let tightTrailing = LazyPieceStitchLayout(measure: measureTight, reposition: repositionTrailing)
}
private extension LazyPieceStitchLayout {
    static func measureTight(axis:LazyPieceStitch.Axis, subpieceFittingSizes:[CGSize]) -> CGSize {
        var w = 0 as CGFloat
        var h = 0 as CGFloat
        var zs = [CGSize]()
        zs.reserveCapacity(subpieceFittingSizes.count)
        switch axis {
        case .x:
            for z in subpieceFittingSizes {
                w = w + z.width
                h = max(h, z.height)
                zs.append(z)
            }
        case .y:
            for z in subpieceFittingSizes {
                w = max(w, z.width)
                h = h + z.height
                zs.append(z)
            }
        }
        return CGSize(width: w, height: h)
    }
    static func repositionCenter(axis:LazyPieceStitch.Axis, fittingSize:CGSize, subpieceFittingSizes:[CGSize], in bounds:CGRect) -> [CGRect] {
        var fs = [CGRect]()
        fs.reserveCapacity(subpieceFittingSizes.count)
        switch axis {
        case .x:
            var x = bounds.midX - (fittingSize.width / 2)
            let y = bounds.midY
            for z in subpieceFittingSizes {
                let f = CGRect(
                    x: x,
                    y: y - (z.height / 2),
                    width: z.width,
                    height: z.height)
                fs.append(f)
                x += z.width
            }
        case .y:
            let x = bounds.midX
            var y = bounds.midY - (fittingSize.height / 2)
            for z in subpieceFittingSizes {
                let f = CGRect(
                    x: x - (z.width / 2),
                    y: y,
                    width: z.width,
                    height: z.height)
                fs.append(f)
                y += z.height
            }
        }
        return fs
    }
    static func repositionLeading(axis:LazyPieceStitch.Axis, fittingSize:CGSize, subpieceFittingSizes:[CGSize], in bounds:CGRect) -> [CGRect] {
        var subpieceFrames = repositionCenter(axis: axis, fittingSize: fittingSize, subpieceFittingSizes: subpieceFittingSizes, in: bounds)
        var x = bounds.minX
        for i in subpieceFrames.indices {
            subpieceFrames[i].origin.x = x
            x += subpieceFrames[i].width
        }
        return subpieceFrames
    }
    static func repositionTrailing(axis:LazyPieceStitch.Axis, fittingSize:CGSize, subpieceFittingSizes:[CGSize], in bounds:CGRect) -> [CGRect] {
        var subpieceFrames = repositionCenter(axis: axis, fittingSize: fittingSize, subpieceFittingSizes: subpieceFittingSizes, in: bounds)
        var x = bounds.maxX - fittingSize.width
        for i in subpieceFrames.indices {
            subpieceFrames[i].origin.x = x
            x += subpieceFrames[i].width
        }
        return subpieceFrames
    }
}

