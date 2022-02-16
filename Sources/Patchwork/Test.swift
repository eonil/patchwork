/// Test support facility.
enum Test {
    struct Stat {
        var customViewInstantiationCount = 0
        var customViewInstallationCount = 0
        var customViewDeinstallationCount = 0
    }
}

#if DEBUG
extension Test {
    static private(set) var stat = Stat()
    static func reset() {
        stat = Stat()
    }
    static func increment(path: WritableKeyPath<Stat,Int>) {
        stat[keyPath: path] += 1
    }
}
#else
extension Test {
    static func reset() {}
    static func increment(path: WritableKeyPath<Stat,Int>) {}
}
#endif
