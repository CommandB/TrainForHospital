//
//  CreateNoticeController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/2.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class TeamSettingController : UIViewController{
    
    var office = JSON()
    
    @IBOutlet weak var txt_title: UITextField!
    
    @IBOutlet weak var txtv_content: UITextView!
    
    @IBAction func btn_back_tui(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_submit_tui(_ sender: UIButton) {
        let title = txt_title.text
        let content = txtv_content.text
        if (title?.length)! < 4 || (title?.length)! > 30 {
            myAlert(self, message: "请将标题长度控制在4-30个字符内!")
            return
        }
        if (content?.length)! < 15 || (content?.length)! > 100 {
            myAlert(self, message: "请将公告正文控制在15-100个字符内!")
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "rest/app/addTeamNotice.do"
        myPostRequest(url,["teamid":office["teamid"].stringValue, "title":title, "msg":content]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    myAlert(self, message: "发布成功",handler:{ action in
                        self.dismiss(animated: true, completion: nil)
                    })
                }else{
                    myAlert(self, message: "发布失败")
                    print(json["msg"].stringValue)
                }
            case .failure(let error):
                
                print(error)
            }
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let lbl_title = view.viewWithTag(10001) as! UILabel
        lbl_title.text = office["teamname"].stringValue
        
        txtv_content.borderWidth = 1
        txtv_content.borderColor = UIColor.groupTableViewBackground
        txtv_content.text = ""
        txtv_content.cornerRadius = 4
        
    }
    
}
