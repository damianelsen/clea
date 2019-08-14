//
//  RoomsViewController.swift
//  Clea
//
//  Created by Damian Elsen on 7/19/18.
//  Copyright © 2018 Damian Elsen. All rights reserved.
//

import UIKit
import CoreData

class RoomsViewController: UIViewController {
    
    var rooms: [Room] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rooms"
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(rawValue: "reloadRoomTable"), object: nil)

        let roomTableViewCell = UINib(nibName: "RoomTableViewCell", bundle: nil)
        self.tableView.register(roomTableViewCell, forCellReuseIdentifier: "RoomTableViewCell")
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
        let roomRequest = NSFetchRequest<Room>(entityName: "Room")
        
        do {
            rooms = try managedObjectContext.fetch(roomRequest)
        } catch let error as NSError {
            print("Could not load rooms. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addRoom(_ sender: UIBarButtonItem) {
        let addAlert = UIAlertController(title: "New Room", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) {
            [unowned self] action in
            guard let nameTextField = addAlert.textFields?[0], let name = nameTextField.text else {
                return
            }
            guard let typeTextField = addAlert.textFields?[1], let type = typeTextField.text else {
                return
            }
            self.save(roomName: name, roomType: type)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        addAlert.addTextField(configurationHandler: {
            textField in textField.placeholder = "What is the name of the new room?"
        })
        addAlert.addTextField(configurationHandler: {
            textField in textField.placeholder = "What is the type of the new room?"
        })
        addAlert.addAction(saveAction)
        addAlert.addAction(cancelAction)
        
        present(addAlert, animated: true)
    }
    
    func save(roomName: String, roomType: String) {
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
    
}

extension RoomsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableViewCell", for: indexPath) as! RoomTableViewCell
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = "Delete Room?"
            let message = "Deleting this room will also delete all of its tasks. Are you sure?"
            let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
                self.deleteRoom(room: self.rooms[indexPath.row], index: indexPath)
            })
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            deleteAlert.addAction(yes)
            deleteAlert.addAction(no)
            
            self.present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    func deleteRoom(room: Room, index: IndexPath) {
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
