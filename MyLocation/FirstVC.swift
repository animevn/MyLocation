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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

    @IBAction func getLocation(_ sender: UIButton) {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startUpdatingLocation()
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted{
            showLocationServicesDeniedAlert()
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    private func updateViews(){
        if let location = location{
            lbLattitude.text = String(format: "%.5f", location.coordinate.latitude)
            lbLongtitude.text = String(format: "%.5f", location.coordinate.longitude)
            bnTag.isHidden = false
            lbMessage.text = ""
        }else{
            lbLongtitude.text = ""
            lbLattitude.text = ""
            lbAddress.text = ""
            bnTag.isHidden = true
            lbMessage.text = "Tap 'Get My Location' to start"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        location = locations.last!
        updateViews()
    }
    
}

