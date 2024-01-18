//
//  TaskRoomTableViewCell.swift
//  Clea
//
//  Created by Damian Elsen on 10/17/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

protocol TaskRoomTableViewCellDelegate: AnyObject {
    func didChangeRoom(forRoom: Room)
}

class TaskRoomTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String = "TaskRoomTableViewCellIdentifier"
    static var cellHeight: CGFloat = 216
    static var cellWidth: CGFloat = 330
    
    weak var delegate: TaskRoomTableViewCellDelegate?
    var roomPickerView: UIPickerView!
    var rooms: [Room] = []
    var selectedRoom: Room?
    
    // MARK: - View Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.secondarySystemBackground
        self.setupUIPickerView()
        
        let roomSortByName = NSSortDescriptor(key: CleaConstants.keyNameName, ascending: true)
        rooms = DataController.fetchAllRooms(sortBy: roomSortByName)
    }
    
    // MARK: - View Overrides
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        var row: Int = 0
        if let room = selectedRoom {
            row = rooms.firstIndex(of: room)!
        }
        
        roomPickerView.selectRow(row, inComponent: 0, animated: false)
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rooms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if rooms.count > 0 {
            selectedRoom = rooms[row]
            delegate?.didChangeRoom(forRoom: selectedRoom!)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rooms[row].name!
    }
    
    // MARK: - Private Methods
    
    private func setupUIPickerView() {
        roomPickerView = UIPickerView(frame: CGRect(x: 15, y: 0, width: TaskRoomTableViewCell.cellWidth, height: TaskRoomTableViewCell.cellHeight))
        roomPickerView.delegate = self
        roomPickerView.dataSource = self
        
        self.contentView.addSubview(roomPickerView)
    }
    
}
