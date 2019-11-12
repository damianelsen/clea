//
//  TaskLastCompletedTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 10/18/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

protocol TaskLastCompletedTableViewCellDelegate: class {
    func didChangeLastCompleted(forDate date: Date)
}

class TaskLastCompletedTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String = "TaskLastCompletedTableViewCellIdentifier"
    static var cellHeight: CGFloat = 216
    
    weak var delegate: TaskLastCompletedTableViewCellDelegate?
    var datePickerView: UIDatePicker!
    var selectedLastCompleted: Date = Date()
    
    // MARK: - View Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.secondarySystemBackground
        
        self.setupUIDatePicker()
    }
    
    // MARK: - View Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        datePickerView.setDate(selectedLastCompleted, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupUIDatePicker() {
        datePickerView = UIDatePicker(frame: CGRect(x: 15, y: 0, width: 315, height: TaskLastCompletedTableViewCell.cellHeight))
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date()
        datePickerView.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        self.contentView.addSubview(datePickerView)
    }
    
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        delegate?.didChangeLastCompleted(forDate: sender.date)
    }
    
}
