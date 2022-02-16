#if DEBUG
/// Test support facility.
enum Test {
    static private(set) var stat = Stat()
    struct Stat {
        var customViewInstantiationCount = 0
        var customViewInstallationCount = 0
        var customViewDeinstallationCount = 0
    }
}
extension Test {
    static func reset() {
        stat = Stat()
    }
    static func increment(path: WritableKeyPath<Stat,Int>) {
        stat[keyPath: path] += 1
    }
}
#else
enum Test {
}
extension Test {
    static func reset() {}
    static func increment(path: WritableKeyPath<Stat,Int>) {}
}
#endif
