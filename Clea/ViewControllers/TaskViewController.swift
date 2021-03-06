//
//  TaskViewController.swift
//  Clea
//
//  Created by Damian Elsen on 9/10/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var task: Task?
    var selectedRoom: Room?
    var selectedInterval: Int = 7
    var selectedIntervalType: IntervalType?
    var selectedLastCompleted: Date = Calendar.current.startOfDay(for: Date())
    var isSingleRoomView: Bool = false
    var cellTextLabels: [String] = ["Room", "Due Every", "Last Completed", "Added"]
    var visiblePickerIndexPath: IndexPath? = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var taskNameContainerView: UIView!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskDetailTableView: UITableView!
    
    // MARK: - Actions
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskNameContainerView.layer.cornerRadius = 10;
        taskNameContainerView.layer.masksToBounds = true;
        
        taskNameTextField.delegate = self
        
        taskDetailTableView.delegate = self
        taskDetailTableView.dataSource = self
        taskDetailTableView.register(TaskRoomTableViewCell.self, forCellReuseIdentifier: TaskRoomTableViewCell.reuseIdentifier)
        taskDetailTableView.register(TaskIntervalTableViewCell.self, forCellReuseIdentifier: TaskIntervalTableViewCell.reuseIdentifier)
        taskDetailTableView.register(TaskLastCompletedTableViewCell.self, forCellReuseIdentifier: TaskLastCompletedTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let task = self.task {
            navigationItem.title = task.name
            taskNameTextField.text = task.name
            selectedRoom = task.ofRoom
            selectedInterval = Int(task.interval)
            selectedIntervalType = task.intervalType
            selectedLastCompleted = task.lastCompleted!
        } else {
            let roomSortByName = NSSortDescriptor(key: CleaConstants.keyNameName, ascending: true)
            let rooms = DataController.fetchAllRooms(sortBy: roomSortByName)
            if rooms.count > 0 && selectedRoom == nil {
                selectedRoom = rooms[0]
            }
            let intervalTypes = DataController.fetchAllIntervalTypes()
            selectedIntervalType = intervalTypes[0]
            saveButton.isEnabled = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else { return }
        
        let name = taskNameTextField.text ?? ""
        
        if !name.isEmpty {
            if task == nil {
                task = DataController.createNewTask()
                task?.dateCreated = Date()
            }
            
            task?.name = name.trimmingCharacters(in: .whitespaces)
            task?.ofRoom = selectedRoom
            task?.interval = Int16(selectedInterval)
            task?.intervalType = selectedIntervalType
            task?.lastCompleted = selectedLastCompleted
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
        
        navigationItem.title = name.isEmpty ? "New Task" : name
        
        saveButton.isEnabled = !name.isEmpty && selectedRoom != nil
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visiblePickerIndexPath == nil ? cellTextLabels.count : cellTextLabels.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == visiblePickerIndexPath {
            switch indexPath.row {
            case 1:
                return createRoomPickerTableViewCell(cellForRowAt: indexPath)
            case 2:
                return createIntervalPickerTableViewCell(cellForRowAt: indexPath)
            default:
                return createLastCompletedPickerTableViewCell(cellForRowAt: indexPath)
            }
        } else {
            return createTableViewCell(cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath == visiblePickerIndexPath ? TaskRoomTableViewCell.cellHeight : 44
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if visiblePickerIndexPath == nil && indexPath.row == 3 { return }
        if visiblePickerIndexPath != nil && indexPath.row == 4 { return }
        if isSingleRoomView && indexPath.row == 0 { return }
        
        tableView.beginUpdates()
        
        if let pickerIndexPath = visiblePickerIndexPath, pickerIndexPath.row - 1 == indexPath.row {
            visiblePickerIndexPath = nil
            tableView.deleteRows(at: [pickerIndexPath], with: .middle)
        } else {
            if let pickerIndexPath = visiblePickerIndexPath {
               tableView.deleteRows(at: [pickerIndexPath], with: .middle)
            }
            visiblePickerIndexPath = determineVisiblePickerIndexPath(forIndexPath: indexPath)
            tableView.insertRows(at: [visiblePickerIndexPath!], with: .middle)
        }
        
        tableView.endUpdates()
    }
    
    // MARK: - Private Methods
    
    private func createTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = visiblePickerIndexPath != nil && indexPath.row > visiblePickerIndexPath!.row ? indexPath.row - 1 : indexPath.row
        let cell = taskDetailTableView.dequeueReusableCell(withIdentifier: CleaConstants.cellReuseIdentifierTaskDetail, for: indexPath)
        var detailText = ""
        
        switch row {
        case 0:
            cell.layer.cornerRadius = 10;
            cell.layer.masksToBounds = true;
            cell.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            detailText = selectedRoom != nil ? selectedRoom!.name! : ""
        case 1:
            cell.layer.cornerRadius = 0;
            let intervalType = selectedInterval == 1 ? String((selectedIntervalType?.name!.dropLast())!) : selectedIntervalType?.name
            detailText = "\(selectedInterval) \(intervalType!)"
        case 2:
            cell.layer.cornerRadius = 0;
            detailText = Shared.formatDate(fromDate: selectedLastCompleted)
        default:
            cell.layer.cornerRadius = 10;
            cell.layer.masksToBounds = true;
            cell.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            cell.detailTextLabel?.textColor = .label
            detailText = Shared.formatDate(fromDate: task != nil ? Calendar.current.startOfDay(for: task!.dateCreated!) : Calendar.current.startOfDay(for: Date()))
        }
        
        cell.textLabel?.text = cellTextLabels[row]
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
    
    private func createRoomPickerTableViewCell(cellForRowAt indexPath: IndexPath) -> TaskRoomTableViewCell {
        let cell = taskDetailTableView.dequeueReusableCell(withIdentifier: TaskRoomTableViewCell.reuseIdentifier, for: indexPath) as! TaskRoomTableViewCell
        
        cell.delegate = self
        cell.selectedRoom = selectedRoom
        
        return cell
    }
    
    private func createIntervalPickerTableViewCell(cellForRowAt indexPath: IndexPath) -> TaskIntervalTableViewCell {
        let cell = taskDetailTableView.dequeueReusableCell(withIdentifier: TaskIntervalTableViewCell.reuseIdentifier, for: indexPath) as! TaskIntervalTableViewCell
        
        cell.delegate = self
        cell.selectedInterval = selectedInterval
        cell.selectedIntervalType = selectedIntervalType
        
        return cell
    }
    
    private func createLastCompletedPickerTableViewCell(cellForRowAt indexPath: IndexPath) -> TaskLastCompletedTableViewCell {
        let cell = taskDetailTableView.dequeueReusableCell(withIdentifier: TaskLastCompletedTableViewCell.reuseIdentifier, for: indexPath) as! TaskLastCompletedTableViewCell
        
        cell.delegate = self
        cell.selectedLastCompleted = selectedLastCompleted
        
        return cell
    }
    
    private func determineVisiblePickerIndexPath(forIndexPath indexPath: IndexPath) -> IndexPath {
        if let pickerIndexPath = visiblePickerIndexPath, pickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
}

extension TaskViewController: TaskRoomTableViewCellDelegate {
    
    func didChangeRoom(forRoom room: Room) {
        selectedRoom = room
        taskDetailTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
}

extension TaskViewController: TaskIntervalTableViewCellDelegate {
    
    func didChangeInterval(forInterval interval: Int, andIntervalType intervalType: IntervalType) {
        selectedInterval = interval
        selectedIntervalType = intervalType
        taskDetailTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }
    
}

extension TaskViewController: TaskLastCompletedTableViewCellDelegate {
    
    func didChangeLastCompleted(forDate date: Date) {
        selectedLastCompleted = date
        taskDetailTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
    }
    
}
