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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        
        var btn = view.viewWithTag(10001) as! UIButton
        btn.set(image: nil, title: "理论考试", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10002) as! UIButton
        btn.set(image: nil, title: "技能考试", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10003) as! UIButton
        btn.set(image: nil, title: "评价任务", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10004) as! UIButton
        btn.set(image: nil, title: "待考任务", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20001) as! UIButton
        btn.set(image: nil, title: "mini-cex", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20002) as! UIButton
        btn.set(image: nil, title: "轮转查询", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20003) as! UIButton
        btn.set(image: nil, title: "请假审批", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20004) as! UIButton
        btn.set(image: nil, title: "教学拍照", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        
    }
    
    @objc func btn_features_even(sender :UIButton){
        
        switch sender.tag {
        case 10001:
            //理论考试
            let vc = getViewToStoryboard("publishExamView") as! PublishExamController
            vc.isSkillExam = false
            present(vc, animated: true, completion: nil)
            break
        case 10002:
            //技能考试
            let vc = getViewToStoryboard("publishExamView") as! PublishExamController
            vc.isSkillExam = true
            present(vc, animated: true, completion: nil)
            break
        case 10003: //待评任务
            myPresentView(self, viewName: "evaluationItemList")
//            myPresentView(self, viewName: "evaluationListView")
            break
        case 10004:
            let vc = getViewToStoryboard("examListView") as! ExamListController
            vc.isInvigilation = false
            present(vc, animated: true, completion: nil)
            
            break
        case 20001:
            myPresentView(self, viewName: "cexStudentsView")
            break
        case 20002:
            
            myAlert(self, message: "暂未开放!")
            break
        case 20003:
            myAlert(self, message: "暂未开放!")
            break
        case 20004:
            myAlert(self, message: "暂未开放!")
            break
        default:
            break
        }
    }
    
}
