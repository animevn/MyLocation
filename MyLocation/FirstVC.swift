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
    
    var location:CLLocation?
    var isUpdateLocation = false
    var lastLocationError:Error?
    
    var geocode = CLGeocoder()
    var placemark:CLPlacemark?
    var isReverseGeocode = false
    var lastGeocodingError:Error?
    
    private func updateViews(){
        if let location = location{
            lbLattitude.text = String(format: "%.5f", location.coordinate.latitude)
            lbLongtitude.text = String(format: "%.5f", location.coordinate.longitude)
            bnTag.isHidden = false
            lbMessage.text = ""
            
            if let placemark = placemark{
                lbAddress.text = string(from: placemark)
            }else if isReverseGeocode{
                lbAddress.text = "Searching for place ..."
            }else if lastGeocodingError != nil{
                lbAddress.text = "Error searching place"
            }else{
                lbAddress.text = "No place found"
            }
            
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
            } else if isUpdateLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            lbMessage.text = statusMessage
        }
        
        
    }
    
    func configureGetbutton(){
        
        if isUpdateLocation{
            bnGet.setTitle("Stop", for: .normal)
        }else{
            bnGet.setTitle("Get My Location", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        configureGetbutton()
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
            isUpdateLocation = true
        }
    }
    
    private func stopLocationManager(){
        if isUpdateLocation{
            manager.stopUpdatingLocation()
            manager.delegate = nil
            isUpdateLocation = false
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
        if isUpdateLocation{
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        updateViews()
        configureGetbutton()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.locationUnknown.rawValue{return}
        lastLocationError = error
        stopLocationManager()
        updateViews()
        configureGetbutton()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        let newLocation = locations.last!
        print(newLocation)
        if newLocation.timestamp.timeIntervalSinceNow < -5{
            return
        }
        
        if newLocation.horizontalAccuracy < 0{
            return
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            lastLocationError = nil
            location = newLocation
            updateViews()
            
            if newLocation.horizontalAccuracy <= manager.desiredAccuracy{
                print("Ok now")
                stopLocationManager()
                configureGetbutton()
            }
            
            if !isReverseGeocode{
                print("Geocode")
                isReverseGeocode = true
                geocode.reverseGeocodeLocation(newLocation){placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let placemarks = placemarks, !placemarks.isEmpty{
                        self.placemark = placemarks.last
                    }else{
                        self.placemark = nil
                    }
                }
                self.isReverseGeocode = false
                self.updateViews()
            }
        }
    }
    
    
    
}

