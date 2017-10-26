//
//  MapHelper.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

struct MapHelper {
    
    static var latitude: Double {
        get {
            return UserDefaults.standard.object(forKey: "latitude") as? Double ?? -500.0
        }
        
        set {
            UserDefaults.standard.set(latitude, forKey: "latitude")
        }
    }
    
    static var longitude: Double {
        get {
            return UserDefaults.standard.object(forKey: "longitude") as? Double ?? -500.0
        }
        
        set {
            UserDefaults.standard.set(longitude, forKey: "longitude")
        }
    }
    
    static var latitudeDelta: Double {
        get {
            return UserDefaults.standard.object(forKey: "latitudeDelta") as? Double ?? -500.0
        }
        
        set {
            UserDefaults.standard.set(latitudeDelta, forKey: "latitudeDelta")
        }
    }
    
    static var longitudeDelta: Double {
        get {
            return UserDefaults.standard.object(forKey: "longitudeDelta") as? Double ?? -500.0
        }
        
        set {
            UserDefaults.standard.set(longitudeDelta, forKey: "longitudeDelta")
        }
    }
}
