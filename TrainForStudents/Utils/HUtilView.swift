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
    
    
}

//红点
extension HUtilView{
    
    private static var redPointDic = [Int : UIView]()
    ///在指定view的右上角添加一个红点
    ///返回值用于删除红点
    static func addRedPoint(view :UIView) -> Int{
        
        let superView = view.superview!
        
        let size = CGSize(width: 10, height: 10)
        let origin = CGPoint(x: view.frame.width + view.frame.origin.x - (size.width / 2), y: view.frame.origin.y - (size.height / 2))
        let redPoint = UILabel()
        redPoint.frame.size = size
        redPoint.frame.origin = origin
        redPoint.clipsToBounds = true
        redPoint.layer.cornerRadius = size.width / 2
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

//显示图片
extension HUtilView{
    
    private static var showImageView = UIView()
    private static var prevScale = CGFloat(0)
    private static var originSize = CGSize(width: 0, height: 0)
    private static var originCenterPoint = CGPoint(x: 0, y: 0)
    
    static func showImageToTagetView(target: UIView, image: UIImage){
        
        
        var _image = image
        showImageView = UIView(frame: CGRect(x: 0, y: 0, width: target.W, height: target.H))
        let btn_bg = UIButton(frame: showImageView.frame)
        btn_bg.backgroundColor = .black
        btn_bg.addTarget(self, action: #selector(removeImageView), for: .touchUpInside)
        
        //添加缩放手势
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchDid(_:)))
//        showImageView.addGestureRecognizer(pinchGesture)
        
        let imageView = UIImageView()
        imageView.tag = 10001
        //先计算宽高
        if _image.size.width > UIScreen.width{
            imageView.setWidth(width: UIScreen.width)
            _image = _image.resizeImage(newSize: _image.scaleImage(imageLength: UIScreen.width))
        }
        imageView.setWidth(width: _image.size.width)
        imageView.setHight(height: _image.size.height)
        
        //再计算x和y
        imageView.setX(x: (showImageView.W - (imageView.W)) / 2)
        imageView.setY(y: (showImageView.H - (imageView.H)) / 2)
        
        //保存图片缩放后在视图中的原始尺寸
        originSize = _image.size
        originCenterPoint = imageView.center
        
        imageView.image = _image
        showImageView.addSubview(btn_bg)
        showImageView.addSubview(imageView)
        target.addSubview(showImageView)
        
    }
    
    @objc static func removeImageView(sender: UIButton){
        print("删除..")
        sender.superview?.removeFromSuperview()
    }
    
    @objc static func pinchDid(_ recognizer:UIPinchGestureRecognizer) {
        //在监听方法中可以实时获得捏合的比例
        let scale = recognizer.scale
        //prevScale - scale
        let multiple = (scale - 1) / 10 + 1
        let imageView = HUtilView.showImageView.viewWithTag(10001) as! UIImageView
        imageView.setWidth(width: imageView.W * multiple)
        imageView.setHight(height: imageView.H * multiple)

        //不能小于原始尺寸
        if imageView.W  < originSize.width {
            imageView.setWidth(width: originSize.width)
            imageView.setHight(height: originSize.height)
        }
        
        //不能大于原始尺寸3倍
        if imageView.W  > originSize.width * 3{
            imageView.setWidth(width: originSize.width * 3)
            imageView.setHight(height: originSize.height * 3)
        }
        
        imageView.center = originCenterPoint
        
        //获取两个触摸点的坐标
        print("scale:\(scale)")
        print("multiple:\(multiple)")
//        print("1:\(recognizer.location(ofTouch: 0, in: HUtilView.showImageView))")
//        print("2:\(recognizer.location(ofTouch: 1, in: HUtilView.showImageView))")
        print(imageView.frame)
        print("--------------------------------------------")
        print("--------------------------------------------")
        
    }
    
}
