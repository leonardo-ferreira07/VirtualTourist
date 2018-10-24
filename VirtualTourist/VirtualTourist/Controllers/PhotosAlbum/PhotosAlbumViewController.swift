//
//  PhotosAlbumViewController.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosAlbumViewController: CoreDataCollectionViewController {

    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var latitude: Double?
    var longitude: Double?
    var locationPin: LocationPin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapLocation()
        
        let fetch = locationPinFetchRequestWith(latitude ?? 0, longitude: longitude ?? 0)
        
        do {
            let result = try CoreDataHelper.shared.stack.context.fetch(fetch)
            let pin = result.first as! LocationPin
            locationPin = pin
            
            let fr = photoFetchRequestWith(pin)
            
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
    }
    
    // MARK: - Actions
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        view.startLoadingAnimation()
        if let photos = fetchedResultsController?.fetchedObjects as? [Photo] {
            let group = DispatchGroup()
            
            for photo in photos {
                let tupple: (String, Double, Double) = (photo.url ?? "", photo.locationPin?.latitude ?? 0, photo.locationPin?.longitude ?? 0)
                
                group.enter()
                CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
                    let fr = NSFetchRequest<NSFetchRequestResult>(entityName: EntitiesNames.photo.rawValue)
                    let latitudePred = NSPredicate.init(format: "locationPin.latitude == %@", argumentArray: [tupple.1 as Any])
                    let longitudePred = NSPredicate.init(format: "locationPin.longitude == %@", argumentArray: [tupple.2 as Any])
                    let urlPred = NSPredicate.init(format: "url == %@", argumentArray: [tupple.0 as Any])
                    let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred, urlPred])
                    fr.predicate = predicateCompound
                    do {
                        if let result = try worker.fetch(fr).first as? Photo {
                            worker.delete(result)
                        }
                        group.leave()
                    } catch {
                        
                    }
                })
            }
            
            group.notify(queue: .global(), execute: {
                print("finished")
                self.view.stopLoadingAnimation()
                CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
                    let fetch = self.locationPinFetchRequestWith(self.latitude ?? 0, longitude: self.longitude ?? 0)
                    do {
                        if let pin = try worker.fetch(fetch).first as? LocationPin {
                            print(pin.page)
                            self.getPhotos(withPage: Int(pin.page))
                        }
                    } catch {
                        
                    }
                })
            })
        }
    }

}

// MARK: - CoreData Operations

extension PhotosAlbumViewController {
    func getPhotos(withPage page: Int = 1) {
        guard let latitude = latitude, let longitude = longitude else {
            print("error")
            return
        }
        
        view.startLoadingAnimation()
        shouldLockUI(true)
        FlickrSearchClient.getFlickrImagesFromLocation(latitude: latitude, longitude: longitude, page: page) { (photos, page, pages)  in
            self.shouldLockUI(false)
            
            if let page = page, let pages = pages {
                if page <= pages-1 {
                    self.locationPin?.page = Int64(page + 1)
                } else {
                    self.locationPin?.page = 1
                }
            }
            
            if photos.count > 0 {
                self.showNoImagesMessage(false)
                
                let fetch = self.locationPinFetchRequestWith(latitude, longitude: longitude)
                
                do {
                    let result = try self.fetchedResultsController!.managedObjectContext.fetch(fetch)
                    let pin = result.first as! LocationPin
                    for photo in photos {
                        print(photo)
                        pin.addToPhotos(Photo(url: photo.photoURL, imageData: nil, context: self.fetchedResultsController!.managedObjectContext))
                    }
                    
                    let fr = self.photoFetchRequestWith(pin)
                    
                    // Create the FetchedResultsController
                    self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                    self.view.stopLoadingAnimation()
                    
                } catch {
                    print("\(error)")
                }
            } else {
                self.view.stopLoadingAnimation()
                self.showNoImagesMessage(true)
            }
        }
    }
    
    func locationPinFetchRequestWith(_ latitude: Double, longitude: Double) -> NSFetchRequest<NSFetchRequestResult> {
        let latitudePred = NSPredicate.init(format: "latitude == %@", argumentArray: [latitude])
        let longitudePred = NSPredicate.init(format: "longitude == %@", argumentArray: [longitude])
        let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred])
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: EntitiesNames.locationPin.rawValue)
        fetch.predicate = predicateCompound
        
        return fetch
    }
    
    func photoFetchRequestWith(_ locationPin: LocationPin) -> NSFetchRequest<NSFetchRequestResult> {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: EntitiesNames.photo.rawValue)
        fr.predicate = NSPredicate(format: "locationPin = %@", argumentArray: [locationPin])
        fr.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        
        return fr
    }
}

// MARK: - CollectionView Data Source

extension PhotosAlbumViewController {
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotoCollectionViewCell, let photo = fetchedResultsController!.object(at: indexPath) as? Photo {
            
            let tupple: (String, Double, Double) = (photo.url ?? "", photo.locationPin?.latitude ?? 0, photo.locationPin?.longitude ?? 0)
            
            if photo.imageData != nil {
                cell.imageView.image = UIImage.init(data: photo.imageData! as Data)
            } else {
                _ = cell.imageView.setImage(photo.url, placeholder: #imageLiteral(resourceName: "icoImagePlaceholder"), completion: { (image, data) in
                    guard let data = data else {
                        return
                    }
                    
                    CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
                        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: EntitiesNames.photo.rawValue)
                        let latitudePred = NSPredicate.init(format: "locationPin.latitude == %@", argumentArray: [tupple.1 as Any])
                        let longitudePred = NSPredicate.init(format: "locationPin.longitude == %@", argumentArray: [tupple.2 as Any])
                        let urlPred = NSPredicate.init(format: "url == %@", argumentArray: [tupple.0 as Any])
                        let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred, urlPred])
                        fr.predicate = predicateCompound
                        do {
                            if let result = try worker.fetch(fr).first as? Photo {
                                result.imageData = data as NSData
                            }
                        } catch {
                            
                        }
                    })
                })
            }
        }
        
    }
    
}

// MARK: - Flow layout

extension PhotosAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let context = fetchedResultsController?.managedObjectContext, let photo = fetchedResultsController?.object(at: indexPath) as? Photo {
            context.delete(photo)
        }
    }
    
}

// MARK: - Error message handling

extension PhotosAlbumViewController {
    func showNoImagesMessage(_ show: Bool) {
        collectionView.isHidden = show
        noImagesLabel.isHidden = !show
    }
}

// MARK: - Lock UI

extension PhotosAlbumViewController {
    func shouldLockUI(_ lock: Bool) {
        newCollectionButton.isEnabled = !lock
    }
}

// MARK: - Map Settings

extension PhotosAlbumViewController {
    func setMapLocation() {
        if let latitude = latitude, let longitude = longitude {
            let latDelta: CLLocationDegrees = 0.005
            let lonDelta: CLLocationDegrees = 0.005
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: true)
            let point = MKPointAnnotation()
            point.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let userAnnotationView:MKPinAnnotationView = MKPinAnnotationView(annotation: point, reuseIdentifier: nil)
            self.mapView.addAnnotation(userAnnotationView.annotation!)
            self.mapView.showsUserLocation = true
        }
    }
}
