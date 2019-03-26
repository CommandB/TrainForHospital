//
//  LeaveOverCollection.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/22.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation

import SwiftyJSON

class LeaveOverCollection : UIViewController ,UICollectionViewDelegate ,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    var parentView : LeaveApprovedController? = nil
    var jds = [JSON]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
//        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        return cell
    }
    
    func getListData(){
        parentView?.overCollection.mj_header.endRefreshing()
        parentView?.overCollection.mj_footer.endRefreshing()
        parentView?.overCollection.reloadData()
    }
    
    @objc func refresh() {
        jds.removeAll()
        parentView?.overCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    @objc  
    func loadMore() {
        getListData()
    }
    
}
