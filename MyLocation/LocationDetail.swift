import UIKit

class LocationDetailViewController:UITableViewController{
    
    @IBOutlet weak var lbDescription: UITextView!
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var lbLatitude: UILabel!
    @IBOutlet weak var lbLongtitude: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
    }
    
}
