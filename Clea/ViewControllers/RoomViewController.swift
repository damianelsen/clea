//
//  RoomViewController.swift
//  Clea
//
//  Created by Damian Elsen on 8/27/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var room: Room?
    var roomTypePickerIsVisible: Bool = false
    var selectedRoomType: RoomType?
    
    // MARK: - Outlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var roomNameContainerView: UIView!
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var roomTypeTableView: UITableView!
    @IBOutlet weak var roomTypeTableViewHeight: NSLayoutConstraint!
    
    // MARK: - Actions
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomTypeTableView.delegate = self
        roomTypeTableView.dataSource = self
        roomTypeTableView.layer.cornerRadius = 10;
        roomTypeTableView.layer.masksToBounds = true;
        
        roomNameContainerView.layer.cornerRadius = 10;
        roomNameContainerView.layer.masksToBounds = true;
        
        roomNameTextField.delegate = self
        
        roomTypeTableView.register(RoomTypeTableViewCell.self, forCellReuseIdentifier: RoomTypeTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let room = self.room {
            navigationItem.title = room.name
            roomNameTextField.text = room.name
            selectedRoomType = room.type
        } else {
            let roomTypes = DataController.fetchAllRoomTypes()
            selectedRoomType = roomTypes[0]
            saveButton.isEnabled = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else { return }
        
        let name = roomNameTextField.text ?? ""
        
        if !name.isEmpty {
            if room == nil {
                room = DataController.createNewRoom()
                room?.dateCreated = Date()
            }
            
            room?.name = name.trimmingCharacters(in: .whitespaces)
            room?.type = selectedRoomType
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var name = textField.text ?? ""
        name = name.trimmingCharacters(in: .whitespaces)
        
        navigationItem.title = name.isEmpty ? "New Room" : name
        
        saveButton.isEnabled = !name.isEmpty
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomTypePickerIsVisible ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CleaConstants.cellReuseIdentifierRoomType, for: indexPath)
            
            cell.backgroundColor = UIColor.secondarySystemBackground
            cell.textLabel?.text = "Room Type"
            cell.detailTextLabel?.text = selectedRoomType?.name
            cell.detailTextLabel?.textColor = UIColor(named: CleaConstants.accentColorName)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RoomTypeTableViewCell.reuseIdentifier, for: indexPath) as! RoomTypeTableViewCell
            cell.delegate = self
            
            if let room = self.room {
                cell.selectedRoomType = room.type
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 44 : RoomTypeTableViewCell.cellHeight
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            roomTypePickerIsVisible = !roomTypePickerIsVisible
            
            if roomTypePickerIsVisible {
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                roomTypeTableViewHeight.constant = 259
            } else {
                tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                roomTypeTableViewHeight.constant = 43
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

extension RoomViewController: RoomTypeTableViewCellDelegate {
    
    func didChangeRoomType(roomType: RoomType) {
        selectedRoomType = roomType
        roomTypeTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
}
