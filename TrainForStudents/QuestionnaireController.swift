//
//  QuestionnaireController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/10.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class QuestionnaireController: MyBaseUIViewController{
    
    var sheetId = ""
    var dataSource = JSON()
    var dataIndex = 0
    var maxIndex = 0
    var resultDic = [String:Any]()
    
    @IBOutlet weak var btn_prev: UIButton!
    
    @IBOutlet weak var btn_next: UIButton!
    
    //collection
    @IBOutlet weak var questionnaireCollection: UICollectionView!
    
    var detailView = QuestionDetailCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionlayout = UICollectionViewFlowLayout()
        questionlayout.minimumLineSpacing = 3
        questionlayout.minimumInteritemSpacing = 0
        questionnaireCollection.collectionViewLayout = questionlayout
        
        detailView.parentView = self
        questionnaireCollection.dataSource = detailView
        questionnaireCollection.delegate = detailView
        
        btn_prev.isEnabled = false
        btn_prev.setTitleColor(UIColor.gray, for: .disabled)
        
        MyNotificationUtil.addKeyBoardWillChangeNotification(self)
        loadData()
    }
    
    //返回按钮
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //上一项
    @IBAction func btn_prev_inside(_ sender: UIButton) {
        dataIndex -= 1
        
        self.detailView.jsonDataSource = self.dataSource["questions"].arrayValue[dataIndex]
        self.questionnaireCollection.reloadData()
        
        if dataIndex < maxIndex{
            btn_next.setTitle("下一项", for: .normal)
        }
        if dataIndex == 0 {
            sender.isEnabled = false
            
        }
    }
    
    //下一项
    @IBAction func btn_next_inside(_ sender: UIButton) {
        
        if dataIndex == maxIndex{   //提交
            myConfirm(self, message: "是否确认提交", okTitle: "提交", cancelTitle: "取消", okHandler: {action in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                let questionnaireId = self.dataSource["questionnaireid"].stringValue
                var param = [String:Any]()
                param["personid"] = UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)
                param["sheetid"] = self.sheetId
                var infoList = [[String:String]]()
                for r in self.resultDic{
                    let k = r.key
                    let v = r.value
                    if v is String{ //简答题
                        var item = [String:String]()
                        item["questionnaireId"] = questionnaireId
                        item["questionId"] = k
                        item["result"] = v as! String
                        infoList.append(item)
                    }else{  //选择题
                        var item = [String:String]()
                        item["questionnaireId"] = questionnaireId
                        item["questionId"] = k
                        for elem in (v as! [String:String]){
                            item["result"] = elem.key
                            infoList.append(item)
                        }
                    }
                }
                param["infolist"] = infoList
                print(JSON.init(param))
                let url = SERVER_PORT+"rest/questionnaire/HandInQuestionnaire.do"
                myPostRequest(url,param).responseJSON(completionHandler: { resp in
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    switch  resp.result{
                    case .success(let result):
                        let json = JSON(result)
                        if json["code"].intValue == 1 {
                            myAlert(self, message: "提交成功!")
                        }else{
                            myAlert(self, title: "提交失败", message: json["msg"].stringValue)
                        }
                        
                    case .failure(let error):
                        myAlert(self, message: "服务异常,提交失败!")
                        debugPrint(error)
                    }
                })
            })
        }else{  //下一项
            //验证
            let data = self.dataSource["questions"].arrayValue[dataIndex]
            if data["itemtype"].intValue == 0 {
                let arr = resultDic[data["questionid"].stringValue] as! [String:Any]
                let minChoice = data["minchoice"].intValue
                let maxChoice = data["maxchoice"].intValue
                if arr.keys.count < minChoice{
                    myAlert(self, message: "请至少选择\(minChoice)项!")
                    return
                }else if arr.keys.count > maxChoice{
                    myAlert(self, message: "最多选择\(maxChoice)项!")
                    return
                }
            }else{
                let text = resultDic[data["questionid"].stringValue] as! String
                if text == "" {
                    //TODO
                }
            }
            
            
            dataIndex += 1
            btn_prev.isEnabled = true
            self.detailView.jsonDataSource = self.dataSource["questions"].arrayValue[dataIndex]
            self.questionnaireCollection.reloadData()
            if dataIndex == maxIndex{
                sender.setTitle("提交", for: .normal)
            }
        }
        
    }
    
    func loadData(){
        
        let url = SERVER_PORT+"rest/questionnaire/getAQuestionnaire.do"
        myPostRequest(url,["sheetid":sheetId]).responseJSON(completionHandler: { resp in
            switch  resp.result{
            case .success(let result):
                let json = JSON(result)
                if json["code"].intValue == 1 {
                    self.dataSource = json["data"]
                    self.detailView.jsonDataSource = self.dataSource["questions"].arrayValue[0]
                    self.maxIndex = self.dataSource["questions"].count - 1
                    
                    //初始化答案map
                    for question in self.dataSource["questions"].arrayValue{
                        let type = question["itemtype"].intValue
                        if type == 0{
                            self.resultDic[question["questionid"].stringValue] = [String:Any]()
                        }else{
                            self.resultDic[question["questionid"].stringValue] = ""
                        }
                        
                    }
                    
                    self.questionnaireCollection.reloadData()
                    
                    
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
}
