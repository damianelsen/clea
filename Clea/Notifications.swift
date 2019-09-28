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
    
    // MARK: - Public Methods
    
    static func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (didAllow, error) in }
    }
    
    static func scheduleNotification(forTask: Task) {
        if (notificationsAreAuthorized()) {
            addNotification(forTask: forTask)
            resetBadgeNumbers()
        } else {
            removeNotification(forTask: forTask)
        }
    }
    
    static func removeNotification(forTask: Task) {
        let taskID = forTask.objectID.uriRepresentation().description
        let notificationIdentifier = "\(CleaConstants.notificationIdentifier) \(taskID)"
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
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
    
    // MARK: - Private Methods
    
    private static func notificationsAreAuthorized() -> Bool {
        var notificationSettings: UNNotificationSettings?
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global().async {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                notificationSettings = settings
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        guard let authorizationStatus = notificationSettings?.authorizationStatus else { return false }
        return authorizationStatus == .authorized
    }
    
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
        
        content.body = "\(taskName) in the \(roomName!) is due today"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in }
    }
    
    private static func resetBadgeNumbers() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let taskRequest = NSFetchRequest<Task>(entityName: CleaConstants.entityNameTask)
        var tasks: [Task] = []
        
        do {
            tasks = try managedObjectContext.fetch(taskRequest)
        } catch let error as NSError {
            print("Could not load tasks. \(error), \(error.userInfo)")
        }
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests(completionHandler: { notifications in
            for notification in notifications {
                let notificationTrigger = notification.trigger as! UNCalendarNotificationTrigger
                let overdueTasks = tasks.filter({ (task) -> Bool in
                    let days = Int(task.intervalType!.noOfDays * task.interval)
                    let dueDate = Calendar.current.date(byAdding: .day, value: days, to: task.lastCompleted!)!
                    return (dueDate < notificationTrigger.nextTriggerDate()!)
                })
                let content = UNMutableNotificationContent()
                
                content.body = notification.content.body
                content.sound = notification.content.sound
                content.badge = overdueTasks.count as NSNumber
                
                let request = UNNotificationRequest(identifier: notification.identifier, content: content, trigger: notification.trigger)
                notificationCenter.add(request) { (error) in }
            }
        })
    }
    
}
