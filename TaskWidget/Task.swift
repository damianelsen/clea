//
//  Task.swift
//  TaskWidgetExtension
//
//  Created by Damian Elsen on 11/11/20.
//  Copyright © 2020 Damian Elsen. All rights reserved.
//

import Foundation
import WidgetKit

struct Task: Identifiable {
    let message: String
    public var id: String {
        return self.message
    }
}

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [Task]
    let overdueCount: Int
}

extension TaskEntry {
    static let previewData = TaskEntry(date: Date(), tasks: [
        Task(message: "Clean Shower in the Master Bathroom is overdue"),
        Task(message: "Wipe Surfaces in the Kitchen is due today"),
        Task(message: "Dust in the TV Room is due tomorrow"),
        Task(message: "Change Bed Linen in the Bedroom is due in 2 days")
    ],
    overdueCount: 1)
}
