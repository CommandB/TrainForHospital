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

class InspectController : MyBaseUIViewController{
    
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
        
        var txt = baseInfo_view.viewWithTag(30001) as! TextFieldForNoMenu
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
        btn.set(image: UIImage(named: "箭头2"), title: "默认常用地址", titlePosition: .left, additionalSpacing: -40.0, state: .normal)
        btn = view.viewWithTag(60001) as! UIButton
        btn.set(image: UIImage(named: "箭头2"), title: "默认常用老师", titlePosition: .left, additionalSpacing: -40.0, state: .normal)
        btn = view.viewWithTag(70001) as! UIButton
        btn.set(image: UIImage(named: "箭头2"), title: "默认常用记录人", titlePosition: .left, additionalSpacing: -55.0, state: .normal)
        
        
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
        dismiss(animated: true, completion: nil)
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
