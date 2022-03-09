import Foundation
import UIKit
import Patchwork

final class PhoneRoot {
    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let navigation = UINavigationController()
    private let menu = MenuVC()
    private let sample1 = Sample1VC()
    init() {
        window.makeKeyAndVisible()
        window.rootViewController = navigation
        navigation.viewControllers = [menu]
    }
}

struct Book {
    var pages = [
        Page(name: "Sample 1", content: Sample1VC.self),
        Page(name: "Sample 2", content: Sample2VC.self),
    ]
}
struct Page {
    var name: String
    var content: UIViewController.Type
}

final class MenuVC: UIViewController, UITableViewDelegate {
    private let tableView = UITableView()
    private var dataSource = nil as DataSource?
    private typealias DataSource = UITableViewDiffableDataSource<Int,Int>
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        let book = Book()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = UIListContentConfiguration.cell()
            content.text = book.pages[indexPath.item].name
            cell.contentConfiguration = content
            return cell
        })
        tableView.automaticallyAdjustsScrollIndicatorInsets = true
        tableView.dataSource = dataSource
        tableView.delegate = self
        var snapshot = NSDiffableDataSourceSnapshot<Int,Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(book.pages.indices), toSection: 0)
        dataSource?.apply(snapshot)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Book().pages[indexPath.item].content.init()
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class Sample1VC: UIViewController {
    private let pieceView = LazyPieceView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(pieceView)
        let x = StitchY {
            StitchX {
                Color(.red, size: CGSize(width: 10, height: 10))
                Text("M", alignment: .center, font: .monospacedDigitSystemFont(ofSize: 24, weight: .regular), color: .red)
                Color(.red, size: CGSize(width: 10, height: 10))
            }
        }
        pieceView.piece = x.piece
        pieceView.delegate = { [weak self] note in
            switch note {
            case .needsResizing:
                self?.view.setNeedsLayout()
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieceView.setNeedsLayout()
        pieceView.frame = view.bounds
    }
}

final class Sample2VC: UIViewController {
    private let pieceView = LazyPieceView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(pieceView)
        let x = StitchY {
            StitchX {
                Color(.red, size: CGSize(width: 10, height: 10))
                Text("Foo", alignment: .center, font: .monospacedDigitSystemFont(ofSize: 24, weight: .regular), color: .red)
                Color(.red, size: CGSize(width: 10, height: 10))
            }
            StitchX {
                Color(.red, size: CGSize(width: 10, height: 10))
                Text("Bar", alignment: .center, font: .monospacedDigitSystemFont(ofSize: 24, weight: .regular), color: .red)
                Color(.red, size: CGSize(width: 10, height: 10))
            }
            StitchX {
                Color(.red, size: CGSize(width: 10, height: 10))
                Text("Jar", alignment: .center, font: .monospacedDigitSystemFont(ofSize: 24, weight: .regular), color: .red)
                Color(.red, size: CGSize(width: 10, height: 10))
            }
        }
        pieceView.piece = x.piece
        pieceView.delegate = { [weak self] note in
            switch note {
            case .needsResizing:
                self?.view.setNeedsLayout()
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieceView.frame = view.bounds
        pieceView.layoutIfNeeded()
        pieceView.setNeedsLayout()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) { [weak self] in
            self?.pieceView.layoutIfNeeded()
        }

    }
}

