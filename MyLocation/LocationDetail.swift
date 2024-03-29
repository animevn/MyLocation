import UIKit
import CoreLocation
import CoreData

class LocationDetailViewController:UITableViewController{
    
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var lbLatitude: UILabel!
    @IBOutlet weak var lbLongtitude: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbAddPhoto: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    
    var image:UIImage?
    var coord = CLLocationCoordinate2DMake(0, 0)
    var placemark:CLPlacemark!
    var categoryName = "Apple Store"
    var date = Date()
    var managedObjectContext:NSManagedObjectContext!
    
    var locationToEdit:Location?{
        didSet{
            if let location = self.locationToEdit{
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coord = CLLocationCoordinate2DMake(location.latitude, location.longtitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    private func updateLabels(){
        tvDescription.text = descriptionText
        lbLatitude.text = String(format: "%.8f", coord.latitude)
        lbLongtitude.text = String(format: "%.8f", coord.longitude)
        if let placemark = placemark{
            lbAddress.text = string(from: placemark)
        }else{
            lbAddress.text = ""
        }
        lbCategory.text = categoryName
        lbDate.text = format(date: Date())
    }
    
    @objc private func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath?.row == 0{
            return
        }
        tvDescription.resignFirstResponder()
    }
    
    private func createTapGesture(){
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationToEdit != nil{
            title = "Edit Location"
        }
        
        updateLabels()
        createTapGesture()
        
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
    
    private func saveLocation(location:Location){
        
        location.locationDescription = tvDescription.text
        location.category = categoryName
        location.latitude = coord.latitude
        location.longtitude = coord.longitude
        location.date = date
        location.placemark = placemark
        
        do{
            try managedObjectContext.save()
            
        }catch let error{
            fatalCoreDataError(error: error)
        }
    }
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        let hudView = HudView.hud(view: navigationController!.view, animated: true)
        
        let location:Location
        if let temp = locationToEdit{
            hudView.text = "Updated"
            location = temp
        }else{
            hudView.text = "Tagg"
            location = Location(context: managedObjectContext)
        }
        saveLocation(location: location)
        
        executeAfter(seconds: 0.6){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func pickCategory(_ segue: UIStoryboardSegue){
        guard let source = segue.source as? CategoryPickerViewController else {return}
        categoryName = source.selectedCategoryName
        lbCategory.text = categoryName
    }
    
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            tvDescription.becomeFirstResponder()
        }else if indexPath.section == 1 && indexPath.row == 0{
            tableView.deselectRow(at: indexPath, animated: true)
            photoPicker()
        }
    }
    
    override func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath)->CGFloat{
        if indexPath.section == 0 && indexPath.row == 0{
            return 90
        }else if indexPath.section == 2 && indexPath.row == 2{
            lbAddress.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            lbAddress.sizeToFit()
            lbAddress.frame.origin.x = view.bounds.size.width - lbAddress.frame.size.width - 15
            return lbAddress.frame.size.height + 20
        }else if indexPath.section == 1 && indexPath.row == 0{
            if ivImage.isHidden{
                return 50
            }else{
                return 280
            }
        }else{
            return 44
        }
        
    }
}

extension LocationDetailViewController:
    UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func takePhotoWithLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func showPhotoOptions(){
        let alertController = UIAlertController(title: nil, message: nil,
                                                preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {_ in
            self.takePhotoWithCamera()
        })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library",
                                                    style: .default, handler: {_ in
            self.takePhotoWithLibrary()
        })
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func photoPicker(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoOptions()
        }else{
            takePhotoWithLibrary()
        }
    }
    
    private func show(image:UIImage){
        ivImage.image = image
        ivImage.isHidden = false
        ivImage.frame = CGRect(x: 10, y: 10, width: 250, height: 250)
        lbAddPhoto.isHidden = true
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let image = image{
            show(image: image)
        }
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
}














