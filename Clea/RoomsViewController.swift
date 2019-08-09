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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rooms"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Room>(entityName: "Room")
        
        do {
            rooms = try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not load rooms. \(error), \(error.userInfo)")
        }
    }

    @IBAction func addRoom(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Room", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) {
            [unowned self] action in
            guard let nameTextField = alert.textFields?.first, let name = nameTextField.text else {
                return
            }
            guard let typeTextField = alert.textFields?.last, let type = typeTextField.text else {
                return
            }
            self.save(roomName: name, roomType: type)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField(configurationHandler: {
            textField in textField.placeholder = "What is the name of the new room?"
        })
        alert.addTextField(configurationHandler: {
            textField in textField.placeholder = "What is the type of the new room?"
        })
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func save(roomName: String, roomType: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let room = Room(context: managedObjectContext)
        
        room.name = roomName
        room.type = roomType
        room.dateCreated = NSDate() as Date
        
        do {
            try managedObjectContext.save()
            rooms.append(room)
        } catch let error as NSError {
            print("Could not add new room. \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var tableView: UITableView!
    
}

extension RoomsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        
        cell.selectedBackgroundView = {
            let bgView = UIView(frame: CGRect.zero)
            bgView.backgroundColor = UIColor.darkGray
            return bgView
        }()
        cell.textLabel?.text = room.name
        cell.detailTextLabel?.text = room.type
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            let title = "Delete Room?"
            let message = "Deleting this room will also delete all of its tasks. Are you sure?"
            let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                self.deleteRoom(room: self.rooms[indexPath.row], index: indexPath)
            })
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            dialogMessage.addAction(yes)
            dialogMessage.addAction(no)
            
            self.present(dialogMessage, animated: true, completion: nil)
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
            tableView.deleteRows(at: [index], with: UITableView.RowAnimation.fade)
            // TODO: force update of task list to reflect deleted tasks
        } catch let error as NSError {
            print("Could not delete room. \(error), \(error.userInfo)")
        }
    }
    
}
