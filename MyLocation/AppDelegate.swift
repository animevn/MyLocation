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

