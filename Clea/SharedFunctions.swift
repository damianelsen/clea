//
//  SharedFunctions.swift
//  Clea
//
//  Created by Damian Elsen on 10/25/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import Foundation

class Shared {
    
    static func formatDate(fromDate date: Date) -> String {
        switch date {
        case Calendar.current.startOfDay(for: Date()):
            return "Today"
        case Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!):
            return "Yesterday"
        default:
            let dateFormatter = DateFormatter()
            
            dateFormatter.locale = .current
            dateFormatter.dateStyle = .medium
            
            return dateFormatter.string(from: date)
        }
    }
    
    static func overdueMessage(forTask task: Task, withDate date: Date) -> String {
        var message = ""
        let now = Calendar.current.startOfDay(for: date)
        let days = Int(task.intervalType!.noOfDays * task.interval)
        let dueDate = Calendar.current.date(byAdding: .day, value: days, to: task.lastCompleted!)!
        let dateDiff = Calendar.current.dateComponents([.day], from: now, to: dueDate)
        let dueDays = dateDiff.day!
        
        switch dueDays {
        case ...(-1):
            message = "overdue"
        case 0:
            message = "today"
        case 1:
            message = "tomorrow"
        case 2...13:
            message = "in \(dueDays.description) day\(dueDays == 1 ? "" : "s")"
        case 14...29:
            let weeks = dueDays / 7
            message = "in \(weeks.description) weeks"
        default:
            let months = dueDays / 30
            message = "in \(months.description) month\(months == 1 ? "" : "s")"
        }
        
        return message
    }
    
}
