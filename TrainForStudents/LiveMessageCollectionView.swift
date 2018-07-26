//
//  LiveMessageCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/4/24.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation


class LiveMessageCollectionView : MyBaseCollectionView {
    
    var parentView = UIViewController()
    let text = ["测试测试测试测试测试测试测试测试测试测试测噢哟噢哟噢哟噢哟噢哟噢哟噢哟噢啊哦啊哦啊哦啊哦啊哦啊哦啊哦","dfasdf9sdf9dsfsdafs","反对四偶发ID酸辣粉即可代理商发的链接发牢骚 发斯蒂芬发送到","大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大🙃幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少","😂🙃☺️🤑","iqiiwiwiwq",
                "好歹方式登记方式发送到发送到发到付","dfasdfdsafsadf大是大非大12312电风扇2/@!#!2"]
    
    //设置每个分区元素的个数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if text.count == 0 {
            collectionView.registerNoDataCellView()
            if showNoDataCell{
                return 1
            }
            return 0
        }else{
            showNoDataCell = false
            return text.count
        }
        
    }
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cellName = "c1"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
//        if indexPath.item % 2 == 0 {
//            cell.backgroundColor = UIColor.gray
//        }else{
//            cell.backgroundColor = UIColor.lightGray
//        }
        
        let btn = cell.viewWithTag(10001) as! UIButton
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        var lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = "名字"
        lbl = cell.viewWithTag(10003) as! UILabel
        lbl.text = "刚刚"
        lbl = cell.viewWithTag(20001) as! UILabel
        
        lbl.text = text[indexPath.item]
        lbl.draw(CGRect.init(x: 5, y: 1, width: lbl.frame.width, height: lbl.frame.height))
        
        lbl.numberOfLines = 0
        lbl.layer.cornerRadius = 4
        lbl.layer.masksToBounds = true
        //减去头像的宽度和边上空白位置
        let maxWidth = cell.frame.width.subtracting(85)
        let num = lbl.text?.getLineNumberForWidth(width: maxWidth)
        if num == 1{
            lbl.frame.size = CGSize(width: (lbl.text?.getWidth())!.adding(8), height: CGFloat(20).adding(5))
        }else{
            lbl.frame.size = CGSize(width: maxWidth, height: (lbl.text?.getHeight().multiplied(by: CGFloat(num!)))!.adding(5))
         
        }
        //lbl.numberOfLines = num!
//        print("frame:\(lbl.frame) \r text:\(String(describing: lbl.text)) numberOfLine:\(lbl.numberOfLines)")
        
        let backgroundHeight = lbl.frame.height
        lbl = cell.viewWithTag(20000) as! UILabel
        lbl.frame.size = CGSize(width: 10, height: backgroundHeight)
        lbl.layer.cornerRadius = 4
        lbl.layer.masksToBounds = true
        
        return cell
        
    }
    
    //设置cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var contentTextHeight = CGFloat(20)
        var cellHeight = CGFloat(0)
        let maxWidth = collectionView.frame.width.subtracting(78)
        let t = text[indexPath.item]
        let num = t.getLineNumberForWidth(width: maxWidth)
        
        if num > 1{
            contentTextHeight = "".getHeight(font: UIFont.systemFont(ofSize: UIFont.systemFontSize)).adding(1).multiplied(by: CGFloat(num))
//            height = height.multiplied(by: CGFloat(num))
        }
        cellHeight = contentTextHeight.adding(40)
        if cellHeight < 60{
            cellHeight = 60
        }
//        print("cellHeight:\(cellHeight)")
        return CGSize(width: UIScreen.width, height: cellHeight)
        
    }
    
}
