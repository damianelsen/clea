//
//  TaskViewController.swift
//  Clea
//
//  Created by Damian Elsen on 9/10/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    var task: Task?
    var room: Room?
    var rooms: [Room] = []
    var intervalTypes: [IntervalType] = []
    var intervals: [String] = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    
    // MARK: - Outlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var roomPickerView: UIPickerView!
    @IBOutlet weak var intervalPickerView: UIPickerView!
    
    // MARK: - Actions
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskNameTextField.delegate = self
        roomPickerView.delegate = self
        roomPickerView.dataSource = self
        intervalPickerView.delegate = self
        intervalPickerView.dataSource = self
        
        let roomSortByName = NSSortDescriptor(key: CleaConstants.keyNameName, ascending: true)
        rooms = DataController.fetchAllRooms(sortBy: roomSortByName)
        intervalTypes = DataController.fetchAllIntervalTypes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let task = self.task {
            let roomIndex = rooms.firstIndex(of: task.ofRoom!)!
            let intervalIndex = intervalTypes.firstIndex(of: task.intervalType!)!
            
            navigationItem.title = task.name
            taskNameTextField.text = task.name
            roomPickerView.selectRow(roomIndex, inComponent: 0, animated: true)
            intervalPickerView.selectRow(Int(task.interval - 1), inComponent: 0, animated: true)
            intervalPickerView.selectRow(intervalIndex, inComponent: 1, animated: true)
        } else {
            self.intervalPickerView.selectRow(1, inComponent: 1, animated: true)
            saveButton.isEnabled = false
        }
        
        if let room = self.room {
            let roomIndex = rooms.firstIndex(of: room)!
            roomPickerView.selectRow(roomIndex, inComponent: 0, animated: true)
            roomPickerView.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else { return }
        
        let name = taskNameTextField.text ?? ""
        let room = rooms[roomPickerView.selectedRow(inComponent: 0)]
        let interval = Int16(self.intervals[intervalPickerView.selectedRow(inComponent: 0)]) ?? 1
        let intervalType = self.intervalTypes[intervalPickerView.selectedRow(inComponent: 1)]
        
        if !name.isEmpty {
            if task == nil {
                task = DataController.createNewTask()
                task?.dateCreated = Date()
                task?.lastCompleted = Calendar.current.startOfDay(for: Date())
            }
            
            task?.name = name.trimmingCharacters(in: .whitespaces)
            task?.ofRoom = room
            task?.interval = interval
            task?.intervalType = intervalType
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
        
        navigationItem.title = name.isEmpty ? "New Task" : name
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView == roomPickerView ? 1 : 2;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == roomPickerView {
            return rooms.count
        } else {
            return component == 0 ? intervals.count : intervalTypes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string: String
        
        if pickerView == roomPickerView {
            string = rooms[row].name!
        } else {
            string = component == 0 ? intervals[row] : intervalTypes[row].name!
        }
        let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: CleaConstants.accentColorName)!])
        
        return attributedString
    }
    
    // MARK: - Private Methods
    
    private func updateSaveButtonState(value: String) {
        saveButton.isEnabled = !value.isEmpty && rooms.count != 0
    }
    
}
