//
//  Location+CoreDataProperties.swift
//  MyLocation
//
//  Created by haanh on 10/1/19.
//  Copyright © 2019 haanh. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var longtitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var placemark: NSObject?

}
