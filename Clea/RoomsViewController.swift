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

    var rooms: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rooms"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Room")
        do {
            rooms = try managedContext.fetch(fetchRequest)
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
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Room", in: managedContext)!
        let room = NSManagedObject(entity: entity, insertInto: managedContext)
        room.setValue(roomName, forKeyPath: "name")
        room.setValue(roomType, forKeyPath: "type")
        do {
            try managedContext.save()
            rooms.append(room)
        } catch let error as NSError {
            print("Could not add new room. \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.textLabel?.text = room.value(forKeyPath: "name") as? String
        cell.detailTextLabel?.text = room.value(forKeyPath: "type") as? String
        return cell
    }
}
