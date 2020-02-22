//
//  ListViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/11.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class ListViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    var controller: NSFetchedResultsController<NSManagedObject>?
    var fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadData()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.title = "메모"
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        controller?.delegate = self
        
        
        do {
            try controller?.performFetch()
        } catch let error as NSError {
            print("could not fetch. \(error), \(error.userInfo)")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            break
        default:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            break
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "content" {
            if let row = tableView.indexPathForSelectedRow {
                let vc = segue.destination as? ContentViewController
                let content = self.controller?.object(at: row) as? Note
                
                vc?.note = content
                
                tableView.deselectRow(at: row, animated: true)
            }
        }
    }
}

extension ListViewController: UITableViewDataSource {
    // tableView cell count
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return (controller?.sections?.first?.numberOfObjects)!
   }

   // tablaView cell label setting
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "listContentCell", for: indexPath) as! ListTableViewCell
       
       let content = self.controller?.object(at: indexPath) as? Note
       let image = content?.images?.firstObject as? Image
       let address = image?.imageAddress

       cell.titleLabel.text = content?.title
       cell.contentLabel.text = content?.content
       
       
       if address?.contains("http") == true {
           let url = URL(string: address!)
           cell.thumbNailImage.kf.setImage(with: url)
       } else {
           cell.thumbNailImage.image = UIImage.init(contentsOfFile: address ?? "")
       }

       return cell
   }
}

extension ListViewController: UITableViewDelegate {
    // tableView touched change color
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // tableView cell swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            guard let memo = self.controller?.object(at: indexPath) else {
                return
            }
            
            do {
                let content = self.controller?.object(at: indexPath) as? Note
                for image in content!.images! {
                    if self.fileManager.fileExists(atPath: (image as AnyObject).imageAddress ?? "") {
                        try! self.fileManager.removeItem(atPath: (image as AnyObject).imageAddress ?? "")
                    }
                }
                context.delete(memo)
                try context.save()
            } catch {
                print(error)
            }
            
        }
    }
}
