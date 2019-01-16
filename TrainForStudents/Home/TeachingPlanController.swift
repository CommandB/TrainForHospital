//
//  TeachingPlanController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/8.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class TeachingPlanController : HBaseViewController{
    
    @IBOutlet weak var planCollection: UICollectionView!
    
    var jds = [JSON]()
    var dataMap = [String:[JSON]]()
    
    override func viewDidLoad() {
        
        planCollection.delegate = self
        planCollection.dataSource = self
        
        self.planCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.planCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.planCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        var param = ["task_state":"1,2" ,"officeid":UserDefaults.standard.integer(forKey: LoginInfo.officeId.rawValue),"pagesize":pageSize ,"pageindex":jds.count] as [String : Any]
        
        let url = SERVER_PORT + "rest/app/queryOfficeTrain.do"
        myPostRequest(url,param).responseJSON(completionHandler: {resp in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.planCollection.mj_header.endRefreshing()
            self.planCollection.mj_footer.endRefreshing()
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let dataArr = json["data"].arrayValue
                    
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
                    
                    if dataArr.count < self.pageSize{
                        self.planCollection.mj_footer.endRefreshingWithNoMoreData()
                    }
                    
                    self.planCollection.reloadData()
                }else{
                    
                }
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    func refresh() {
        jds.removeAll()
        planCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension TeachingPlanController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        var cell = UICollectionViewCell()
        if let _ = data["isHeader"].bool{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            (cell.viewWithTag(10001) as! UILabel).text = data["text"].stringValue
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bodyCell", for: indexPath)
            let date = DateUtil.stringToDateTime(data["starttime"].stringValue)
            
            (cell.viewWithTag(10001) as! UILabel).text = date.day.description
            (cell.viewWithTag(10002) as! UILabel).text = data["weekday"].stringValue
            if date.isToday{
                (cell.viewWithTag(10003) as! UILabel).text = "今天"
            }else{
                (cell.viewWithTag(10003) as! UILabel).text = ""
            }
            (cell.viewWithTag(20001) as! UILabel).text = data["traintype"].stringValue
            (cell.viewWithTag(30001) as! UILabel).text = data["starttime"].stringValue.substring(from: 11).substring(to: 5) + " - " + data["endtime"].stringValue.substring(from: 11).substring(to: 5)
            (cell.viewWithTag(40001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(50001) as! UILabel).text = data["addressname"].stringValue
            
        }
        
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        if let _ = data["isHeader"].bool{
            return CGSize(width: UIScreen.width, height: 50)
        }
        return CGSize(width: UIScreen.width, height: 110)
        
    }
    
}
