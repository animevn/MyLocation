import UIKit
import CoreLocation

class LocationDetailViewController:UITableViewController{
    
    @IBOutlet weak var lbDescription: UITextView!
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var lbLatitude: UILabel!
    @IBOutlet weak var lbLongtitude: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    var coord:CLLocationCoordinate2D!
    var placemark:CLPlacemark!
    
    private func updateLabels(){
        
        lbDescription.text = ""
        lbLatitude.text = String(format: "%.8f", coord.latitude)
        lbLongtitude.text = String(format: "%.8f", coord.longitude)
        lbAddress.text = string(from: placemark)
        lbDate.text = format(date: Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
    }
    
}
