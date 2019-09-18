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
    
    // MARK: - Types
    
    typealias Interval = (name: String, noOfDays: Int16)
    
    // MARK: - Properties
    
    var roomTypes: [String] = ["Living Room", "Bedroom", "Bathroom", "Kitchen", "Dining Room", "Office"]
    var intervalTypes: [Interval] = [("Days", 1), ("Weeks", 7), ("Months", 30)]
    
    // MARK: - Navigation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createStaticData()
    }
    
    // MARK: - Private Methods
    
    private func createStaticData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let mainQueueContext = appDelegate.persistentContainer.viewContext
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        childContext.parent = mainQueueContext
        childContext.perform {
            self.createRoomTypes(inContext: childContext)
            self.createIntervalTypes(inContext: childContext)
            
            do {
                try mainQueueContext.save()
            } catch let error as NSError {
                print("Could not create static data. \(error), \(error.userInfo)")
            }
        }
    }
    
    private func createRoomTypes(inContext: NSManagedObjectContext) {
        let roomTypeRequest = NSFetchRequest<RoomType>(entityName: CleaConstants.entityNameRoomType)
        var existingRoomTypes: [RoomType] = []
        
        do {
            existingRoomTypes = try inContext.fetch(roomTypeRequest)
        } catch let error as NSError {
            print("Could not load room types. \(error), \(error.userInfo)")
        }
        
        guard existingRoomTypes.count == 0 else {
            return
        }
        
        for type in roomTypes {
            let roomType = RoomType(context: inContext)
            roomType.name = type
        }
        
        do {
            try inContext.save()
        } catch let error as NSError {
            print("Could not create room types. \(error), \(error.userInfo)")
        }
    }
    
    private func createIntervalTypes(inContext: NSManagedObjectContext) {
        let intervalTypeRequest = NSFetchRequest<IntervalType>(entityName: CleaConstants.entityNameIntervalType)
        var existingIntervalTypes: [IntervalType] = []
        
        do {
            existingIntervalTypes = try inContext.fetch(intervalTypeRequest)
        } catch let error as NSError {
            print("Could not load interval types. \(error), \(error.userInfo)")
        }
        
        guard existingIntervalTypes.count == 0 else {
            return
        }
        
        for type in intervalTypes {
            let intervalType = IntervalType(context: inContext)
            intervalType.name = type.name
            intervalType.noOfDays = type.noOfDays
        }
        
        do {
            try inContext.save()
        } catch let error as NSError {
            print("Could not create interval types. \(error), \(error.userInfo)")
        }
    }
    
}
