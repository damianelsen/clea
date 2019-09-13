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
        
        self.selectedBackgroundView = {
            let bgView = UIView(frame: .zero)
            bgView.backgroundColor = .darkGray
            return bgView
        }()
    }
    
    // MARK: - View Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard task != nil, task!.name != nil else {
            return
        }
        
        name.text = task!.name
        room.text = task!.ofRoom?.name
        taskDue.text = overdueMessage(forTask: task!)
        
        let messageColor = color(forMessage: taskDue.text!)
        
        self.taskDue?.textColor = messageColor
        self.taskDue?.highlightedTextColor = messageColor
    }
    
    // MARK: - Private Methods
    
    private func overdueMessage(forTask: Task) -> String {
        let days = Int(forTask.intervalType!.noOfDays * forTask.interval)
        let lastCompleted = Calendar.current.startOfDay(for: forTask.lastCompleted!)
        let dueDate = Calendar.current.date(byAdding: .day, value: days, to: lastCompleted)!
        let now = Calendar.current.startOfDay(for: Date())
        let dateDiff = Calendar.current.dateComponents([.day], from: now, to: dueDate)
        let dueDays = dateDiff.day!
        
        var message: String
        if (dueDays < 0) {
            message = "Overdue"
        } else if (dueDays == 0) {
            message = "Due today"
        } else if (dueDays == 1) {
            message = "Due tomorrow"
        } else {
            message = "Due in " + dueDays.description + " day" + (dueDays == 1 ? "" : "s")
        }
        
        return message
    }
    
    private func color(forMessage: String) -> UIColor {
        var color = UIColor.white
        
        if (forMessage.contains("Overdue")) {
            color = UIColor.red
        } else if (forMessage.contains("today") || forMessage.contains("tomorrow")) {
            color = UIColor.yellow
        }
        
        return color
    }
    
}
