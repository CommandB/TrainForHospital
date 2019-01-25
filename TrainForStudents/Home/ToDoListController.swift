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
        
        toDoCollection.delegate = self
        toDoCollection.dataSource = self
        
        //先将数据 按月份分组
        for item in dataArr{
            let startDate = DateUtil.stringToDateTime(item["starttime"].stringValue.replacingOccurrences(of: ".0", with: ""))
            let month = startDate.month.description
            var monthPlans = self.dataMap[month]
            if monthPlans == nil{
                monthPlans = [JSON]()
            }
            monthPlans?.append(item)
            self.dataMap[month] = monthPlans
        }
        
        //然后按月份排序分组
        let softedKeys = self.dataMap.keys.sorted()
        for monthKey in softedKeys{
            let monthCellData = JSON(["text":monthKey ,"isHeader":true])
            self.jds.append(monthCellData)
            self.jds += self.dataMap[monthKey]!
        }
        
        self.toDoCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.toDoCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.toDoCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        self.toDoCollection.mj_header.endRefreshing()
        self.toDoCollection.mj_footer.endRefreshingWithNoMoreData()
        toDoCollection.reloadData()
    }
    
    func refresh() {
        //toDoCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
}

extension ToDoListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        var cell = UICollectionViewCell()
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
            
            (cell.viewWithTag(20001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(30001) as! UILabel).text = data["starttime"].stringValue.substring(from: 11).substring(to: 5) + " - " + data["endtime"].stringValue.substring(from: 11).substring(to: 5)
            (cell.viewWithTag(40001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(50002) as! UILabel).text = data["addressname"].stringValue
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
        let vc = getViewToStoryboard("taskDetail2View") as! TaskDetail2Controller
        vc.headDataJson = jds[indexPath.item]
        present(vc, animated: true, completion: nil)
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
    
}
