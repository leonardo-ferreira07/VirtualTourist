//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 28/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit

extension UIView {
    func startLoadingAnimation() {
        stopLoadingAnimation()
        
        DispatchQueue.main.async {
            let loadingView = LoadingViewPresenter.newInstance()
            loadingView.frame = UIScreen.main.bounds
            UIApplication.shared.keyWindow?.addSubview(loadingView)
        }
    }
    
    func stopLoadingAnimation() {
        DispatchQueue.main.async {
            if let subviews = UIApplication.shared.keyWindow?.subviews {
                for subview in subviews {
                    if let subview = subview as? LoadingViewPresenter {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}
