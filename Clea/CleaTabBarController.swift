//
//  CleaTabBarController.swift
//  Clea
//
//  Created by Damian Elsen on 9/2/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class CleaTabBarController: UITabBarController {
    
    // MARK: - Properties
    
    var roomTypes: [String] = ["Living Room", "Bedroom", "Bathroom", "Kitchen", "Dining Room", "Office"]
    
    // MARK: - Navigation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createRoomTypes()
    }
    
    // MARK: - Private Methods
    
    private func createRoomTypes() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let mainQueueContext = appDelegate.persistentContainer.viewContext
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        childContext.parent = mainQueueContext
        childContext.perform {
            let roomTypeRequest = NSFetchRequest<RoomType>(entityName: "RoomType")
            var existingRoomTypes: [RoomType] = []
            
            do {
                existingRoomTypes = try childContext.fetch(roomTypeRequest)
            } catch let error as NSError {
                print("Could not load room types. \(error), \(error.userInfo)")
            }
            
            guard existingRoomTypes.count == 0 else {
                return
            }
            
            for type in self.roomTypes {
                let roomType = RoomType(context: childContext)
                roomType.name = type
            }
            
            do {
                try childContext.save()
                try mainQueueContext.save()
            } catch let error as NSError {
                print("Could not create room types. \(error), \(error.userInfo)")
            }
        }
    }
    
}
