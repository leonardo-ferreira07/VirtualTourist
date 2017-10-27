//
//  PhotosAlbumViewController.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import CoreData

class PhotosAlbumViewController: CoreDataCollectionViewController {

    var latitude: Double?
    var longitude: Double?
    var locationPin: LocationPin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latitudePred = NSPredicate.init(format: "latitude == %@", argumentArray: [latitude as Any])
        let longitudePred = NSPredicate.init(format: "longitude == %@", argumentArray: [longitude as Any])
        let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred])
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
        fetch.predicate = predicateCompound
        do {
            let result = try CoreDataHelper.shared.stack.context.fetch(fetch)
            let lala = result.first as! LocationPin
            locationPin = lala
            
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            fr.predicate = NSPredicate(format: "locationPin = %@", argumentArray: [lala])
            fr.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
            
            // Create the FetchedResultsController
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataHelper.shared.stack.context, sectionNameKeyPath: nil, cacheName: nil)
            if fetchedResultsController?.fetchedObjects?.isEmpty ?? false {
                
                getPhotos()
                
            }
        } catch {
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
//        guard let latitude = latitude, let longitude = longitude else {
//            print("error")
//            return
//        }
//
//        FlickrSearchClient.getFlickrImagesFromLocation(latitude: latitude, longitude: longitude) { (photos) in
//            CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
//                let latitudePred = NSPredicate.init(format: "latitude == %@", argumentArray: [latitude])
//                let longitudePred = NSPredicate.init(format: "longitude == %@", argumentArray: [longitude])
//                let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred])
//                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
//                fetch.predicate = predicateCompound
//                do {
//                    let result = try worker.fetch(fetch)
//                    let pin = result.first as! LocationPin
//                    for photo in photos {
//                        print(photo)
//                        pin.addToPhotos(Photo(url: photo.photoURL, imageData: NSData(), context: worker))
//                    }
//                } catch {
//                    print("\(error)")
//                }
//            })
//        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getPhotos() {
        guard let latitude = latitude, let longitude = longitude else {
            print("error")
            return
        }
        
        FlickrSearchClient.getFlickrImagesFromLocation(latitude: latitude, longitude: longitude) { (photos) in
            
            let latitudePred = NSPredicate.init(format: "latitude == %@", argumentArray: [latitude])
            let longitudePred = NSPredicate.init(format: "longitude == %@", argumentArray: [longitude])
            let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred])
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
            fetch.predicate = predicateCompound
            
            do {
                let result = try self.fetchedResultsController!.managedObjectContext.fetch(fetch)
                let pin = result.first as! LocationPin
                for photo in photos {
                    print(photo)
                    pin.addToPhotos(Photo(url: photo.photoURL, imageData: NSData(), context: self.fetchedResultsController!.managedObjectContext))
                }
                
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                fr.predicate = NSPredicate(format: "locationPin = %@", argumentArray: [self.locationPin])
                fr.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
                
                // Create the FetchedResultsController
                self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                
            } catch {
                print("\(error)")
            }
        }
    }

}

extension PhotosAlbumViewController {
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController!.object(at: indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.label.text = photo.url
        
        return cell
    }
    
}
