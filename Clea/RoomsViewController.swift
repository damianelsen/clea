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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
        let alert = UIAlertController(title: "Add Room", message: "What is the name of the new room?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Room", in: managedContext)!
        let room = NSManagedObject(entity: entity, insertInto: managedContext)
        room.setValue(name, forKeyPath: "name")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = room.value(forKeyPath: "name") as? String
        return cell
    }
}
