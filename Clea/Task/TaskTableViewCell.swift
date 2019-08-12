//
//  TaskTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 8/12/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var taskDue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectedBackgroundView = {
            let bgView = UIView(frame: .zero)
            bgView.backgroundColor = .darkGray
            return bgView
        }()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if ((self.taskDue?.text?.contains("Overdue"))!) {
            self.taskDue?.textColor = .red
            self.taskDue?.highlightedTextColor = .red
        }
    }
    
}
