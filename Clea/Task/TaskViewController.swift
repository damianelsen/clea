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
        
        rooms = getRooms()
        intervalTypes = getIntervalTypes()
        
        if let task = self.task {
            navigationItem.title = task.name
            taskNameTextField.text = task.name
            let roomIndex = rooms.firstIndex(of: task.ofRoom!)!
            roomPickerView.selectRow(roomIndex, inComponent: 0, animated: true)
            intervalPickerView.selectRow(Int(task.interval - 1), inComponent: 0, animated: true)
            let intervalIndex = intervalTypes.firstIndex(of: task.intervalType!)!
            intervalPickerView.selectRow(intervalIndex, inComponent: 1, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskNameTextField.borderStyle = UITextField.BorderStyle.none
        
        let taskNameTextFieldBottomBorder = CALayer()
        taskNameTextFieldBottomBorder.frame = CGRect(x: 0.0, y: taskNameTextField.frame.height - 1, width: taskNameTextField.frame.width, height: 1.0)
        taskNameTextFieldBottomBorder.backgroundColor = CleaColors.accentColor.cgColor
        taskNameTextField.layer.addSublayer(taskNameTextFieldBottomBorder)
        
        guard self.task != nil else {
            self.intervalPickerView.selectRow(1, inComponent: 1, animated: true)
            saveButton.isEnabled = false
            return
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let name = taskNameTextField.text ?? ""
        let room = rooms[roomPickerView.selectedRow(inComponent: 0)]
        let interval = Int16(self.intervals[intervalPickerView.selectedRow(inComponent: 0)]) ?? 1
        let intervalType = self.intervalTypes[intervalPickerView.selectedRow(inComponent: 1)]
        
        if (!name.isEmpty) {
            
            if (task == nil) {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                let managedObjectContext = appDelegate.persistentContainer.viewContext
                
                task = Task(context: managedObjectContext)
                task?.dateCreated = Date()
                task?.lastCompleted = .distantPast
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
        if (pickerView == roomPickerView) {
            return rooms.count
        } else {
            return component == 0 ? intervals.count : intervalTypes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == roomPickerView) {
            return rooms[row].name
        } else {
            return component == 0 ? intervals[row] : intervalTypes[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string: String
        if (pickerView == roomPickerView) {
            string = rooms[row].name!
        } else {
            string = component == 0 ? intervals[row] : intervalTypes[row].name!
        }
        let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : CleaColors.accentColor])
        
        return attributedString
    }
    
    // MARK: - Private Methods
    
    private func updateSaveButtonState(value: String) {
        saveButton.isEnabled = !value.isEmpty && rooms.count != 0
    }
    
    private func getRooms() -> [Room] {
        var rooms: [Room] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return rooms
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomRequest = NSFetchRequest<Room>(entityName: CleaConstants.entityNameRoom)
        let roomSortByName = NSSortDescriptor(key: CleaConstants.keyNameName, ascending: true)
        roomRequest.sortDescriptors = [roomSortByName]
        
        do {
            rooms = try managedObjectContext.fetch(roomRequest)
        } catch let error as NSError {
            print("Could not load rooms. \(error), \(error.userInfo)")
        }
        
        return rooms
    }
    
    private func getIntervalTypes() -> [IntervalType] {
        var intervalTypes: [IntervalType] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return intervalTypes
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let intervalRequest = NSFetchRequest<IntervalType>(entityName: CleaConstants.entityNameIntervalType)
        let intervalSortByDays = NSSortDescriptor(key: CleaConstants.keyNameDays, ascending: true)
        intervalRequest.sortDescriptors = [intervalSortByDays]
        
        do {
            intervalTypes = try managedObjectContext.fetch(intervalRequest)
        } catch let error as NSError {
            print("Could not load task intervals. \(error), \(error.userInfo)")
        }
        
        return intervalTypes
    }
    
}
