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
    
    // MARK: - Properties
    
    var rooms: [Room] = []
    var currentRow: Int? = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func unwindToRoomList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? RoomViewController, let room = sourceViewController.room else { return }
        
        self.save(room: room)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rooms"
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: CleaConstants.notificationRefreshRooms), object: nil)
        
        let roomTableViewCell = UINib(nibName: RoomTableViewCell.nibName, bundle: nil)
        self.tableView.register(roomTableViewCell, forCellReuseIdentifier: RoomTableViewCell.reuseIdentifier)
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case CleaConstants.segueShowDetailRoom:
            let roomNavigationController = segue.destination as! UINavigationController
            let roomViewController = roomNavigationController.viewControllers[0] as? RoomViewController
            let indexPath = sender as! IndexPath
            
            roomViewController!.room = rooms[indexPath.row]
            currentRow = indexPath.row
            
        case CleaConstants.segueShowRoomTasks:
            let taskTableViewController = segue.destination as! TaskTableViewController
            let room = sender as! Room
            
            taskTableViewController.room = room
            taskTableViewController.hidesBottomBarWhenPushed = true
            
        default:
            guard let button = sender as? UIBarButtonItem, button === addButton else { return }
            
            currentRow = nil
        }
    }
    
    // MARK: - View Overrides
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> RoomTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomTableViewCell.reuseIdentifier, for: indexPath) as! RoomTableViewCell
        let room = rooms[indexPath.row]
        
        cell.room = room
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: CleaConstants.segueShowRoomTasks, sender: rooms[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.performSegue(withIdentifier: CleaConstants.segueShowDetailRoom, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let title = "Delete Room?"
            let message = "Deleting this room will also delete all of its tasks. Are you sure?"
            let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
                self.delete(index: indexPath)
            })
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            deleteAlert.addAction(yes)
            deleteAlert.addAction(no)
            
            self.present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func refresh() {
        rooms = DataController.fetchAllRooms(sortBy: nil)
        
        self.sort()
        self.tableView.reloadData()
    }
    
    private func sort() {
        rooms.sort { room1, room2 in
            let overduePredicateFormat = CleaConstants.predicateOverdueTask
            let overduePredicate = NSPredicate(format: overduePredicateFormat, Date() as CVarArg)
            let room1OverdueTasks = room1.tasks?.filtered(using: overduePredicate)
            let room2OverdueTasks = room2.tasks?.filtered(using: overduePredicate)
            
            return room1OverdueTasks!.count == room2OverdueTasks!.count ? room1.name! < room2.name! : room1OverdueTasks!.count >= room2OverdueTasks!.count
        }
    }
    
    private func save(room: Room) {
        let isAdd = currentRow == nil
        
        guard let success = DataController.save(), success else {
            let message = "Room could not be \(isAdd ? "added" : "changed")"
            Toast.show(message: message, withType: .Error, forController: self.parent!)
            
            return
        }
        
        if isAdd {
            rooms.append(room)
            self.sort()
            let index = rooms.firstIndex(of: room)
            tableView.insertRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
        } else {
            let oldRow = rooms.firstIndex(of: room)!
            self.sort()
            let newRow = rooms.firstIndex(of: room)!
            self.reorderTable(fromRow: oldRow, toRow: newRow)
        }
    }
    
    private func delete(index: IndexPath) {
        guard let success = DataController.delete(forObject: rooms.remove(at: index.row) as NSManagedObject), success else {
            Toast.show(message: "Room could not be deleted", withType: .Error, forController: self.parent!)
            
            return
        }
        
        tableView.deleteRows(at: [index], with: .fade)
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
