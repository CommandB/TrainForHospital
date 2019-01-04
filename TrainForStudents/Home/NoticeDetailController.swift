//
//  NoticeDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/3.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class NoticeDetailController : HBaseViewController{
    
    @IBOutlet weak var replyCollection: UICollectionView!
    
    var noticeJson = JSON()
    var jds = [JSON]()
    
    var size12LineHeight = CGFloat(16)
    
    override func viewDidLoad() {
        
        replyCollection.delegate = self
        replyCollection.dataSource = self
        
        var lbl = view.viewWithTag(22222) as? UILabel
        lbl?.setBorderBottom(size: 1, color: .red)
        
        lbl = view.viewWithTag(20001) as? UILabel
        let content = noticeJson["msg"].stringValue
        
        //计算展示大纲label的行数与高度
        lbl?.text = content
        let lineNum = content.getLineNumberForUILabel(lbl!)
        lbl?.numberOfLines = lineNum
        lbl?.frame.size = CGSize(width: (lbl?.frame.width)!, height: size12LineHeight.multiplied(by: CGFloat(lineNum)))
        
        replyCollection.setY(y: (lbl?.bottom.adding(20))!)
        replyCollection.setHight(height: UIScreen.height.subtracting(replyCollection.Y).subtracting(40))
        
        self.replyCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.replyCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.replyCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_history_inside(_ sender: UIButton) {
        let vc = getViewToStoryboard("noticeListView") as! NoticeListController
        vc.teamId = noticeJson["teamid"].intValue
        present(vc, animated: true, completion: nil)
    }
    
    func getListData(){
        self.replyCollection.mj_header.endRefreshing()
        self.replyCollection.mj_footer.endRefreshing()
        replyCollection.reloadData()
    }
    
    func refresh() {
        jds.removeAll()
        replyCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension NoticeDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 55)
    }
    
}
