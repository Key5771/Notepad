//
//  ViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/11.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class ViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var collectionView: UICollectionView!
    
    let picker = UIImagePickerController()
    let fileManager = FileManager.default
    var imageArray: [String] = []
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        picker.delegate = self
        
        setUpText()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setUpText() {
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        contentTextView.delegate = self
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        if note != nil {
            titleTextField.text = note?.title
            contentTextView.text = note?.content
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetupView()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetupView()
        }
    }
    
    private func textViewSetupView() {
        if contentTextView.text == "내용입력" {
            contentTextView.text = ""
            if #available(iOS 12.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    contentTextView.textColor = UIColor.white
                } else {
                    contentTextView.textColor = UIColor.black
                }
            } else {
                // Fallback on earlier versions
            }
        } else if contentTextView.text == "" {
            contentTextView.text = "내용입력"
            contentTextView.textColor = UIColor.lightGray
        }
    }

    @IBAction func saveButton(_ sender: Any) {
        let titleToSave = titleTextField.text!
        let contentToSave = contentTextView.text!
        let dateToSave = Date()
        
        let alert = UIAlertController(title: "저장", message: "저장하시겠습니까?", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "확인", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
            
            if self.note != nil {
                self.updateData(title: titleToSave, content: contentToSave, updateDate: dateToSave)
            } else {
                self.save(title: titleToSave, content: contentToSave, createDate: dateToSave)
            }
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
    }
    
    private func save(title: String, content: String, createDate: Date) {
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
        note.setValue(createDate, forKey: "createDate")
        note.setValue(NSOrderedSet(array: images), forKey: "images")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func updateData(title: String, content: String, updateDate: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
         
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
         
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "title = %@", titleTextField.text ?? "")
        
        let images = imageArray.compactMap { (address) -> Image? in
            let entity = NSEntityDescription.entity(forEntityName: "Image", in: managedContext)!
            
            let image = NSManagedObject(entity: entity, insertInto: managedContext) as? Image
            image?.imageAddress = address
            
            return image
        }
        
        do {
            note?.title = title
            note?.content = content
            note?.createDate = updateDate
            note?.setValue(NSOrderedSet(array: images), forKey: "images")
             do {
                 try managedContext.save()
             } catch {
                 print(error)
             }
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
        
        let file = UIAlertAction(title: "사진추가", style: .default) {
            (action) in self.openFilePath()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(file)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    private func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    
    private func openFilePath() {
        let alert = UIAlertController(title: "사진추가", message: "경로를 입력하세요.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "추가", style: .default) { (_) in
            let textField = alert.textFields![0] as UITextField
            
            self.imageArray.append(textField.text ?? "")
            self.collectionView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addTextField { (textField) in
            textField.placeholder = "경로"
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let uuid = NSUUID().uuidString

            let fileURL = documentsURL.appendingPathComponent(uuid).appendingPathExtension("png")

            let data = image.fixOrientation().pngData()
            try? data?.write(to: fileURL)

            self.imageArray.append(fileURL.path)
            self.collectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundClick(_ sender: Any) {
        titleTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break

        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ImageCollectionViewCell
        
        
        if imageArray[indexPath.row].contains("http") {
            let url = URL(string: imageArray[indexPath.row])
            cell.imageView.kf.setImage(with: url)
        } else {
            cell.imageView.image = UIImage.init(contentsOfFile: imageArray[indexPath.row])
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "사진삭제", message: "삭제하시겠습니까?", preferredStyle: .actionSheet)
        
        let okButton = UIAlertAction(title: "삭제", style: .default) { (_) in
            collectionView.deselectItem(at: indexPath, animated: true)
            self.imageArray.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.reloadData()
        }
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
        
    }
}

