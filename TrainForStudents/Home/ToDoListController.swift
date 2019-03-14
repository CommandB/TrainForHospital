//
//  ToDoListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/19.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ToDoListController : HBaseViewController{
    
    @IBOutlet weak var toDoCollection: UICollectionView!
    
    var jds = [JSON]()
    var dataMap = [String:[JSON]]()
    var dataArr = [JSON]()
    
    override func viewDidLoad() {
        
        self.sortData()
        
        toDoCollection.delegate = self
        toDoCollection.dataSource = self
        
        self.toDoCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.toDoCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.toDoCollection.mj_header.beginRefreshing()
//        refresh()
        self.toDoCollection.mj_footer.endRefreshingWithNoMoreData()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT + "rest/app/getMyTask.do"
        myPostRequest(url,  method: .post).responseString(completionHandler: {resp in
            
            self.toDoCollection.mj_header.endRefreshing()
            self.toDoCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                //                print(json)
                if json["code"].stringValue == "1"{
                    self.dataArr = json["data"].arrayValue
                    self.sortData()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
            case .failure(let error):
                myAlert(self, message: "获取待办任务异常!")
                print(error)
            }
            self.toDoCollection.reloadData()
        })
        
    }
    
    func sortData(){
        
        dataMap = [String:[JSON]]()
        
        //先将数据 按月份分组
        for item in dataArr{
            let startDate = DateUtil.stringToDateTime(item["starttime"].stringValue.replacingOccurrences(of: ".0", with: ""))
            //key要加上年份 不然跨年时候 当年1月会排在上一年的12月前面
            let month = "\(startDate.year)-\(startDate.month)"
            var monthPlans = self.dataMap[month]
            if monthPlans == nil{
                monthPlans = [JSON]()
            }
            monthPlans?.append(item)
            self.dataMap[month] = monthPlans
        }
        
        //然后按月份排序分组
        let softedKeys = self.dataMap.keys.sorted().reversed()
        for monthKey in softedKeys{
            //因为key是 年月的结构 要截断前面的年
            let monthCellData = JSON(["text":monthKey ,"isHeader":true])
            self.jds.append(monthCellData)
            self.jds += self.dataMap[monthKey]!
        }
    }
    
    func refresh() {
        jds = [JSON]()
        getListData()
    }
    
}

extension ToDoListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if jds.count == 0{
            return collectionView.dequeueReusableCell(withReuseIdentifier: "bodyCell", for: indexPath)
        }
        
        var cell = UICollectionViewCell()
        let data = jds[indexPath.item]
        if let _ = data["isHeader"].bool{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            (cell.viewWithTag(10002) as! UILabel).text = data["text"].stringValue + "月"
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bodyCell", for: indexPath)
            let date = DateUtil.stringToDateTime(data["starttime"].stringValue.replacingOccurrences(of: ".0", with: ""))
            
            //判断一下 如果当前日期和上一个日期一样 则这一个cell不显示日期
            let previousItem = jds[indexPath.item - 1]
            var previousItemDateStr = previousItem["starttime_show"].stringValue
            if previousItemDateStr == ""{
                previousItemDateStr = data["starttime"].stringValue.replacingOccurrences(of: ".0", with: "")
            }
            if previousItem["isHeader"].boolValue || date.day != DateUtil.stringToDateTime(previousItemDateStr).day{
                (cell.viewWithTag(10001) as! UILabel).text = date.day.description
                (cell.viewWithTag(10002) as! UILabel).text = DateUtil.getWeek(date)
                //            if date.isToday{
                //                (cell.viewWithTag(10003) as! UILabel).text = "今天"
                //            }else{
                //                (cell.viewWithTag(10003) as! UILabel).text = ""
                //            }
            }else{
                (cell.viewWithTag(10001) as! UILabel).text = ""
                (cell.viewWithTag(10002) as! UILabel).text = ""
            }
            
            (cell.viewWithTag(20001) as! UILabel).text = data["tasktype"].stringValue
            
            if data["endtime"].stringValue.count > 0{
                (cell.viewWithTag(30001) as! UILabel).text = data["starttime"].stringValue.substring(from: 11).substring(to: 5) + " - " + data["endtime"].stringValue.substring(from: 11).substring(to: 5)
            }else{
                (cell.viewWithTag(30001) as! UILabel).text = data["starttime"].stringValue
            }
            
            (cell.viewWithTag(40001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(50002) as! UILabel).text = data["addressname"].stringValue
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
        if jds.count == 0 {
            return 
        }
        let data = jds[indexPath.item]
        let type = data["butype"].stringValue
        if type == "评价"{
            presentEvaluationDetail(data["buid"].stringValue)
        }else if type == "教学活动"{
            presentTeachingPlanDetail(data)
        }else if type == "教材阅读"{
            presentStudyView(data)
        }else if type == "技能考试评分"{
            presentSkillExam(data)
        }else if type == "OSCE考试评分通知" || type == "理论考试监考" {
            presentInvigilation(data)
        }else if type == "理论考试" || type == "技能考试" || type == "OSCE考试通知" {
            presentStuExam(data)
        }
        
        
        //考试
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        if data["isHeader"].boolValue{
            return CGSize(width: UIScreen.width, height: 50)
        }else{
            return CGSize(width: UIScreen.width, height: 110)
        }
        //return CGSize(width: UIScreen.width.subtracting(20), height: 0)
    }
    
    ///跳转到待评任务
    func presentEvaluationDetail(_ evaluateid: String){
        
        let url = SERVER_PORT+"rest/taskEvaluation/query.do"
        myPostRequest(url,["evaluateid":evaluateid, "pageindex": 0 , "pagesize":10]).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    print(json)
                    let vc = getViewToStoryboard("evaluationDetailView") as! EvaluationDetailController
                    vc.isReadonly = false
                    vc.headData = json["data"].arrayValue[0]
                    self.present(vc, animated: true, completion: nil)
                }else{
                    myAlert(self, message: "获取评价信息失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    ///教学计划
    func presentTeachingPlanDetail(_ data: JSON){
        
        var param = data
        param["taskid"] = data["buid"]
        let vc = getViewToStoryboard("teachingPlanDetailView") as! TeachingPlanDetailController
        vc.taskInfo = param
        present(vc, animated: true, completion: nil)
    }
    
    ///教材阅读
    func presentStudyView(_ data: JSON){
        
        let vc = getViewToStoryboard("studyView") as! StudyController
        vc.taskId = data["buid"].stringValue
        present(vc, animated: true, completion: nil)
    }
    ///技能考试
    func presentSkillExam(_ data: JSON){
        let vc = getViewToStoryboard("skillExamInfoView") as! SkillExamInfoController
        vc.paramData = data
        present(vc, animated: true, completion: nil)
    }
    
    ///理论考试监考，OSCE考试评分通知
    func presentInvigilation(_ data: JSON){
        let vc = getViewToStoryboard("invigilationInfoView") as! InvigilationInfoController
        vc.paramData = data
        present(vc, animated: true, completion: nil)
    }
    ///
    func presentStuExam(_ data: JSON){
        let vc = getViewToStoryboard("examInfoForStuView") as! ExamInfoForStuController
        vc.paramData = data
        present(vc, animated: true, completion: nil)
    }
    
    
}
