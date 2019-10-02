import UIKit
import MapKit
import CoreData

class MapViewController:UIViewController{
   
    @IBOutlet weak var mvMap:MKMapView!
    
    @IBAction func onLocationsClick(_ sender: UIBarButtonItem){
        
    }
    
    @IBAction func onUserClick(_ sender: UIBarButtonItem){
        let region = MKCoordinateRegion(center: mvMap.userLocation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mvMap.setRegion(region, animated: true)
    }
    
    var manageObjectContext:NSManagedObjectContext!
    var locations = [Location]()
    
    private func updateLocation(){
        mvMap.removeAnnotations(locations)
        let fetch = NSFetchRequest<Location>()
        fetch.entity = Location.entity()
        do{
            locations = try manageObjectContext.fetch(fetch)
            mvMap.addAnnotations(locations)
        }catch{
            fatalCoreDataError(error: error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocation()
    }
    
}
