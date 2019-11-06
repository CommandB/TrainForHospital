//
//  PublishSubjectExamDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/26.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PublishSubjectExamDetailController : HBaseViewController,UITextFieldDelegate{
    
    var isSkillExam = false
    
    @IBOutlet weak var examInfoCollection: UICollectionView!
    
    var stuView = StudentsInExamCollection()
    
    let datePicker = UIDatePicker()
    
    var addrPicker = UIPickerView()
    let addrPickerImpl = HSimplePickerViewImpl()
    
    var jds = [JSON]()
    var submitData = [String:Any]()
    
    //选监考老师
    let teacherNotice = "teacherNotice"
    //选阅卷老师
    let markingNotice = "markingNotice"
    
    var currentChooseExamIndex = IndexPath()
    
    override func viewDidLoad() {
        
        
        
        examInfoCollection.delegate = self
        examInfoCollection.dataSource = self
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
        
        addrPicker = addrPickerImpl.getDefaultPickerView()
        addrPickerImpl.titleKey = "facilitiesname"
        addrPickerImpl.dataSource = UserDefaults.AppConfig.json(forKey: .classroomList).arrayValue
        addrPickerImpl.clorsureImpl = addrClosureImpl
        
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
        txt.delegate = self
//        txt.inputView = addrPicker
        
        var btn = view.viewWithTag(60001) as! UIButton
        btn.addTarget(self, action: #selector(btn_teacher_evet), for: .touchUpInside)
        
        btn = view.viewWithTag(80001) as! UIButton
        btn.addTarget(self, action: #selector(chooseSignInType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(80002) as! UIButton
        btn.addTarget(self, action: #selector(chooseSignInType(sender:)), for: .touchUpInside)
        
        btn = view.viewWithTag(100001) as! UIButton
        btn.addTarget(self, action: #selector(chooseAppExam(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(100002) as! UIButton
        btn.addTarget(self, action: #selector(chooseAppExam(sender:)), for: .touchUpInside)
        
        
        submitData["exerciseslist"] = [JSON]()
        var exercisesList = [JSON]()
        for stu in jds{
            var index = 0
            var examInfo = JSON()
            //试卷id
            let exercisesId = stu["exercisesid"].intValue
            
            if exercisesId == 0{    //0表示这个学生没有参加考试
                continue
            }
            //遍历找出对应的考试信息
            for exam in exercisesList{
                if exercisesId == exam["exercisesid"].intValue {
                    examInfo = exam
                    break
                }
                index += 1
            }
            if examInfo.isEmpty{
                examInfo["studentlist"] = JSON([JSON]())
                examInfo["exercisesid"] = JSON(exercisesId)
                examInfo["title"] = stu["title"]
                examInfo["marking"] = stu["marking"]
                examInfo["versionnumber"] = stu["versionnumber"]
                examInfo["markingteacherlist"] = JSON([JSON]())
                exercisesList.append(examInfo)
            }
            var arr = examInfo["studentlist"].arrayValue
            arr.append(stu)
            examInfo["studentlist"] = JSON(arr)
            
            exercisesList[index] = examInfo
        }
        
        submitData["exerciseslist"] = exercisesList
        submitData["marking"] = "0"
        submitData["isneedsign"] = 0
        jds = exercisesList
        
//        examInfoCollection.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.reloadExamCollection()
        })
    }
    
    @objc func selectAddress(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveTeacherNotice), name: Notification.Name.init(teacherNotice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMarkingNotice), name: Notification.Name.init(markingNotice), object: nil)
        
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //发布
    @IBAction func btn_submit_inside(_ sender: UIButton) {
        
        submitData["officeid"] = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)
        //默认是出科考试
        submitData["stagetype"] = 1
        if let t = (view.viewWithTag(10001) as! UITextField).text{
            submitData["examname"] = t
        }else{
            myAlert(self, message: "请填写考试主题!")
            return
        }
        
        //开始结束时间
        let startTime = (view.viewWithTag(30001) as! UITextField).text! + " " + (view.viewWithTag(30002) as! UITextField).text!
        let endTime = (view.viewWithTag(40001) as! UITextField).text! + " " + (view.viewWithTag(40002) as! UITextField).text!
        if startTime.count != 16{
            myAlert(self, message: "开始时间不合法!")
            return
        }
        submitData["starttime"]  = startTime
        submitData["endtime"] = endTime
        if endTime.count != 16{
            myAlert(self, message: "结束时间不合法!")
            return
        }
        
        if submitData["facilitiesid"] == nil{
            myAlert(self, message: "请选择考试地址!")
            return
        }
        
        if submitData["teacherlist"] == nil{
            myAlert(self, message: "请选择监考老师!")
            return
        }
        if submitData["appexamination"] == nil{
            myAlert(self, message: "请确认是否允许APP进行考试!")
            return
        }
        
        let exerciseslist = JSON(submitData["exerciseslist"]).arrayValue
        for exam in exerciseslist{
            if exam["marking"].debugDescription == "1" && (exam["markingteacherlist"] as! [JSON]).count == 1 {
                myAlert(self, message: "请选择阅卷老师!")
                return
            }

        }
        
        //print(submitParam)
        var url = ""
        if isSkillExam{
            url = SERVER_PORT + "rest/app/releaseExitOfficeSkillExam.do"
        }else{
            url = SERVER_PORT + "rest/app/releaseExitOfficeTheoryExam.do"
        }
        myPostRequest(url, submitData, method: .post).responseString(completionHandler: {resp in

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
                    print(json)
                }
                break

            case .failure(let error):
                myAlert(self, message: "发布考试异常!")
                print(error)
                break
            }
        })
    }
    
    
    ///选监考老师 callback
    @objc func receiveTeacherNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(teacherNotice), object: nil)
        if notification.userInfo != nil{
            let data = notification.userInfo!["data"] as! [JSON]
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
                
            }
            //添加监考老师
            submitData["teacherlist"] = data
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
    
    ///选阅卷老师 回调
    @objc func receiveMarkingNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(markingNotice), object: nil)
        if notification.userInfo != nil{
            let data = (notification.userInfo!["data"] as! [JSON])
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
            }
            //添加监考老师
            //submitPara  m["markingteacherlist"] = data
            var examArr = JSON(submitData["exerciseslist"]).arrayValue
            let index = submitData["indexPath"] as! Int
            examArr[index]["markingteacherlist"] = JSON(data)
            examArr[index]["markingteacherlistText"] = JSON(text)
            
            submitData["exerciseslist"] = examArr
            jds = examArr
//            examInfoCollection.reloadData()
            reloadExamCollection()
            
        }
    }
    
    //选监考老师
    @objc func btn_teacher_evet(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON](), noticeName: teacherNotice)
    }
    
    //选阅卷老师
    @objc func btn_marking_evet(sender : UIButton){
        //记录当前的选的index
//        currentChooseExamIndex = sender.viewParam!["indexPath"] as! IndexPath
        submitData["indexPath"] = (sender.viewParam!["indexPath"] as! IndexPath).item
        
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON](), noticeName: markingNotice)
    }
    
    
    ///选时间日期
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
            //设置当前时间为最小时间
            picker.minimumDate = picker.date
        }else if t41.isFirstResponder || t42.isFirstResponder{
            t41.text = date
            t42.text = time
            //计算开始和结束时间的区间
            let interval = DateUtil.intervalDate("\(t31.text!) \(t32.text!)", to: "\(t41.text!) \(t42.text!)", pattern: "yyyy-MM-dd HH:mm")
            let lbl = view.viewWithTag(20001) as! UILabel
            lbl.text = "时长：\(interval.day*24 + interval.hour)时\(interval.minute)分"
        }
    }
    
    ///选签到类型
    @objc func chooseSignInType(sender : UIButton){
        hiddenKeyBoard()
        var i = 0
        while (i < 2){
            let btn = view.viewWithTag(80001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitData["isneedsign"] = sender.tag - 80001
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
    }
    
    ///选是否可以APP考试
    @objc func chooseAppExam(sender : UIButton){
        hiddenKeyBoard()
        var i = 0
        while (i < 2){
            let btn = view.viewWithTag(100001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitData["appexamination"] = sender.tag - 100001
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
        submitData["facilitiesid"] = ds[row]["facilitiesid"].stringValue
        submitData["name"] = text
    }
    
    func reloadExamCollection(){
        for (index ,item) in jds.enumerated(){
            examInfoCollection.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let tag = textField.tag
        if tag == 40001 || tag == 40002{
            let t31 = view.viewWithTag(30001) as! UITextField
            if t31.text == nil || t31.text == ""{
                myAlert(self, message: "请先选择开始时间!")
                return false
            }
        }else if tag == 50001 {
            let vc = SelectAdressController()
            vc.callback = {[weak self] str,indexID in
                textField.text = str
                self?.submitData["facilitiesid"] = indexID
                self?.submitData["name"] = str
            }
            self.present(vc, animated: true, completion: nil)
        }else{
            datePicker.minimumDate = nil
            let t41 = view.viewWithTag(40001) as! UITextField
            t41.text = ""
            let t42 = view.viewWithTag(40002) as! UITextField
            t42.text = ""
        }
        return true
    }
    
}

extension PublishSubjectExamDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //构造cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        //试卷标题
        (cell.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
        
        //显示考试学员
        let stuCollection = cell.viewWithTag(10002) as! UICollectionView
        stuView = StudentsInExamCollection()
        stuCollection.delegate = stuView
        stuCollection.dataSource = stuView
        stuView.jds = data["studentlist"].arrayValue

        //控制阅卷老师
        cell.viewWithTag(10003)?.isHidden = true
        cell.viewWithTag(10004)?.isHidden = true
        if data["marking"].intValue == 1 {
            cell.viewWithTag(10003)?.isHidden = false
            cell.viewWithTag(10004)?.isHidden = false
        }
        let btn = (cell.viewWithTag(10004) as! UIButton)
        btn.viewParam = ["indexPath":indexPath]
        btn.addTarget(self, action: #selector(btn_marking_evet), for: .touchUpInside)
        
        let text = data["markingteacherlistText"].stringValue
        if text.count > 0{
            btn.setTitle(text, for: .normal)
            btn.setTitleColor(UIColor.darkText, for: .normal)
            btn.alpha = 1
        }else{
            btn.setTitle("请选择阅卷老师", for: .normal)
            btn.setTitleColor(UIColor.lightGray, for: .normal)
            btn.alpha = 0.6
        }
        
        print("初始化:\(indexPath)")
        print("btn.param:\(btn.viewParam)")
        print("stuView.jds:\(stuView.jds.count)")
        print("d--------分割线--------b")
        
        stuCollection.reloadData()
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
        collectionView.reloadItems(at: [indexPath])
    }
    
    
    //设置cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        if data["marking"].intValue == 1{
            return CGSize(width: UIScreen.width, height: 125)
        }else{
            return CGSize(width: UIScreen.width, height: 100)
        }
        
    }
}
