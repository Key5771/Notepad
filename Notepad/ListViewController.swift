//
//  ListViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/11.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    var notes: [NSManagedObject] = []
    
    
    // tableView cell count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    // tablaView cell label setting
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listContentCell", for: indexPath) as! ListTableViewCell
        
        let content = notes[indexPath.row]

        cell.titleLabel.text = content.value(forKeyPath: "title") as? String
        cell.contentLabel.text = content.value(forKeyPath: "content") as? String

        return cell
    }

    // tableView touched change color
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // tableView cell swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        do {
            notes = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    
    // edit button click
    @IBAction func edit(_ sender: Any) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editButton.title = "편집"
        } else {
            tableView.setEditing(true, animated: true)
            editButton.title = "완료"
        }
    }
    
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addNote" {
//            let vc = segue.destination as? ViewController
//            vc?.modalPresentationStyle = .fullScreen
//
//        }
//    }
    

}
