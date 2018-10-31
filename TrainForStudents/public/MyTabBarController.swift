//
//  MyTabBarController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/31.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class MyTabBarController : UITabBarController{
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.title)
        
        if item.title == "发布"{
            //myPresentView(self, viewName: "inspectView")
        }
    }
    
    
    
}
