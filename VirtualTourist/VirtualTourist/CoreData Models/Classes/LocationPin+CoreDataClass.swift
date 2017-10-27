//
//  LocationPin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//
//

import Foundation
import CoreData

@objc(LocationPin)
public class LocationPin: NSManagedObject {
    
    convenience init(name: String, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "LocationPin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
