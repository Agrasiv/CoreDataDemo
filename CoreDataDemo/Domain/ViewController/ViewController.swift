//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Pyae Phyo Oo on 31/10/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Refrence to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table
    var items: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PersonCell")
        
        //Get item From CoreData
        fetchPeople()
        relationshipDemo()
    }
    
    func relationshipDemo() {
        
        //Create Family
        var family = Family(context: context)
        family.name = "ABC Famliy"
        
        //Create person
        var person = Person(context: context)
        person.name = "Babayaga"
        person.family = family
        
        //Add person to the family other way to develop
//        family.addToPeople(person)
        
        //SAve context
        try! context.save()
        self.fetchPeople()
    }
    
    func fetchPeople() {
        
        //Fetch the data from Core Data to display in the tableview
        do {
            let request = Person.fetchRequest()
            
            // set the filtering and sorting
//            let pred = NSPredicate(format: "name CONTAINS %@", "")
//            request.predicate = pred
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            print("Error")
        }
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        
        //Create Alert
        let alert = UIAlertController(title: "Add Person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            let textfield = alert.textFields![0]
            
            // Create a person object
            let newPerson = Person(context: self.context)
            newPerson.name = textfield.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            // Save Data
            do {
                try self.context.save()
            }
            catch {
                print("Error")
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        alert.addAction(submitButton)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - TableView

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        
        // Get Person from array and set label
        let person = self.items![indexPath.row]
        cell.textLabel?.text = person.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.items![indexPath.row]
        let alert = UIAlertController(title: "Edit Person", message: "Edit name:", preferredStyle: .alert)
        alert.addTextField()
        let textfield = alert.textFields![0]
        textfield.text = person.name
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { action in
            
            // get the textfield for the alert
            let textfield = alert.textFields![0]
            
            //edit the name
            person.name = textfield.text
            
            //save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            // re-fetch the data
            self.fetchPeople()
        }
        alert.addAction(saveButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHendler) in
            
            // which person remove
            let personToRemove = self.items![indexPath.row]
            
            // remove person
            self.context.delete(personToRemove)
            
            // save data
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            // re-fetch data
            self.fetchPeople()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
