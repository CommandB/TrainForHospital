//
//  ExamInfoForStuController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/13.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ExamInfoForStuController : HBaseViewController{
    
    @IBOutlet weak var btn_exam: UIButton!
    
    var paramData = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        btn_exam.isHidden = true
        (self.view.viewWithTag(10001) as! UILabel).text = paramData["title"].stringValue
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_exam_inside(_ sender: UIButton) {
        
        MBProgressHUD.showAdded(to: view, animated: true)
        let vc = getViewToStoryboard("examView") as! ExamViewController
        vc.exerciseId = paramData["exercisesid"].stringValue
        vc.taskId = paramData["taskid"].stringValue
        vc.isSimulation = true
        let url = SERVER_PORT + "rest/questions/queryExercisesQuestions.do"
        myPostRequest(url,["exercisesid":vc.exerciseId]).responseJSON(completionHandler: { resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            switch  resp.result{
            case .success(let result):
                let json = JSON(result)
                if json["code"].intValue == 1 {
                    vc.exercises = json["data"].arrayValue
                    vc.fromView = self
                    self.present(vc, animated: true, completion: nil)
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func getData(){
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "rest/app/getExamInfoByStudent.do"
        myPostRequest(url,["examroomid": paramData["buid"]], method: .post).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            //启用 开始考试 按钮
            self.btn_exam.isEnabled = true
            
            switch resp.result{
            case .success(let respJson):
                let json = JSON(respJson)
                if json["code"].intValue == 1{
                    let data = json["data"]
//                    print("json:\(json)")
                    (self.view.viewWithTag(20001) as! UILabel).text = data["examtype"].stringValue
//                    (self.view.viewWithTag(30001) as! UILabel).text = data["bepersonname"].stringValue
                    //                    (self.view.viewWithTag(40001) as! UILabel).text = data["exercisesid"].stringValue
                    (self.view.viewWithTag(50001) as! UILabel).text = data["addressname"].stringValue
                    (self.view.viewWithTag(60001) as! UILabel).text = data["longtime"].stringValue
                    (self.view.viewWithTag(70001) as! UILabel).text = data["starttime"].stringValue
                    if data["appexamination"].intValue == 1{
                        self.btn_exam.isHidden = false
                    }
                    self.paramData["exercisesid"] = data["exercisesid"]
                }
                
            case .failure(let err):
                print(err)
                break
            }
            
        })
        
        
    }
    
}
