//
//  GradientLayerBaseView.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit

class GradientLayerBaseView: UIView {
    var preHeight:CGFloat = 0
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        if preHeight == self.bounds.height {
            return
        }
        preHeight = self.bounds.height
        addGradientLayer(frame: self
            .bounds, colors: [RGBCOLOR(r: 87, 192, 248).cgColor, RGBCOLOR(r: 12, 82, 230).cgColor])
    }
    
    public func addGradientLayer(
        start: CGPoint = CGPoint(x: 0, y: 0), //渐变起点
        end: CGPoint = CGPoint(x: 1, y: 1), //渐变终点
        frame: CGRect,
        colors: [CGColor]
        ) {
        layoutIfNeeded()
        removeGradientLayer()
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public func removeGradientLayer() {
        guard let layers = self.layer.sublayers else { return }
        for layer in layers {
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
    }
}
