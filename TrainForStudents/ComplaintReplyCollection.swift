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
    var isanonymous = true
    
    var parentView : ComplaintReplyController? = nil
    let lineHeight = 17
    
    //设置每个分区元素的个数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return jsonDataSource.count + 1
        
    }
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if showNoDataCell{
            return collectionView.dequeueReusableCell(withReuseIdentifier: MyNoDataCellView.identifier, for: indexPath)
        }
        //print(indexPath)
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            return cell
        }
        let json = jsonDataSource[indexPath.item - 1]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
        
        let contentLbl = cell.viewWithTag(10001) as! UILabel
        let text = json["reply"].stringValue
        let tn = text.getLineNumberForWidth(width: contentLbl.frame.width.subtracting(10), cFont: contentLbl.font)
        contentLbl.numberOfLines = 0
        contentLbl.text = text
        var lblHeight = lineHeight * tn
        if lblHeight < 30{
            lblHeight = 30
        }
        contentLbl.frame.size = CGSize(width: contentLbl.frame.size.width, height: CGFloat(lblHeight))
        
        //先删除20001 不然会重影
        let v = cell.viewWithTag(20001)
        if v != nil{
            v?.removeFromSuperview()
        }
        
        let f = contentLbl.frame
        let dateLbl = UILabel(frame: CGRect(x: f.origin.x, y: f.origin.y.adding(f.size.height).adding(5), width: cell.frame.width.subtracting(75), height: 20))
        dateLbl.text = json["replytime1"].stringValue
        dateLbl.textColor = UIColor.gray
        dateLbl.font = UIFont.systemFont(ofSize: 13)
        dateLbl.textAlignment = .right
        dateLbl.tag = 20001
        //dateLbl.backgroundColor = UIColor.orange
        cell.addSubview(dateLbl)
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        
        let nameLbl =  cell.viewWithTag(22222) as! UILabel
        let selfPersonid = UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)
        if json["personid"].stringValue == selfPersonid {
            if isanonymous == true {
                nameLbl.text = json["personname"].stringValue
            }else{
                nameLbl.text = "匿名"
            }
        }else{
            nameLbl.text = "科教回复"
        }
        
        return cell
        
    }
    
    //计算大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0{
            return CGSize.init(width: UIScreen.width , height: 30)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        let json = jsonDataSource[indexPath.item - 1]
        let str = json["reply"].stringValue
        
        //计算多行label的高度
        let lineNumber = str.getLineNumberForWidth(width: lbl.frame.width.subtracting(10),cFont: lbl.font)
        let lblHeight = lineHeight * lineNumber
        var cellHeight = lblHeight + 40
        if cellHeight < 70{
            cellHeight = 70
        }
        return CGSize.init(width: UIScreen.width - 10 , height: CGFloat(cellHeight))
        
        
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parentView?.hiddenKeyBoard()
    }

}
