//
//  TaskWidgetView.swift
//  Clea
//
//  Created by Damian Elsen on 11/10/20.
//  Copyright © 2020 Damian Elsen. All rights reserved.
//

import SwiftUI
import WidgetKit

extension Color {
    static let cleaAccentColor = Color("AccentColor")
    static let textColor = Color("TextColor")
    static let dividerColor = Color("DividerColor")
    static let taskScheduledColor = Color("TaskScheduledColor")
    static let taskDueColor = Color("TaskDueColor")
    static let taskOverdueColor = Color("TaskOverdueColor")
}

struct TaskWidgetView: View {
    let entry: TaskEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.cleaAccentColor)
                    .font(.system(size: 30))
                    .padding(.bottom, 4)
                Text("Overdue")
                    .frame(width: 230, height: 34, alignment: .bottomTrailing)
                    .font(.system(size: 12))
                    .foregroundColor(.taskOverdueColor)
                    .padding(.bottom, 2)
                Text("\(entry.overdueCount)")
                    .frame(width: 24, height: 34, alignment: .trailing)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.taskOverdueColor)
                    .padding(.bottom, 1).padding(.vertical, 0)
            }
            ForEach(entry.tasks, id: \.id) { task in
                TaskRow(task: task)
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let textColor = Color.taskScheduledColor
    
    private func selectTextColor(for message: String) -> Color {
        if (message.contains("overdue") || message.contains("due today")) {
            return Color.taskOverdueColor
        } else if (message.contains("due tomorrow")) {
            return Color.taskDueColor
        } else {
            return Color.taskScheduledColor
        }
    }
    
    var body: some View {
        Divider()
            .frame(width: 300, height: 1)
            .background(Color.dividerColor)
        Text("\(task.message)")
            .frame(width: 300, height: 14, alignment: .topLeading)
            .font(.system(size: 11))
            .foregroundColor(selectTextColor(for: task.message))
            .padding(.vertical, -3)
    }
}

struct TaskWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TaskWidgetView(entry: .previewData)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
