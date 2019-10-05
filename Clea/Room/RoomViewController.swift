//
//  RoomViewController.swift
//  Clea
//
//  Created by Damian Elsen on 8/27/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class RoomViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    var room: Room?
    var roomTypes: [RoomType] = []
    
    // MARK: - Outlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var roomTypePickerView: UIPickerView!
    
    // MARK: - Actions
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNameTextField.delegate = self
        roomTypePickerView.delegate = self
        roomTypePickerView.dataSource = self
        
        roomTypes = DataController.fetchAllRoomTypes()
        
        if let room = self.room {
            navigationItem.title = room.name
            
            roomNameTextField.text = room.name
            
            let row = roomTypes.firstIndex(of: room.type!)!
            roomTypePickerView.selectRow(row, inComponent: 0, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        roomNameTextField.borderStyle = UITextField.BorderStyle.none
        
        if (roomNameTextField.layer.sublayers?.count ?? 1 == 1) {
            let roomNameTextFieldBottomBorder = CALayer()
            roomNameTextFieldBottomBorder.frame = CGRect(x: 0.0, y: roomNameTextField.frame.height - 1, width: roomNameTextField.frame.width, height: 1.0)
            roomNameTextFieldBottomBorder.backgroundColor = UIColor(named: CleaConstants.accentColorName)?.cgColor
            roomNameTextField.layer.addSublayer(roomNameTextFieldBottomBorder)
        }

        guard self.room != nil else {
            self.roomTypePickerView.selectRow(2, inComponent: 0, animated: true)
            saveButton.isEnabled = false
            return
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else { return }
        
        let name = roomNameTextField.text ?? ""
        let type = roomTypes[roomTypePickerView.selectedRow(inComponent: 0)]
        
        if (!name.isEmpty) {
            
            if (room == nil) {
                room = DataController.createNewRoom()
                room?.dateCreated = Date()
            }
            
            room?.name = name.trimmingCharacters(in: .whitespaces)
            room?.type = type
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
        
        updateSaveButtonState(value: name)
        
        navigationItem.title = name.isEmpty ? "New Room" : name
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roomTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: roomTypes[row].name!, attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: CleaConstants.accentColorName)!])
        return attributedString
    }
    
    // MARK: - Private Methods
    
    private func updateSaveButtonState(value: String) {
        saveButton.isEnabled = !value.isEmpty
    }
    
}
