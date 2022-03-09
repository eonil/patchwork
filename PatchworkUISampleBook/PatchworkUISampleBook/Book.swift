import UIKit

struct Book {
    var pages = [
        Page(name: "Sample 1", content: Sample1VC.self)
    ]
}
struct Page {
    var name: String
    var content: UIViewController.Type
}
