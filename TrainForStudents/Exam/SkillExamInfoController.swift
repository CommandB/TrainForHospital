//
//  ExamInfoController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/12.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

///老师进来技能考试的前置页
class SkillExamInfoController : HBaseViewController{
    
    
    @IBOutlet weak var btn_exam: UIButton!
    
    var paramData = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_exam.isEnabled = false
        getData()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_exam_inside(_ sender: UIButton) {
        let vc = getViewToStoryboard("stillExamView") as! StillExamController
        //vc.exercisesId = self.exercisesId
        vc.headInfo = self.paramData.dictionaryValue
        self.present(vc, animated: true, completion: nil)
    }
    
    func getData(){
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "rest/app/getJNExamInfo.do"
        var param = ["taskid":paramData["taskid"], "bepersonid": paramData["bepersonid"]]
        if paramData["bepersonid"].isEmpty{
            param.removeValue(forKey: "bepersonid")
        }
        myPostRequest(url, param , method: .post).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            //启用 开始考试 按钮
            self.btn_exam.isEnabled = true
            
            switch resp.result{
            case .success(let respJson):
                let json = JSON(respJson)
                if json["code"].intValue == 1{
                    let data = json["data"]
                    (self.view.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
                    (self.view.viewWithTag(20001) as! UILabel).text = data["examtypename"].stringValue
                    (self.view.viewWithTag(30001) as! UILabel).text = data["bepersonname"].stringValue
//                    (self.view.viewWithTag(40001) as! UILabel).text = data["exercisesid"].stringValue
                    (self.view.viewWithTag(50001) as! UILabel).text = data["passscore"].stringValue
                    (self.view.viewWithTag(60001) as! UILabel).text = data["longtime"].stringValue
                    (self.view.viewWithTag(70001) as! UILabel).text = data["starttime"].stringValue
                    self.paramData["exercisesid"] = data["exercisesid"]
                }
                
                /*
                 时长
                 地点
                 开始时间
                 类型
                 被考人/监考人
                 
                 
                 */
            case .failure(let err):
                print(err)
                break
            }
            
        })
        
        
    }
    
}
