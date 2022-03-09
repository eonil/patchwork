struct DiscardingQueue<Element> {
    private var buffer = nil as Element?
    mutating func enqueue(_ x:Element) {
        buffer = x
    }
    mutating func dequeue() -> Element? {
        var result = nil as Element?
        swap(&result, &buffer)
        return result
    }
}
