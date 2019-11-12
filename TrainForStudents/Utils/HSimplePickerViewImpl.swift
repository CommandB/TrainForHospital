//
//  HSimplePickerViewImpl.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/3.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AudioToolbox

typealias didSelectorClorsure = (_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void
class HSimplePickerViewImpl :UIViewController, UIPickerViewDelegate , UIPickerViewDataSource{
    
    var clorsureImpl : didSelectorClorsure?
    var dataSource = [JSON]()
    var titleKey = ""
//    var parentView : UIViewController? = nil
    
   
    
    
    func getDefaultPickerView( picker :UIPickerView? = nil) -> UIPickerView{
        var p = UIPickerView()
        if picker != nil{
            p = picker!
        }
        p.delegate = self
        p.dataSource = self
        return p
    }
    
    func getOfficePickerView( picker :UIPickerView? = nil) -> UIPickerView{
        
        
        self.titleKey = "officename"
        self.dataSource = UserDefaults.AppConfig.json(forKey: .officeList).arrayValue
        self.dataSource.insert(JSON(["officename":"全部","officeid":"-1"]), at: 0)
        var p = UIPickerView()
        if picker != nil{
            p = picker!
        }
        p.delegate = self
        p.dataSource = self
        
        
        
        return p
    }
    //判断切换科室内容是否为空
    func juggeChanegeOfficeContent()->Bool{
        let tempData = UserDefaults.AppConfig.json(forKey: .officeList).arrayValue
        var dataBot = [JSON]()
        for item in tempData{
            if item["ismymanage"].stringValue == "1"{
                dataBot.append(item)
            }
        }
        print(dataBot)
        if dataBot.count == 0 {
            return false
        }else{
            return true
        }
    }
    
    //切换科室只能选择管理科室
    func getOfficeManagerPickerView( picker :UIPickerView? = nil) -> UIPickerView{
        
        
        self.titleKey = "officename"
        let tempData = UserDefaults.AppConfig.json(forKey: .officeList).arrayValue
        var dataBot = [JSON]()
        for item in tempData{
            if item["ismymanage"].stringValue == "1"{
                dataBot.append(item)
            }
        }
        self.dataSource = dataBot
        var p = UIPickerView()
        if picker != nil{
            p = picker!
        }
        p.delegate = self
        p.dataSource = self
        
        return p
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row][titleKey].stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //1519
        //1520
        //1521
//        AudioServicesPlayAlertSound(1520)
//        if parentView != nil{
//            if clorsureImpl == nil{
//                myAlert(parentView!, message: "clorsureImpl == nil")
//            }
//        }
        
        if clorsureImpl != nil{
            clorsureImpl!(dataSource,pickerView,row,component)
        }
        
    }
    
}
