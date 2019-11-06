//
//  ChangePersonInfoController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/8/23.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChangePersonInfoController: MyBaseUIViewController {
    
    var sex = 0
    var selectedSexBtn = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sexStr = UserDefaults.User.string(forKey: .sex) ?? "0"
        if sexStr.isEmpty{
            sex = 0
        }else{
            sex = Int(sexStr)!
        }
        
        
        let tag = 20001 + sex
        (view.viewWithTag(tag) as! UIButton).setTitle("🔘\(sex == 1 ? "男" : "女")", for: .normal)
        var textField = self.view.viewWithTag(30001) as! UITextField
        textField.clearButtonMode = .always
        textField.keyboardType = .numberPad
        textField.text = UserDefaults.User.string(forKey: .phoneNo)
        
        textField = self.view.viewWithTag(40001) as! UITextField
        textField.isHidden = true
        textField.clearButtonMode = .always
        textField.text = UserDefaults.User.string(forKey: .highestDegree)
        
    }
    
    
    @IBAction func btn_sex(_ sender: UIButton) {
        
        (view.viewWithTag(20001) as! UIButton).setTitle("⚪️女", for: .normal)
        (view.viewWithTag(20002) as! UIButton).setTitle("⚪️男", for: .normal)
        
        if sender.tag == 20002{
            sex = 1
            (view.viewWithTag(20002) as! UIButton).setTitle("🔘男", for: .normal)
        }else{
            sex = 0
            (view.viewWithTag(20001) as! UIButton).setTitle("🔘女", for: .normal)
        }
        
    }
    
    //返回
    @IBAction func btn_back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //提交
    @IBAction func btn_submit(_ sender: UIButton) {
        
        let url = SERVER_PORT + "rest/person/UpdatePerson.do"
        
        let phoneno = self.view.viewWithTag(30001) as! UITextField
        if phoneno.text == ""{
            myAlert(self, message: "请输入电话!")
            return
        }
        
//        let highestdegree = self.view.viewWithTag(40001) as! UITextField
//        if highestdegree.text == ""{
//            myAlert(self, message: "请输入学历!")
//            return
//        }
        
        myPostRequest(url,["sex":sex, "personid":UserDefaults.User.string(forKey: .personId),"personname":UserDefaults.User.string(forKey: .personName),"phoneno":phoneno.text]).responseJSON(completionHandler: { resp in
            
            switch  resp.result{
            case .success(let result):
                
                let resultJson = JSON(result)
                switch  resultJson["code"].stringValue{
                case "1":
                    myAlert(self, message: "修改成功!", handler: {action in
                        //更新缓存
//                        UserDefaults.User.set(value: highestdegree.text, forKey: .highestDegree)
                        UserDefaults.User.set(value: phoneno.text, forKey: .phoneNo)
                        UserDefaults.User.set(value: self.sex, forKey: .sex)
                        self.dismiss(animated: true, completion: nil)
                    })
                default:
                    myAlert(self, message: resultJson["msg"].stringValue)
                }
                
            case .failure(let err):
                
                myAlert(self, message: "服务器异常!")
                print(err)
            }
            
        })
        
    }
    
}
