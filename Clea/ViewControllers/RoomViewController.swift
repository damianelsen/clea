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
    
    // MARK: - Actions
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNameContainerView.layer.cornerRadius = 10;
        roomNameContainerView.layer.masksToBounds = true;
        
        roomNameTextField.delegate = self
        
        roomTypeTableView.delegate = self
        roomTypeTableView.dataSource = self
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
        return roomTypePickerIsVisible ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if roomTypePickerIsVisible && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RoomTypeTableViewCell.reuseIdentifier, for: indexPath) as! RoomTypeTableViewCell
            cell.delegate = self
            
            if let room = self.room {
                cell.selectedRoomType = room.type
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CleaConstants.cellReuseIdentifierRoomType, for: indexPath)
            
            cell.layer.cornerRadius = 10;
            cell.layer.masksToBounds = true;
            
            switch indexPath.row {
            case 0:
                cell.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
                cell.textLabel?.text = "Room Type"
                cell.detailTextLabel?.text = selectedRoomType?.name
            default:
                cell.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
                cell.textLabel?.text = "Added"
                cell.detailTextLabel?.textColor = .label
                cell.detailTextLabel?.text = Shared.formatDate(fromDate: room != nil ? Calendar.current.startOfDay(for: room!.dateCreated!) : Calendar.current.startOfDay(for: Date()))
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return roomTypePickerIsVisible && indexPath.row == 1 ? TaskRoomTableViewCell.cellHeight : 44
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        if indexPath.row == 0 {
            roomTypePickerIsVisible = !roomTypePickerIsVisible
            
            if roomTypePickerIsVisible {
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            } else {
                tableView.deleteRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
    }
    
}

extension RoomViewController: RoomTypeTableViewCellDelegate {
    
    func didChangeRoomType(forRoomType roomType: RoomType) {
        selectedRoomType = roomType
        roomTypeTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
}
