//
//  UIButton.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/8/11.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    
    @objc func set(image anImage: UIImage?, title: String,
                   titlePosition: UIViewContentMode, additionalSpacing: CGFloat, state: UIControlState){
        let oldFrame = self.frame
//        print("设置前:\(self.frame)")
        self.imageView?.contentMode = .scaleAspectFit
        self.setImage(anImage, for: state)
//        print("设置后:\(self.frame)")
        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing ,image: anImage)
        
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
        self.frame = oldFrame
//        print("最后后:\(self.frame)")
        print("--------------------")
    }
    
    private func positionLabelRespectToImage(title: String, position: UIViewContentMode,
                                             spacing: CGFloat,image : UIImage?) {
        //let imageSize = self.imageRect(forContentRect: self.frame)
        let imageSize = UIImageView(image: image).frame
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(attributes: [NSFontAttributeName: titleFont!])
        
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
//        print("title=\(self.titleLabel?.frame)")
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
            
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
        //print("title=\(self.titleLabel?.frame)")
        //print("titleInsets=\(titleInsets)")
        //print("image=\(self.imageView?.frame)")
        //print("imageInsets=\(imageInsets)")
        
    }
    
}
