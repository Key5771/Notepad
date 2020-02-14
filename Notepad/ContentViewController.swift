//
//  ContentViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/13.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    var note: Note?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = note?.title
        contentLabel.text = note?.content
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
