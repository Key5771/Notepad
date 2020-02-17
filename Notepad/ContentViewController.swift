//
//  ContentViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/13.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit

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
        
        cell.imageView.image = UIImage.init(contentsOfFile: imageArray[indexPath.row])
        
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        titleLabel.text = note?.title
        contentLabel.text = note?.content
        imageArray = note?.images?.compactMap { ($0 as AnyObject).imageAddress } ?? []
        collectionView.reloadData()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
