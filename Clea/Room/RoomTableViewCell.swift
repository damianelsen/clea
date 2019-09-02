//
//  RoomTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 8/10/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {
    
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

        // Configure the view for the selected state
    }
    
}
