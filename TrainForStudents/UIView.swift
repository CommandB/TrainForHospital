//
//  UIView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/20.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

struct RunTimeViewKey {
    static let RunTimeViewID = UnsafeRawPointer.init(bitPattern: "RunTimeViewID".hashValue)
    static let RunTimeViewParam = UnsafeRawPointer.init(bitPattern: "RunTimeViewParam".hashValue)
}
extension UIView{
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
            W     }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    var viewParam: Dictionary<String, Any>? {
        set {
            objc_setAssociatedObject(self, RunTimeViewKey.RunTimeViewParam!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return  objc_getAssociatedObject(self, RunTimeViewKey.RunTimeViewParam!) as? Dictionary
        }
    }
    
    /// 宽
    public var W: CGFloat {
        return self.bounds.size.width
    }
    /// 高
    public var H: CGFloat {
        return self.bounds.size.height
    }
    /// X
    public var X: CGFloat {
        return self.frame.origin.x
    }
    /// Y
    public var Y: CGFloat {
        return self.frame.origin.y
    }
    /// bottom
    public var bottom:CGFloat{
        return Y+H
    }
    /// centerX
    public var centerX: CGFloat {
        return self.center.x
    }
    /// centerY
    public var centerY: CGFloat {
        return self.center.y
    }
    
    /// 设置圆角
    public func setCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    /// 设置边框
    public func setBorder(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        layer.masksToBounds = true
    }
    ///设置顶部边框
    public func setBorderTop(size: CGFloat, color: UIColor) {
        setBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    /// 设置底部边框
    public func setBorderBottom(size: CGFloat, color: UIColor) {
        setBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    /// 设置左侧边框
    public func setBorderLeft(size: CGFloat, color: UIColor) {
        setBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    /// 设置右侧边框
    public func setBorderRight(size: CGFloat, color: UIColor) {
        setBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    
    fileprivate func setBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
    
    //返回该view所在VC
    func firstViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    func setX( x : CGFloat){
        self.frame.origin = CGPoint(x: x, y: frame.origin.y)
    }
    
    func setY( y : CGFloat){
        self.frame.origin = CGPoint(x: frame.origin.x, y: y)
    }
    
    func setWidth( width : CGFloat){
        self.frame.size = CGSize(width: width, height: self.H)
    }
    
    func setHight(height :CGFloat){
        self.frame.size = CGSize(width: self.W, height: height)
    }
    
    func moveToBefore(target: UIView , space: CGFloat = 0){
        
        let _h = (self.H - (target.H)) / 2
        self.setY(y: target.Y - (_h))
        self.setX(x: target.X - self.W - space)
    }
    
    func moveToAfter(target: UIView , space: CGFloat = 0){
        
        let _h = (self.H - target.H) / 2
        self.setY(y: target.Y - (_h))
        self.setX(x: (target.X + target.W) + space)
    }
    
}



extension UIView {
    
    // 360度旋转图片
    func hAnimat_rotate360Degree(repeatCount : Float = 1 , duration : TimeInterval = 1) {
        // 让其在z轴旋转
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        // 旋转角度
        rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
        // 动画持续时间
        rotationAnimation.duration = duration
        // 旋转累加角度
        rotationAnimation.isCumulative = true
        // 旋转次数
        rotationAnimation.repeatCount = repeatCount
        layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // 停止所有动画
    func stopAllAnimations() {
        layer.removeAllAnimations()
        
    }

}
