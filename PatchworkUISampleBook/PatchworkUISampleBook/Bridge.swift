import Foundation
import UIKit
import Patchwork

@UIApplicationMain
final class Bridge: NSObject, UIApplicationDelegate {
    private var root = Root?.none
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        root = Root()
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        root = nil
    }
}

final class Root {
    let mainWindow = UIWindow(frame: UIScreen.main.bounds)
    let mainNC = UINavigationController()
    let homeVC = HomeVC()
    let sampleVCs = [
        makeSampleVC(AnimationSample())
    ]
    
    init() {
        mainWindow.backgroundColor = .systemBackground
        mainWindow.makeKeyAndVisible()
        mainWindow.rootViewController = mainNC
        mainNC.viewControllers = [homeVC]
        mainNC.navigationBar.prefersLargeTitles = true
        homeVC.items = sampleVCs.map(\.name)
        homeVC.action = { [weak self] i in self?.processSelect(i) }
    }
    deinit {
        
    }
    func processSelect(_ i:Int) {
        mainNC.pushViewController(sampleVCs[i].vc, animated: true)
    }
}

final class HomeVC: UITableViewController {
    var items = [String]()
    var action = { _ in } as (Int) -> Void
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "UI Sample Book"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        action(indexPath.row)
    }
}
func makeSampleVC(_ v:UIView) -> (name:String, vc:UIViewController) {
    final class SampleVC: UIViewController {
        weak var contentView: UIView?
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            view.backgroundColor = .systemBackground
            contentView?.frame = view.safeAreaLayoutGuide.layoutFrame
        }
    }
    let n = NSStringFromClass(type(of: v))
    let vc = SampleVC()
    vc.navigationItem.title = n
    vc.contentView = v
    vc.view.addSubview(v)
    v.backgroundColor = .systemBackground
    return (n,vc)
}

final class AnimationSample: UIView {
    private let pieceView = PieceView()
    private let updateButton = UIButton()
    private var count = 0
    override init(frame x: CGRect) {
        super.init(frame: x)
        install()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        pieceView.frame = bounds
    }
    
    private func install() {
        addSubview(pieceView)
        updateButton.setTitle("Update", for: .normal)
        updateButton.addTarget(self, action: #selector(update(_:)), for: .touchUpInside)
        pieceView.piece = makePiece(0)
    }
    @objc
    func update(_:AnyObject?) {
        count += 1
        pieceView.piece = makePiece(count)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    private func makePiece(_ n:Int) -> Piece {
        let b = updateButton
        return divY {
            stackZ(height: .fitContent) {
                color(.blue)
                view(b)
            }
            stackZ(height: .fitContent) {
                color(.red)
                wrapY {
                    space(width: 10, height: 10)
                    wrapX {
                        space()
                        wrapX {
                            labe("AAA")
                            space(width: CGFloat(n) * 30, height: CGFloat(n) * 30)
                            labe("BBB")
                        }
                        space()
                    }
                    space(width: 10, height: 10)
                }
            }
            stackZ {
                color(.black)
                color(.green, width: 10, height: 10)
            }
        }
    }
}

func labe(_ s:String, size: CGFloat = UIFont.labelFontSize) -> Piece {
    text(NSAttributedString(string: s, attributes: [
        .font: UIFont.systemFont(ofSize: size),
        .foregroundColor: UIColor.lightText,
    ]))
}

func row(@ArrayBuilder<Piece> content c:() -> [Piece]) -> Piece {
    divX {
        space()
//        c()
        space()
    }
}
