//
//  ImageContentViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/22.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class ImageContentViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var imageArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension ImageContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageExtensionCollectionViewCell
        
        let imageAddress = imageArray[indexPath.row]
        
        if imageArray[indexPath.row].contains("http") {
            let url = URL(string: imageAddress)
            cell.imageView.kf.setImage(with: url)
        } else {
            cell.imageView.image = UIImage.init(contentsOfFile: imageAddress)
        }
        
        return cell
    }
}

extension ImageContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = collectionView.bounds.size
        return screenSize
    }
}
