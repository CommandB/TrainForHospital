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
    
    var jds = [JSON]()
    
    let datePicker = UIDatePicker()
    
    var addrPicker = UIPickerView()
    let hPickerImpl = HSimplePickerViewImpl()
    
    override func viewDidLoad() {
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
        
        addrPicker = hPickerImpl.getDefaultPickerView()
        hPickerImpl.titleKey = "facilitiesname"
        hPickerImpl.dataSource = UserDefaults.AppConfig.json(forKey: .classroomList).arrayValue
        hPickerImpl.clorsureImpl = addrClosureImpl
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.personCollection.mj_header.beginRefreshing()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PersonSelectorController.addPersonNotificationName, object: nil)
    }
    
    func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self)
        if notification.userInfo != nil{
            jds = notification.userInfo!["data"] as! [JSON]
            personCollection.reloadData()
            let lbl = view.viewWithTag(10001) as! UIButton
            lbl.setTitle(jds.count.description, for: .normal)
        }
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_addPerson_inside(_ sender: UIButton) {
        myPresentView(self, viewName: "personSelectorView")
    }
    
    @IBAction func btn_selectPaper_inside(_ sender: UIButton) {
        //dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        if tag == 40001 || tag == 40002{
            let t31 = view.viewWithTag(30001) as! UITextField
            if t31.text == nil || t31.text == ""{
                myAlert(self, message: "请先选择开始时间!")
                return false
            }
        }else{
            datePicker.minimumDate = nil
            let t41 = view.viewWithTag(40001) as! UITextField
            t41.text = ""
            let t42 = view.viewWithTag(40002) as! UITextField
            t42.text = ""
        }
        return true
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
            //设置当前时间为最小时间
            picker.minimumDate = picker.date
        }else if t41.isFirstResponder || t42.isFirstResponder{
            t41.text = date
            t42.text = time
            //计算开始和结束时间的区间
            let interval = DateUtil.intervalDate("\(t31.text!) \(t32.text!)", to: "\(t41.text!) \(t42.text!)", pattern: "yyyy-MM-dd HH:mm")
            let lbl = view.viewWithTag(20001) as! UILabel
            lbl.text = "时长：\(interval.hour)时\(interval.minute)分"
        }
    }
    
    func addrClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        let txt = view.viewWithTag(50001) as! UITextField
        txt.text = ds[row]["facilitiesname"].stringValue
    }
    
}

extension PublishExamController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let btn = cell.viewWithTag(10001) as! UIButton
        btn.setCornerRadius(radius: btn.W.divided(by: 2))
        btn.setImage(UIImage(named: "loginId"), for: .normal)
        let lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["personname"].stringValue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: 60, height: 70)
    }
    
}
