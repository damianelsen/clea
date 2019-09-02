//
//  RoomTableViewController.swift
//  Clea
//
//  Created by Damian Elsen on 8/14/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class RoomTableViewController: UITableViewController {
    
    // MARK: - Constants
    
    let cellReuseIdentifier = "RoomTableViewCell"
    
    // MARK: - Properties
    
    var rooms: [Room] = []
    
    // MARK: - Actions
    
    @IBAction func unwindToRoomList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? RoomViewController, let room = sourceViewController.room {
            self.save(roomName: room.name, roomType: room.type)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rooms"
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: "reloadRoomTable"), object: nil)
        
        let roomTableViewCell = UINib(nibName: cellReuseIdentifier, bundle: nil)
        self.tableView.register(roomTableViewCell, forCellReuseIdentifier: cellReuseIdentifier)
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.load()
    }
    
    // MARK: - View Overrides
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! RoomTableViewCell
        let overdueTasks = room.tasks?.filtered(using: NSPredicate(format: "CAST(CAST(lastCompleted, 'NSNumber') + (interval * 604800), 'NSDate') < %@", Date() as CVarArg))
        var totalTaskMessage = (room.tasks?.count == 0 ? "No" : (room.tasks?.count.description)!) + " task"
        totalTaskMessage = totalTaskMessage + (room.tasks?.count != 1 ? "s" : "")
        var overdueTaskMessage = ""
        if (overdueTasks!.count > 0) {
            overdueTaskMessage = (overdueTasks?.count.description)! + " task" + (overdueTasks!.count > 1 ? "s" : "") + " overdue"
        }
        
        cell.name?.text = room.name
        cell.type?.text = room.type
        cell.taskCount?.text = totalTaskMessage
        cell.tasksOverdue?.text = overdueTaskMessage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = "Delete Room?"
            let message = "Deleting this room will also delete all of its tasks. Are you sure?"
            let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
                self.delete(room: self.rooms[indexPath.row], index: indexPath)
            })
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            deleteAlert.addAction(yes)
            deleteAlert.addAction(no)
            
            self.present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods

    @objc private func refresh() {
        self.load()
        self.tableView.reloadData()
    }
    
    private func load() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomRequest = NSFetchRequest<Room>(entityName: "Room")
        
        do {
            rooms = try managedObjectContext.fetch(roomRequest)
        } catch let error as NSError {
            print("Could not load rooms. \(error), \(error.userInfo)")
        }
    }
    
    private func save(roomName: String, roomType: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let room = Room(context: managedObjectContext)
        
        room.name = roomName
        room.type = roomType
        room.dateCreated = Date()
        
        do {
            try managedObjectContext.save()
            rooms.append(room)
        } catch let error as NSError {
            print("Could not add new room. \(error), \(error.userInfo)")
        }
    }
    
    private func delete(room: Room, index: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        managedObjectContext.delete(room as NSManagedObject)
        
        do {
            try managedObjectContext.save()
            rooms.remove(at: index.row)
            tableView.deleteRows(at: [index], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTaskTable"), object: nil)
        } catch let error as NSError {
            print("Could not delete room. \(error), \(error.userInfo)")
        }
    }
    
}
