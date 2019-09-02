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
    
    var room: RoomModel?
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
        
        roomTypes = getRoomTypes()
        
        saveButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        roomNameTextField.borderStyle = UITextField.BorderStyle.none
        
        let roomNameTextFieldBottomBorder = CALayer()
        roomNameTextFieldBottomBorder.frame = CGRect(x: 0.0, y: roomNameTextField.frame.height - 1, width: roomNameTextField.frame.width, height: 1.0)
        roomNameTextFieldBottomBorder.backgroundColor = CleaColors.accentColor.cgColor
        roomNameTextField.layer.addSublayer(roomNameTextFieldBottomBorder)
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
        return roomTypes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: roomTypes[row].name!, attributes: [NSAttributedString.Key.foregroundColor : CleaColors.accentColor])
        return attributedString
    }
    
    // MARK: - Private Methods
    
    private func updateSaveButtonState(value: String) {
        saveButton.isEnabled = !value.isEmpty
    }
    
    private func getRoomTypes() -> [RoomType] {
        var types: [RoomType] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return types
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomTypeRequest = NSFetchRequest<RoomType>(entityName: "RoomType")
        
        do {
            types = try managedObjectContext.fetch(roomTypeRequest)
        } catch let error as NSError {
            print("Could not load room types. \(error), \(error.userInfo)")
        }
        
        return types
    }
    
}
