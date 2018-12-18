//
//  FeaturesCollection.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/31.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class FeaturesController : UIViewController{
    
    override func viewDidLoad() {
        
        var btn = view.viewWithTag(10001) as! UIButton
        btn.set(image: nil, title: "现场考试", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10002) as! UIButton
        btn.set(image: nil, title: "考试任务", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10003) as! UIButton
        btn.set(image: nil, title: "评价", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10004) as! UIButton
        btn.set(image: nil, title: "大纲审批", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20001) as! UIButton
        btn.set(image: nil, title: "技能考试", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20002) as! UIButton
        btn.set(image: nil, title: "mini-cex", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20003) as! UIButton
        btn.set(image: nil, title: "请假审批", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20004) as! UIButton
        btn.set(image: nil, title: "教学拍照", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        
    }
    
    func btn_features_even(sender :UIButton){
        
        switch sender.tag {
        case 10001:
            //现场技能考试
            myPresentView(self, viewName: "publishStillView")
            break
        case 10002:
            //理论考试
            let vc = getViewToStoryboard("publishExamView") as! PublishExamController
            vc.isSkillExam = false
            present(vc, animated: true, completion: nil)
            break
        case 10003:
            break
        case 10004:
            break
        case 20001:
            //技能考试
            let vc = getViewToStoryboard("publishExamView") as! PublishExamController
            vc.isSkillExam = true
            present(vc, animated: true, completion: nil)
            break
        case 20002:
            break
        case 20003:
            break
        case 20004:
            break
        default:
            break
        }
        
    }
    
}
