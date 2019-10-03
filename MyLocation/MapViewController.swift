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
        
        let extra = 1.2
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

extension MapViewController:MKMapViewDelegate{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editLocation"{
            let navigation = segue.destination as! UINavigationController
            let controller = navigation.topViewController as! LocationDetailViewController
            controller.managedObjectContext = manageObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
    
    @objc private func showLocationDetail(sender:UIButton){
        performSegue(withIdentifier: "editLocation", sender: sender)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is Location else {return nil}
        
        let identifier = "location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil{
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1)
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetail), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
        
        if let annotationView = annotationView{
            annotationView.annotation = annotation
            
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.firstIndex(of: annotation as! Location){
                button.tag = index
            }
        }
        return annotationView
        
        
    }
    
}

extension MapViewController:UINavigationBarDelegate{
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
