//
//  HistoryTheoryExamController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/27.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class HistoryTheoryExamController : HBaseViewController{
    
    @IBOutlet weak var questionCollection: UICollectionView!
    
    @IBOutlet weak var btn_prev: UIButton!
    
    @IBOutlet weak var btn_next: UIButton!
    
    
    ///试卷的JSON
    var paperJson = [JSON]()
    ///当前显示的试题JSON
    var jds = JSON()
    //
    var paramData = JSON()
    
    ///当前显示的试题在这个题型里的索引
    var questionIndex = 0
    ///当前显示的题型在paperJson里的索引
    var questionTypeIndex = 0
    ///当前显示题型的类型编号
    var currentQuetionType = -1
    
    override func viewDidLoad() {
        
        questionCollection.delegate = self
        questionCollection.dataSource = self
        getListData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.questionCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_prev_inside(_ sender: UIButton) {
        
//        btn_next.isHidden = false
        questionIndex -= 1
        
//        if questionIndex == 0 {
//            btn_prev.isHidden = true
//        }
        
        switchQuestionType()
        //切换显示题目collection的数据源
        jds = paperJson[questionTypeIndex]["questions"].arrayValue[questionIndex]
        questionCollection.reloadData()
    }
    
    @IBAction func btn_next_inside(_ sender: UIButton) {
        
//        btn_prev.isHidden = false
        questionIndex += 1
        
//        if questionIndex == jds.count - 1 {
//            btn_next.isHidden = true
//        }
        
        switchQuestionType()
        //切换显示题目collection的数据源
        jds = paperJson[questionTypeIndex]["questions"].arrayValue[questionIndex]
        questionCollection.reloadData()
    }
    
    ///是否需要切换题型
    func switchQuestionType(){
        //当前题型question总数
        let questionTotal = paperJson[questionTypeIndex]["questions"].arrayValue.count
        if questionIndex >= questionTotal{
            
            //判断是否是最后一个题型
            if questionTypeIndex < paperJson.count - 1{
                //切换到下一个题型的索引
                questionTypeIndex += 1
                questionIndex = 0
            }else{
                questionIndex = questionTotal - 1
                MBProgressHUD.showError("已经是最后一题啦!")
                return
            }
        }else if questionIndex < 0{
            
            
            if questionTypeIndex > 0 {
                //切换到上一个题型的索引
                questionTypeIndex -= 1
                questionIndex = paperJson[questionTypeIndex]["questions"].arrayValue.count - 1
            }else{
                questionIndex = 0
                MBProgressHUD.showError("已经是第一题啦!")
                return
            }
        }else{
            return
        }
        
        //变更当前显示的题型编号
        currentQuetionType = paperJson[questionTypeIndex]["type"].intValue
        
        //更新题型简介
        let _j = paperJson[questionTypeIndex]
        (view.viewWithTag(10001) as! UILabel).text = "    \(_j["indexname"].stringValue)【\(_j["typename"].stringValue)】 共\(_j["count"].stringValue)道 每道\(_j["score"].stringValue)分 共\(_j["count"].intValue * _j["score"].intValue )分"
        
    }

    func getListData(){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let url = SERVER_PORT+"rest/app/getMyTheoryExamInfo.do"
        
        myPostRequest(url,["exercisesid": paramData["exercisesid"].stringValue, "examroomid": paramData["examroomid"].stringValue ]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                print(json)
                if json["code"].stringValue == "1"{
                    
                    self.paperJson = json["data"].arrayValue
                    self.jds = self.paperJson[self.questionTypeIndex]["questions"].arrayValue[self.questionIndex]
                    //更新题型简介
                    let _j = self.paperJson[self.questionTypeIndex]
                    (self.view.viewWithTag(10001) as! UILabel).text = "    \(_j["indexname"].stringValue)【\(_j["typename"].stringValue)】 共\(_j["count"].stringValue)道 每道\(_j["score"].stringValue)分 共\(_j["count"].intValue * _j["score"].intValue )分"
                }else{
                    myAlert(self, message: "请求考试列表失败!")
                }
                self.questionCollection.reloadData()
            case .failure(let error):
                print(error)
            }
            
        })
    }
}

extension HistoryTheoryExamController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if jds.isEmpty{
            return 0
        }
        
        switch jds["type"].intValue {
        case 0,2:
            //单选题,多选题
            return jds["answers"].arrayValue.count + 1
        case 3:
            //配伍题
            return jds["sub_questions"].arrayValue.count + jds["up_answers"].arrayValue.count
        case 4,6,8,9:
            return 3
        default:
            print(jds)
            return 0
        }
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    
        switch jds["type"].intValue {
        case 0,2:
            //单选题,多选题
            return type02(collectionView, cellForItemAt: indexPath, data: jds)
        case 3:
            //配伍题
            return type3(collectionView, cellForItemAt: indexPath, data: jds)
        case 4,6,8,9:
            return type4689(collectionView, cellForItemAt: indexPath, data: jds)
        default:
            //print(jds)
            return collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        }
        
        
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let lineHeight = 17
        var text = ""
        var lbl = UILabel()
        var extendHight = 10
        switch jds["type"].intValue {
        case 0,2:
            //单选题,多选题
            if indexPath.item == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
                text = "\(jds["indexname"])\(jds["title"])\(jds["studentanswervalue"])"
                lbl = cell.viewWithTag(10001) as! UILabel
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
                lbl = cell.viewWithTag(10002) as! UILabel
                text = jds["answers"].arrayValue[indexPath.item - 1]["answervalue"].stringValue
            }
            
        case 3:
            //配伍题
            if indexPath.item < jds["sub_questions"].arrayValue.count{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
                let data = jds["sub_questions"].arrayValue[indexPath.item]
                text = "\(data["indexname"])\(data["title"])"
                lbl = cell.viewWithTag(10001) as! UILabel
            }else{
                let index = indexPath.item - jds["sub_questions"].arrayValue.count
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
                lbl = cell.viewWithTag(10002) as! UILabel
                text = jds["up_answers"].arrayValue[index]["answervalue"].stringValue
            }
            break
        case 4,6,8,9:
            //简答题.名词解释.论述题.病例解释
            switch indexPath.item{
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c3", for: indexPath)
                lbl = cell.viewWithTag(10002) as! UILabel
                text = jds["answervalue"].stringValue
                print(text)
                extendHight += Int(cell.viewWithTag(10001)!.H) + 5
                break
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c3", for: indexPath)
                lbl = cell.viewWithTag(10002) as! UILabel
                text = jds["studentanswervalue"].stringValue
                extendHight += Int(cell.viewWithTag(10001)!.H) + 5
                
                break
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
                lbl = cell.viewWithTag(10001) as! UILabel
                text = "\(jds["indexname"])\(jds["title"])"
                break
            }
        default:
            break
        }
        let lineNumber = text.getLineNumberForUILabel(lbl)
        return CGSize(width: collectionView.W, height: CGFloat(lineNumber * lineHeight + extendHight))
    }
    
    
    ///单选题,多选题
    func type02(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath ,data: JSON) -> UICollectionViewCell{
        if indexPath.item == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            let stuAnswer = jds["studentanswervalue"].stringValue
            var title = jds["title"].stringValue
            let answerIndex = title.index(title.endIndex, offsetBy: -2)
            title.insert(contentsOf: stuAnswer, at: answerIndex)
            (cell.viewWithTag(10001) as! UILabel).text = "\(jds["indexname"])\(title)"
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            let data = jds["answers"].arrayValue[indexPath.item - 1]
            (cell.viewWithTag(10001) as! UILabel).text = data["indexname"].stringValue
            (cell.viewWithTag(10002) as! UILabel).text = data["answervalue"].stringValue
            
            cell.viewWithTag(10000)?.isHidden = data["isanswer"].intValue == 0 ? true : false
            
            return cell
        }
    }
    
    ///配伍题
    func type3(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath ,data: JSON) -> UICollectionViewCell{
        if indexPath.item < jds["sub_questions"].arrayValue.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            let data = jds["sub_questions"].arrayValue[indexPath.item]
            (cell.viewWithTag(10001) as! UILabel).text = "\(data["indexname"])\(data["title"])"
            return cell
        }else{
            let index = indexPath.item - jds["sub_questions"].arrayValue.count
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            (cell.viewWithTag(10001) as! UILabel).text = jds["up_answers"].arrayValue[index]["indexname"].stringValue
            (cell.viewWithTag(10002) as! UILabel).text = jds["up_answers"].arrayValue[index]["answervalue"].stringValue
            return cell
        }
    }
    
    ///简答题.名词解释.论述题.病例解释
    func type4689(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath ,data: JSON) -> UICollectionViewCell{
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        switch indexPath.item {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            (cell.viewWithTag(10001) as! UILabel).text = "\(data["indexname"])\(data["title"])"
            break
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c3", for: indexPath)
            (cell.viewWithTag(10001) as! UILabel).text = "参考答案:"
            (cell.viewWithTag(10001) as! UILabel).textColor = .green
            (cell.viewWithTag(10002) as! UILabel).text = data["answervalue"].stringValue
//            (cell.viewWithTag(10001) as! UILabel).backgroundColor = .red
//            (cell.viewWithTag(10001) as! UILabel).backgroundColor = .blue
//            cell.backgroundColor = .green
            break
        case 2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c3", for: indexPath)
            (cell.viewWithTag(10001) as! UILabel).text = "你的答案:"
            (cell.viewWithTag(10001) as! UILabel).textColor = .blue
            (cell.viewWithTag(10002) as! UILabel).text = data["studentanswervalue"].stringValue
            break
        default:
            break
        }
        return cell
    }
    
}
