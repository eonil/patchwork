import Foundation
import UIKit

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
    init() {
        mainWindow.makeKeyAndVisible()
    }
}

final class VC1: UIViewController {
}
