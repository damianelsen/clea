//
//  RoomModel.swift
//  Clea
//
//  Created by Damian Elsen on 8/31/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class RoomModel {
    
    // MARK: - Properties
    
    var name: String
    var type: String
    var created: Date
    
    // MARK: - Initialization
    
    init?(name: String, type: String) {
        if name.isEmpty {
            return nil
        }
        
        if type.isEmpty  {
            return nil
        }
        
        self.name = name
        self.type = type
        self.created = Date()
    }
    
}
