import UIKit

class CategoryPickerViewController:UITableViewController{
    
    var selectedCategoryName:String!
    
    let categories = [
        "Apple Store",
        "Bar",
        "Bookstore",
        "Historic Building",
        "Grocery Store"
    ]
    
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<categories.count{
            if categories[i] == selectedCategoryName{
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryPickerCell",
                                                 for: indexPath)
        let categoryName = categories[indexPath.row]
        cell.textLabel?.text = categoryName
        
        if categoryName == selectedCategoryName{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row{
            if let newCell = tableView.cellForRow(at: indexPath){
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath){
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryPickerUnwind"{
            guard
                let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell)
            else {return}
            selectedCategoryName = categories[indexPath.row]
        }
    }
    
}
