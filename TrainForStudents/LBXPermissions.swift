//
//  LBXPermissions.swift
//  swiftScan
//
//  Created by xialibing on 15/12/15.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}




class LBXPermissions: NSObject {

    //MARK: ---相机权限
    static func isGetCameraPermission()->Bool
    {
        
        let authStaus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStaus != AVAuthorizationStatus.denied
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    //MARK: ----获取相册权限
    static func isGetPhotoPermission()->Bool
    {
        var bResult = false
        
        let verNumber = Int(UIDevice.current.systemVersion.prefix(1))!
        
        if  verNumber >= 2 && verNumber <= 8{

            if( ALAssetsLibrary.authorizationStatus() != ALAuthorizationStatus.denied ){
                bResult = true
            }
            
        }else{
            if ( PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.denied ){
                bResult = true
            }
        }
        
        return bResult
    }
    
}
