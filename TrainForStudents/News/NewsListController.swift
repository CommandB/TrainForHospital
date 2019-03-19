//
//  NewsListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/19.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class NewsListController : HBaseViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myAlert(self, message: "暂未开放,敬请期待!", handler:{action in
            let app = (UIApplication.shared.delegate) as! AppDelegate
            let tabBar = (app.window?.rootViewController) as! MyTabBarController
            tabBar.selectedIndex = selectedTabBarIndex
        })
    }
    
}
