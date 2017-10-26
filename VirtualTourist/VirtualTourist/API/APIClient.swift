//
//  APIClient.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

public enum URLMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

class APIClient: NSObject {
    
    fileprivate static func buildError(_ error: String) -> Error {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey: error]
        return NSError(domain: "performRequestReturnsData", code: 1, userInfo: userInfo)
    }
    
    open static func performRequest(_ url: URL, method: URLMethod? = .GET, jsonBody: [String: AnyObject]? = nil, headerValues: [String: String]? = nil, ignore5First: Bool = false, completion: @escaping (_ data: AnyObject?, Error?) -> Void, timeoutAfter timeout: TimeInterval = 0, onTimeout: (()->Void)? = nil) -> URLSessionDataTask? {
        
        return performRequestReturnsData(url, method: method, jsonBody: jsonBody, headerValues: headerValues, ignore5First: ignore5First, completion: { (data, error) in
            
            guard let jsonObject = jsonObject(data) else {
                completion(nil, buildError("error parsing Json"))
                return
            }
            
            completion(jsonObject, nil)
            
        }, timeoutAfter: timeout) {
            
        }
    }
    
    open static func performRequestReturnsData(_ url: URL, method: URLMethod? = .GET, jsonBody: [String: AnyObject]? = nil, headerValues: [String: String]? = nil, ignore5First: Bool = false, completion: @escaping (_ data: Data?, Error?) -> Void, timeoutAfter timeout: TimeInterval = 0, onTimeout: (()->Void)? = nil) -> URLSessionDataTask? {
        
        let urlRequest = NSMutableURLRequest(url: url)
        
        if let method = method {
            urlRequest.httpMethod = method.rawValue
        }
        
        var data: Data?
        if let jsonBody = jsonBody {
            do {
                try data = JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            } catch {
                NSLog("Error unwraping json object")
                completion(nil, buildError("Error unwraping json object"))
            }
        }
        
        if let bodyData = data {
            urlRequest.httpBody = bodyData
        }
        
        if let headerValues = headerValues {
            for (key, headerValue) in headerValues {
                urlRequest.addValue(headerValue, forHTTPHeaderField: key)
            }
        }
        
        if timeout > 0 {
            urlRequest.timeoutInterval = timeout
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                completion(nil, buildError("There was an error with your request: \(error!)"))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, buildError("Your request returned a status code other than 2xx! \((response as? HTTPURLResponse)?.statusCode ?? 0))"))
                return
            }
            
            guard var data = data else {
                completion(nil, buildError("No data was returned by the request!"))
                return
            }
            
            if ignore5First {
                let range = Range(5..<data.count)
                data = data.subdata(in: range)
            }
            
            DispatchQueue.main.async(execute: {
                completion(data, nil)
            })
        }
        task.resume()
        
        return task
    }
    
}

// MARK: - URL builder

extension APIClient {
    
    open static func buildURL(_ parameters: [String: AnyObject]? = nil, withHost host: String, withPathExtension path: String) -> URL {
        var components = URLComponents()
        components.scheme = Constants.apiScheme
        components.host = host
        components.path = "/" + path
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
}

// MARK: - JSON Serializer

extension APIClient {
    
    private static func jsonObject(_ data: Data?) -> AnyObject? {
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return json as AnyObject?
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        
        return nil
    }
    
}
