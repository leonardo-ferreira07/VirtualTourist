//
//  PhotosAlbumViewController.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import CoreData

class PhotosAlbumViewController: UIViewController {

    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let latitude = latitude, let longitude = longitude else {
            print("error")
            return
        }
        
        FlickrSearchClient.getFlickrImagesFromLocation(latitude: latitude, longitude: longitude) { (photos) in
            CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
                let latitudePred = NSPredicate.init(format: "latitude == %@", argumentArray: [latitude])
                let longitudePred = NSPredicate.init(format: "longitude == %@", argumentArray: [longitude])
                let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred])
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
                fetch.predicate = predicateCompound
                do {
                    let result = try worker.fetch(fetch)
                    let pin = result.first as! LocationPin
                    for photo in photos {
                        print(photo)
                    }
                }
                catch {
                    print("\(error)")
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
