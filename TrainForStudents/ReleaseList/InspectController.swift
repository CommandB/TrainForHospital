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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var baseInfo_view: UIView!
    
    @IBOutlet weak var students_view: UIView!
    
    @IBOutlet weak var patient_View: UIView!
    
    let datePicker = UIDatePicker()
    
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    //提交时候用的数据
    var submitParam = [String:Any]()
    
    override func viewDidLoad() {
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
        
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
        var txt = baseInfo_view.viewWithTag(10001) as! UITextField
        txt.delegate = self
        txt = baseInfo_view.viewWithTag(30001) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = baseInfo_view.viewWithTag(30002) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = baseInfo_view.viewWithTag(40001) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = baseInfo_view.viewWithTag(40002) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        var btn = view.viewWithTag(50001) as! UIButton
        btn.set(image: UIImage(named: "箭头2"), title: "选择地址", titlePosition: .left, additionalSpacing: -40.0, state: .normal)
        btn = view.viewWithTag(60001) as! UIButton
        btn.set(image: UIImage(named: "箭头2"), title: "默认常用老师", titlePosition: .left, additionalSpacing: -40.0, state: .normal)
        
        let isNeedCheckIn = UserDefaults.AppConfig.string(forKey: .trainingIsNeedCheckIn)
        
        //签到方式
        btn = baseInfo_view.viewWithTag(80001+(isNeedCheckIn?.toInt())!) as! UIButton
        btn.setImage(UIImage(named: "选择-大"), for: .normal)
        
        btn = baseInfo_view.viewWithTag(80001) as! UIButton
        btn.addTarget(self, action: #selector(chooseCheckInType), for: .touchUpInside)
        
        
        //培训学员设置
        let sv_btn = students_view.viewWithTag(10001) as! UIButton
        sv_btn.addTarget(self, action: #selector(presentPersonSelector), for: .touchUpInside)
        
        //患者信息设置
        
        //附件设置
        
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        //dismiss(animated: true, completion: nil)
        
        submitParam["isfreein"] = 0
        
        let url = SERVER_PORT + "/doctor_train/rest/app/train/releaseTrain.do"
        
        //标题
        let txt_title = baseInfo_view.viewWithTag(10001) as! UITextField
        if txt_title.text == ""{
            myAlert(self, message: "主题不能为空!")
            return
        }
        submitParam["title"] = txt_title.text
        
        //开始结束时间
        let startTime = (baseInfo_view.viewWithTag(30001) as! UITextField).text! + " " + (baseInfo_view.viewWithTag(30002) as! UITextField).text!
        let endTime = (baseInfo_view.viewWithTag(40001) as! UITextField).text! + " " + (baseInfo_view.viewWithTag(40002) as! UITextField).text!
        
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
        
        
        
        //学员信息
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PersonSelectorController.addStudentsNotificationName, object: nil)
        
        print(submitParam)
        
        
        
        //view.current
        
        //        myPostRequest(url, submitParam, method: .post).responseString(completionHandler: {resp in
        //            switch resp.result{
        //            case .success(let respStr):
        //                let json = JSON(respStr)
        //                if json["code"].stringValue == "1"{
        //
        //                }else{
        //                    myAlert(self, message: json["msg"].stringValue)
        //                }
        //                break
        //            case .failure(let error):
        //                myAlert(self, message: "提交异常!")
        //                print(error)
        //                break
        //            }
        //        })
        
    }
    
    func receiveNotice(notification : NSNotification){
        if notification.userInfo != nil{
            let result = notification.userInfo!["data"] as! [JSON]
            var stuList = [[String:String]]()
            for item in result {
                var stu = ["personid":item["personid"].stringValue]
                stu["personname"] = item["personname"].stringValue
                stuList.append(stu)
            }
            submitParam["studentlist"] = stuList
        }
    }
    
    //待考任务 待评任务 调查问卷 按钮
    @IBAction func btn_undone_inside(_ sender: UIButton) {
        tabsTouchAnimation(sender: sender)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField.tag - 30002) > 0{
            let t31 = baseInfo_view.viewWithTag(30001) as! UITextField
            if t31.text == nil || t31.text == ""{
                myAlert(self, message: "请先选择开始时间!")
                return false
            }
        }else{
            datePicker.minimumDate = nil
        }
        return true
    }
    
    func presentPersonSelector(){
        myPresentView(self, viewName: "personSelectorView")
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
        
        var i = 0
        while (i < 3){
            let btn = baseInfo_view.viewWithTag(80001+i) as! UIButton
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
        let t31 = baseInfo_view.viewWithTag(30001) as! UITextField
        let t32 = baseInfo_view.viewWithTag(30002) as! UITextField
        let t41 = baseInfo_view.viewWithTag(40001) as! UITextField
        let t42 = baseInfo_view.viewWithTag(40002) as! UITextField
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
            let lbl = baseInfo_view.viewWithTag(20001) as! UILabel
            lbl.text = "时长：\(interval.hour)时\(interval.minute)分"
        }
        
    }
    
}

extension InspectController : UIScrollViewDelegate{
    
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
