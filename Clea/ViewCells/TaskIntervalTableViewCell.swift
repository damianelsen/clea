//
//  TaskIntervalTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 10/17/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

protocol TaskIntervalTableViewCellDelegate: class {
    func didChangeInterval(interval: Int, intervalType: IntervalType)
}

class TaskIntervalTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String = "TaskIntervalTableViewCellIdentifier"
    static var cellHeight: CGFloat = 216
    
    weak var delegate: TaskIntervalTableViewCellDelegate?
    var intervalPickerView: UIPickerView!
    var intervalTypes: [IntervalType] = []
    var selectedInterval: Int?
    var selectedIntervalType: IntervalType?
    
    // MARK: - View Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.secondarySystemBackground
        self.setupUIPickerView()
        
        intervalTypes = DataController.fetchAllIntervalTypes()
    }
    
    // MARK: - View Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let intervalRow = (selectedInterval ?? 1) - 1
        var intervalTypeRow: Int = 0
        if let intervalType = selectedIntervalType {
            intervalTypeRow = intervalTypes.firstIndex(of: intervalType)!
        }
        
        intervalPickerView.selectRow(intervalRow, inComponent: 0, animated: false)
        intervalPickerView.selectRow(intervalTypeRow, inComponent: 1, animated: false)
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 12 : intervalTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedInterval = row + 1
        } else {
            selectedIntervalType = intervalTypes[row]
        }
        
        delegate?.didChangeInterval(interval: selectedInterval!, intervalType: selectedIntervalType!)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? String(row + 1) : intervalTypes[row].name!
    }
    
    // MARK: - Private Methods
    
    private func setupUIPickerView() {
        intervalPickerView = UIPickerView(frame: CGRect(x: 15, y: 0, width: 330, height: TaskIntervalTableViewCell.cellHeight))
        intervalPickerView.delegate = self
        intervalPickerView.dataSource = self
        
        self.contentView.addSubview(intervalPickerView)
    }
    
}
