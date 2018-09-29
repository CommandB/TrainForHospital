//
//  ComplaintReplyCollection.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/9/27.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ComplaintReplyCollection : MyBaseCollectionView{
    
    var parentView : ComplaintReplyController? = nil
    let lineHeight = 18
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if showNoDataCell{
            return collectionView.dequeueReusableCell(withReuseIdentifier: MyNoDataCellView.identifier, for: indexPath)
        }
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            return cell
        }
        let json = jsonDataSource[indexPath.item - 1]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
        
        let contentLbl = cell.viewWithTag(10001) as! UILabel
        let text = json["reply"].stringValue
        let tn = text.getLineNumberForUILabel(contentLbl)
        contentLbl.numberOfLines = 0
        contentLbl.text = text
        contentLbl.frame.size = CGSize(width: contentLbl.frame.size.width, height: CGFloat(lineHeight * tn))
        
        //先删除20001 不然会重影
        let v = cell.viewWithTag(20001)
        if v != nil{
            v?.removeFromSuperview()
        }
        
        let f = contentLbl.frame
        let dateLbl = UILabel(frame: CGRect(x: f.origin.x, y: f.origin.y.adding(f.size.height).adding(5), width: cell.frame.width.subtracting(75), height: 20))
        let rt = json["replytime"].stringValue
        dateLbl.text = rt.substring(to: rt.index(rt.startIndex, offsetBy: 16))
        dateLbl.textColor = UIColor.gray
        dateLbl.font = UIFont.systemFont(ofSize: 13)
        dateLbl.textAlignment = .right
        dateLbl.tag = 20001
        //dateLbl.backgroundColor = UIColor.orange
        cell.addSubview(dateLbl)
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        
        return cell
        
    }
    
    //计算大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0{
            return CGSize.init(width: UIScreen.width , height: 30)
        }
        
        let json = jsonDataSource[indexPath.item - 1]
        let str = json["reply"].stringValue
        
        //计算多行label的高度
        let lineNumber = str.getLineNumberForWidth(width: UIScreen.width - 90)
        let lblHeight = lineHeight * lineNumber
        return CGSize.init(width: UIScreen.width - 10 , height: CGFloat(lblHeight + 40))
        
        
    }

}
