//
//  TaskTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 8/12/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var task: Task?
    
    // MARK: - Outlets
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var taskDue: UILabel!
    
    // MARK: - View Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - View Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard task != nil, task!.name != nil else { return }
        
        name.text = task!.name
        room.text = task!.ofRoom?.name
        taskDue.text = overdueMessage(forTask: task!)
        
        let messageColor = color(forMessage: taskDue.text!)
        
        self.taskDue?.textColor = messageColor
        self.taskDue?.highlightedTextColor = messageColor
    }
    
    // MARK: - Private Methods
    
    private func overdueMessage(forTask: Task) -> String {
        var message = ""
        let now = Calendar.current.startOfDay(for: Date())
        let days = Int(forTask.intervalType!.noOfDays * forTask.interval)
        let dueDate = Calendar.current.date(byAdding: .day, value: days, to: forTask.lastCompleted!)!
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
    
    private func color(forMessage: String) -> UIColor {
        var color = UIColor(named: CleaConstants.taskScheduledColorName)
        
        if (forMessage.contains("overdue") || forMessage.contains("today")) {
            color = UIColor(named: CleaConstants.taskOverdueColorName)
        } else if (forMessage.contains("tomorrow")) {
            color = UIColor(named: CleaConstants.taskDueColorName)
        }
        
        return color!
    }
    
}
