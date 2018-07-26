//
//  HistoryExamCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/27.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class HistoryExamCollectionView : MyBaseCollectionView{
    
    var parentVC = UIViewController()
    
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if showNoDataCell{
            return collectionView.dequeueReusableCell(withReuseIdentifier: MyNoDataCellView.identifier, for: indexPath)
        }
        
        let cellName = "c1"
        let json = jsonDataSource[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        var lbl = cell.viewWithTag(10001) as! UILabel
        let title = json["tasktitle"].stringValue
        lbl.text = title
        
        lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width, cFont: (lbl.font)!)
        lbl.frame.size = CGSize(width: lbl.frame.size.width, height: CGFloat(lbl.numberOfLines * 21))
        
        
        lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = json["ispassshow"].stringValue
        lbl = cell.viewWithTag(20001) as! UILabel
        lbl.text = "考试时间  \(json["starttime"].stringValue)"
        lbl = cell.viewWithTag(20002) as! UILabel
        lbl.text = "\(json["exercisesscore"].intValue)"
        
        return cell
        
    }
    
    //设置cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let json = jsonDataSource[indexPath.item]
        let lblWidth = UIScreen.width.subtracting(100)
        let title = json["tasktitle"].stringValue
        let lineNumber = title.getLineNumberForWidth(width: lblWidth, cFont: UIFont.systemFont(ofSize: 17))
        let cHeight = 85 + (lineNumber - 1) * 25
        return CGSize(width: UIScreen.width, height: CGFloat(cHeight))
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    
}
