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
        
        roomTypes = getRoomTypes()
        
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
        
        let roomNameTextFieldBottomBorder = CALayer()
        roomNameTextFieldBottomBorder.frame = CGRect(x: 0.0, y: roomNameTextField.frame.height - 1, width: roomNameTextField.frame.width, height: 1.0)
        roomNameTextFieldBottomBorder.backgroundColor = CleaColors.accentColor.cgColor
        roomNameTextField.layer.addSublayer(roomNameTextFieldBottomBorder)

        guard self.room == nil else {
            return
        }
        
        self.roomTypePickerView.selectRow(2, inComponent: 0, animated: true)
        saveButton.isEnabled = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let name = roomNameTextField.text ?? ""
        let type = roomTypes[roomTypePickerView.selectedRow(inComponent: 0)]
        
        if (!name.isEmpty) {
            
            if (room == nil) {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                let managedObjectContext = appDelegate.persistentContainer.viewContext
                
                room = Room(context: managedObjectContext)
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
        var roomName = textField.text ?? ""
        roomName = roomName.trimmingCharacters(in: .whitespaces)
        
        guard let exists = roomExists(withName: roomName), !exists else {
            let alert = UIAlertController(title: "Duplicate Room", message: "A room with this name already exists. Please choose a different name.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
            return
        }
        
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
        let roomTypeSortByName = NSSortDescriptor(key: "name", ascending: true)
        roomTypeRequest.sortDescriptors = [roomTypeSortByName]
        
        do {
            types = try managedObjectContext.fetch(roomTypeRequest)
        } catch let error as NSError {
            print("Could not load room types. \(error), \(error.userInfo)")
        }
        
        return types
    }
    
    private func roomExists(withName: String) -> Bool? {
        var exists = true
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return exists
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomRequest = NSFetchRequest<Room>(entityName: "Room")
        let roomNamePredicate = NSPredicate(format: "name = %@", withName)
        roomRequest.predicate = roomNamePredicate
        
        do {
            let rooms = try managedObjectContext.fetch(roomRequest)
            exists = rooms.count != 0
        } catch let error as NSError {
            print("Could not load rooms. \(error), \(error.userInfo)")
        }
        
        return exists
    }
    
}
