//
//  PublishExamController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/4.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PublishExamController : HBaseViewController{
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    var isSkillExam = false
    
    var jds = [JSON]()
    var submitParam = [String : Any]()
    
    let datePicker = UIDatePicker()
    
    var addrPicker = UIPickerView()
    let addrPickerImpl = HSimplePickerViewImpl()
    
    //选考试人
    let stuNotice = "stuNotice"
    //选监考老师
    let teacherNotice = "teacherNotice"
    //选阅卷老师
    let markingNotice = "markingNotice"
    
    override func viewDidLoad() {
        
        if isSkillExam{
            (view.viewWithTag(22222) as! UILabel).text = "发布技能考试"
            (view.viewWithTag(100001) as! UIButton).isEnabled = false
            (view.viewWithTag(100002) as! UIButton).isEnabled = false
        }
        
        
        submitParam["markingteacherlist"] = [JSON]()
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
        
        addrPicker = addrPickerImpl.getDefaultPickerView()
        addrPickerImpl.titleKey = "facilitiesname"
        addrPickerImpl.dataSource = UserDefaults.AppConfig.json(forKey: .classroomList).arrayValue
        addrPickerImpl.clorsureImpl = addrClosureImpl
        
        
        var btn = view.viewWithTag(10002) as! UIButton
        btn.setBorder(width: 1, color: (btn.titleLabel?.textColor)!)
        btn.setCornerRadius(radius: 4)
        btn = view.viewWithTag(10003) as! UIButton
        btn.setBorder(width: 1, color: (btn.titleLabel?.textColor)!)
        btn.setCornerRadius(radius: 4)
        
        var txt = view.viewWithTag(30001) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = view.viewWithTag(30002) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = view.viewWithTag(40001) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = view.viewWithTag(40002) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        
        txt = view.viewWithTag(50001) as! TextFieldForNoMenu
        txt.inputView = addrPicker
        txt.delegate = self
        
        btn = view.viewWithTag(60001) as! UIButton
        btn.addTarget(self, action: #selector(btn_teacher_evet), for: .touchUpInside)
        
        
        btn = view.viewWithTag(70001) as! UIButton
        btn.addTarget(self, action: #selector(chooseExamType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(70002) as! UIButton
        btn.addTarget(self, action: #selector(chooseExamType(sender:)), for: .touchUpInside)

        btn = view.viewWithTag(80001) as! UIButton
        btn.addTarget(self, action: #selector(chooseSignInType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(80002) as! UIButton
        btn.addTarget(self, action: #selector(chooseSignInType(sender:)), for: .touchUpInside)
        
        
        //技能考试 隐藏 app进行考试的选项,并把阅卷老师的选项往上移
        if isSkillExam{
            (view.viewWithTag(100000))?.isHidden = true
            (view.viewWithTag(100001))?.isHidden = true
            (view.viewWithTag(100002))?.isHidden = true
            (view.viewWithTag(100003))?.isHidden = true
            (view.viewWithTag(90001))?.frame = ((view.viewWithTag(100001))?.frame)!
            (view.viewWithTag(90002))?.setY(y: ((view.viewWithTag(100002))?.Y)!)
        }
        
        btn = view.viewWithTag(100001) as! UIButton
        btn.addTarget(self, action: #selector(chooseAppExam(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(100002) as! UIButton
        btn.addTarget(self, action: #selector(chooseAppExam(sender:)), for: .touchUpInside)
        
        btn = view.viewWithTag(90002) as! UIButton
        btn.addTarget(self, action: #selector(btn_marking_evet), for: .touchUpInside)
        
        chooseSignInType(sender: view.viewWithTag(80001) as! UIButton)
        chooseExamType(sender: view.viewWithTag(70001) as! UIButton)
        chooseAppExam(sender: view.viewWithTag(100001) as! UIButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.personCollection.mj_header.beginRefreshing()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: Notification.Name.init(stuNotice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveTeacherNotice), name: Notification.Name.init(teacherNotice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMarkingNotice), name: Notification.Name.init(markingNotice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivePaperNotice), name: PaperSelectorController.defaultNoticeName, object: nil)
    }
    
    @objc func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(stuNotice), object: nil)
        if notification.userInfo != nil{
            jds = notification.userInfo!["data"] as! [JSON]
            personCollection.reloadData()
            let lbl = view.viewWithTag(10001) as! UIButton
            lbl.setTitle(jds.count.description, for: .normal)
            //添加考试人员
            submitParam["studentlist"] = jds
        }
    }
    
    @objc func receiveTeacherNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(teacherNotice), object: nil)
        if notification.userInfo != nil{
            let data = notification.userInfo!["data"] as! [JSON]
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
                
            }
            //添加监考老师
            submitParam["teacherlist"] = data
            let btn = view.viewWithTag(60001) as! UIButton
            if text.count > 0{
                btn.setTitle(text, for: .normal)
                btn.setTitleColor(UIColor.darkText, for: .normal)
                btn.alpha = 1
            }else{
                btn.setTitle("请选择监考老师", for: .normal)
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                btn.alpha = 0.6
            }
            
        }
    }
    
    @objc func receiveMarkingNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(markingNotice), object: nil)
        if notification.userInfo != nil{
            let data = (notification.userInfo!["data"] as! [JSON])
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
            }
            //添加监考老师
            submitParam["markingteacherlist"] = data
            let btn = view.viewWithTag(90002) as! UIButton
            if text.count > 0{
                btn.setTitle(text, for: .normal)
                btn.setTitleColor(UIColor.darkText, for: .normal)
                btn.alpha = 1
            }else{
                btn.setTitle("请选择阅卷老师", for: .normal)
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                btn.alpha = 0.6
            }
            
        }
    }
    
    //试卷选择器 callback
    @objc func receivePaperNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: PaperSelectorController.defaultNoticeName, object: nil)
        
        if notification.userInfo != nil{
            let data = notification.userInfo!["data"] as! JSON
            if !data.isEmpty{
                
                view.viewWithTag(90001)?.isHidden = true
                view.viewWithTag(90002)?.isHidden = true
                if  data["marking"].intValue == 1 {
                    view.viewWithTag(90001)?.isHidden = false
                    view.viewWithTag(90002)?.isHidden = false
                }
                (view.viewWithTag(10004) as! UILabel).text =  data["title"].stringValue
                
                submitParam["exercisesid"] = data["exercisesid"].stringValue
                submitParam["versionnumber"] =  data["versionnumber"].intValue
                submitParam["marking"] =  data["marking"].stringValue
                
            }
            
        }
        
    }
    
    //返回
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //发布
    @IBAction func btn_submit_inside(_ sender: UIButton) {
        
        submitParam["officeid"] = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)
        
        //开始结束时间
        let startTime = (view.viewWithTag(30001) as! UITextField).text! + " " + (view.viewWithTag(30002) as! UITextField).text!
        let endTime = (view.viewWithTag(40001) as! UITextField).text! + " " + (view.viewWithTag(40002) as! UITextField).text!
        if startTime.count != 16{
            myAlert(self, message: "开始时间不合法!")
            return
        }
        submitParam["starttime"]  = startTime
        
        if endTime.count != 16{
            myAlert(self, message: "结束时间不合法!")
            return
        }
        
        let examName = (view.viewWithTag(110001) as! UITextField).text
        if  examName?.isEmpty ?? true {
            myAlert(self, message: "请填写考试主题!")
            return
        }else{
            submitParam["examname"] = examName
        }
        
        if submitParam["studentlist"] == nil{
            myAlert(self, message: "请选择考试学员!")
            return
        }
        
        if submitParam["facilitiesid"] == nil{
            myAlert(self, message: "请选择考试地址!")
            return
        }
        
        if submitParam["exercisesid"] == nil{
            myAlert(self, message: "请选择试卷!")
            return
        }
        
//        if submitParam["teacherlist"] == nil{
//            myAlert(self, message: "请选择监考老师!")
//            return
//        }
        
        if submitParam["marking"].debugDescription == "1" && (submitParam["markingteacherlist"] as! [JSON]).count == 1 {
            myAlert(self, message: "请选择阅卷老师!")
            return
        }
        
        submitParam["endtime"] = endTime
        //print(submitParam)
        
        var url = ""
        if isSkillExam{
            url = SERVER_PORT + "rest/app/releaseSkillExam.do"
        }else{
            url = SERVER_PORT + "rest/app/releaseTheoryExam.do"
        }
        myPostRequest(url, submitParam, method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    myAlert(self, message: "发布成功!" ,handler :{  action in
                        self.dismiss(animated: true, completion: nil)
                    })
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
                
            case .failure(let error):
                myAlert(self, message: "发布考试异常!")
                print(error)
                break
            }
        })
    }
    
    //选人
    @IBAction func btn_addPerson_inside(_ sender: UIButton) {
        PersonSelectorController.presentPersonSelector(viewController: self, data: jds , noticeName: stuNotice)
    }
    
    //选择试卷
    @IBAction func btn_selectPaper_inside(_ sender: UIButton) {
        
        let vc = getViewToStoryboard("paperSelectorView") as! PaperSelectorController
        vc.isSkillExam = isSkillExam
        present(vc, animated: true, completion: nil)
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let tag = textField.tag
        if tag == 50001{
            
            let row = addrPicker.selectedRow(inComponent: 0)
            let text = addrPickerImpl.dataSource[row]["facilitiesname"].stringValue
            textField.text = text
            submitParam["facilitiesid"] = addrPickerImpl.dataSource[row]["facilitiesid"].stringValue
            submitParam["name"] = text
            
        }else if tag == 40001 || tag == 40002{
            let t31 = view.viewWithTag(30001) as! UITextField
            let t32 = view.viewWithTag(30002) as! UITextField
            if t31.text == nil || t31.text == ""{
                myAlert(self, message: "请先选择开始时间!")
                return false
            }
            //设置开始时间为最小时间
            let dateStr = "\(t31.text!) \(t32.text!):00"
            datePicker.minimumDate = DateUtil.stringToDateTime(dateStr)
        }else{
            datePicker.minimumDate = nil
            let t41 = view.viewWithTag(40001) as! UITextField
            t41.text = ""
            let t42 = view.viewWithTag(40002) as! UITextField
            t42.text = ""
        }
        return true
    }
    
    //选监考老师
    @objc func btn_teacher_evet(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON](), noticeName: teacherNotice)
    }
    
    //选阅卷老师
    @objc func btn_marking_evet(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON](), noticeName: markingNotice)
    }
    
    @objc func chooseDate(picker :UIDatePicker){
        
        let t31 = view.viewWithTag(30001) as! UITextField
        let t32 = view.viewWithTag(30002) as! UITextField
        let t41 = view.viewWithTag(40001) as! UITextField
        let t42 = view.viewWithTag(40002) as! UITextField
        let datetime = DateUtil.formatDate(picker.date, pattern: DateUtil.dateTimePattern)
        let date = datetime.substring(to: 10)
        let time = datetime.substring(from: 11).substring(to:5)
        if t31.isFirstResponder || t32.isFirstResponder{
            t31.text = date
            t32.text = time
        }else if t41.isFirstResponder || t42.isFirstResponder{
            t41.text = date
            t42.text = time
            //计算开始和结束时间的区间
            let interval = DateUtil.intervalDate("\(t31.text!) \(t32.text!)", to: "\(t41.text!) \(t42.text!)", pattern: "yyyy-MM-dd HH:mm")
            let lbl = view.viewWithTag(20001) as! UILabel
            lbl.text = "时长：\(interval.day*24 + interval.hour)时\(interval.minute)分"
        }
    }
    
    @objc func chooseExamType(sender : UIButton){
        
        hiddenKeyBoard()
        var i = 0
        while (i < 2){
            let btn = view.viewWithTag(70001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitParam["stagetype"] = sender.tag - 70001
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
    }
    
    @objc func chooseSignInType(sender : UIButton){
        hiddenKeyBoard()
        var i = 0
        while (i < 2){
            let btn = view.viewWithTag(80001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitParam["isneedsign"] = sender.tag - 80001
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
    }
    
    @objc func chooseAppExam(sender : UIButton){
        hiddenKeyBoard()
        var i = 0
        while (i < 2){
            let btn = view.viewWithTag(100001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitParam["appexamination"] = sender.tag - 100001
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
    }
    
    func addrClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        let text = ds[row]["facilitiesname"].stringValue
        let txt = view.viewWithTag(50001) as! UITextField
        txt.text = text
        submitParam["facilitiesid"] = ds[row]["facilitiesid"].stringValue
        submitParam["name"] = text
    }
    
}

extension PublishExamController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        var btn = cell.viewWithTag(10001) as! UIButton
        btn.setCornerRadius(radius: btn.W / 2)
        btn.setImage(UIImage(named: "loginId"), for: .normal)
        let lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["personname"].stringValue
        btn = cell.viewWithTag(10003) as! UIButton
        btn.setCornerRadius(radius: btn.W / 2)
        btn.addTarget(self, action: #selector(removePerson), for: .touchUpInside)
        btn.viewParam = ["indexPath" : indexPath]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: 60, height: 70)
    }
    
    @objc func removePerson(sender : UIButton){
        let indexPath = sender.viewParam!["indexPath"] as! IndexPath
        jds.remove(at: indexPath.item)
        submitParam["studentlist"] = jds
        personCollection.reloadData()
        let lbl = view.viewWithTag(10001) as! UIButton
        lbl.setTitle(jds.count.description, for: .normal)
    }
    
}
