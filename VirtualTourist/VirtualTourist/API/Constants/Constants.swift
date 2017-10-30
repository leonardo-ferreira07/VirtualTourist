//
//  Constants.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: - Scheme
    
    static let apiScheme = "https"
    
    // MARK: - Host
    
    static let apiHostFlickr = "api.flickr.com"
    
    // MARK: - Path
    
    static let apiPathFlickr = "/services/rest"
    
    // MARK: - Flickr Parameters
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "f129577dffb2d550fe57abc1ad307e2b"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: - Flickr Parameter Keys
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let Page = "page"
    }
    
    // MARK: - Flickr BBox
    
    struct FlickrBBox {
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
}
