//
//  InspectController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/23.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class InspectController : HBaseViewController,UITextFieldDelegate{
    
    @IBOutlet weak var btn_baseInfo: UIButton!
    
    @IBOutlet weak var btn_students: UIButton!
    
    @IBOutlet weak var btn_patient: UIButton!
    
    @IBOutlet weak var btn_files: UIButton!
    
    @IBOutlet weak var lbl_markLine: UILabel!
    
    @IBOutlet weak var scrollView: HUIScrollView!
    
    @IBOutlet weak var students_view: UIView!
    
    @IBOutlet weak var patient_View: UIView!
    
    @IBOutlet weak var officeList_View: UIView!
    
    @IBOutlet weak var officeList_collection: UICollectionView!
    
    var jds = [JSON]()
    
    var jdsMyControl = [JSON]()
    
    let datePicker = UIDatePicker()
    var durationPicker = UIPickerView()
    let addrPicker = UIPickerView()
    var evPicker = UIPickerView()
    
    let hPickerImpl = HSimplePickerViewImpl()
    let durationPickerImpl = HSimplePickerViewImpl()
    
    var addrPickerDs = [JSON]()
    
    //选主讲人
    let speakerNotice = "speakerNotice"
    
    //发布的培训类型
    var trainType = JSON()
    
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    //提交时候用的数据
    var submitParam = [String:Any]()
    //评价功能
    var evaluaList = [String:[String:String]]()
    
    var selectedTextField : UITextField?
    
    var switchKeyBoardBtn:UIButton!
    override func viewDidLoad() {
        
        //初始化提交数据
        submitParam["sign"] = 0
        submitParam["officeid"] = UserDefaults.standard.integer(forKey: LoginInfo.officeId.rawValue)
        
        view.bringSubview(toFront: officeList_View)
        
        let lbl_viewTitle = view.viewWithTag(11111) as! UILabel
        lbl_viewTitle.text = trainType["traintypename"].stringValue
        
        officeList_collection.delegate = self
        officeList_collection.dataSource = self
        
        jds = UserDefaults.AppConfig.json(forKey: .officeList).arrayValue
        
        for item in jds{
            if item["ismymanage"].stringValue == "1"{
                jdsMyControl.append(item)
            }
        }
        
        officeList_collection.reloadData()
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
        
        addrPicker.delegate = self
        addrPicker.dataSource = self
        var classroomList = UserDefaults.AppConfig.json(forKey: .classroomList).arrayValue
        classroomList.insert(["facilitiesname":""], at: 0)
        addrPickerDs = classroomList
        
        switchKeyBoardBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 100, height: 40))
        switchKeyBoardBtn.setTitle("手动输入", for: .normal)
        switchKeyBoardBtn.addTarget(self, action: #selector(switchKeyboard), for: .touchUpInside)
//        addrPicker.addSubview(switchKeyBoardBtn)
        addrPicker.bringSubview(toFront: switchKeyBoardBtn)
        
        evPicker = hPickerImpl.getDefaultPickerView()
//        evPicker.addCloseButton(parentView: self.view)
        hPickerImpl.titleKey = "evaluationname"
        var teachingActivityEvaluationList = UserDefaults.AppConfig.json(forKey: .teachingActivityEvaluationList).arrayValue
        teachingActivityEvaluationList.insert(JSON(["evaluationname":"不需要评价"]), at: 0)
        hPickerImpl.dataSource = teachingActivityEvaluationList
        hPickerImpl.clorsureImpl = evClosureImpl
//        hPickerImpl.parentView = self
        
        durationPicker = durationPickerImpl.getDefaultPickerView()
        durationPickerImpl.titleKey = "text"
        durationPickerImpl.dataSource = JSON([["text":"请选择"], ["text":"30分钟", "value":30],["text":"45分钟", "value":45], ["text":"1小时", "value":60], ["text":"1小时30分钟", "value":90], ["text":"2小时", "value":120]]).arrayValue
        durationPickerImpl.clorsureImpl = durationClosureImpl
        
        //用作滚动页的容器
        scrollView.contentSize = CGSize(width: UIScreen.width * (3), height: scrollView.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        //tab的下划线及tab需要的一些设置
        lbl_markLine.clipsToBounds = true
        lbl_markLine.layer.cornerRadius = 1
        buttonGroup = [btn_baseInfo ,btn_students ,btn_patient ,btn_files]
        
        students_view.frame.origin = CGPoint(x: UIScreen.width, y: students_view.frame.origin.y)
        patient_View.frame.origin = CGPoint(x: UIScreen.width * (2), y: patient_View.frame.origin.y)
        
        //基础数据设置
        var txt = view.viewWithTag(10001) as! UITextField
        txt.delegate = self
        
        txt = view.viewWithTag(20001) as! TextFieldForNoMenu
        txt.inputView = durationPicker
        txt.delegate = self
        
        txt = view.viewWithTag(30001) as! TextFieldForNoMenu
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
//        txt.inputView = addrPicker
        txt.delegate = self
        
        var btn = view.viewWithTag(60001) as! UIButton
        btn.addTarget(self, action: #selector(addSpeaker), for: .touchUpInside)
        btn.contentHorizontalAlignment = .right
        
        btn = view.viewWithTag(70001) as! UIButton
        btn.addTarget(self, action: #selector(showOfficeList), for: .touchUpInside)
        btn.setTitle(UserDefaults.standard.string(forKey: LoginInfo.officeName.rawValue), for: .normal)
        

        var isNeedCheckIn = UserDefaults.AppConfig.string(forKey: .trainingIsNeedCheckIn)
        if isNeedCheckIn == nil {
            isNeedCheckIn = "0"
        }
        //签到方式
        btn = view.viewWithTag(80001+(isNeedCheckIn?.toInt())!) as! UIButton
        btn.setImage(UIImage(named: "选择-大"), for: .normal)

        btn = view.viewWithTag(80001) as! UIButton
        btn.addTarget(self, action: #selector(chooseCheckInType), for: .touchUpInside)
        btn = view.viewWithTag(80002) as! UIButton
        btn.addTarget(self, action: #selector(chooseCheckInType), for: .touchUpInside)
        btn = view.viewWithTag(80003) as! UIButton
        btn.addTarget(self, action: #selector(chooseCheckInType), for: .touchUpInside)
        
        //评价功能
        
        
        let s2t = JSON(parseJSON: UserDefaults.AppConfig.string(forKey: .teachingActivityS2TEvaluationList)!)
        let t2s = JSON(parseJSON: UserDefaults.AppConfig.string(forKey: .teachingActivityT2SEvaluationList)!)
        
        txt = view.viewWithTag(90001) as! UITextField
        txt.delegate = self
        txt.inputView = evPicker
        evaluaList["s2t"] = ["beevaluateid":"5", "beevaluatename":"培训老师" , "evaluatetableid":s2t["evaluationid"].stringValue, "evaluatetablename":s2t["evaluationname"].stringValue, "evaluateid":"1", "evaluatename":"学生"]
        txt.text = s2t["evaluationname"].stringValue
        
        txt = view.viewWithTag(90002) as! UITextField
        txt.delegate = self
        txt.inputView = evPicker
        txt.text = t2s["evaluationname"].stringValue
        evaluaList["t2s"] = ["beevaluateid":"1", "beevaluatename":"学生", "evaluatetableid":t2s["evaluationid"].stringValue, "evaluatetablename":t2s["evaluationname"].stringValue, "evaluateid":"5", "evaluatename":"培训老师"]

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: Notification.Name.init(speakerNotice), object: nil)
    }
    
    @objc func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self)
        if notification.userInfo != nil{
            let data = notification.userInfo!["data"] as! [JSON]
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
            }
            let btn = view.viewWithTag(60001) as! UIButton
            if text.count > 0 {
                btn.setTitle(text, for: .normal)
                btn.alpha = 1
                btn.setTitleColor(UIColor.black, for: .normal)
                //主讲人
                submitParam["teacherlist"] = data
            }else{
                btn.setTitle("点击选择主讲人", for: .normal)
                btn.alpha = 0.8
                btn.setTitleColor(UIColor.gray, for: .normal)
            }
            
        }
    }
    
    @objc func addSpeaker(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON]() , noticeName: speakerNotice)
    }
    
    @objc func showOfficeList(){
        if jdsMyControl.count == 0 {
            myAlert(self, message: "暂无可切换科室")
        }else{
            officeList_View.isHidden = false
        }
        
    }
    
    
    @IBAction func btn_hiddenOfficeList_inside(_ sender: UIButton) {
        officeList_View.isHidden = true
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        myConfirm(self, message: "确定退出编辑吗?" ,okTitle: "是" ,cancelTitle: "否", okHandler : { action in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        //dismiss(animated: true, completion: nil)
        
        submitParam["isfreein"] = 0
        submitParam["issend"] = 0
        submitParam["videiotape"] = 0
        submitParam["traintype"] = trainType["traintypeid"].intValue
        
        let url = SERVER_PORT + "rest/app/train/releaseTrain.do"
        
        //标题
        let txt_title = view.viewWithTag(10001) as! UITextField
        if txt_title.text == ""{
            myAlert(self, message: "主题不能为空!")
            return
        }
        submitParam["title"] = txt_title.text
        
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
        submitParam["endtime"] = endTime
        
        //评价功能
        submitParam["evaluatelist"] = ([[String:String]])(evaluaList.values)
        
        //学员信息
        if InspectStudentsController.jds.count == 0 {
            myAlert(self, message: "请选择参加学员!")
            return
        }
        var stuList = [[String:String]]()
        for item in InspectStudentsController.jds {
            var stu = ["personid":item["personid"].stringValue]
            stu["personname"] = item["personname"].stringValue
            stuList.append(stu)
        }
        submitParam["studentlist"] = stuList
        
//        print(submitParam)
        
        //view.current
        uploadImage(url, images: nil, parameters: submitParam, completionHandler: {resp in
            switch resp.result{
            case .success(let respStr):
                let json = JSON(respStr)
                print(json)
                if json["code"].stringValue == "1"{
                    myAlert(self, message: "发布成功!", handler: {action in
                        self.dismiss(animated: true, completion: nil)
                    })
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "提交异常!")
                print(error)
                break
            }
        })
        
    }
    
    //页签按钮
    @IBAction func btn_undone_inside(_ sender: UIButton) {
        hiddenKeyBoard()
        tabsTouchAnimation(sender: sender)
    }
    
    @objc func switchKeyboard(sender : UIButton){
        print("我来啦啦啦安利安利安利安利啊啊来啦安利安利啊~~")
        
    }
    
    func tabsTouchAnimation( sender : UIButton){
        //-----------------计算 "下标线"label的动画参数
        
        for b in buttonGroup {
            if b == sender{
                b.setTitleColor(UIColor.init(hex: "407BD8"), for: .normal)
            }else{
                b.setTitleColor(UIColor.black, for: .normal);
            }
        }
        
        let btn_x = sender.frame.origin.x                      //按钮x轴
        let btn_middle = sender.frame.size.width / 2           //按钮中线
        let lbl_half = lbl_markLine.frame.size.width / 2       //下标线的一半宽度
        //计算下标线的x轴位置
        let target_x = btn_x + btn_middle - lbl_half
        let target_y = lbl_markLine.frame.origin.y
        
        
        //动画开始
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        lbl_markLine.frame = CGRect(origin: CGPoint(x:target_x,y:target_y), size: lbl_markLine.frame.size)
        
        //滚动效果
        if sender.restorationIdentifier == "btn_baseInfo"{
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }else if sender.restorationIdentifier == "btn_students"{
            scrollView.setContentOffset(CGPoint(x: UIScreen.width, y: 0), animated: true)
        }else if sender.restorationIdentifier == "btn_patient"{
            scrollView.setContentOffset(CGPoint(x: UIScreen.width * 2, y: 0), animated: true)
        }
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
        //print("btn_x = \(btn_x)")
        //print("lbl_markLine.frame = \(lbl_markLine.frame)")
    }
    
    @objc func chooseCheckInType(sender : UIButton){
        hiddenKeyBoard()
        var i = 0
        while (i < 3){
            let btn = view.viewWithTag(80001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitParam["sign"] = i
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
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
            let txt = view.viewWithTag(20001) as! TextFieldForNoMenu
            txt.text = "时长：\(interval.hour)时\(interval.minute)分"
        }
    }
    
    func evClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
//        myAlert(self, message: "row:\(row)")
        if let t = selectedTextField{
            var key = "1"
            let data = ds[row]
            if t.tag == 90002{
                key = "5"
            }
            if row == 0 {
                t.text = data["evaluationname"].stringValue
                evaluaList.removeValue(forKey: key)
                if t.tag == 90001{
                    evaluaList["s2t"]?.removeAll()
                }else if t.tag == 90002{
                    evaluaList["t2s"]?.removeAll()
                }
            }else{
                t.text = data["evaluationname"].stringValue
                
                if t.tag == 90001{
                    evaluaList["s2t"] = ["beevaluateid":"5","beevaluatename":"培训老师", "evaluatetableid":data["evaluationid"].stringValue, "evaluatetablename":t.text!, "evaluateid":"1", "evaluatename":"学生"]
                }else{
                    evaluaList["t2s"] = ["beevaluateid":"1","beevaluatename":"学生", "evaluatetableid":data["evaluationid"].stringValue, "evaluatetablename":t.text!,  "evaluateid":"5", "evaluatename":"培训老师"]
                }
                
            }
            
            
            
        }
    }
    
    func durationClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        
        if row == 0{
            return
        }
        
        let t41 = view.viewWithTag(40001) as! UITextField
        let t42 = view.viewWithTag(40002) as! UITextField
        let data = ds[row]
        let txt = view.viewWithTag(20001) as! TextFieldForNoMenu
        txt.text = "时长：\(data["text"].stringValue)"
        let startTimeStr = (view.viewWithTag(30001) as! UITextField).text! + " " + (view.viewWithTag(30002) as! UITextField).text! + ":00"
        var endTime = DateUtil.stringToDateTime(startTimeStr)
        endTime.addTimeInterval(data["value"].doubleValue * 60)
        let endTimeStr = DateUtil.dateTimeToString(endTime)
        let date = endTimeStr.substring(to: 10)
        let time = endTimeStr.substring(from: 11).substring(to:5)
        t41.text = date
        t42.text = time
        
        
    }
  
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        if tag == 30001 || tag == 30002{
            let t31 = view.viewWithTag(30001) as! UITextField
            let t32 = view.viewWithTag(30002) as! UITextField
            if t31.text == nil || t32.text == ""{
                t31.text = DateUtil.formatDate(Date(), pattern: DateUtil.datePattern)
                t32.text = DateUtil.formatDate(Date(), pattern: "HH:mm")
            }
            
        }else if tag == 40001 || tag == 40002 || tag == 20001{
            let t31 = view.viewWithTag(30001) as! UITextField
            let t32 = view.viewWithTag(30002) as! UITextField
            if t31.text == nil || t31.text == ""{
                myAlert(self, message: "请先选择开始时间!")
                return false
            }
            //设置开始时间为最小时间
            let dateStr = "\(t31.text!) \(t32.text!):00"
            datePicker.minimumDate = DateUtil.stringToDateTime(dateStr)
        }else if tag == 50001{
            let vc = SelectAdressController()
            vc.callback = {[weak self] str,indexID in
                textField.text = str
                self?.submitParam["address"] = str
            }
            self.present(vc, animated: true, completion: nil)
            
        }else if tag == 90002 || tag == 90001 {
            
            var selectedRowNumber = 0
            var key = "s2t"
            if tag == 90002{
                key = "t2s"
            }
            if !(evaluaList[key]?.isEmpty ?? true){
                let selectedId = evaluaList[key]!["evaluatetableid"]
                let json = UserDefaults.AppConfig.json(forKey: .teachingActivityEvaluationList).arrayValue
                var index = 0
                for o in json{
                    if o["evaluationid"].stringValue == selectedId{
                        break
                    }
                    index += 1
                    
                }
                selectedRowNumber = index + 1
            }
            evPicker.selectRow(selectedRowNumber, inComponent: 0, animated: true)
            selectedTextField = textField
        }else if tag == 30001 || tag == 30002{
            datePicker.minimumDate = nil
            let t41 = view.viewWithTag(40001) as! UITextField
            t41.text = ""
            let t42 = view.viewWithTag(40002) as! UITextField
            t42.text = ""
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        hiddenKeyBoard()
        return true
    }
    
}

extension InspectController : UIPickerViewDelegate , UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return addrPickerDs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return addrPickerDs[row]["facilitiesname"].stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let addr = addrPickerDs[row]["facilitiesname"].stringValue
        submitParam["address"] = addrPickerDs[row]["facilitiesname"].stringValue
        if row == 0 {
            submitParam["address"] = "-1"
        }
        let txt = view.viewWithTag(50001) as! TextFieldForNoMenu
        txt.text = addr
    }
    
    
}

extension InspectController : UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //print("will")
        hiddenKeyBoard()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = scrollView.contentOffset.x
        if x < UIScreen.width / 2{
            tabsTouchAnimation(sender: btn_baseInfo)
        }else if x > UIScreen.width / 2 && x < UIScreen.width + (UIScreen.width / 2){
            tabsTouchAnimation(sender: btn_students)
        }else{
            tabsTouchAnimation(sender: btn_patient)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        if x < UIScreen.width / 2{
            tabsTouchAnimation(sender: btn_baseInfo)
        }else if x > UIScreen.width / 2 && x < UIScreen.width + (UIScreen.width / 2){
            tabsTouchAnimation(sender: btn_students)
        }else{
            tabsTouchAnimation(sender: btn_patient)
        }
    }
}


extension InspectController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return jdsMyControl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jdsMyControl[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["officename"].stringValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = jdsMyControl[indexPath.item]
        let btn = view.viewWithTag(70001) as! UIButton
        btn.setTitle(data["officename"].stringValue, for: .normal)
        submitParam["officeid"] = data["officeid"].stringValue
        officeList_View.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: 40)
    }
    
}
