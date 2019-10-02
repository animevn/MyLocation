import Foundation
import CoreData
import MapKit


public class Location: NSManagedObject, MKAnnotation{
    
    public var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(latitude, longtitude)
    }
    
    public var title: String?{
        if locationDescription.isEmpty{
            return "No detail"
        }else{
            return locationDescription
        }
    }
    
    public var subtitle: String?{
        return category
    }
}
