//
//  PersonSelectorAdvanceSearchController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/21.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PersonSelectorAdvanceSearchController : HBaseViewController{
    
    var dataPicker = UIPickerView()
    let dataPickerImpl = HSimplePickerViewImpl()
    
    var submitData = [String:Any]()
    var selectedKey = ""
    var selectedTextField = UITextField()
    
    static var defaultNoticeName = NSNotification.Name(rawValue: "paperSelectorAdvanceSearchDefaultNoticeName")
    
    override func viewDidLoad() {
        
        dataPicker = dataPickerImpl.getDefaultPickerView()
        dataPickerImpl.titleKey = "grade"
        dataPickerImpl.dataSource = UserDefaults.AppConfig.json(forKey: .gradeList).arrayValue
        dataPickerImpl.clorsureImpl = addrClosureImpl
        
        (view.viewWithTag(10001) as! UITextField).inputView = dataPicker
        (view.viewWithTag(10001) as! UITextField).delegate = self
        (view.viewWithTag(20001) as! UITextField).inputView = dataPicker
        (view.viewWithTag(20001) as! UITextField).delegate = self
        (view.viewWithTag(30001) as! UITextField).inputView = dataPicker
        (view.viewWithTag(30001) as! UITextField).delegate = self
        (view.viewWithTag(40001) as! UITextField).inputView = dataPicker
        (view.viewWithTag(40001) as! UITextField).delegate = self
        (view.viewWithTag(50001) as! UITextField).inputView = dataPicker
        (view.viewWithTag(50001) as! UITextField).delegate = self
        (view.viewWithTag(60001) as! UITextField).inputView = dataPicker
        (view.viewWithTag(60001) as! UITextField).delegate = self
        (view.viewWithTag(70001) as! UITextField).inputView = dataPicker
        (view.viewWithTag(70001) as! UITextField).delegate = self
        
        
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        print(submitData)

        NotificationCenter.default.post(name: PersonSelectorAdvanceSearchController.defaultNoticeName, object: nil, userInfo: ["data":submitData])

        dismiss(animated: true, completion: nil)
    }
    @IBAction func btn_reset_inside(_ sender: UIButton) {
        
        for i in 1...7{
            let tag = i * 10000 + 1
            (view.viewWithTag(tag) as! UITextField).text = "全部"
        }
        submitData.removeAll()
    }
    
    
    func addrClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        
        var data = JSON()
        var text = ""
        let index = row == 0 ? 0 : row - 1
        
        switch selectedTextField.tag {
        case 10001:
            data = UserDefaults.AppConfig.json(forKey: .majorList).arrayValue[index]
            text = data["majorname"].stringValue
            submitData["majorsubjectid"] = data["majorsubjectid"].stringValue
            if row == 0{
                submitData.removeValue(forKey: "majorsubjectid")
            }
        case 20001:
            data = UserDefaults.AppConfig.json(forKey: .gradeList).arrayValue[index]
            text = data["grade"].stringValue
            submitData["grade"] = text
            if row == 0{
                submitData.removeValue(forKey: "grade")
            }
        case 30001:
            data = UserDefaults.AppConfig.json(forKey: .gradeYearList).arrayValue[index]
            text = data["gradeyear"].stringValue
            submitData["gradeyear"] = data["gradeyear"].stringValue
            if row == 0{
                submitData.removeValue(forKey: "gradeyear")
            }
        case 40001:
            data = UserDefaults.AppConfig.json(forKey: .personGroupList).arrayValue[index]
            text = data["groupname"].stringValue
            submitData["persongroupid"] = data["groupid"].stringValue
            if row == 0{
                submitData.removeValue(forKey: "persongroupid")
            }
        case 50001:
            data = UserDefaults.AppConfig.json(forKey: .studentTypeList).arrayValue[index]
            text = data["studenttypename"].stringValue
            submitData["studenttype"] = data["studenttype"].stringValue
            if row == 0{
                submitData.removeValue(forKey: "studenttype")
            }
        case 60001:
            data = UserDefaults.AppConfig.json(forKey: .professionalList).arrayValue[index]
            text = data["professionaltitle"].stringValue
            submitData["professionaltitle"] = "'\(text)'"
            if row == 0{
                submitData.removeValue(forKey: "professionaltitle")
            }
        case 70001:
            data = UserDefaults.AppConfig.json(forKey: .highestdegreeList).arrayValue[index]
            text = data["highestdegree"].stringValue
            submitData["highestdegree"] = "'\(text)'"
            if row == 0{
                submitData.removeValue(forKey: "highestdegree")
            }
        default:
            break
        }
        
        if row == 0{
            text = "全部"
        }
        selectedTextField.text = text
        
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //切换数据源
        selectedTextField = textField
        
        switch textField.tag {
        case 10001:
            var array = UserDefaults.AppConfig.json(forKey: .majorList).arrayValue
            array.insert(JSON(["majorname":"全部"]), at: 0)
            dataPickerImpl.dataSource = array
            dataPickerImpl.titleKey = "majorname"
        case 20001:
            var array = UserDefaults.AppConfig.json(forKey: .gradeList).arrayValue
            array.insert(JSON(["grade":"全部"]), at: 0)
            dataPickerImpl.dataSource = array
            dataPickerImpl.titleKey = "grade"
        case 30001:
            var array = UserDefaults.AppConfig.json(forKey: .gradeYearList).arrayValue
            array.insert(JSON(["gradeyear":"全部"]), at: 0)
            dataPickerImpl.dataSource = array
            dataPickerImpl.titleKey = "gradeyear"
        case 40001:
            var array = UserDefaults.AppConfig.json(forKey: .personGroupList).arrayValue
            array.insert(JSON(["groupname":"全部"]), at: 0)
            dataPickerImpl.dataSource = array
            dataPickerImpl.titleKey = "groupname"
        case 50001:
            var array = UserDefaults.AppConfig.json(forKey: .studentTypeList).arrayValue
            array.insert(JSON(["studenttypename":"全部"]), at: 0)
            dataPickerImpl.dataSource = array
            dataPickerImpl.titleKey = "studenttypename"
        case 60001:
            var array = UserDefaults.AppConfig.json(forKey: .professionalList).arrayValue
            array.insert(JSON(["professionaltitle":"全部"]), at: 0)
            dataPickerImpl.dataSource = array
            dataPickerImpl.titleKey = "professionaltitle"
        case 70001:
            var array = UserDefaults.AppConfig.json(forKey: .highestdegreeList).arrayValue
            array.insert(JSON(["highestdegree":"全部"]), at: 0)
            dataPickerImpl.dataSource = array
            dataPickerImpl.titleKey = "highestdegree"
        default:
            break
        }
        dataPicker.selectRow(0, inComponent: 0, animated: true)
        dataPicker.reloadAllComponents()
//        dataPicker.reloadInputViews()
        return true
        
    }
    
    
}
