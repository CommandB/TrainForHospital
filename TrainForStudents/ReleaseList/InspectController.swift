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

class InspectController : HBaseViewController{
    
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
    
    let datePicker = UIDatePicker()
    let addrPicker = UIPickerView()
    var evPicker = UIPickerView()
    let hPickerImpl = HSimplePickerViewImpl()
    
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
    
    override func viewDidLoad() {
        
        let lbl_viewTitle = view.viewWithTag(11111) as! UILabel
        lbl_viewTitle.text = trainType["traintypename"].stringValue
        
        officeList_collection.delegate = self
        officeList_collection.dataSource = self
        jds = UserDefaults.AppConfig.json(forKey: .officeList).arrayValue
        
        officeList_collection.reloadData()
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
        
        addrPicker.delegate = self
        addrPicker.dataSource = self
        addrPickerDs = JSON(parseJSON:UserDefaults.AppConfig.string(forKey: .classroomList)!).arrayValue
        
        evPicker = hPickerImpl.getDefaultPickerView()
        hPickerImpl.titleKey = "evaluationname"
        hPickerImpl.dataSource = UserDefaults.AppConfig.json(forKey: .teachingActivityEvaluationList).arrayValue
        hPickerImpl.clorsureImpl = evClosureImpl
        
        //用作滚动页的容器
        scrollView.contentSize = CGSize(width: UIScreen.width.multiplied(by: 3), height: scrollView.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        //tab的下划线及tab需要的一些设置
        lbl_markLine.clipsToBounds = true
        lbl_markLine.layer.cornerRadius = 1
        buttonGroup = [btn_baseInfo ,btn_students ,btn_patient ,btn_files]
        
        students_view.frame.origin = CGPoint(x: UIScreen.width, y: students_view.frame.origin.y)
        patient_View.frame.origin = CGPoint(x: UIScreen.width.multiplied(by: 2), y: patient_View.frame.origin.y)
        
        //基础数据设置
        var txt = view.viewWithTag(10001) as! UITextField
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
        txt.inputView = addrPicker
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
        evaluaList["1"] = ["beevaluateid":"1","evaluationid":s2t["evaluationid"].stringValue]
        txt.text = s2t["evaluationname"].stringValue
        
        txt = view.viewWithTag(90002) as! UITextField
        txt.delegate = self
        txt.inputView = evPicker
        txt.text = t2s["evaluationname"].stringValue
        evaluaList["5"] = ["beevaluateid":"5","evaluationid":t2s["evaluationid"].stringValue]

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: Notification.Name.init(speakerNotice), object: nil)
    }
    
    func receiveNotice(notification : NSNotification){
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
            }else{
                btn.setTitle("点击选择主讲人", for: .normal)
                btn.alpha = 0.8
                btn.setTitleColor(UIColor.gray, for: .normal)
            }
            
        }
    }
    
    func addSpeaker(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON]() , noticeName: speakerNotice)
    }
    
    func showOfficeList(){
        officeList_View.isHidden = false
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
        submitParam["issend"] = 1
        submitParam["type"] = trainType["traintypeid"].intValue
        submitParam["officeid"] = UserDefaults.standard.integer(forKey: LoginInfo.officeId.rawValue)
        
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
        
        print(submitParam)
        
        
        
        //view.current
        
        myPostRequest(url, submitParam, method: .post).responseString(completionHandler: {resp in
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                print(json)
                if json["code"].stringValue == "1"{

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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        if tag == 40001 || tag == 40002{
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
            textField.text = addrPickerDs[addrPicker.selectedRow(inComponent: 0)]["facilitiesname"].stringValue
            submitParam["address"] = addrPickerDs[addrPicker.selectedRow(inComponent: 0)]["facilitiesid"].stringValue
        }else if tag == 90002 || tag == 90001 {
            evPicker.reloadAllComponents()
            selectedTextField = textField
        }else{
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
            scrollView.setContentOffset(CGPoint(x: UIScreen.width.multiplied(by: 2), y: 0), animated: true)
        }
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
        //print("btn_x = \(btn_x)")
        //print("lbl_markLine.frame = \(lbl_markLine.frame)")
    }
    
    func chooseCheckInType(sender : UIButton){
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
    
    
    func chooseDate(picker :UIDatePicker){
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
            lbl.text = "时长：\(interval.hour)时\(interval.minute)分"
        }
    }
    
    func evClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        if let t = selectedTextField{
            let data = ds[row]
            t.text = data["evaluationname"].stringValue
            if t.tag == 90001{
                evaluaList["1"]!["evaluationid"] = data["evaluationid"].stringValue
            }else{
                evaluaList["5"]!["evaluationid"] = data["evaluationid"].stringValue
            }
        }
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
        submitParam["address"] = addrPickerDs[row]["facilitiesid"].stringValue
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
        if x < UIScreen.width.divided(by: 2){
            tabsTouchAnimation(sender: btn_baseInfo)
        }else if x > UIScreen.width.divided(by: 2) && x < UIScreen.width.adding(UIScreen.width.divided(by: 2)){
            tabsTouchAnimation(sender: btn_students)
        }else{
            tabsTouchAnimation(sender: btn_patient)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        if x < UIScreen.width.divided(by: 2){
            tabsTouchAnimation(sender: btn_baseInfo)
        }else if x > UIScreen.width.divided(by: 2) && x < UIScreen.width.adding(UIScreen.width.divided(by: 2)){
            tabsTouchAnimation(sender: btn_students)
        }else{
            tabsTouchAnimation(sender: btn_patient)
        }
    }
}


extension InspectController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["officename"].stringValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = jds[indexPath.item]
        let btn = view.viewWithTag(70001) as! UIButton
        btn.setTitle(data["officename"].stringValue, for: .normal)
        submitParam["officeid"] = data["officeid"].stringValue
        officeList_View.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: 40)
    }
    
}
