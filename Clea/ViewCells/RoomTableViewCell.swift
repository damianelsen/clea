//
//  RoomTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 8/10/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    static var nibName: String = "RoomTableViewCell"
    static var reuseIdentifier: String = "RoomTableViewCellIdentifier"
    
    var room: Room?
    
    // MARK: - Outlets
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var taskCount: UILabel!
    @IBOutlet weak var tasksOverdue: UILabel!
    
    // MARK: - View Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - View Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard room != nil, room!.name != nil else { return }
        
        name?.text = room!.name
        type?.text = room!.type?.name
        taskCount?.text = taskCountMessage(forRoom: room!)
        tasksOverdue?.text = overdueTaskMessage(forRoom: room!)
    }
    
    // MARK: - Private Methods
    
    private func taskCountMessage(forRoom room: Room) -> String {
        var message = "\(room.tasks?.count == 0 ? "No" : (room.tasks?.count.description)!) task"
        message += (room.tasks?.count != 1 ? "s" : "")
        
        return message
    }
    
    private func overdueTaskMessage(forRoom room: Room) -> String {
        var message = ""
        let now = Calendar.current.startOfDay(for: Date())
        let overduePredicate = NSPredicate(format: CleaConstants.predicateOverdueTask, now as CVarArg)
        let overdueTasks = room.tasks?.filtered(using: overduePredicate)
        let dueTodayPredicate = NSPredicate(format: CleaConstants.predicateDueTodayTask, now as CVarArg)
        let dueTodayTasks = room.tasks?.filtered(using: dueTodayPredicate)
        
        if overdueTasks!.count > 0 {
            message = "\(overdueTasks!.count.description) overdue"
        }
        
        if dueTodayTasks!.count > 0 {
            if overdueTasks!.count == 0 {
                message = "\(dueTodayTasks!.count.description) due today"
            } else {
                message += " and \(dueTodayTasks!.count.description) today"
            }
        }
        
        return message
    }
    
}
