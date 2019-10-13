//
//  UIPickerTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 10/9/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

protocol RoomTypeTableViewCellDelegate: class {
    func didChangeRoomType(roomType: RoomType)
}

class RoomTypeTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String = "PickerTableViewCellIdentifier"
    static var cellHeight: CGFloat = 216
    static var cellWidth: CGFloat = 345
    
    weak var delegate: RoomTypeTableViewCellDelegate?
    var roomTypePickerView: UIPickerView!
    var roomTypes: [RoomType] = []
    var selectedRoomType: RoomType?
    
    // MARK: - View Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.secondarySystemBackground
        self.setupUIPickerView()
        
        roomTypes = DataController.fetchAllRoomTypes()
    }
    
    // MARK: - View Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        var row: Int = 0
        if let roomType = self.selectedRoomType {
            row = roomTypes.firstIndex(of: roomType)!
        }
        
        roomTypePickerView.selectRow(row, inComponent: 0, animated: true)
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roomTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRoomType = roomTypes[row]
        delegate?.didChangeRoomType(roomType: selectedRoomType!)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: roomTypes[row].name!, attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: CleaConstants.accentColorName)!])
        return attributedString
    }
    
    // MARK: - Private Methods
    
    func setupUIPickerView() {
        roomTypePickerView = UIPickerView(frame: CGRect(x: 15, y: 0, width: RoomTypeTableViewCell.cellWidth, height: RoomTypeTableViewCell.cellHeight))
        roomTypePickerView.delegate = self
        roomTypePickerView.dataSource = self
        
        self.contentView.addSubview(roomTypePickerView)
    }
    
}
