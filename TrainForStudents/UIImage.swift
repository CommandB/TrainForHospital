//
//  UIImage.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/8/4.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    
    static func createQR(text : String , size : CGFloat) -> UIImage{
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        let ciImage = filter?.outputImage
        return createNonInterpolatedUIImageFormCIImage(image: ciImage!, size: size)
        
    }
    
    static private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale);
        //        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        bitmapRef.draw(bitmapImage, in: extent)
        
        let scaledImage: CGImage = bitmapRef.makeImage()!
        
        return UIImage(cgImage: scaledImage)
    }
    
}



extension UIImage {
    
    /**
     *  通过指定图片最长边，获得等比例的图片size
     *
     *  image       原始图片
     *  imageLength 图片允许的最长宽度（高度）
     *
     *  return 获得等比例的size
     */
    func  scaleImage(imageLength: CGFloat) -> CGSize {
        
        //        var newWidth:CGFloat = 0.0
        //        var newHeight:CGFloat = 0.0
//                let width = self.size.width
//                let height = self.size.height
        
        //        if (width > imageLength || height > imageLength){
        //
        //            if (width > height) {
        //
        //                newWidth = imageLength;
        //                newHeight = newWidth * height / width;
        //
        //            }else if(height > width){
        //
        //                newHeight = imageLength;
        //                newWidth = newHeight * width / height;
        //
        //            }else{
        //
        //                newWidth = imageLength;
        //                newHeight = imageLength;
        //            }
        //            return CGSize(width: newWidth, height: newHeight)
        //        }else{
        //            return CGSize(width: width, height: height)
        //        }
        
        
        let width = self.size.width
        let height = self.size.height
        let scale = width / imageLength
        return CGSize(width: imageLength, height: height / scale)
        
    }
    
    /**
     *  获得指定size的图片
     *
     *  newSize 指定的size
     *
     *  return 调整后的图片
     */
    func resizeImage(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    /**
     *  压缩上传图片到指定字节
     *
     *  image     压缩的图片
     *  maxLength 压缩后最大字节大小
     *
     *  return 压缩后图片的二进制
     */
    func compressImage(maxLength: Int , resize: CGFloat = 0) -> Data? {
        
        var newImage = self
        if resize != 0 {
            let newSize = self.scaleImage(imageLength: resize)
            newImage = self.resizeImage(newSize: newSize)
        }
        
        var compress:CGFloat = 0.9
        var data = UIImageJPEGRepresentation(newImage, compress)
        while (data?.count)! > maxLength && compress > 0.01 {
            compress -= 0.02
            data = UIImageJPEGRepresentation(newImage, compress)
        }
        
        return data
    }
    
    
}
