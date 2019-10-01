import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbLattitude: UILabel!
    @IBOutlet weak var lbLongtitude: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var bnTag: UIButton!
    @IBOutlet weak var bnGet: UIButton!
    
    let manager = CLLocationManager()
    var location:CLLocation?
    var isSeachingLocation = false
    var locationError:Error?
    
    var geocoder = CLGeocoder()
    var placemark:CLPlacemark?
    var isReversingGeocoder = false
    var geocoderError:Error?
    
    var managedObjectContext:NSManagedObjectContext!
    
    private func updateAddressLabel(){
        if let placemark = placemark{
            lbAddress.text = string(from: placemark)
        }else if isReversingGeocoder{
            lbAddress.text = "Searching for place ..."
        }else if geocoderError != nil{
            lbAddress.text = "Error searching for place ..."
        }else if !isSeachingLocation{
            lbAddress.text = ""
        }else{
            lbAddress.text = "Place not found"
        }
    }
    
    private func updateMessageLabel(){
        let message:String
        if let error = locationError as NSError?{
            if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue{
                message = "Location services disabled"
            }else{
                message = "Error getting location"
            }
        }else if !CLLocationManager.locationServicesEnabled(){
            message = "Location services disabled"
        }else if isSeachingLocation{
            message = "Searching ..."
        }else{
            message = "Click Get My Location Button"
        }
        lbMessage.text = message
    }
    
    private func updateLabelsWhenLocationFound(location:CLLocation){
        lbLattitude.text = String(format: "%.8f", location.coordinate.latitude)
        lbLongtitude.text = String(format: "%.8f", location.coordinate.longitude)
        bnTag.isHidden = false
        lbMessage.text = ""
        updateAddressLabel()
    }
    
    private func updateLabelWhenLocationNotFound(){
        lbLongtitude.text = ""
        lbLattitude.text = ""
        bnTag.isHidden = true
        updateAddressLabel()
        updateMessageLabel()
    }
    
    
    private func updateLabels(){
        if let location = location{
            updateLabelsWhenLocationFound(location: location)
            
        }else{
            updateLabelWhenLocationNotFound()
        }
    }
    
    func updateGetButton(){
        
        if isSeachingLocation{
            bnGet.setTitle("Stop", for: .normal)
        }else{
            bnGet.setTitle("Get My Location", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        updateGetButton()
    }
    
    private func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
            isSeachingLocation = true
        }
    }
    
    private func stopLocationManager(){
        if isSeachingLocation{
            manager.stopUpdatingLocation()
            manager.delegate = nil
            isSeachingLocation = false
        }
    }

    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted{
            showLocationServicesDeniedAlert()
            return
        }
        if isSeachingLocation{
            stopLocationManager()
        }else{
            location = nil
            locationError = nil
            startLocationManager()
        }
        updateLabels()
        updateGetButton()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.locationUnknown.rawValue{return}
        locationError = error
        stopLocationManager()
        updateLabels()
        updateGetButton()
    }
    
    private func reversingGeocoding(location:CLLocation!){
        if !isReversingGeocoder{
            isReversingGeocoder = true
            geocoder.reverseGeocodeLocation(location){placemarks, error in
                self.geocoderError = error
                if error == nil, let placemarks = placemarks, !placemarks.isEmpty{
                    self.placemark = placemarks.last
                }else{
                    self.placemark = nil
                }
                self.isReversingGeocoder = false
                self.updateAddressLabel()
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        guard let newLocation = locations.last else {return}
        if newLocation.timestamp.timeIntervalSinceNow < -5{return}
        if newLocation.horizontalAccuracy < 0{return}
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            locationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= manager.desiredAccuracy{
                reversingGeocoding(location: newLocation)
                stopLocationManager()
                updateLabels()
                updateGetButton()
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tagLocation"{
            guard
                let location = location,
                let placemark = placemark,
                let destination = segue.destination as? UINavigationController,
                let controller = destination.topViewController as? LocationDetailViewController
            else {return}
            controller.coord = location.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
}

