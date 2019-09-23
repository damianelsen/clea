//
//  Notifications.swift
//  Clea
//
//  Created by Damian Elsen on 9/21/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class Notifications {
    
    // MARK: - Public Methods - Notifications
    
    static func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: options) { (didAllow, error) in
            // Do nothing
        }
    }
    
    static func scheduleNotification(forTask: Task) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .authorized) {
                self.addNotification(forTask: forTask)
            } else {
                self.removeNotification(forTask: forTask)
            }
        }
    }
    
    static func removeNotification(forTask: Task) {
        let taskID = forTask.objectID.uriRepresentation().description
        let notificationIdentifier = "\(CleaConstants.notificationIdentifier) \(taskID)"
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
    
    static func getBadgeCount() -> Int {
        var count = 0
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return count }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomRequest = NSFetchRequest<Room>(entityName: CleaConstants.entityNameRoom)
        var rooms: [Room] = []
        
        do {
            rooms = try managedObjectContext.fetch(roomRequest)
        } catch let error as NSError {
            print("Could not load rooms. \(error), \(error.userInfo)")
        }
        
        let overduePredicate = NSPredicate(format: CleaConstants.predicateOverdueTask, Date() as CVarArg)
        
        for room in rooms {
            let overdueTasks = room.tasks?.filtered(using: overduePredicate)
            count += overdueTasks!.count
        }
        
        return count
    }
    
    // MARK: - Private Methods - Notifications
    
    private static func addNotification(forTask: Task) {
        let taskID = forTask.objectID.uriRepresentation().description
        let notificationIdentifier = "\(CleaConstants.notificationIdentifier) \(taskID)"
        let days = Int(forTask.intervalType!.noOfDays * forTask.interval)
        let dueDate = Calendar.current.date(byAdding: .day, value: days, to: forTask.lastCompleted!)!
        let notificationTime = Calendar.current.date(byAdding: .hour, value: 9, to: dueDate)!
        let triggerTime = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerTime, repeats: false)
        let taskName = forTask.name!
        let roomName = forTask.ofRoom!.name
        let content = UNMutableNotificationContent()
        
//        content.title = "Time to do some cleaning!"
        content.body = "\(taskName) in the \(roomName!) is due today"
        content.sound = UNNotificationSound.default
        
        let notificationCenter = UNUserNotificationCenter.current()
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            // Do nothing
        }
    }
    
}
