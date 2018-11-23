//
//  ReleaseController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/31.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class ReleaseController : UIViewController{
    
    override func viewDidLoad() {
        
        
        
        var btn = view.viewWithTag(10001) as! UIButton
//        btn.set(image: UIImage(named: "病例讨论"), title: "病例讨论", titlePosition: .bottom, additionalSpacing: 10.0, state: .normal)
//        btn = view.viewWithTag(10002) as! UIButton
//        btn.set(image: UIImage(named: "小讲课"), title: "小讲课", titlePosition: .center, additionalSpacing: 10.0, state: .normal)
//        btn = view.viewWithTag(10003) as! UIButton
//        btn.set(image: UIImage(named: "阅片会"), title: "阅片会", titlePosition: .center, additionalSpacing: -40.0, state: .normal)
//        btn = view.viewWithTag(10004) as! UIButton
//        btn.set(image: nil, title: "教学查房", titlePosition: .center, additionalSpacing: 20.0, state: .normal)
//        btn = view.viewWithTag(10005) as! UIButton
//        btn.set(image: UIImage(named: "其他教学活动"), title:"其他教学活动", titlePosition: .scaleAspectFill, additionalSpacing: 50.0, state: .normal)
//        btn = view.viewWithTag(10006) as! UIButton
//        btn.set(image: UIImage(named: "release-360评价"), title: "360评价", titlePosition: .bottomLeft, additionalSpacing: 60.0, state: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        let app = (UIApplication.shared.delegate) as! AppDelegate
        let tabBar = (app.window?.rootViewController) as! UITabBarController
        tabBar.selectedIndex = selectedTabBarIndex
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
