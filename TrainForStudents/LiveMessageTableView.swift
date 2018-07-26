//
//  LiveMessageTableView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/4/19.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import SwiftyJSON

class LiveMessageTableView : UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var parentView = UIViewController()
    var jsonDataSource = [JSON]()
    let text = ["测试测试测试测试测试测试测试测试测试测试测噢哟噢哟噢哟噢哟噢哟噢哟噢哟噢啊哦啊哦啊哦啊哦啊哦啊哦啊哦","dfasdf9sdf9dsfsdafs","反对四偶发ID酸辣粉即可代理商发的链接发牢骚 发斯蒂芬发送到","大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大🙃幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少大幅度发多少","😂🙃☺️🤑","fdsafds",
                "好歹方式登记方式发送到发送到发到付","dfasdfdsafsadf大是大非大12312电风扇2/@!#!2"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return jsonDataSource.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return text.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellName = "c1"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        cell.selectionStyle = .none
        
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
        let maxWidth = cell.frame.width.subtracting(78)
        let num = lbl.text?.getLineNumberForWidth(width: maxWidth)
        if num == 1{
            lbl.frame.size = CGSize(width: (lbl.text?.getWidth())!.adding(8), height: lbl.frame.height.multiplied(by: CGFloat(num!)).adding(5))
        }else{
            lbl.frame.size = CGSize(width: maxWidth, height: lbl.frame.height.multiplied(by: CGFloat(num!)))
        }
        lbl.numberOfLines = num!
        print("frame:\(lbl.frame) \r text:\(String(describing: lbl.text)) numberOfLine:\(lbl.numberOfLines)")
        
        let backgroundHeight = lbl.frame.height
        lbl = cell.viewWithTag(20000) as! UILabel
        lbl.frame.size = CGSize(width: 10, height: backgroundHeight)
        lbl.layer.cornerRadius = 4
        lbl.layer.masksToBounds = true
        
        return cell
        
    }
    
    //cell的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellName = "c1"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName)!
        let lbl = cell.viewWithTag(20001) as! UILabel
        var height = lbl.frame.height
        let maxWidth = cell.frame.width.subtracting(78)
        let t = text[indexPath.item]
        let num = t.getLineNumberForWidth(width: maxWidth)
        if num > 1{
            height = height.multiplied(by: CGFloat(num))
        }
        return CGFloat.init(height).adding(42)
    }
    
    //section的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
