//
//  HRedPointView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/9.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class HUtilView {
    
    private static var redPointDic = [Int : UIView]()
    
    ///在指定view的右上角添加一个红点
    ///返回值用于删除红点
    static func addRedPoint(view :UIView) -> Int{
        
        let superView = view.superview!
        
        let size = CGSize(width: 10, height: 10)
        let origin = CGPoint(x: view.frame.width.adding(view.frame.origin.x).subtracting(size.width.divided(by: 2)), y: view.frame.origin.y.subtracting(size.height.divided(by: 2)))
        let redPoint = UILabel()
        redPoint.frame.size = size
        redPoint.frame.origin = origin
        redPoint.clipsToBounds = true
        redPoint.layer.cornerRadius = size.width.divided(by: 2)
        redPoint.backgroundColor = UIColor.red
        
        //随机生成一个tag
        var tag = generateTag4RedPoint()
        //判断这个tag是否被使用
        var tempView = superView.viewWithTag(tag)
        while tempView != nil || redPointDic[tag] != nil{
            tag = generateTag4RedPoint()
            tempView = superView.viewWithTag(tag)
        }
        redPoint.tag = tag
        superView.addSubview(redPoint)
        
        //保存到字典
        redPointDic[tag] = superView
        
        return tag
    }
    
    ///删除成功返回true 反之返回false
    static func removeRedPoint(tag : Int) -> Bool{
        if tag < 100000{
            return false
        }
        let superView = redPointDic[tag]
        if superView != nil{
            superView?.viewWithTag(tag)?.removeFromSuperview()
            return true
        }
        return false
    }
    
    private static func generateTag4RedPoint() -> Int{
        var random = arc4random()
        while random < 100000 {
            random = arc4random()
        }
        //print("random:\(random)")
        return Int(random.description.substring(to: 6)) ?? 0
    }
    
}
