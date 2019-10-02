import UIKit
import CoreData
import CoreLocation

class LocationsViewController:UITableViewController{
    
    var managedObjectContext:NSManagedObjectContext!
    var locations = [Location]()
    lazy var fetchedResultController:NSFetchedResultsController<Location> = {
        let fetch = NSFetchRequest<Location>()
        fetch.entity = Location.entity()
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetch.fetchBatchSize = 10
        let fetchedRC = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Location")
        fetchedRC.delegate = self
        return fetchedRC
    }()
    
    private func loadFromCoreData(){
        do{
            try fetchedResultController.performFetch()
        }catch let error{
            fatalCoreDataError(error: error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSFetchedResultsController<Location>.deleteCache(withName: "Location")
        loadFromCoreData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    private func updateCell(cell:UITableViewCell, location:Location){
        let lbDescription = cell.viewWithTag(99) as! UILabel
        let lbAddress = cell.viewWithTag(199) as! UILabel
        
        lbDescription.text = location.locationDescription
        if let placemark = location.placemark{
            lbAddress.text = string(from: placemark)
        }else{
            lbAddress.text = ""
        }
    }
    
    private func createCell(indexPath:IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let location = fetchedResultController.object(at: indexPath)
        updateCell(cell: cell, location: location)
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
            controller.locationToEdit = fetchedResultController.object(at: indexPath)
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "locationEdit", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let location = fetchedResultController.object(at: indexPath)
            managedObjectContext.delete(location)
            do{
                try managedObjectContext.save()
            }catch{
                fatalCoreDataError(error: error)
            }
        }
    }
    
}

extension LocationsViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>){
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!){
                let location = controller.object(at: indexPath!) as! Location
                updateCell(cell: cell, location: location)
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            print("move")
        case .update:
            print("update")
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>){
        tableView.endUpdates()
    }
    
}
