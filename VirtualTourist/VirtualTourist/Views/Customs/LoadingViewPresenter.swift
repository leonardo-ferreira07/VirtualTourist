//
//  LoadingViewPresenter.swift
//  OnTheMap
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 23/10/17.
//  Copyright © 2017 Leonardo Ferreira. All rights reserved.
//

import UIKit

class LoadingViewPresenter: UIView {
    
    static func newInstance() -> LoadingViewPresenter {
        return Bundle(for: self).loadNibNamed("LoadingView", owner: self, options: nil)![0] as! LoadingViewPresenter
    }
    
}
