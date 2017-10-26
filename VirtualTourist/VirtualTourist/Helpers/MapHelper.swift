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
            return UserDefaults.standard.double(forKey: "latitude")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "latitude")
        }
    }
    
    static var longitude: Double {
        get {
            return UserDefaults.standard.double(forKey: "longitude")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "longitude")
        }
    }
    
    static var latitudeDelta: Double {
        get {
            return UserDefaults.standard.double(forKey: "latitudeDelta")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "latitudeDelta")
        }
    }
    
    static var longitudeDelta: Double {
        get {
            return UserDefaults.standard.double(forKey: "longitudeDelta")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "longitudeDelta")
        }
    }
    
    static var didGetFirstCoodinates: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didGetFirstCoodinates")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "didGetFirstCoodinates")
        }
    }
}
