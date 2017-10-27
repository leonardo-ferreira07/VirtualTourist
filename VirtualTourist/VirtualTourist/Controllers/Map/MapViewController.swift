//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    enum PinIdentifier: String {
        case pin
    }

    @IBOutlet weak var mapView: MKMapView!
    
    var canAddPin: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        getPinLocations { (pins) in
            
            var annotations = [MKPointAnnotation]()
            
            for pin in pins {
                print(pin)
                
                let lat = CLLocationDegrees(pin.latitude)
                let long = CLLocationDegrees(pin.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(pin.latitude) \(pin.longitude)"
                
                annotations.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(annotations)
            }
        }
        
        if MapHelper.didGetFirstCoodinates {
            let span: MKCoordinateSpan = MKCoordinateSpanMake(MapHelper.latitudeDelta, MapHelper.longitudeDelta)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(MapHelper.latitude, MapHelper.longitude)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            self.mapView.setRegion(region, animated: true)
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PhotosAlbumViewController {
            if let pin = sender as? (Double, Double) {
                print(pin.0)
                viewController.latitude = pin.0
                viewController.longitude = pin.1
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK : - MKMapView Delegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: PinIdentifier.pin.rawValue) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: PinIdentifier.pin.rawValue)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let latitude = view.annotation?.coordinate.latitude, let longitude = view.annotation?.coordinate.longitude else {
                print("error")
                return
            }
            getPinLocation(latitude, longitude: longitude, completion: { (pin) in
                if let pin = pin {
                    let tupple = (pin.latitude, pin.longitude)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showPhotosAlbum", sender: tupple)
                    }
                }
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        MapHelper.didGetFirstCoodinates = true
        
        let newRegion = self.mapView.region
        MapHelper.latitude = Double(newRegion.center.latitude)
        MapHelper.longitude = Double(newRegion.center.longitude)
        MapHelper.latitudeDelta = Double(newRegion.span.latitudeDelta)
        MapHelper.longitudeDelta = Double(newRegion.span.longitudeDelta)
    }
    
}

// MARK: - UIGesture Recognizer

extension MapViewController {
    
    func addGesture() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(triggerLongpressOn(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func triggerLongpressOn(_ gestureRecognizer: UIGestureRecognizer) {
        
        if canAddPin {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            annotation.title = "\(newCoordinates.latitude) \(newCoordinates.longitude)"
            mapView.addAnnotation(annotation)
            
            addNewLocationToDatabase(Double(newCoordinates.latitude), longitude: Double(newCoordinates.longitude))
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            canAddPin = false
        } else if gestureRecognizer.state == UIGestureRecognizerState.ended {
            canAddPin = true
        }
        
    }
    
}

// MARK: - Core Data operations

extension MapViewController {
    
    func addNewLocationToDatabase(_ latitude: Double, longitude: Double) {
        CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
            _ = LocationPin(name: "\(latitude) \(longitude)", latitude: latitude, longitude: longitude, context: worker)
        })
    }
    
    func getPinLocations(completion: @escaping ([LocationPin]) -> Void) {
        CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
            do {
                let result = try worker.fetch(fetch)
                completion(result as! [LocationPin])
            }
            catch {
                completion([])
                print("\(error)")
            }
        })
    }
    
    func getPinLocation(_ latitude: Double, longitude: Double, completion: @escaping (LocationPin?) -> Void) {
        CoreDataHelper.shared.stack.performBackgroundBatchOperation({ (worker) in
            let latitudePred = NSPredicate.init(format: "latitude == %@", argumentArray: [latitude])
            let longitudePred = NSPredicate.init(format: "longitude == %@", argumentArray: [longitude])
            let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [latitudePred, longitudePred])
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
            fetch.predicate = predicateCompound
            do {
                let result = try worker.fetch(fetch)
                let pin = result.first as! LocationPin
                completion(pin)
                print(result.count)
            }
            catch {
                completion(nil)
                print("\(error)")
            }
        })
    }

}
