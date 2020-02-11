//
//  ListViewController.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/11.
//  Copyright © 2020 김기현. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewCell: UITableViewCell!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
