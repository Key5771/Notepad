//
//  ContentViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/13.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class ContentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var note: Note?
    var imageArray: [String] = []
    let fileManager = FileManager.default
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentCollectionCell", for: indexPath) as! ContentImageCollectionViewCell
        
        if imageArray[indexPath.row].contains("http") {
            let url = URL(string: imageArray[indexPath.row])
            cell.imageView.kf.setImage(with: url)
        } else {
            cell.imageView.image = UIImage.init(contentsOfFile: imageArray[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        titleLabel.text = note?.title
        contentLabel.text = note?.content
        imageArray = note?.images?.compactMap { ($0 as AnyObject).imageAddress } ?? []
        collectionView.reloadData()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "삭제", message: "삭제하시겠습니까?", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "확인", style: .default) { (_) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "title = %@", self.titleLabel.text ?? "")
            
            do {
                let test = try managedContext.fetch(fetchRequest)
                
                let objectToDelete = test[0] as! NSManagedObject
                
                for image in self.note!.images! {
                    if self.fileManager.fileExists(atPath: (image as AnyObject).imageAddress ?? "") {
                        try! self.fileManager.removeItem(atPath: (image as AnyObject).imageAddress ?? "")
                    }
                }
                
                managedContext.delete(objectToDelete)
                
                do {
                    try managedContext.save()
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "editNote" {
            let vc = segue.destination as? ViewController
            
//            vc?.editTitle = self.titleLabel.text!
//            vc?.editContent = self.contentLabel.text!
//            vc?.imageArray = self.imageArray
            
            vc?.note = note
            vc?.imageArray = self.imageArray
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    

}
