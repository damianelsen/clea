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
    
    static var nibName: String = "TaskTableViewCell"
    static var reuseIdentifier: String = "TaskTableViewCellIdentifier"
    
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
        taskDue.text = Shared.overdueMessage(forTask: task!, withDate: Date())
        
        let messageColor = color(forMessage: taskDue.text!)
        
        self.taskDue?.textColor = messageColor
        self.taskDue?.highlightedTextColor = messageColor
    }
    
    // MARK: - Private Methods
    
    private func color(forMessage message: String) -> UIColor {
        var color = UIColor(named: CleaConstants.taskScheduledColorName)
        
        if message.contains("overdue") {
            color = UIColor(named: CleaConstants.taskOverdueColorName)
        } else if message.contains("today") {
            color = UIColor(named: CleaConstants.taskDueColorName)
        }
        
        return color!
    }
    
}
