//
//  FlickrPhotos.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 27/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

struct FlickrPhotos: Codable {
    
    let main: FlickrMain
    
    private enum CodingKeys: String, CodingKey {
        case main = "photos"
    }
}

struct FlickrMain: Codable {
    
    let page: Int
    let pages: Int
    let perPage: Int
    let photos: [FlickrPhoto]
    
    private enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case photos = "photo"
    }
    
}

struct FlickrPhoto: Codable {
    
    let photoURL: String
    
    private enum CodingKeys: String, CodingKey {
        case photoURL = "url_m"
    }
}
