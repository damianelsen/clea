//
//  RoomTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 8/10/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var room: Room?
    
    // MARK: - Outlets
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var taskCount: UILabel!
    @IBOutlet weak var tasksOverdue: UILabel!
    
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
        
        guard room != nil, room!.name != nil else {
            return
        }
        
        name?.text = room!.name
        type?.text = room!.type?.name
        taskCount?.text = taskCountMessage(forRoom: room!)
        tasksOverdue?.text = overdueTaskMessage(forRoom: room!)
    }
    
    // MARK: - Private Methods
    
    private func taskCountMessage(forRoom: Room) -> String {
        var message = (room!.tasks?.count == 0 ? "No" : (room!.tasks?.count.description)!) + " task"
        message += (room!.tasks?.count != 1 ? "s" : "")
        
        return message
    }
    
    private func overdueTaskMessage(forRoom: Room) -> String {
        var message = ""
        let now = Calendar.current.startOfDay(for: Date())
        let overduePredicateFormat = CleaConstants.predicateOverdueTask
        let overduePredicate = NSPredicate(format: overduePredicateFormat, now as CVarArg)
        let overdueTasks = forRoom.tasks?.filtered(using: overduePredicate)
        
        if (overdueTasks!.count > 0) {
            message = (overdueTasks!.count.description) + " overdue"
        }
        
        return message
    }
    
}
