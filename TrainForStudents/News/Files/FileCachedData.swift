//
//  FileCachedData.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/27.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class FileCachedData: NSObject {
    static let sharedInstance = FileCachedData()
    
    func setData() {
        UserDefaults.standard.object(forKey: "collectData")
    }

    var collectData: [JSON] {
        
        
        return UserDefaults.standard.object(forKey: "collectData") as! [JSON]
    }
    
    
}
