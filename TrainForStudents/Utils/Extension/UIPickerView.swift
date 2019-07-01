//
//  UIPickerView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/5/9.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation

extension UIPickerView : UIGestureRecognizerDelegate{
    
    ///添加一个关闭按钮
    func addCloseButton(parentView : UIView){
        
        let btn_closePickerView = UIButton(frame: CGRect(x: UIScreen.width - 60, y: 0, width: 60, height: 40))
        btn_closePickerView.setTitle("关闭", for: .normal)
        btn_closePickerView.setTitleColor(.darkText, for: .normal)
        
        self.addSubview(btn_closePickerView)
        
        //增加手势 在点击btn之后 隐藏pdatepicker
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.delegate = self
        self.addGestureRecognizer(gesture)
        if viewParam == nil{
            viewParam = [String:Any]()
        }
        viewParam!["parentView"] = parentView
        
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //print("gestureRecognizerShouldBegin..")
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let pointer = touch.location(in: self)
        if pointer.y < 40 && pointer.x > W - 60{
            if let param = viewParam{
                let parentView = param["parentView"] as? UIView
                parentView?.endEditing(true)
            }
//            return false
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}
