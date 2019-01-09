//
//  NoticeLIstController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/4.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class NoticeListController : HBaseViewController{
    
    @IBOutlet weak var messageCollection: UICollectionView!
    
    let size12LineHeight = CGFloat(16)
    var teamId = 0
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        messageCollection.delegate = self
        messageCollection.dataSource = self
        
        self.messageCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.messageCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        messageCollection.mj_header.beginRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.messageCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT + "rest/app/queryTeamNotice.do"
        myPostRequest(url,["teamid":teamId ,"pageindex":jds.count,"pagesize":pageSize] ,method: .post).responseString(completionHandler: {resp in
            
            self.messageCollection.mj_header.endRefreshing()
            self.messageCollection.mj_footer.endRefreshing()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    let dataArr = json["data"].arrayValue
                    self.jds += dataArr
                    
                    if dataArr.count < self.pageSize{
                        self.messageCollection.mj_footer.endRefreshingWithNoMoreData()
                    }
                    
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取公告列表异常!")
                print(error)
                break
            }
            self.messageCollection.reloadData()
        })
        
    }
    
    func refresh() {
        jds.removeAll()
        messageCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension NoticeListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noticeCell", for: indexPath)
        cell.setCornerRadius(radius: 4)
        var lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["createtime"].stringValue
        
        lbl = cell.viewWithTag(20001) as! UILabel
        let content = data["noticemsg"].stringValue
        
        //计算展示大纲label的行数与高度
        lbl.text = content
        let lineNum = content.getLineNumberForUILabel(lbl)
        lbl.numberOfLines = lineNum
        lbl.frame.size = CGSize(width: lbl.frame.width, height: size12LineHeight.multiplied(by: CGFloat(lineNum)))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noticeCell", for: indexPath)
        
        let content = data["noticemsg"].stringValue
        let lbl = cell.viewWithTag(20001) as! UILabel
        let lineNumber = content.getLineNumberForUILabel(lbl)
        
        let cellHeight = size12LineHeight.multiplied(by: CGFloat(lineNumber)).adding(50)
        print("cellHeight:\(cellHeight)")
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width - 15, height: cellHeight)
    }
    
}
