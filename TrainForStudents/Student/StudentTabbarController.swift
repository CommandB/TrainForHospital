//
//  StudentTabbarController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class StudentTabbarController : UITabBarController{
    
    override func viewDidLoad() {
        let tabBarItems = tabBar.items
        if tabBarItems != nil{
            
            tabBarItems![0].image = UIImage(named: "首页-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![0].selectedImage = UIImage(named: "首页-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![1].image = UIImage(named: "资讯-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![1].selectedImage = UIImage(named: "资讯-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![2].image = UIImage(named: "功能-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![2].selectedImage = UIImage(named: "功能-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![3].image = UIImage(named: "资讯-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![3].selectedImage = UIImage(named: "资讯-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            tabBarItems![4].image = UIImage(named: "我的-tabbar")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            tabBarItems![4].selectedImage = UIImage(named: "我的-选择")?.resizeImage(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
            
            
        }
        
    }
}
