//
//  UIImageView+VirtualTourist.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 28/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit

private var loadedUrlAssociationKey: String = ""
private var alreadyLoadedOriginalImageAssociationKey: Bool = false

public extension UIImageView {
    
    final internal var loadedUrl: String! {
        get {
            return objc_getAssociatedObject(self, &loadedUrlAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &loadedUrlAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final internal var alreadyLoadedOriginalImage: Bool! {
        get {
            return objc_getAssociatedObject(self, &alreadyLoadedOriginalImageAssociationKey) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &alreadyLoadedOriginalImageAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func setImage(_ url: String?, thumbnailUrl: String? = nil, placeholder: UIImage? = nil, animated: Bool = false, completion:((_ image: UIImage?, _ data: Data?) -> Void)?) -> URLSessionDataTask? {
        self.layer.masksToBounds = true
        
        self.image = nil
        
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        self.loadedUrl = ""
        self.alreadyLoadedOriginalImage = false
        
        guard let url = url else {
            return nil
        }
        
        
        self.loadedUrl = url
        
        let initialLoadedUrl = self.loadedUrl as String
        
        return APIClient.performRequestReturnsData(URL.init(string: url)!, completion: { (data, error) in
            if(initialLoadedUrl == self.loadedUrl && !self.alreadyLoadedOriginalImage) {
                guard let data = data else {
                    completion?(nil, nil)
                    return
                }
                let image = UIImage.init(data: data)
                self.image = image
                if(animated) {
                    self.alpha = 0.2
                    UIView.animate(withDuration: 0.2, animations: {
                        self.alpha = 1.0
                    })
                }
                completion?(image, data)
            } else {
                return
            }
        })
    }
    
}
