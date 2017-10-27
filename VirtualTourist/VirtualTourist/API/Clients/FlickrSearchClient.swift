//
//  FlickrSearchClient.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 27/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

struct FlickrSearchClient {
    
    static func getFlickrImagesFromLocation(latitude: Double, longitude: Double, completion: @escaping (_ success: Bool) -> Void) {
        let url = APIClient.buildURL([
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude, longitude: longitude),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback] as [String: AnyObject], withHost: Constants.apiHostFlickr, withPathExtension: Constants.apiPathFlickr)
        
        _ = APIClient.performRequest(url, completion: { (dict, error) in
            
            guard let dict = dict else {
                completion(false)
                return
            }
            
            completion(true)
//            if let array = dict[StudentLocationKeys.results.rawValue] as? [[String: AnyObject]] {
//                MemoryStorage.shared.studentsLocations.removeAll()
//                for object in array {
//                    MemoryStorage.shared.studentsLocations.append(StudentLocation(withDictionary: object))
//                }
//                completion(true)
//            } else {
//                completion(false)
//            }
            
        }) {
            
        }
    }
    
    static private func bboxString(_ latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - Constants.FlickrBBox.SearchBBoxHalfWidth, Constants.FlickrBBox.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.FlickrBBox.SearchBBoxHalfHeight, Constants.FlickrBBox.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.FlickrBBox.SearchBBoxHalfWidth, Constants.FlickrBBox.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.FlickrBBox.SearchBBoxHalfHeight, Constants.FlickrBBox.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
}
