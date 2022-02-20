import Foundation

public struct PieceViewConfig {
    public var frameRounding = false
    /// Enlarges text to fit point grid.
    public var textSizeCeiling = false
    
    /// Global default value for piece view config.
    /// - You can change this value. New value will be applied to all subsequenty created `PieceView` instances.
    public static var `default` = PieceViewConfig() {
        willSet { assert(Thread.isMainThread) }
    }
    public static var pointGridFitting: PieceViewConfig {
        PieceViewConfig(
            frameRounding: true,
            textSizeCeiling: true)
    }
}
