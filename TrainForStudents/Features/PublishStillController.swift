//
//  PublishStillController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/17.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PublishStillController : HBaseViewController{
    
    @IBOutlet weak var questionsCollection: UICollectionView!
    
    var directoryView = DirectoryCollectionView()
    
    var paperPicker = UIPickerView()
    let paperPickerImpl = HSimplePickerViewImpl()
    
    var exercisesId = ""
    var submitParam = [String : Any]()
    
    
    
    override func viewDidLoad() {
        
        questionsCollection.delegate = directoryView
        questionsCollection.dataSource = directoryView
        
        paperPicker = paperPickerImpl.getDefaultPickerView()
        paperPickerImpl.titleKey = "title"
        paperPickerImpl.clorsureImpl = paperClosureImpl
        
        questionsCollection.register(TitleReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        var btn = view.viewWithTag(20001) as! UIButton
        btn.addTarget(self, action: #selector(btn_student_evet), for: .touchUpInside)
        let txt = view.viewWithTag(30001) as! TextFieldForNoMenu
        txt.delegate = self
        txt.inputView = paperPicker
        btn = view.viewWithTag(40001) as! UIButton
        btn.addTarget(self, action: #selector(chooseExamType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(40002) as! UIButton
        btn.addTarget(self, action: #selector(chooseExamType(sender:)), for: .touchUpInside)
        
        let url = SERVER_PORT + "rest/app/getSkillExercisesList.do"
        //下载试卷
        myPostRequest(url, method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    
                    self.paperPickerImpl.dataSource = json["data"].arrayValue
                    
                    self.paperPickerImpl.dataSource.insert(JSON(["title":"请选择技能考试试卷"]), at: 0)
                    
                    self.paperPicker.reloadAllComponents()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "加载试卷异常!")
                print(error)
                break
            }
        })
        
        chooseExamType(sender: view.viewWithTag(40001) as! UIButton)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStudentNotice), name: PersonSelectorController.addPersonDefaultNotificationName, object: nil)
        
    }
    
    //返回
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //发布
    @IBAction func btn_submit_inside(_ sender: UIButton) {
        
        submitParam["isneedsign"] = 0
        
        if exercisesId.count < 1{
            myAlert(self, message: "请先选择试卷!")
            return
        }
        
        
        if let t = (view.viewWithTag(10001) as! UITextField).text{
            submitParam["examname"] = t
        }else{
            myAlert(self, message: "请填写考试主题!")
            return
        }
        
        if submitParam["exampersonid"] == nil {
            myAlert(self, message: "请选择考试学员!")
            return
        }
        
//        print(submitParam)
        
        let url = SERVER_PORT + "rest/app/onceSkillExam.do"
        //发布
        myPostRequest(url,submitParam, method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.submitParam["taskid"] = json["taskid"].stringValue
                    let vc = getViewToStoryboard("stillExamView") as! StillExamController
                    //vc.exercisesId = self.exercisesId
                    vc.headInfo = self.submitParam
                    self.present(vc, animated: true, completion: nil)
                    
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "加载试卷异常!")
                print(error)
                break
            }
        })
        
        
    }
    
    //选考试学生
    func btn_student_evet(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON](), single: true)
    }
    
    //考试类型选择
    func chooseExamType(sender : UIButton){
        
        var i = 0
        while (i < 2){
            let btn = view.viewWithTag(40001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitParam["stagetype"] = sender.tag - 40001
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
    }
    
    //人员选择器 callback
    func receiveStudentNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: PersonSelectorController.addPersonDefaultNotificationName, object: nil)
        if notification.userInfo != nil{
            let data = notification.userInfo!["data"] as! [JSON]
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
                submitParam["exampersonid"] = item["personid"].stringValue
            }
            
            //添加考试学员
            
            let btn = self.view.viewWithTag(20001) as! UIButton
            if text.count > 0{
                btn.setTitle(text, for: .normal)
                btn.setTitleColor(UIColor.darkText, for: .normal)
                btn.alpha = 1
            }else{
                btn.setTitle("点击选择学员", for: .normal)
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                btn.alpha = 0.6
            }
            
        }
    }
    
    
    //选择试卷
    func paperClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        
        
        if row == 0 {
            self.directoryView.jsonDataSource = [JSON]()
            self.questionsCollection.reloadData()
            return
        }
        let data = ds[row]
        exercisesId = data["exercisesid"].stringValue
        submitParam["exercisesid"] = exercisesId
        submitParam["versionnumber"] = data["versionnumber"].stringValue
        (view.viewWithTag(30001) as! TextFieldForNoMenu).text = ds[row]["title"].stringValue
        
//        submitParam["exercisesid"] = exercisesId
//        submitParam["versionnumber"] = ds[row]["versionnumber"].intValue
//        submitParam["examname"] = ds[row]["title"].stringValue
//        submitParam["marking"] = ds[row]["marking"].stringValue
        
//        MBProgressHUD.showAdded(to: questionsCollection, animated: true)
//        let url = SERVER_PORT + "rest/app/getTheoryExercisesDetail.do"
//        myPostRequest(url, ["exercisesid": exercisesId], method: .post).responseString(completionHandler: {resp in
//            MBProgressHUD.hideAllHUDs(for: self.questionsCollection, animated: true)
//            switch resp.result{
//            case .success(let respStr):
//                let json = JSON(parseJSON: respStr)
//                if json["code"].stringValue == "1"{
//                    self.directoryView.jsonDataSource = json["data"].arrayValue
//                    self.questionsCollection.reloadData()
//                }else{
//                    myAlert(self, message: json["msg"].stringValue)
//                }
//                break
//            case .failure(let error):
//                myAlert(self, message: "加载试卷异常!")
//                print(error)
//                break
//            }
//        })
        
    }
    
}
