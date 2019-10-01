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
    var categoryName = "Apple Store"
    
    
    private func updateLabels(){
        
        lbDescription.text = ""
        lbLatitude.text = String(format: "%.8f", coord.latitude)
        lbLongtitude.text = String(format: "%.8f", coord.longitude)
        lbAddress.text = string(from: placemark)
        lbDate.text = format(date: Date())
        
    }
    
    @objc private func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath?.row == 0{
            return
        }
        lbDescription.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        lbCategory.text = categoryName
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryPicker"{
            guard let destination = segue.destination as? CategoryPickerViewController else {return}
            destination.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        let hudView = HudView.hud(view: navigationController!.view, animated: true)
        hudView.text = "Tagg"
    }
    
    @IBAction func pickCategory(_ segue: UIStoryboardSegue){
        guard let source = segue.source as? CategoryPickerViewController else {return}
        categoryName = source.selectedCategoryName
        lbCategory.text = categoryName
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            lbDescription.becomeFirstResponder()
        }
    }
    
}
