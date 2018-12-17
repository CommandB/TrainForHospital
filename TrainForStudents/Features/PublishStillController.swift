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
    
    
    override func viewDidLoad() {
        
        questionsCollection.delegate = directoryView
        questionsCollection.dataSource = directoryView
        
        paperPicker = paperPickerImpl.getDefaultPickerView()
        paperPickerImpl.titleKey = "title"
        paperPickerImpl.clorsureImpl = paperClosureImpl
        //paperPicker.backgroundColor = UIColor.groupTableViewBackground
        paperPicker.setWidth(width: UIScreen.width)
        paperPicker.setHight(height: 200)
        paperPicker.setY(y: 20)
        
        view.addSubview(paperPicker)
        view.sendSubview(toBack: paperPicker)
        
        questionsCollection.register(TitleReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        var btn = view.viewWithTag(100001) as! UIButton
        btn.addTarget(self, action: #selector(btn_student_evet), for: .touchUpInside)
        
//        let url = SERVER_PORT + "rest/app/getSkillExercisesList.do"
        let url = SERVER_PORT + "rest/app/getTheoryExercisesList.do"
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
        
    }
    
    //选监考老师
    func btn_student_evet(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON](), single: true)
    }
    
    //人员选择器 callback
    func receiveStudentNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: PersonSelectorController.addPersonDefaultNotificationName, object: nil)
        if notification.userInfo != nil{
            let data = notification.userInfo!["data"] as! [JSON]
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
            }
            
            //添加考试学员
            //submitParam["teacherlist"] = data
            let btn = self.view.viewWithTag(100001) as! UIButton
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
    
    func paperClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        
        let exercisesId = ds[row]["exercisesid"].stringValue
        
        if row == 0 {
            self.directoryView.jsonDataSource = [JSON]()
            self.questionsCollection.reloadData()
            return
        }
        
        //(view.viewWithTag(10004) as! UILabel).text = ds[row]["title"].stringValue
        
//        submitParam["exercisesid"] = exercisesId
//        submitParam["versionnumber"] = ds[row]["versionnumber"].intValue
//        submitParam["examname"] = ds[row]["title"].stringValue
//        submitParam["marking"] = ds[row]["marking"].stringValue
        
        MBProgressHUD.showAdded(to: questionsCollection, animated: true)
        let url = SERVER_PORT + "rest/app/getTheoryExercisesDetail.do"
        myPostRequest(url, ["exercisesid": exercisesId], method: .post).responseString(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.questionsCollection, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.directoryView.jsonDataSource = json["data"].arrayValue
                    self.questionsCollection.reloadData()
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
    
}
