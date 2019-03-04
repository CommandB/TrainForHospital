//
//  IconLabel.swift
//  easyStore
//
//  Created by 黄玮晟 on 2017/3/22.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit


extension UILabel{
    
    func setIconFont(fontSize : CGFloat){
        self.font = UIFont(name: "iconfont", size: fontSize)
    }
    
    static func getDefaultLineHeight() -> CGFloat{
        return 20
    }
    
    func setWidthFromText(){
        //稍微增加一点 防止出现省略号
        self.frame.size = CGSize(width: (self.text?.getWidth().adding(2))!, height: self.H)
    }
    
}
