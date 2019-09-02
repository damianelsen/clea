//
//  RoomViewController.swift
//  Clea
//
//  Created by Damian Elsen on 8/27/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    var room: RoomModel?
    var roomTypes: [String] = [String]()

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
        
        saveButton.isEnabled = false
        
        // TODO: Add Room Type as an entity in Core Data
        roomTypes = ["Living Room", "Bedroom", "Bathroom", "Kitchen", "Dining Room", "Office"]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let name = roomNameTextField.text ?? ""
        let type = roomTypes[roomTypePickerView.selectedRow(inComponent: 0)]
        
        room = RoomModel(name: name, type: type)
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
        let roomName = textField.text ?? ""
        updateSaveButtonState(value: roomName)
        navigationItem.title = roomName.isEmpty ? "New Room" : roomName
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roomTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roomTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: roomTypes[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.61223846670000004, green: 1.0, blue: 0.0, alpha: 1.0)])
        return attributedString
    }
    
    // MARK: - Private Methods
    
    private func updateSaveButtonState(value: String) {
        saveButton.isEnabled = !value.isEmpty
    }
    
}