//
//  CoreDataHelper.swift
//  VirtualTourist
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 27/10/17.
//  Copyright © 2017 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import Foundation

class CoreDataHelper {
    
    static let shared = CoreDataHelper()
    
    private init() {}
    
    var stack: CoreDataStack!
    
    public func setupDatabase() {
        stack = CoreDataStack(modelName: "VirtualTourist")!
    }
}
