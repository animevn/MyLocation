import UIKit
import CoreData
import CoreLocation

class LocationsViewController:UITableViewController{
    
    var managedObjectContext:NSManagedObjectContext!
    var locations = [Location]()
    
    private func loadFromCoreData(){
        
        let fetch = NSFetchRequest<Location>()
        fetch.entity = Location.entity()
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do{
            locations = try managedObjectContext.fetch(fetch)
        }catch let error{
            fatalCoreDataError(error: error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFromCoreData()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    private func createCell(indexPath:IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let location = locations[indexPath.row]
        let lbDescription = cell.viewWithTag(99) as! UILabel
        let lbAddress = cell.viewWithTag(199) as! UILabel
        
        lbDescription.text = location.locationDescription
        if let placemark = location.placemark{
            lbAddress.text = string(from: placemark)
        }else{
            lbAddress.text = ""
        }
        return cell
    }
    
    
    override func tableView(_ tableView:UITableView,
                            cellForRowAt indexPath:IndexPath)->UITableViewCell{
        return createCell(indexPath: indexPath)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationEdit"{
            let navigation = segue.destination as! UINavigationController
            let controller = navigation.topViewController as! LocationDetailViewController
            let indexPath = sender as! IndexPath
            controller.locationToEdit = locations[indexPath.row]
            print(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "locationEdit", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}