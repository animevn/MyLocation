import UIKit
import MapKit
import CoreData

class MapViewController:UIViewController{
   
    @IBOutlet weak var mvMap:MKMapView!
    
    @IBAction func onLocationsClick(){
        let theRegion = region(for: locations)
        mvMap.setRegion(theRegion, animated: true)
    }
    
    @IBAction func onUserClick(){
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
    
    private func regionIfNoPlace()->MKCoordinateRegion{
        return MKCoordinateRegion(
            center: mvMap.userLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
    }
    
    private func regionIfOnePlace(annotation:MKAnnotation)->MKCoordinateRegion{
        return MKCoordinateRegion(
            center: annotation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
    }
    
    private func foundTopLeftBottomRightOfAllPlaces(annotations:[MKAnnotation])
            ->(topLeft:CLLocationCoordinate2D, bottomRight:CLLocationCoordinate2D){
        
        var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
        for annotation in annotations{
            topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
            topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
            bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
            bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
        }
        return (topLeft, bottomRight)
    }
    
    private func regionIfMoreThanOnePlace(annotations:[MKAnnotation])->MKCoordinateRegion{
        let (topLeft, bottomRight) = foundTopLeftBottomRightOfAllPlaces(annotations: annotations)
        
        let center = CLLocationCoordinate2D(
            latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude)/2,
            longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude)/2)
        
        let extra = 1.1
        let span = MKCoordinateSpan(
            latitudeDelta: abs(topLeft.latitude - bottomRight.latitude)*extra,
            longitudeDelta: abs(topLeft.longitude - bottomRight.longitude)*extra)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
      
        let region:MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = regionIfNoPlace()
        case 1:
            region = regionIfOnePlace(annotation: annotations[0])
        default:
            region = regionIfMoreThanOnePlace(annotations: annotations)
            
        }
        return mvMap.regionThatFits(region)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocation()
        if !locations.isEmpty{
            onLocationsClick()
        }
    }
    
}
