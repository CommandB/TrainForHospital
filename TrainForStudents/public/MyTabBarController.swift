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
        let tabBarItems = tabBar.items
        if tabBarItems != nil{
            
            tabBarItems![0].image = UIImage(named: "首页-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![0].selectedImage = UIImage(named: "首页-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![1].image = UIImage(named: "资讯-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![1].selectedImage = UIImage(named: "资讯-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![2].image = UIImage(named: "发布")?.resizeImage(newSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            tabBarItems![2].selectedImage = UIImage(named: "发布")?.resizeImage(newSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![3].image = UIImage(named: "功能-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![3].selectedImage = UIImage(named: "功能-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![4].image = UIImage(named: "我的-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![4].selectedImage = UIImage(named: "我的-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
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
//                    tabBar_Item.image =
//                    tabBar_Item.selectedImage = UIImage(named: "首页-选择.png")?.withRenderingMode(.alwaysOriginal)
            //item.image = UIImage(named: "发布")?.withRenderingMode(.alwaysOriginal)
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
