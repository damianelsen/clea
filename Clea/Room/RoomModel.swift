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
    var type: RoomType
    var created: Date
    
    // MARK: - Initialization
    
    init?(name: String, type: RoomType) {
        if name.isEmpty {
            return nil
        }
        
        self.name = name
        self.type = type
        self.created = Date()
    }
    
}
