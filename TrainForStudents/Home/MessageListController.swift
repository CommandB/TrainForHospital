//
//  MessageListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/8.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MessageListController : HBaseViewController{
    
    @IBOutlet weak var messageCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        messageCollection.delegate = self
        messageCollection.dataSource = self
        
        self.messageCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.messageCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.messageCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        self.messageCollection.mj_header.endRefreshing()
        self.messageCollection.mj_footer.endRefreshing()
        messageCollection.reloadData()
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

extension MessageListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
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
