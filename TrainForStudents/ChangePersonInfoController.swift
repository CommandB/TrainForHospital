//
//  ChangePersonInfoController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/8/23.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChangePersonInfoController: MyBaseUIViewController   {
    
    
    //返回
    @IBAction func btn_back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //提交
    @IBAction func btn_submit(_ sender: UIButton) {
        
        let url = SERVER_PORT + "rest/person/UpdatePerson.do"
        
        let personname = self.view.viewWithTag(20001) as! UITextField
        if personname.text == ""{
            myAlert(self, message: "请输入姓名!")
            return
        }
        
        let phoneno = self.view.viewWithTag(30001) as! UITextField
        if phoneno.text == ""{
            myAlert(self, message: "请输入电话!")
            return
        }
        
        let highestdegree = self.view.viewWithTag(40001) as! UITextField
        if highestdegree.text == ""{
            myAlert(self, message: "请输入学历!")
            return
        }
        
        myPostRequest(url,["personid":UserDefaults.User.string(forKey: .personId),"jobnum":UserDefaults.User.string(forKey: .jobNum),"personname":personname.text,"phoneno":phoneno.text,"highestdegree":highestdegree.text]).responseJSON(completionHandler: { resp in
            
            switch  resp.result{
            case .success(let result):
                
                let resultJson = JSON(result)
                switch  resultJson["code"].stringValue{
                case "1":
                    myAlert(self, message: "修改成功!", handler: {action in
                        var root = self.presentingViewController
                        while let parent = root?.presentingViewController{
                            root = parent
                        }
                        root?.dismiss(animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var textField = self.view.viewWithTag(20001) as! UITextField
        textField.clearButtonMode = .always
        textField.text = UserDefaults.User.string(forKey: .personName)
        
        textField = self.view.viewWithTag(30001) as! UITextField
        textField.clearButtonMode = .always
        textField.keyboardType = .numberPad
        textField.text = UserDefaults.User.string(forKey: .phoneNo)
        
        textField = self.view.viewWithTag(40001) as! UITextField
        textField.clearButtonMode = .always
        textField.text = UserDefaults.User.string(forKey: .highestDegree)
        
        
        
    }
    
}
