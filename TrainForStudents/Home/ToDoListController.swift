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

class ToDoListController : UIViewController{
    
    @IBOutlet weak var toDoCollection: UICollectionView!
    
    var jds = [JSON]()
    var dataMap = [String:[JSON]]()
    
    
    override func viewDidLoad() {
        
        toDoCollection.delegate = self
        toDoCollection.dataSource = self
        
        let dataArr = jds
        
        //先将数据 按月份分组
        for item in dataArr{
            let startDate = DateUtil.stringToDateTime(item["starttime"].stringValue)
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
        self.toDoCollection.mj_footer.endRefreshing()
        toDoCollection.reloadData()
    }
    
    func refresh() {
        toDoCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
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
            (cell.viewWithTag(10001) as! UILabel).text = data["text"].stringValue
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bodyCell", for: indexPath)
            let date = DateUtil.stringToDateTime(data["starttime_show"].stringValue)
            
            (cell.viewWithTag(10001) as! UILabel).text = date.day.description
            (cell.viewWithTag(10002) as! UILabel).text = data["weekday"].stringValue
            if date.isToday{
                (cell.viewWithTag(10003) as! UILabel).text = "今天"
            }else{
                (cell.viewWithTag(10003) as! UILabel).text = ""
            }
            (cell.viewWithTag(20001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(30001) as! UILabel).text = data["starttime_show"].stringValue.substring(from: 11).substring(to: 5) + " - " + data["endtime_show"].stringValue.substring(from: 11).substring(to: 5)
            (cell.viewWithTag(40001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(50001) as! UILabel).text = data["addressname"].stringValue
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        let cellName = data["cellName"].stringValue
        if cellName == "headerCell"{
            return CGSize(width: UIScreen.width, height: 50)
        }else if cellName == "bodyCell"{
            return CGSize(width: UIScreen.width, height: 110)
        }
        return CGSize(width: UIScreen.width.subtracting(20), height: 0)
    }
    
}
