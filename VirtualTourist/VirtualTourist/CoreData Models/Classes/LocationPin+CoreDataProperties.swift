//
//  LocationPin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 30/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//
//

import Foundation
import CoreData


extension LocationPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationPin> {
        return NSFetchRequest<LocationPin>(entityName: "LocationPin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var page: Int64
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension LocationPin {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
