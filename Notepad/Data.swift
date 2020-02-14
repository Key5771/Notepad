//
//  Data.swift
//  Notepad
//
//  Created by 김기현 on 2020/02/12.
//  Copyright © 2020 김기현. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Data {
    var id: Int?
    var title: String?
    var content: String?
    var image: UIImage?
    var timestamp: Date?
}

extension Data: Equatable {
    static func ==(lhs: Data, rhs: Data) -> Bool {
        return lhs.id == rhs.id
    }
}
