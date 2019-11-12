//
//  DataController.swift
//  Clea
//
//  Created by Damian Elsen on 9/28/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class DataController {
    
    // MARK: - Public Methods
    
    static func fetchAllRooms(sortBy sort: NSSortDescriptor?) -> [Room] {
        var rooms: [Room] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return rooms }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomRequest = NSFetchRequest<Room>(entityName: CleaConstants.entityNameRoom)
        if sort != nil {
            roomRequest.sortDescriptors = [sort!]
        }
        
        do {
            rooms = try managedObjectContext.fetch(roomRequest)
        } catch let error as NSError {
            print("Could not load rooms. \(error), \(error.userInfo)")
        }
        
        return rooms
    }
    
    static func fetchAllRoomTypes() -> [RoomType] {
        var types: [RoomType] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return types
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomTypeRequest = NSFetchRequest<RoomType>(entityName: CleaConstants.entityNameRoomType)
        let roomTypeSortByName = NSSortDescriptor(key: CleaConstants.keyNameName, ascending: true)
        roomTypeRequest.sortDescriptors = [roomTypeSortByName]
        
        do {
            types = try managedObjectContext.fetch(roomTypeRequest)
        } catch let error as NSError {
            print("Could not load room types. \(error), \(error.userInfo)")
        }
        
        return types
    }
    
    static func fetchAllTasks(sortBy sort: NSSortDescriptor?) -> [Task] {
        var tasks: [Task] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return tasks }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let taskRequest = NSFetchRequest<Task>(entityName: CleaConstants.entityNameTask)
        if sort != nil {
            taskRequest.sortDescriptors = [sort!]
        }
        
        do {
            tasks = try managedObjectContext.fetch(taskRequest)
        } catch let error as NSError {
            print("Could not load tasks. \(error), \(error.userInfo)")
        }
        
        return tasks
    }
    
    static func fetchAllIntervalTypes() -> [IntervalType] {
        var intervalTypes: [IntervalType] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return intervalTypes
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let intervalRequest = NSFetchRequest<IntervalType>(entityName: CleaConstants.entityNameIntervalType)
        let intervalSortByDays = NSSortDescriptor(key: CleaConstants.keyNameDays, ascending: true)
        intervalRequest.sortDescriptors = [intervalSortByDays]
        
        do {
            intervalTypes = try managedObjectContext.fetch(intervalRequest)
        } catch let error as NSError {
            print("Could not load task intervals. \(error), \(error.userInfo)")
        }
        
        return intervalTypes
    }
    
    static func createNewRoom() -> Room? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        return Room(context: managedObjectContext)
    }
    
    static func createNewTask() -> Task? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        return Task(context: managedObjectContext)
    }
    
    static func save() -> Bool? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save changes. \(error), \(error.userInfo)")
            managedObjectContext.rollback()
            return false
        }
        
        return true
    }
    
    static func delete(forObject object: NSManagedObject) -> Bool? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        managedObjectContext.delete(object)
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not delete object. \(error), \(error.userInfo)")
            managedObjectContext.rollback()
            return false
        }
        
        return true
    }
    
}
