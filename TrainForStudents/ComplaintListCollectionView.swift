//
//  ComplaintListCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/9/27.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class ComplaintListCollectionView : MyBaseCollectionView{
    
    var parentView : ComplaintListController? = nil
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if showNoDataCell{
            return collectionView.dequeueReusableCell(withReuseIdentifier: MyNoDataCellView.identifier, for: indexPath)
        }
        
        let json = jsonDataSource[indexPath.item]
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        var lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = json["making"].stringValue
        lbl = cell.viewWithTag(20001) as! UILabel
        lbl.text = json["makingtime"].stringValue.substring(to: 16)
        
        return cell
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = getViewToStoryboard("complaintReplyView") as! ComplaintReplyController
        vc.data = jsonDataSource[indexPath.item]
        parentView?.present(vc, animated: true, completion: nil)
        
    }
    
    //计算大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: UIScreen.width , height: 75)
    }
    
    
}
