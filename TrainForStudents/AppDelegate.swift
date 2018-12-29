//
//  AppDelegate.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/5.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate{

    var window: UIWindow?
    //支持当前controller横屏
    var blockRotation = false
    
    fileprivate var loadAppConfigFailedCount = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.applicationIconBadgeNumber = 0;
        // Override point for customization after application launch.
        
//        registerForPushNotifications(launchOptions)
        
        //注册3D Touch
        //UIApplicationShortcutIcon(type: .capturePhoto)
        let scanIcon = UIApplicationShortcutIcon(templateImageName: "扫一扫")
        let scanItem = UIApplicationShortcutItem(type: "scan", localizedTitle: "扫码签到", localizedSubtitle: nil , icon: scanIcon, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [scanItem]
        
        //注册极光推送
        registerJPushService(launchOptions)
        
        //验证服务器地址缓存
        let sp = UserDefaults.standard.string(forKey: LoginInfo.server_port.rawValue)
        let pp = UserDefaults.standard.string(forKey: LoginInfo.portal_port.rawValue)
        let token = UserDefaults.standard.string(forKey: LoginInfo.token.rawValue)
        
        if sp != nil {
            SERVER_PORT = sp!
        }
        if pp != nil {
            PORTAL_PORT = pp!
        }
        if token != nil{
            r_token = token!
        }
        //版本号验证
        checkNewVersion()
        return true
    }
    
    //3D Touch 按钮对应的事件
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let rootViewController = UIApplication.shared.delegate?.window?!.rootViewController
        
        switch shortcutItem.type {
        case "scan":
            myPresentView(rootViewController!, viewName: "scannerView")
            break
        default:
            break
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0;
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //判断缓存中是否存在token
        let token = UserDefaults.standard.string(forKey: LoginInfo.token.rawValue)
        if token == nil{
            myPresentView((self.window?.rootViewController)!, viewName: "loginView")
        }else{
            loadAppConfigFailedCount = 0
            loadAppConfig()
        }
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if blockRotation{
            return UIInterfaceOrientationMask.all
        }else{
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    //推送服务注册成功时调用
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //let token = String.init(data: deviceToken, encoding: .)
//        print(deviceToken.description)
        let nsData = NSData(data: deviceToken)
        //print("推送服务注册成功,token=" + nsData.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: ""))
        //47e5c3bcbcc12aea61f6653940a730124d3f42db2681a8a804922319e34fd7f8
        //47e5c3bcbcc12aea61f6653940a730124d3f42db2681a8a804922319e34fd7f8
        JPUSHService.registerDeviceToken(deviceToken)
        
    }
    
    //推送服务注册失败时调用
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("推送服务注册失败...")
    }
    
    //当有消息推送到设备并且点击消息启动app时会调用
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("收到新消息Active\(userInfo)")
        if application.applicationState == .active{
            //表示从前台接受消息
            print("从前台接受消息")
        }else{
            //表示从后台接受消息后进入app
            print("从后台接受消息后进入app")
        }
        
    }
    
    
    //注册极光推送
    func registerJPushService(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        }else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        
        JPUSHService.setup(withOption: launchOptions,
                           appKey: "177ce40228242a0009b41965",
                           channel: "app store",
                           apsForProduction: true)

    }
    
    //注册推送服务
    func registerForPushNotifications(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        if #available(iOS 10.0, *){
            let notifiCenter = UNUserNotificationCenter.current()
            notifiCenter.delegate = self
            let types  = UNAuthorizationOptions(arrayLiteral: [.alert , .badge , .sound ])
            notifiCenter.requestAuthorization(options: types, completionHandler: {
                (flag, err) in
                if flag{
                    print("ios request notification success")
                }else{
                    print("ios 10 request notification fail")
                }
            })
            
        }else{
            let setting = UIUserNotificationSettings.init(types: [.alert , .badge , .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            //UIApplication.shared.scheduleLocalNotification()
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    //处理前台接受通知的代理方法
    @available(iOS 10.0 , *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        //print("userInfo 10 = \(userInfo)")
//        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler([.sound , .alert])
        
    }
    
    //处理后台点击通知的代理方法
    @available(iOS 10.0 , *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        //print("userInfo 10 = \(userInfo)")
        
        //处理本地消息通知
//        center.removeAllDeliveredNotifications()
//        center.removeAllPendingNotificationRequests()
        
        //print("bagge:\(UIApplication.shared.applicationIconBadgeNumber)")
//        UIApplication.shared.applicationIconBadgeNumber = 0
        //print("bagge:\(UIApplication.shared.applicationIconBadgeNumber)")
        
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
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func loadAppConfig(){
        
        
        let rootView = self.window?.rootViewController
        
        //如果没登录 则不去查询
        if r_token == ""{
            return
        }
        
        
        if loadAppConfigFailedCount > 10 {
            myAlert(rootView!, message: "请求配置异常,请联系网络管理员!")
            loadAppConfigFailedCount = 0
            return
        }
        
        let url = SERVER_PORT+"rest/app/systemConfigData.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let data = json["data"]
                    print(json)
                    UserDefaults.AppConfig.set(value: data["投诉功能名称"].description, forKey:.complaintTitle)
                    UserDefaults.AppConfig.set(value: data["教学计划未提报通知时间"].description, forKey: .planNoticeTime)
                    UserDefaults.AppConfig.set(value: data["培训是否默认需要签到"].description, forKey: .trainingIsNeedCheckIn)
                    UserDefaults.AppConfig.set(value: data["教学活动学员评价老师默认评价表"].description, forKey:.teachingActivityS2TEvaluationList)
                    UserDefaults.AppConfig.set(value: data["教学活动老师评价学员默认评价表"].description, forKey:.teachingActivityT2SEvaluationList)
                    UserDefaults.AppConfig.set(value: data["教学计划未提报通知日期"].description, forKey:.planNoticeDate)
                    UserDefaults.AppConfig.set(value: data["客户代码"].description, forKey:.clientCode)
                    UserDefaults.AppConfig.set(value: data["观摩室观看考站编码"].description, forKey:.watchClassroomId)
                    UserDefaults.AppConfig.set(value: data["教学活动类型"].description, forKey:.teachingActivityType)
                    UserDefaults.AppConfig.set(value: data["通用评价表编码"].description, forKey:.publicEvaluationList)
                    UserDefaults.AppConfig.set(value: data["延迟签出分钟数"].description, forKey:.lateCheckOutMinutes)
                    UserDefaults.AppConfig.set(value: data["延迟签到分钟数"].description, forKey:.lateCheckInMinutes)
                    UserDefaults.AppConfig.set(value: data["发布培训通知延时时间（分钟）"].description, forKey:.trainingDelayNoticeMinutes)
                    UserDefaults.AppConfig.set(value: data["带教老师是否允许发科室公告"].description, forKey:.teacherAllowCreateDeptNotice)
                    UserDefaults.AppConfig.set(value: data["扫码签到是否需要拍照上传"].description, forKey:.scanCheckInTakePhoto)
                    UserDefaults.AppConfig.set(value: data["是否学员"].description, forKey:.isStudent)
                    UserDefaults.AppConfig.set(value: data["是否老师"].description, forKey:.isTeacher)
                    UserDefaults.AppConfig.set(value: data["是否秘书"].description, forKey:.isSecretary)
                    UserDefaults.AppConfig.set(value: data["签到机扫码拍照"].description, forKey:.checkInMachineTakePhoto)
                    UserDefaults.AppConfig.set(value: data["二维码失效时间"].description, forKey:.qrCodeExpireTime)
                    UserDefaults.AppConfig.set(value: data["科室清单"].description, forKey:.officeList)
                    
                    UserDefaults.AppConfig.set(value: data["科室清单"].description, forKey:.officeList)
                    UserDefaults.AppConfig.set(value: data["教室清单"].description, forKey:.classroomList)
                    UserDefaults.AppConfig.set(value: data["评价表清单"].description, forKey:.teachingActivityEvaluationList)
                    UserDefaults.AppConfig.set(value: data["是否开启Mini-CEX"].description, forKey:.isOpenMiniCex)
                    
                }else{
                    myAlert(rootView!, message: json["msg"].stringValue)
                }
                
                
                //缓存web模块 (这里存不了json数组 所以存string 后面自己转一下)
            //                                UserDefaults.standard.set(json["webmodule"].description, forKey: AppConfiguration.webModule.rawValue)
            case .failure(let error):
                //记录错误次数
                self.loadAppConfigFailedCount += 1
                //延迟2秒重新执行
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                    self.loadAppConfig()
                })
                print(error)
            }
            
        })
    }
    

}

extension AppDelegate : JPUSHRegisterDelegate{
    /**
     收到静默推送的回调
     
     @param application  UIApplication 实例
     @param userInfo 推送时指定的参数
     @param completionHandler 完成回调
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        //print("iOS7及以上系统，收到通知:\(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
        JPUSHService.setBadge(0)
        application.applicationIconBadgeNumber = 0
    }
    
    //    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
    //        JPUSHService.showLocalNotification(atFront: notification, identifierKey: nil)
    //    }
    //
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo
        
        //        let request = notification.request; // 收到推送的请求
        //        let content = request.content; // 收到推送的消息内容
        //
        //        let badge = content.badge;  // 推送消息的角标
        //        let body = content.body;    // 推送消息体
        //        let sound = content.sound;  // 推送消息的声音
        //        let subtitle = content.subtitle;  // 推送消息的副标题
        //        let title = content.title;  // 推送消息的标题
        
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            //print("iOS10 前台收到远程通知:\(userInfo)")
            JPUSHService.handleRemoteNotification(userInfo)
        }else {
            // 判断为本地通知
            //print("iOS10 前台收到本地通知:\(userInfo)")
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue | UNAuthorizationOptions.sound.rawValue | UNAuthorizationOptions.badge.rawValue))// 需要执行这个方法，选择是否提醒用户，有badge、sound、alert三种类型可以选择设置
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            //print("iOS10 收到远程通知:\(userInfo)")
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }
}

//    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
//        print(">JPUSHRegisterDelegate jpushNotificationCenter didReceive");
//        let userInfo = response.notification.request.content.userInfo
//        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
//            JPUSHService.handleRemoteNotification(userInfo)
//        }
//        completionHandler()
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
//
//
//    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
//
//        print(">JPUSHRegisterDelegate jpushNotificationCenter willPresent");
//        let userInfo = notification.request.content.userInfo
//        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
//            JPUSHService.handleRemoteNotification(userInfo)
//        }
//        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))// 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
//
//    }

