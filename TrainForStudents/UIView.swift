//
//  UIView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/20.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation

extension UIView{
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
}
