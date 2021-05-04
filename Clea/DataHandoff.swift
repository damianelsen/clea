//
//  DataHandoff.swift
//  Clea
//
//  Created by Damian Elsen on 11/18/20.
//  Copyright © 2020 Damian Elsen. All rights reserved.
//

import CoreData
import Foundation

extension FileManager {
    static func sharedContainerURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CleaConstants.appGroup)!
    }
}

class DataHandoff {
    
    // MARK: - Constants
    
    static var maxTasks: Int = 4
    static var maxDays: Int = 7
    
    // MARK: - Public Methods
    
    static func exportMostRecentTasks() {
        let sharedDocumentDirectoryUrl = FileManager.sharedContainerURL()
        let fileUrl = sharedDocumentDirectoryUrl.appendingPathComponent(CleaConstants.tasksDataFilename)
        
        var recentTasks: [Any] = []
        for day in 0...maxDays - 1 {
            recentTasks.append(self.getTaskSummary(withCount: maxTasks, forDay: day))
        }
        
        do {
            let tasks = try JSONSerialization.data(withJSONObject: recentTasks, options: [])
            try tasks.write(to: fileUrl, options: [.atomic])
        } catch {
            print(error)
        }
    }
    
    // MARK: - Private Methods
    
    private static func getTaskSummary(withCount count: Int, forDay day: Int) -> Dictionary<String, Any> {
        var tasks = DataController.fetchAllTasks(sortBy: nil)
        var tasksToExport: [String] = []
        let date = Calendar.current.date(byAdding: .day, value: day, to: Date())!
        
        self.sort(tasksToSort: &tasks)
        
        for task in tasks.prefix(count) {
            let taskName = task.name!
            let roomName = task.ofRoom!.name
            var due = Shared.overdueMessage(forTask: task, withDate: date)
            due = due == "overdue" ? due : "due \(due)"
            let taskMessage = "\(taskName) in the \(roomName!) is \(due)"
            tasksToExport.append(taskMessage)
        }
        
        let taskSummary: Dictionary<String, Any> = [
            "date": Calendar.current.startOfDay(for: date).description,
            "tasks": tasksToExport
        ]
        return taskSummary
    }
    
    private static func sort(tasksToSort: inout [Task]){
        tasksToSort.sort { task1, task2 in
            let now = Calendar.current.startOfDay(for: Date())
            let task1Days = Int(task1.intervalType!.noOfDays * task1.interval)
            let task2Days = Int(task2.intervalType!.noOfDays * task2.interval)
            let task1DueDate = Calendar.current.date(byAdding: .day, value: task1Days, to: task1.lastCompleted!)!
            let task2DueDate = Calendar.current.date(byAdding: .day, value: task2Days, to: task2.lastCompleted!)!
            let task1DateDiff = Calendar.current.dateComponents([.day], from: now, to: task1DueDate)
            let task2DateDiff = Calendar.current.dateComponents([.day], from: now, to: task2DueDate)
            let task1DueDays = task1DateDiff.day!
            let task2DueDays = task2DateDiff.day!
            
            return task1DueDays == task2DueDays ? task1.name! < task2.name! : task1DueDays < task2DueDays
        }
    }
    
}
