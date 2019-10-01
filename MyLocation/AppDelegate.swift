import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer:NSPersistentContainer = {
       let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: {storeDescription, error in
            guard let error = error else {return}
            fatalError("Could load data store: \(error)")
        })
        return container
    }()
    
    lazy var managedObjectContext:NSManagedObjectContext = persistentContainer.viewContext
    
    func viewControllerShowingAlert()->UIViewController{
        let rootView = self.window!.rootViewController!
        if let presentedVC = rootView.presentedViewController{
            return presentedVC
        }else{
            return rootView
        }
    }
    
    func listenForFatalErrorCoreData(){
        NotificationCenter.default.addObserver(forName: mySaveDidFailNotification, object: nil, queue: .main, using: {notification in
            let alert = UIAlertController(
                title: "Internal Error",
                message: "There was a fatal error in the app and it cannot continue.\n\n"
                    + "Press OK to terminate the app. Sorry for the inconvenience.",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let exception = NSException(
                    name: NSExceptionName.internalInconsistencyException,
                    reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            self.viewControllerShowingAlert().present(alert, animated: true, completion: nil)
        })
    }
    
    
    
    
    func application(
        _ application:UIApplication,
        didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?) ->Bool{
        
        let controller = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = controller.viewControllers{
            let currentLocation = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocation.managedObjectContext = managedObjectContext
        }
        print(appSupportDirectory)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

