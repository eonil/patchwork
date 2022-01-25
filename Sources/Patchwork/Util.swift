import CoreGraphics

func unsupported() -> Never {
    fatalError("Unsupported.")
}

public struct AlwaysDifferent: Hashable {
    public init() {}
    public static func == (_:AlwaysDifferent, _:AlwaysDifferent) -> Bool { false }
    public static func != (_:AlwaysDifferent, _:AlwaysDifferent) -> Bool { true }
}

func composeX(_ a:CGSize, _ b:CGSize) -> CGSize {
    CGSize(width: a.width + b.width, height: max(a.height,b.height))
}
func composeY(_ a:CGSize, _ b:CGSize) -> CGSize {
    CGSize(width: max(a.width, b.width), height: a.height + b.height)
}

extension CGPoint {
    func translated(_ v:CGVector) -> CGPoint {
        CGPoint(x: x + v.dx, y: y + v.dy)
    }
    var rect: CGRect {
        CGRect(origin: self, size: .zero)
    }
    var vector: CGVector {
        CGVector(dx: x, dy: y)
    }
}
extension CGSize {
    func rect(with origin:CGPoint) -> CGRect {
        CGRect(origin: origin, size: self)
    }
    var vector: CGVector {
        CGVector(dx: width, dy: height)
    }
    func scaled(_ v:CGFloat) -> CGSize {
        CGSize(width: width * v, height: height * v)
    }
}
extension CGRect {
    func withOrigin(_ v:CGPoint) -> CGRect {
        CGRect(origin: v, size: size)
    }
    func translated(_ v:CGVector) -> CGRect {
        CGRect(origin: origin.translated(v), size: size)
    }
    func translatedX(_ v:CGFloat) -> CGRect {
        translated(CGVector(dx: v, dy: 0))
    }
    func translatedY(_ v:CGFloat) -> CGRect {
        translated(CGVector(dx: 0, dy: v))
    }
    /// Extended new rect based at `origin` point.
    func extendedX(_ v:CGFloat) -> CGRect {
        CGRect(origin: origin, size: CGSize(width: width + v, height: height))
    }
    /// Extended new rect based at `origin` point.
    func extendedY(_ v:CGFloat) -> CGRect {
        CGRect(origin: origin, size: CGSize(width: width, height: height + v))
    }
    /// Scaled new rect based at `origin` point.
    func scaledX(_ v:CGFloat) -> CGRect {
        CGRect(origin: origin, size: CGSize(width: width * v, height: height))
    }
    /// Scaled new rect based at `origin` point.
    func scaledY(_ v:CGFloat) -> CGRect {
        CGRect(origin: origin, size: CGSize(width: width, height: height * v))
    }
    func inset(by v:CGVector) -> CGRect {
        insetBy(dx: v.dx, dy: v.dy)
    }
    
    var midPoint: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
extension CGVector {
    func scaled(_ v:CGFloat) -> CGVector {
        CGVector(dx: dx * v, dy: dy * v)
    }
}

func perAxisMax(_ a:CGSize, _ b:CGSize) -> CGSize {
    CGSize(width: max(a.width, b.width), height: max(a.height, b.height))
}






