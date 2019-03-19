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
    
    var lastViewName = ""
    
    override func viewDidLoad() {
        
        for item in tabBar.items!{
//            let title = item.title!
//            item.image = UIImage(named: title)
//            item.imageInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
//            if title == "发布"{
//                item.imageInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//                item.selectedImage = UIImage(named: "\(title)")
//            }else{
//                item.selectedImage = UIImage(named: "\(title)-选择")
//            }
            
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "首页":
            lastViewName = "homeView"
            selectedTabBarIndex = 0
            break
        case "资讯":
            lastViewName = "newsView"
            //selectedTabBarIndex = 1
            break
        case "发布":
            myPresentView(self, viewName: "releaseView")
            break
        case "功能":
            lastViewName = "releasView"
            selectedTabBarIndex = 3
            break
        case "我的":
            lastViewName = "mineView"
            selectedTabBarIndex = 4
            //退出系统
//            UserDefaults.standard.set(nil, forKey: LoginInfo.token.rawValue)
//            r_token = ""
//            myPresentView(self, viewName: "loginView")
            break
        default:
            break
        }
        
        
    }
    
    
    
}
