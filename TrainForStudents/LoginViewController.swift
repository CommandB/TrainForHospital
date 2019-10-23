//
//  LoginController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/6.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import CoreTelephony

class LoginViewController : HBaseViewController, UIPickerViewDataSource , UIPickerViewDelegate{
    
    @IBOutlet weak var content: UILabel!
    
    @IBOutlet weak var txt_loginId: UITextField!
    
    @IBOutlet weak var txt_password: UITextField!
    
    @IBOutlet weak var txt_hospital: TextFieldForNoMenu!
    
    @IBOutlet weak var loginBtn: UIButton!
    let myPickerView = UIPickerView()
    
    var pickerDataSource = [JSON]()
    
    let pickerViewFirstStr = "请选择"
    
//    var btn_closePickerView = UIButton()
    
    @IBAction func btn_login_inside(_ sender: UIButton) {
        login()
        
        //富文本设置
        var attributeString = NSMutableAttributedString(string:"welcome to hangge.com")
        //从文本0开始6个字符字体HelveticaNeue-Bold,16号
        attributeString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "HelveticaNeue-Bold", size: 18)!,
                                     range: NSMakeRange(0,6))
        //设置字体颜色
        attributeString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue,
                                     range: NSMakeRange(0, 3))
        //设置文字背景颜色
        attributeString.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.green,
                                     range: NSMakeRange(3,3))
        
        let smileImage : UIImage = UIImage(named: "playboy.jpg")!
        let textAttachment : NSTextAttachment = NSTextAttachment()
        textAttachment.image = smileImage
        textAttachment.bounds = CGRect(x: 0, y: -20, width: 50, height: 50)

        attributeString.append(NSAttributedString(attachment: textAttachment))
        attributeString.append(NSAttributedString(string: "一些什么东西呢"))
        content.attributedText = attributeString
        
//        var htmlText = "空は<font color=\"blue\">青い</font>。<br>An apple is <font color=\"red\">red</font>."
//        do{
//            let attrStr = try NSAttributedString(data: htmlText.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
//
//            content.attributedText = attrStr
//        }catch let error as NSError {
//            print(error.localizedDescription)
//        }
        
        
//        setup(content: "<div style='font-size:20px;color:red;background-color:green;'>哈哈哈哈哈哈哦哦哦哦<img style='width:30px !important;height:30px; margin-left:20px;padding-right:50px;' src='https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554102155517&di=3408e01d4ed786bf7495b1c6e4e1a68f&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201408%2F18%2F20140818125020_GLPZS.jpeg'><input type='text' value='好好好' style='color:#c00'>哒哒哒哒哒哒哒哒哒哒哒哒</div><img src='https://avatar.csdn.net/9/6/F/3_flg1554112450.jpg'>")
        
        
        
    }
    
    @IBAction func btn_hospital_inside(_ sender: UITextField) {
        
    }
    
    @IBAction func btn_forgotPassword_inside(_ sender: UIButton) {
        let nav = UINavigationController(rootViewController: ForgotPasswordViewController())
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
    func setup(content:String){
        self.content.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - 36
        let content = "<html><head><meta name= \"viewport\" content= \"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\"></head><body>" + content + "</body></html>"
        

        let data:NSData? = content.data(using:.unicode, allowLossyConversion: true) as NSData?
    
        do {
            
//            let attrStr = try NSMutableAttributedString(data: data! as Data, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
            
//            nsdocumentt
            
            let attrStr = try NSMutableAttributedString(data: data as! Data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            
            attrStr.enumerateAttribute(NSAttributedStringKey.attachment, in: NSMakeRange(0, attrStr.length), options: NSAttributedString.EnumerationOptions.reverse, using: { (vale, range, stop) -> Void in
                if let ment = vale as? NSTextAttachment{
                    ment.bounds.size = CGSize(width: UIScreen.main.bounds.size.width - 20, height: 130)
                }
            })
            
            attrStr.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, attrStr.length))
            // 设置行距
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            attrStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSMakeRange(0, attrStr.length))
            self.content.attributedText = attrStr
        } catch{
            
        }
        self.content.font = UIFont.systemFont(ofSize: 14)
        self.content.textColor = UIColor.darkGray
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        content.isHidden = true
        
        myPickerView.dataSource = self
        myPickerView.delegate = self
        
//        myPickerView.frame = CGRect.init(x: 0, y:  loginBtn.frame.maxY, width: self.view.frame.size.width, height: self.view.frame.size.height-loginBtn.frame.maxY)

        
        txt_loginId.returnKeyType = .next
        txt_loginId.delegate = self
        txt_password.delegate = self
        txt_hospital.delegate = self
        txt_hospital.inputView = myPickerView
        txt_hospital.restorationIdentifier = "hospital"
        txt_hospital.tintColor = UIColor.clear
        txt_hospital.layer.borderColor = UIColor.clear.cgColor
        txt_hospital.layer.borderWidth = 1
        
        checkNetworkEnable()
        
        loadHospital()
        
//        myPickerView.addCloseButton(parentView: self.view)
        
    }
    
    
    func checkNetworkEnable() {
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (_ state:CTCellularDataRestrictedState)->() in
            switch state {
            case .restricted:
                let alert = UIAlertController(title: "请到设置中设置允许网络访问", message: nil, preferredStyle: .alert)
                let setAction = UIAlertAction(title: "设置", style: UIAlertActionStyle.default, handler: { (action) in
                    if let url = URL.init(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                })
                let cancelAction =  UIAlertAction(title: "好的", style: UIAlertActionStyle.default, handler: { (action) in
                    
                })
                alert.addAction(setAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                break
            case .notRestricted:
                break
            case .restrictedStateUnknown:
                break
            default:
                break
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let loginId = UserDefaults.standard.string(forKey: LoginInfo.loginId.rawValue)
        let hospital = UserDefaults.standard.string(forKey: LoginInfo.hospital.rawValue)
        
        if loginId != nil {
            txt_loginId.text = loginId
        }
        
        if hospital != nil {
            txt_hospital.text = hospital
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let json = pickerDataSource[row]
        
        return json["name"].stringValue
    }
    
    //picker 选中
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row > 0 {
            let data = pickerDataSource[row]
            txt_hospital.text = data["name"].stringValue
            
            let server_port = "http://\(data["url"].stringValue )/doctor_train/"
            let portal_port = "http://\(data["portalurl"].stringValue)/doctor_portal/"
            
            //存app本地
            UserDefaults.standard.set(server_port, forKey: LoginInfo.server_port.rawValue)
            UserDefaults.standard.set(portal_port, forKey: LoginInfo.portal_port.rawValue)
            //UserDefaults.standard.set(txt_loginId.text!, forKey: LoginInfo.loginId.rawValue)
            //UserDefaults.standard.set(txt_password.text!, forKey: LoginInfo.password.rawValue)
            UserDefaults.standard.set(txt_hospital.text!, forKey: LoginInfo.hospital.rawValue)
            
            SERVER_PORT = server_port
            PORTAL_PORT = portal_port
            
        }
        
    }
    
    var loadHospitalTotal = 0
    //下载基地列表
    func loadHospital(){
        
        if !isReachable(){
            myAlert(self, message: "请检查网络连接...")
            return
        }
        
        if loadHospitalTotal == 10 {
            myAlert(self, message: "请检查网络连接...")
            loadHospitalTotal = 0
        }
        
        let url = CLOUD_SERVER + "rest/trainHospital/query.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    self.pickerDataSource = [JSON]()
                    self.pickerDataSource.append(JSON(["name":self.pickerViewFirstStr]))
                    self.pickerDataSource += json["data"].arrayValue
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                self.myPickerView.reloadAllComponents()
            case .failure(let error):
                //记录错误次数
                self.loadHospitalTotal += 1
                //延迟2秒重新执行
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                    self.loadHospital()
                })
                print(error)
            }
            
        })
    }
    
    
    //登录
    func login(){
        
        hiddenKeyBoard()
        
        if txt_loginId.text?.length == 0{
            myAlert(self, message: "请输入用户名!")
            return
        }else if txt_password.text?.length == 0 {
            myAlert(self, message: "请输入密码!")
            return
        }else if txt_hospital.text?.length == 0 {
            myAlert(self, message: "请选择基地")
            return
        }
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = PORTAL_PORT + "rest/loginCheck.do"
//        let url = "http://192.168.1.106:8081/doctor_portal/rest/loginCheck.do"
        myPostRequest(url,["loginid":txt_loginId.text , "password":txt_password.text?.sha1() ,"logintype":"iphone", "mac":uuid,"devicetype":"ios","deviceid":CloudPushSDK.getDeviceId()!]).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let token = json["token"].stringValue
                    r_token = token
                    UserDefaults.standard.set(token, forKey: LoginInfo.token.rawValue)

                    //如果本次登录账号和上次登录账号不一样 则清除缓存的考试数据并修改本地缓存
                    let preLoginId = UserDefaults.standard.string(forKey: LoginInfo.loginId.rawValue)
                    if preLoginId != self.txt_loginId.text!{
                        let cacheAnswersDic = [String : [String : Dictionary<String, String>]]()
                        //清除考试缓存
                        UserDefaults.Exam.set(value: cacheAnswersDic, forKey: .answerDic)
                        //缓存登录人的信息
                        UserDefaults.standard.set(self.txt_loginId.text!, forKey:
                            LoginInfo.loginId.rawValue)
                        UserDefaults.standard.set(json["personid"].stringValue, forKey: LoginInfo.personId.rawValue)
                        
                    }
                    
                    self.appDelegate.loadAppConfig()
                    
                    //-----------------------------请求科室信息开始-----------------------------
                    let getOfficeURL = SERVER_PORT+"rest/app/queryMyOffice.do"
                    myPostRequest(getOfficeURL).responseJSON(completionHandler: { resp in
                        
                        switch  resp.result{
                        case .success(let result):
                            
                            let json = JSON(result)
                            //print(json)
                            if json["code"].stringValue == "1"{
                                //缓存科室信息
                                let data = json["data"].arrayValue
                                if data.count == 0 {
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    myAlert(self, message: "您暂未分配科室,请联系科教!")
                                    return
                                }
                                UserDefaults.standard.set(data[0]["officeid"].stringValue, forKey:
                                    LoginInfo.officeId.rawValue)
                                UserDefaults.standard.set(data[0]["officename"].stringValue, forKey:
                                    LoginInfo.officeName.rawValue)
                                
                                //解析角色信息并缓存
                                let role = json["role"].arrayValue
                                var roleDic = [String:Bool]()
                                if role.count > 0{
                                    let r = role[0]
                                    for item in r{
                                        if 0 == item.1{
                                            roleDic[item.0] = false
                                        }else{
                                            roleDic[item.0] = true
                                        }
                                    }
                                }
                                UserDefaults.standard.set(roleDic, forKey: LoginInfo.role.rawValue)
                                self.getMySelfData()

                                //-----------------------------请求配置信息开始-----------------------------
                                let url = SERVER_PORT+"rest/app/systemConfigData.do"
                                myPostRequest(url).responseJSON(completionHandler: {resp in
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    switch resp.result{
                                    case .success(let responseJson):
                                        
                                        let json = JSON(responseJson)
                                        if json["code"].stringValue == "1"{
                                            let data = json["data"]
                                            self.appDelegate.saveConfigToCache(data: data)
                                            
                                            //验证角色,判断登录到哪一端
                                            if isOnlyStudent(){
//                                                if UserDefaults.AppConfig.string(forKey: .isUseNewApp) == "1"{
                                                    self.appDelegate.window?.rootViewController = getViewToStoryboard("studentTabbar")
//                                                }else{
//                                                    self.appDelegate.window?.rootViewController = getViewToStoryboard("tabBarView")
//                                                }
                                            }else{
                                                //myPresentView(self, viewName: "hTabBarView")
                                                self.appDelegate.window?.rootViewController = getViewToStoryboard("hTabBarView")
                                                let tabBar = (self.appDelegate.window?.rootViewController) as! MyTabBarController
                                                tabBar.selectedIndex = 0
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }else{
                                            myAlert(self, message: json["msg"].stringValue)
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
                                    
                                })
                                //-----------------------------请求配置信息结束-----------------------------
                                
                            }else{
                                MBProgressHUD.hide(for: self.view, animated: true)
                                myAlert(self, message: json["msg"].stringValue)
                            }
                        case .failure(let err):
                            MBProgressHUD.hide(for: self.view, animated: true)
                            myAlert(self, message: "服务器异常!")
                            print(err)
                        }
                    })
                    //-----------------------------请求科室信息结束-----------------------------
                    
                }else{
                    MBProgressHUD.hide(for: self.view, animated: true)
                    myAlert(self, message: json["msg"].stringValue)
                }
                
                self.checkNewVersion()
                
            case .failure(let error):
                MBProgressHUD.hide(for: self.view, animated: true)
                myAlert(self, message: "服务器异常!")
                print(error)
            }
            
        })
        
    }
    
    //获取我的信息
    func getMySelfData(){
        
        let url = SERVER_PORT+"rest/personStudent/query.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json=JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    //缓存用户基础信息
                    UserDefaults.User.set(value: json["data"]["personid"].stringValue, forKey: .personId)
                    UserDefaults.User.set(value: json["data"]["jobnum"].stringValue, forKey: .jobNum)
                    UserDefaults.User.set(value: json["data"]["personname"].stringValue, forKey: .personName)
                    UserDefaults.User.set(value: json["data"]["subjectname"].stringValue, forKey: .majorName)
                    UserDefaults.User.set(value: json["data"]["highestdegree"].stringValue, forKey: .highestDegree)
                    UserDefaults.User.set(value: json["data"]["phoneno"].stringValue, forKey: .phoneNo)
                    UserDefaults.User.set(value: json["data"]["sex"].stringValue, forKey: .sex)
                    
                }else{
                    myAlert(self, message: "请求我的信息失败!")
                }
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    func checkNewVersion() {
        Task().checkUpdateForAppID { (thisVersion, version) in
            let alertController = UIAlertController(title: "最新版本(\(version))已发布", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "立刻更新", style: .default) { (UIAlertAction) in
                let AppID = "1279781724"
                if let URL = URL(string: "https://itunes.apple.com/us/app/id\(AppID)?ls=1&mt=8") {
                    UIApplication.shared.openURL(URL)
                }
            }
            alertController.addAction(okAction)
            guard let keyWindow = UIApplication.shared.keyWindow else { return }
            keyWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension LoginViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if "loginId" == textField.restorationIdentifier{
            txt_password.becomeFirstResponder()
        }else if "password" == textField.restorationIdentifier{
            login()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if "hospital" == textField.restorationIdentifier{
            myPickerView.selectRow(0, inComponent: 0, animated: true)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if pickerDataSource.count <= 0 {
            loadHospital()
            myAlert(self, message: "基地列表加载中,请稍后...")
            return false
        }
        return true
    }
    
}
