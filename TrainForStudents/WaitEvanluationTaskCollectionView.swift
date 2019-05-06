//
//  WaitEvanluationTaskCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/26.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class WaitEvanluationTaskCollectionView : UIViewController,  UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    var jsonDataSource = [JSON]()
    var parentView : EvaluationCenterController? = nil
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsonDataSource.count
    }
    
    //实现UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cellName = "c1"
        let json = jsonDataSource[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        var lbl = cell.viewWithTag(10001) as? UILabel
        lbl?.text = json["title"].stringValue
        lbl = cell.viewWithTag(20001) as? UILabel
        lbl?.text = "\(json["evaluatetypename"].stringValue)"
        lbl = cell.viewWithTag(20002) as? UILabel
        lbl?.text = json["personname"].stringValue
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width, height: 80)
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = jsonDataSource[indexPath.item]
        let vc = getViewToStoryboard("evaluationDetailView") as! EvaluationDetailController
        vc.isReadonly = false
        vc.headData = data
        parentView?.present(vc, animated: true, completion: nil)
    }
    
    @objc public func refresh() {
        print("评价刷新")
        jsonDataSource = [JSON]()
        parentView?.evaluationCollection.mj_footer.resetNoMoreData()
        parentView?.getEvaluationDatasource()
        
    }
    
    @objc public func loadMore() {
        parentView?.getEvaluationDatasource()
    }
    
    
}

