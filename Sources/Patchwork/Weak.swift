struct Weak<Object:AnyObject> {
    weak var object = Object?.none
    init(_ o:Object? = nil) { object = o }
}
