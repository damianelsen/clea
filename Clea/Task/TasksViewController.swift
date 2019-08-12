//
//  TasksViewController.swift
//  Clea
//
//  Created by Damian Elsen on 7/14/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class TasksViewController: UIViewController {
    
    var tasks: [Task] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tasks"
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(rawValue: "reloadTable"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        do {
            tasks = try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not load tasks. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let taskTextField = alert.textFields?[0], let taskToSave = taskTextField.text else {
                return
            }
            guard let roomTextField = alert.textFields?[1], let roomToSave = roomTextField.text else {
                return
            }
            guard let intervalTextField = alert.textFields?[2], let intervalToSave = intervalTextField.text else {
                return
            }
            self.save(taskName: taskToSave, roomName: roomToSave, interval: Int(intervalToSave) ?? 0)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField(configurationHandler: {
            textField in textField.placeholder = "What is the name of the new task?"
        })
        alert.addTextField(configurationHandler: {
            textField in textField.placeholder = "In what room does this task happen?"
        })
        alert.addTextField(configurationHandler: {
            textField in textField.placeholder = "Interval (in weeks)?"
        })
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(taskName: String, roomName: String, interval: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let task = Task(context: managedObjectContext)
        
        task.name = taskName
        task.dateCreated = Date()
        task.lastCompleted = Date.distantPast
        task.interval = Int16(interval)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Room")
        fetchRequest.predicate = NSPredicate(format: "name = %@", roomName)
        var fetchResults: [NSManagedObject] = []
        do {
            fetchResults = try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not load room. \(error), \(error.userInfo)")
        }
        let room = fetchResults[0]  as! Room
        task.ofRoom = room
        
        do {
            try managedObjectContext.save()
            tasks.append(task)
        } catch let error as NSError {
            print("Could not add new task. \(error), \(error.userInfo)")
        }
    }
    
}

extension TasksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let dueDate = Calendar.current.date(byAdding: .weekOfMonth, value: Int(task.interval), to: task.lastCompleted!)!

        cell.selectedBackgroundView = {
            let bgView = UIView(frame: CGRect.zero)
            bgView.backgroundColor = UIColor.darkGray
            return bgView
        }()
        cell.textLabel?.text = task.name
        if (dueDate < Date()) {
            cell.textLabel?.textColor = UIColor.red
        }
        cell.detailTextLabel?.text = task.ofRoom?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.deleteTask(task: self.tasks[indexPath.row], index: indexPath)
        }
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
            tableView.deleteRows(at: [index], with: UITableView.RowAnimation.fade)
        } catch let error as NSError {
            print("Could not delete task. \(error), \(error.userInfo)")
        }
    }
    
}
