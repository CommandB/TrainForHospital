//
//  extension.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/8.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//


import Foundation
import Alamofire
import UIKit
import SwiftyJSON
import Reachability

let CLOUD_SERVER = "http://www.jiuhuatech.com:6023/cloud_doctor_train/"
var SERVER_PORT = "http://192.168.1.108:8070/doctor_train/"
var PORTAL_PORT = "http://120.77.181.22:8080/doctor_portal/"
//let PORTAL_URL = "http://192.168.1.106:8080/doctor_portal/"

//var rootViewController
var selectedTabBarIndex = 0

///request请求后台必须要带下列参数
var r_param = [String:Any]()
var r_token = "";
///图片下载默认id
let congou_image_id = "congou_image_id"

//MARK: 判断是否有网络
func isReachable() -> Bool{
    
    let reachable = Reachability.forInternetConnection().isReachable()
    return reachable
}

///当前登录人是否只有学生一个角色
func isOnlyStudent() -> Bool{
    let roleDic = (UserDefaults.standard.dictionary(forKey: LoginInfo.role.rawValue)) as! [String:Bool]
    if roleDic["issecretary"]! {
        return false
    }
    if roleDic["isteacher"]! {
        return false
    }
    return true
}

//post方式提交数据
func myPostRequest(_ url:String, _ parameters: [String: Any]? = nil , method: HTTPMethod = HTTPMethod.post , timeoutInterval : TimeInterval = 60) -> DataRequest {
    
    var requestParam = [String:Any]()
    let paramData = NSMutableDictionary(dictionary:["token":r_token])
    
    //合并默认参数和用户请求的参数
    if parameters != nil{
        paramData.addEntries(from: parameters!)
    }

    //把请求参数转成JSON
    let jsonData = JSON(paramData)
    
    //把json放入request请求的参数
    requestParam["data"] = jsonData.description
    //添加必要参数
    requestParam["myshop_forapp_key"] = 987654321
    
//    print("url:\(url)\nparam:\(JSON.init(requestParam))")
    
    
    //设置请求超时时间
    let sessionManager = Alamofire.SessionManager.default
    sessionManager.session.configuration.timeoutIntervalForRequest = timeoutInterval
    
    return sessionManager.request(url, method: method, parameters: requestParam, encoding: URLEncoding.default, headers: ["Content-type":"application/x-www-form-urlencoded"])
}

///图片上传
func uploadImage(_ url: String , images:[String : UIImage]? , parameters:[String : Any]? , completionHandler : @escaping (DataResponse<Any>) -> Void ){
    
    //用于验证的参数必须放在url里
    let urlParam = "myshop_forapp_key=987654321&token="+r_token;
    var postUrl = url
    if url.hasSuffix(".do") || url.hasSuffix(".action") {
        postUrl += "?" + urlParam
    }else {
        postUrl += "&" + urlParam
    }
    
    
    if parameters != nil {
        let jsonData = JSON(parameters!)
        r_param["data"] = jsonData.description
    }
    
    upload(multipartFormData: { multipartFormData in
        
        if images != nil && (images?.count)!>0 {
            for (k , v ) in images!{
                let data = UIImagePNGRepresentation(v)
                let imageName = k + ".png"
                multipartFormData.append(data!, withName: "file", fileName: imageName, mimeType: "image/png")
                
            }
        }
        
        for (k , v) in r_param{
            multipartFormData.append((v as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: k)
//            multipartFormData.append(v.data(using: String.Encoding.utf8)!, withName: k)
        }
        
    },to:postUrl, encodingCompletion: { encodingResult in
        
        
        switch encodingResult {
        case .success(let upload, _, _):
            
            upload.responseJSON(completionHandler: completionHandler)
            
            
        case .failure(let encodingError):
            print(encodingError)
        }
        
    })
    
}

///系统消息提示
func myAlert(_ viewController:UIViewController, title:String = "系统提示", message:String, btnTitle:String = "好的", handler:((UIAlertAction) -> Void)? = nil){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: btnTitle, style: .default, handler: handler))
    viewController.present(alert, animated: true, completion: nil)
    
}

//我要报名
func signUpAlertPresent(_ viewController:UIViewController, title:String?, message:String?, btnTitle:String?, handler:((UIAlertAction) -> Void)? = nil){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: btnTitle, style: .default, handler: handler))
    viewController.present(alert, animated: true, completion: nil)
    
}

///confirm
func myConfirm(_ viewController:UIViewController, title:String = "系统提示", message:String, okTitle:String = "好的", cancelTitle:String = "取消" , okHandler:((UIAlertAction) -> Void)? = nil , cancelHandler:((UIAlertAction) -> Void)? = nil ){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: okHandler))
    alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: cancelHandler))
    
    viewController.present(alert, animated: true, completion: nil)
    
}



///跳转view
func myPresentView(_ controller:UIViewController, viewName:String , completion: (() -> Void)? = nil ){
    let vc=getViewToStoryboard(viewName)
    //跳转
    controller.present(vc, animated: true, completion: nil)
    
}

func getViewToStoryboard(_ viewName:String) -> UIViewController{
    //获取Main.Storyboard对象
    let sb=UIStoryboard(name: "Main", bundle: nil)
    //从storyboard中获取view
    return sb.instantiateViewController(withIdentifier: viewName)
    	
}

///基础的http访问成功处理结果
func baseHttpRequestSuccessHandle(_ vc:UIViewController , httpResult:AnyObject, successMsg:String = "提交成功!" , errorMsg:String = "服务器异常,访问失败!"){
    
    let json = JSON(httpResult)
    
    if json["code"] == "1" {
        myAlert(vc, message: successMsg)
    }else{
        var msg = json["msg"].stringValue
        if msg == "" {
            msg = errorMsg
        }
        myAlert(vc, message: msg)
        print(json)
    }
    
}

//MARK: 计算label长度
func getLabWidth(labelStr:String,font:CGFloat,height:CGFloat) -> CGFloat {
    let statusLabelText: NSString = NSString(string: labelStr)
    let size = CGSize.init(width: 900, height: height)
    let dic = NSDictionary(object: UIFont.systemFont(ofSize: font), forKey: NSAttributedStringKey.font as NSCopying)
    let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : Any], context:nil).size
    
    
    return strSize.width+20
    
}

