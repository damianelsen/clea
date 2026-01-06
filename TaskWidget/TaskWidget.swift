//
//  TaskWidget.swift
//  TaskWidget
//
//  Created by Damian Elsen on 11/10/20.
//  Copyright © 2020 Damian Elsen. All rights reserved.
//

import SwiftUI
import WidgetKit

extension FileManager {
    static func sharedContainerURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CleaConstants.appGroup)!
    }
}

struct Provider: TimelineProvider {
    
    // MARK: - Public Methods
    
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry.previewData
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry.previewData
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let taskSummaries = self.importMostRecentTasks()
        var entries: [TaskEntry] = []
        
        for summary in taskSummaries {
            let taskMessages: [String] = summary["tasks"] as! [String]
            var tasks: [Task] = []
            for message in taskMessages {
                tasks.append(Task(message: message))
            }
            let date = self.getDate(fromText: summary["date"] as! String)
            let overdueCount = self.getOverdueCount(fromMessages: taskMessages)
            let entry = TaskEntry(date: date, tasks: tasks, overdueCount: overdueCount)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
    
    // MARK: - Private Methods
    
    private func importMostRecentTasks() -> [Dictionary<String, Any>] {
        let sharedDocumentDirectoryUrl = FileManager.sharedContainerURL()
        let fileUrl = sharedDocumentDirectoryUrl.appendingPathComponent(CleaConstants.tasksDataFilename)
        var taskMessages: [Dictionary<String, Any>] = []
        
        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            taskMessages = try (JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String, Any>])!
        } catch {
            print(error)
        }
        
        return taskMessages
    }
    
    private func getDate(fromText text: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
        return dateFormatter.date(from: text)!
    }
    
    private func getOverdueCount(fromMessages messages: [String]) -> Int {
        let overdue = messages.filter { message in
            return message.contains("overdue")
        }
        return overdue.count
    }
}

@main
struct TaskWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: CleaConstants.widgetIdentifier, provider: Provider()) { entry in
            TaskWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.widgetBackgroundColor)
        }
        .configurationDisplayName("Upcoming Tasks")
        .description("Your upcoming tasks at a glance.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
