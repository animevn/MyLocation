import UIKit
import CoreLocation

class CurrentLocationVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbLattitude: UILabel!
    @IBOutlet weak var lbLongtitude: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var bnTag: UIButton!
    @IBOutlet weak var bnGet: UIButton!
    
    let manager = CLLocationManager()
    var newLocation:CLLocation?
    var updateLocation = false
    var lastLocationError:Error?
    
    private func updateViews(){
        if let location = newLocation{
            lbLattitude.text = String(format: "%.5f", location.coordinate.latitude)
            lbLongtitude.text = String(format: "%.5f", location.coordinate.longitude)
            bnTag.isHidden = false
            lbMessage.text = ""
        }else{
            lbLongtitude.text = ""
            lbLattitude.text = ""
            lbAddress.text = ""
            bnTag.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain
                    && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updateLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            lbMessage.text = statusMessage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
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
            updateLocation = true
        }
    }
    
    private func stopLocationManager(){
        if updateLocation{
            manager.stopUpdatingLocation()
            manager.delegate = nil
            updateLocation = false
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
        startLocationManager()
        updateViews()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.locationUnknown.rawValue{return}
        lastLocationError = error
        stopLocationManager()
        updateViews()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        newLocation = locations.last!
        print("lat: \(newLocation!.coordinate.latitude) lon: \(newLocation!.coordinate.longitude)")
        
        updateViews()
    }
    
}

