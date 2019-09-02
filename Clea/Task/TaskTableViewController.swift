//
//  TaskTableViewController.swift
//  Clea
//
//  Created by Damian Elsen on 8/16/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: UITableViewController {
    
    let cellReuseIdentifier = "TaskTableViewCell"
    
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tasks"
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(rawValue: "reloadTaskTable"), object: nil)
        
        let taskTableViewCell = UINib(nibName: cellReuseIdentifier, bundle: nil)
        self.tableView.register(taskTableViewCell, forCellReuseIdentifier: cellReuseIdentifier)
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.load()
    }
    
    @objc func refreshTableView() {
        self.load()
        self.tableView.reloadData()
    }
    
    func load() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let taskRequest = NSFetchRequest<Task>(entityName: "Task")
        
        do {
            tasks = try managedObjectContext.fetch(taskRequest)
        } catch let error as NSError {
            print("Could not load tasks. \(error), \(error.userInfo)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let addAlert = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) {
            [unowned self] action in
            guard let nameTextField = addAlert.textFields?[0], let taskToSave = nameTextField.text else {
                return
            }
            guard let roomTextField = addAlert.textFields?[1], let roomToSave = roomTextField.text else {
                return
            }
            guard let intervalTextField = addAlert.textFields?[2], let intervalToSave = intervalTextField.text else {
                return
            }
            self.save(taskName: taskToSave, roomName: roomToSave, interval: Int(intervalToSave) ?? 0)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        addAlert.addTextField(configurationHandler: {
            textField in textField.placeholder = "What is the name of the new task?"
        })
        addAlert.addTextField(configurationHandler: {
            textField in textField.placeholder = "In what room does this task happen?"
        })
        addAlert.addTextField(configurationHandler: {
            textField in textField.placeholder = "Interval (in weeks)?"
        })
        addAlert.addAction(saveAction)
        addAlert.addAction(cancelAction)
        
        present(addAlert, animated: true)
    }
    
    func save(taskName: String, roomName: String, interval: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let task = Task(context: managedObjectContext)
        
        task.name = taskName
        task.dateCreated = Date()
        task.lastCompleted = .distantPast
        task.interval = Int16(interval)
        
        let roomRequest = NSFetchRequest<NSManagedObject>(entityName: "Room")
        roomRequest.predicate = NSPredicate(format: "name = %@", roomName)
        // TODO: Is there a better way to get the room rather than using its name?
        var roomResults: [NSManagedObject] = []
        do {
            roomResults = try managedObjectContext.fetch(roomRequest)
        } catch let error as NSError {
            print("Could not load room. \(error), \(error.userInfo)")
        }
        let room = roomResults[0] as! Room
        task.ofRoom = room
        
        do {
            try managedObjectContext.save()
            tasks.append(task)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRoomTable"), object: nil)
        } catch let error as NSError {
            print("Could not add new task. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! TaskTableViewCell
        let dueDate = Calendar.current.date(byAdding: .weekOfMonth, value: Int(task.interval), to: task.lastCompleted!)!
        let dueDays = Int(dueDate.timeIntervalSince(Date()) / 86400)
        var taskDue = "Due in " + dueDays.description + " day" + (dueDays == 1 ? "" : "s")
        taskDue = dueDays < 0 ? "Overdue" : taskDue
        // TODO: Needs work to correctly reflect the number of days, e.g. Due in 7 days, Due today (perhaps in yellow),
        //      Overdue (when really overdue)
        
        cell.name.text = task.name
        cell.room.text = task.ofRoom?.name
        cell.taskDue.text = taskDue
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteTask(task: self.tasks[indexPath.row], index: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cleanedAction = UIContextualAction(style: .normal, title: "Clean") { (action, view, actionPerformed) in
            let task = self.tasks[indexPath.row]
            task.lastCompleted = Date()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not mark task as cleaned. \(error), \(error.userInfo)")
            }
            
            self.tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRoomTable"), object: nil)
            actionPerformed(true)
        }
        cleanedAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [cleanedAction])
    }
    
    func deleteTask(task: Task, index: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        managedObjectContext.delete(task as NSManagedObject)
        
        do {
            try managedObjectContext.save()
            tasks.remove(at: index.row)
            tableView.deleteRows(at: [index], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRoomTable"), object: nil)
        } catch let error as NSError {
            print("Could not delete task. \(error), \(error.userInfo)")
        }
    }
    
}
