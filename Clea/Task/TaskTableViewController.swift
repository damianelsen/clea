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
    
    // MARK: - Properties
    
    var tasks: [Task] = []
    var room: Room?
    var currentRow: Int?
    
    // MARK: - Outlets
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? TaskViewController, let task = sourceViewController.task else { return }
        
        self.save(task: task)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: CleaConstants.notificationRefreshTasks), object: nil)
        
        let taskTableViewCell = UINib(nibName: CleaConstants.cellReuseIdentifierTask, bundle: nil)
        self.tableView.register(taskTableViewCell, forCellReuseIdentifier: CleaConstants.cellReuseIdentifierTask)
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let taskNavigationController = segue.destination as! UINavigationController
        let taskViewController = taskNavigationController.viewControllers[0] as? TaskViewController
        
        guard segue.identifier == CleaConstants.segueShowDetailTask else {
            guard let button = sender as? UIBarButtonItem, button === addButton else { return }
            
            currentRow = nil
            
            if let room = self.room {
                taskViewController?.room = room
            }
            
            return
        }
        
        let indexPath = sender as! IndexPath
        currentRow = indexPath.row
        taskViewController!.task = tasks[indexPath.row]
    }
    
    // MARK: - View Overrides
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TaskTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CleaConstants.cellReuseIdentifierTask, for: indexPath) as! TaskTableViewCell
        let task = tasks[indexPath.row]
        
        cell.task = task
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.performSegue(withIdentifier: CleaConstants.segueShowDetailTask, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.delete(index: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cleanedAction = UIContextualAction(style: .normal, title: "Clean") { (action, view, actionPerformed) in
            let task = self.tasks[indexPath.row]
            
            self.markAsClean(forTask: task)
            
            actionPerformed(true)
        }
        cleanedAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [cleanedAction])
    }
    
    // MARK: - Private Methods
    
    @objc private func refresh() {
        if let room = self.room {
            title = room.name
            tasks = room.tasks?.allObjects as! [Task]
        } else {
            title = "Tasks"
            tasks = DataController.fetchAllTasks(sortBy: nil)
        }
        
        self.sort()
        self.tableView.reloadData()
    }
    
    private func sort() {
        tasks.sort { task1, task2 in
            let now = Calendar.current.startOfDay(for: Date())
            let task1Days = Int(task1.intervalType!.noOfDays * task1.interval)
            let task2Days = Int(task2.intervalType!.noOfDays * task2.interval)
            let task1DueDate = Calendar.current.date(byAdding: .day, value: task1Days, to: task1.lastCompleted!)!
            let task2DueDate = Calendar.current.date(byAdding: .day, value: task2Days, to: task2.lastCompleted!)!
            let task1DateDiff = Calendar.current.dateComponents([.day], from: now, to: task1DueDate)
            let task2DateDiff = Calendar.current.dateComponents([.day], from: now, to: task2DueDate)
            let task1DueDays = task1DateDiff.day!
            let task2DueDays = task2DateDiff.day!
            
            return task1DueDays == task2DueDays ? task1.name! < task2.name! : task1DueDays < task2DueDays
        }
    }
    
    private func save(task: Task) {
        let isAdd = currentRow == nil
        
        guard let success = DataController.save(), success else {
            let message = "Task could not be \(isAdd ? "added" : "changed")"
            Toast.show(message: message, withType: .Error, forController: self.parent!)
            
            return
        }
        
        if (isAdd) {
            tasks.append(task)
            self.sort()
            let index = tasks.firstIndex(of: task)
            tableView.insertRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
        } else {
            self.refresh()
        }

        Notifications.scheduleNotification(forTask: task)
    }
    
    private func delete(index: IndexPath) {
        let task = tasks[index.row]
        let taskId = task.objectID.uriRepresentation().description
        
        guard let success = DataController.delete(forObject: task as NSManagedObject), success else {
            Toast.show(message: "Task could not be deleted", withType: .Error, forController: self.parent!)
            
            return
        }

        tasks.remove(at: index.row)
        Notifications.removeNotification(forTaskId: taskId)
        tableView.deleteRows(at: [index], with: .fade)
    }
    
    private func markAsClean(forTask: Task) {
        forTask.lastCompleted = Calendar.current.startOfDay(for: Date())
        
        guard let success = DataController.save(), success else {
            Toast.show(message: "Could not mark task as clean", withType: .Error, forController: self.parent!)
            
            return
        }
        
        Notifications.scheduleNotification(forTask: forTask)
        
        let oldRow = tasks.firstIndex(of: forTask)!
        self.sort()
        let newRow = tasks.firstIndex(of: forTask)!
        self.reorderTable(fromRow: oldRow, toRow: newRow)
    }
    
    private func reorderTable(fromRow: Int, toRow: Int) {
        let indexes = fromRow < toRow ? (fromRow...toRow) : (toRow...fromRow)
        var indexPaths: [IndexPath] = []
        
        for index in indexes {
            let indexPath = IndexPath(row: index, section: 0)
            indexPaths.append(indexPath)
        }
        
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
    
}
