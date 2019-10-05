//
//  AppDelegate.swift
//  Clea
//
//  Created by Damian Elsen on 7/19/18.
//  Copyright © 2018 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Types
    
    typealias Interval = (name: String, noOfDays: Int16)
    
    // MARK: - Properties
    
    var window: UIWindow?

    // MARK: - Application Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Notifications.requestAuthorization()
        
        self.createStaticData()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UIApplication.shared.applicationIconBadgeNumber = Notifications.getBadgeCount()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CleaConstants.notificationRefreshTasks), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CleaConstants.notificationRefreshRooms), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Clea")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Private Methods - Static Data Creation
    
    private func createStaticData() {
        let mainContext = persistentContainer.viewContext
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        childContext.parent = mainContext
        childContext.perform {
            self.createRoomTypes(usingContext: childContext)
            self.createIntervalTypes(usingContext: childContext)
            
            do {
                try mainContext.save()
            } catch let error as NSError {
                print("Could not create static data. \(error), \(error.userInfo)")
            }
        }
    }
    
    private func createRoomTypes(usingContext: NSManagedObjectContext) {
        let roomTypes = ["Living Room", "Bedroom", "Bathroom", "Kitchen", "Dining Room", "Office"]
        let roomTypeRequest = NSFetchRequest<RoomType>(entityName: CleaConstants.entityNameRoomType)
        var existingRoomTypes: [RoomType] = []
        
        do {
            existingRoomTypes = try usingContext.fetch(roomTypeRequest)
        } catch let error as NSError {
            print("Could not load room types. \(error), \(error.userInfo)")
        }
        
        guard existingRoomTypes.count == 0 else { return }
        
        for type in roomTypes {
            let roomType = RoomType(context: usingContext)
            roomType.name = type
        }
        
        do {
            try usingContext.save()
        } catch let error as NSError {
            print("Could not create room types. \(error), \(error.userInfo)")
        }
    }
    
    private func createIntervalTypes(usingContext: NSManagedObjectContext) {
        let intervalTypes: [Interval] = [("Days", 1), ("Weeks", 7), ("Months", 30)]
        let intervalTypeRequest = NSFetchRequest<IntervalType>(entityName: CleaConstants.entityNameIntervalType)
        var existingIntervalTypes: [IntervalType] = []
        
        do {
            existingIntervalTypes = try usingContext.fetch(intervalTypeRequest)
        } catch let error as NSError {
            print("Could not load interval types. \(error), \(error.userInfo)")
        }
        
        guard existingIntervalTypes.count == 0 else { return }
        
        for type in intervalTypes {
            let intervalType = IntervalType(context: usingContext)
            intervalType.name = type.name
            intervalType.noOfDays = type.noOfDays
        }
        
        do {
            try usingContext.save()
        } catch let error as NSError {
            print("Could not create interval types. \(error), \(error.userInfo)")
        }
    }
    
}
