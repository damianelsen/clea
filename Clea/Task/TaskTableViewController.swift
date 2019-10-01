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
    
    // MARK: - Outlets
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? TaskViewController, let task = sourceViewController.task else { return }
        
        self.save(task: task)
        self.tableView.reloadData()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CleaConstants.reloadTableRoom), object: nil)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tasks"
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: CleaConstants.reloadTableTask), object: nil)
        
        let taskTableViewCell = UINib(nibName: CleaConstants.cellReuseIdentifierTask, bundle: nil)
        self.tableView.register(taskTableViewCell, forCellReuseIdentifier: CleaConstants.cellReuseIdentifierTask)
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.load()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == CleaConstants.segueShowDetailTask else {
            guard let button = sender as? UIBarButtonItem, button === addButton else { return }
            guard tableView!.indexPathForSelectedRow != nil else { return }
            
            tableView.deselectRow(at: tableView!.indexPathForSelectedRow!, animated: true)
            
            return
        }
        
        let taskNavigationController = segue.destination as! UINavigationController
        let indexPath = sender as! IndexPath
        let taskViewController = taskNavigationController.viewControllers[0] as? TaskViewController
        
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
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CleaConstants.cellReuseIdentifierTask, for: indexPath) as! TaskTableViewCell
        
        cell.task = task
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            task.lastCompleted = Calendar.current.startOfDay(for: Date())
            
            guard let success = DataController.save(), success else {
                Toast.show(message: "Could not mark task cleaned", withType: .Error, forController: self.parent!)
                
                return
            }

            self.sort()
            self.tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CleaConstants.reloadTableRoom), object: nil)
            Notifications.scheduleNotification(forTask: task)
            actionPerformed(true)
        }
        cleanedAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [cleanedAction])
    }
    
    // MARK: - Private Methods
    
    @objc func refresh() {
        self.load()
        self.tableView.reloadData()
    }
    
    private func load() {
        tasks = DataController.fetchAllTasks(sortBy: nil)
        
        self.sort()
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
        let isAdd = tableView?.indexPathForSelectedRow == nil
        
        guard let success = DataController.save(), success else {
            let message = "Task could not be \(isAdd ? "added" : "changed")"
            Toast.show(message: message, withType: .Error, forController: self.parent!)
            
            return
        }

        if (isAdd) {
            tasks.append(task)
        }

        self.sort()
        Notifications.scheduleNotification(forTask: task)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CleaConstants.reloadTableRoom), object: nil)
    }
    
    private func delete(index: IndexPath) {
        let task = tasks[index.row]
        
        guard let success = DataController.delete(forObject: task as NSManagedObject), success else {
            Toast.show(message: "Task could not be deleted", withType: .Error, forController: self.parent!)
            
            return
        }

        Notifications.removeNotification(forTask: task)
        tasks.remove(at: index.row)
        tableView.deleteRows(at: [index], with: .fade)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CleaConstants.reloadTableRoom), object: nil)
    }
    
}
