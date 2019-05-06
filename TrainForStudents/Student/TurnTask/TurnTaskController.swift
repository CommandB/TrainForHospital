//
//  TurnTaskController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/2.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class TurnTaskController : HBaseViewController{
    
    @IBOutlet weak var turnTaskCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        turnTaskCollection.delegate = self
        turnTaskCollection.dataSource = self
        
        self.turnTaskCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.turnTaskCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.turnTaskCollection.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func btn_his_inside(_ sender: UIButton) {
        myPresentView(self, viewName: "historyTurnTaskView")
    }
    
    func getListData(){
        
        let url = SERVER_PORT + "rest/app/getMyRoundPlan.do"
        myPostRequest(url,  method: .post).responseString(completionHandler: {resp in
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                    if self.jds.count == 0 {
                        self.turnTaskCollection.mj_header.endRefreshing()
                        self.turnTaskCollection.mj_footer.endRefreshingWithNoMoreData()
                        return
                    }
                    let url2 = SERVER_PORT + "rest/app/getMyRoundHistory.do"
                    myPostRequest(url2,  method: .post).responseString(completionHandler: {resp in
                        
                        self.turnTaskCollection.mj_header.endRefreshing()
                        self.turnTaskCollection.mj_footer.endRefreshingWithNoMoreData()
                        
                        switch resp.result{
                        case .success(let respStr):
                            let json = JSON(parseJSON: respStr)
                            
                            if json["code"].stringValue == "1"{
                                self.jds[0]["historyTurnTotal"] = JSON(json["data"].arrayValue.count)
                            }else{
                                myAlert(self, message: json["msg"].stringValue)
                                print(json)
                            }
                            break
                        case .failure(let error):
                            myAlert(self, message: "获取轮转数据异常!")
                            print(error)
                            break
                        }
                        self.turnTaskCollection.reloadData()
                    })
                    
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取轮转数据异常!")
                print(error)
                break
            }
            //self.turnTaskCollection.reloadData()
        })
        
    }
    
    @objc func refresh() {
        jds.removeAll()
        turnTaskCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        
    }
    
}

extension TurnTaskController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        if indexPath.item == 0{
            let bg = cell.viewWithTag(22222)!
            bg.setCornerRadius(radius: 2)
            
            (cell.viewWithTag(10001) as! UILabel).text = "已轮转\(data["historyTurnTotal"].intValue)个科室"
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            let bg = cell.viewWithTag(22222)!
            bg.setCornerRadius(radius: 2)
            bg.setBorder(width: 1, color: .gray)
        }
        (cell.viewWithTag(20001) as! UILabel).text = "\(data["month"])月"
        (cell.viewWithTag(20002) as! UILabel).text = "\(data["endtime"])~\(data["starttime"])"
        (cell.viewWithTag(30001) as! UILabel).text = data["officename"].stringValue
        (cell.viewWithTag(40001) as! UILabel).text = data["contacts"].stringValue == "" ? "暂无" : data["contacts"].stringValue
        (cell.viewWithTag(40002) as! UILabel).text = data["contactsphoneno"].stringValue == "" ? "暂无" : data["contactsphoneno"].stringValue
        
        cell.setCornerRadius(radius: 4)
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0{
            return CGSize(width: collectionView.W - 15, height: 130)
        }
        
        return CGSize(width: collectionView.W - 15, height: 111)
    }
    
}