//
//  ViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/11.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    
    var memo: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        titleTextField.layer.cornerRadius = 5
        
        contentTextView.delegate = self
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetupView()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetupView()
        }
    }
    
    func textViewSetupView() {
        if contentTextView.text == "내용입력" {
            contentTextView.text = ""
            contentTextView.textColor = UIColor.black
        } else if contentTextView.text == "" {
            contentTextView.text = "내용입력"
            contentTextView.textColor = UIColor.lightGray
        }
    }

    @IBAction func saveButton(_ sender: Any) {
        let titleToSave = titleTextField.text!
        let contentToSave = contentTextView.text!
        
        let alert = UIAlertController(title: "저장", message: "저장되었습니다", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "확인", style: .default, handler: { (_) in
//            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(okButton)
        
        present(alert, animated: true)
        
        self.save(title: titleToSave, content: contentToSave)
    }
    
    func save(title: String, content: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
        
        note.setValue(title, forKey: "title")
        note.setValue(content, forKey: "content")
        
        do {
            try managedContext.save()
            memo.append(note)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
}

