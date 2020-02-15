//
//  ViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/11.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var collectionView: UICollectionView!
    
    let picker = UIImagePickerController()
    
    var imageArray: [String] = []
    let fileManager = FileManager.default
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ImageCollectionViewCell
        
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(imageArray[indexPath.row])
        cell.imageView.image = UIImage.init(contentsOfFile: fileURL.path)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        picker.delegate = self
        
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
//        titleTextField.layer.cornerRadius = 5
        
        contentTextView.delegate = self
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
//        contentTextView.layer.cornerRadius = 5
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
        managedContext.automaticallyMergesChangesFromParent = true
        
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let images = imageArray.compactMap { (address) -> Image? in
            let entity = NSEntityDescription.entity(forEntityName: "Image", in: managedContext)!
            
            let image = NSManagedObject(entity: entity, insertInto: managedContext) as? Image
            image?.imageAddress = address
            
            return image
        }
        
        note.setValue(title, forKey: "title")
        note.setValue(content, forKey: "content")
        note.setValue(Set(images) as NSSet, forKey: "images")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        let alert = UIAlertController(title: "사진추가", message: "선택", preferredStyle: .actionSheet)
        
        let library = UIAlertAction(title: "사진앨범", style: .default) {
            (action) in self.openLibrary()
        }
        
        let camera = UIAlertAction(title: "카메라", style: .default) {
            (action) in self.openCamera()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let uuid = NSUUID().uuidString

            let fileURL = documentsURL.appendingPathComponent(uuid)

            let data = image.pngData()
            try? data?.write(to: fileURL)

            self.imageArray.append(uuid)
            self.collectionView.reloadData()
            print(info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

