//
//  UIColorExtension.swift
//  easyStore
//
//  Created by 黄玮晟 on 2017/3/28.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#") {
            let index = hex.index(after: hex.startIndex)
            hexWithoutSymbol = hex.substring(from: index)
        }
        
        let scanner = Scanner(string: hexWithoutSymbol)
        var hexInt:UInt32 = 0x0
        scanner.scanHexInt32(&hexInt)
        
        var r:UInt32!, g:UInt32!, b:UInt32!
        switch (hexWithoutSymbol.length) {
        case 3: // #RGB
            r = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
            g = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
            b = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
            break;
        case 6: // #RRGGBB
            r = (hexInt >> 16) & 0xff
            g = (hexInt >> 8) & 0xff
            b = hexInt & 0xff
            break;
        default:
            // TODO:ERROR
            break;
        }
        
        self.init(
            red: (CGFloat(r)/255),
            green: (CGFloat(g)/255),
            blue: (CGFloat(b)/255),
            alpha:alpha)
    }
    
    class func defaultColor() -> UIColor {
        return UIColor.init(
            red: (CGFloat(38)/255),
            green: (CGFloat(135)/255),
            blue: (CGFloat(241)/255),
            alpha:1.0)
    }
}

//MARK: 常用颜色
func RGBCOLOR(r:CGFloat,_ g:CGFloat,_ b:CGFloat) -> UIColor
{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: 1.0)
}

func RGBACOLOR(r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ a:CGFloat) -> UIColor
{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}
