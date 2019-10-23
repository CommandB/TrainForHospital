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
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    //支持当前controller横屏
    var blockRotation = false
    
    let testAppKey = "25980468"
    let testAppSecret = "2dbaabbe9ce6c058d4f44ea4b85d46c7"
    
    fileprivate var loadAppConfigFailedCount = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.applicationIconBadgeNumber = 0;
        // Override point for customization after application launch.
        
        // APNs注册，获取deviceToken并上报
        registerAPNs(application)
        // 初始化阿里云推送SDK
        initCloudPushSDK()
        // 监听推送通道打开动作
        listenOnChannelOpened()
        // 监听推送消息到达
        registerMessageReceive()
        // 点击通知将App从关闭状态启动时，将通知打开回执上报
        //CloudPushSDK.handleLaunching(launchOptions)(Deprecated from v1.8.1)
        CloudPushSDK.sendNotificationAck(launchOptions)
        
        
        //注册3D Touch
        //UIApplicationShortcutIcon(type: .capturePhoto)
        let scanIcon = UIApplicationShortcutIcon(templateImageName: "扫一扫")
        let scanItem = UIApplicationShortcutItem(type: "scan", localizedTitle: "扫码签到", localizedSubtitle: nil , icon: scanIcon, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [scanItem]
        
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
//        print("applicationDidBecomeActive.......start")
        //判断缓存中是否存在token
        let token = UserDefaults.standard.string(forKey: LoginInfo.token.rawValue)
        if token == nil{
            myPresentView((self.window?.rootViewController)!, viewName: "loginView")
        }else{
            if isOnlyStudent(){
//                if UserDefaults.AppConfig.string(forKey: .isUseNewApp) == "1"{
                    let vc = getViewToStoryboard("studentTabbar")
                    if self.window?.rootViewController?.classForCoder.description() != vc.classForCoder.description(){
                        self.window?.rootViewController = vc
                    }
//                }else{
//                    let vc = getViewToStoryboard("tabBarView")
//                    if self.window?.rootViewController?.classForCoder.description() != vc.classForCoder.description(){
//                        self.window?.rootViewController = vc
//                    }
//                }
            }
            
            loadAppConfigFailedCount = 0
            loadAppConfig()
        }
//        print("applicationDidBecomeActive.......end")
        
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
    
    // APNs注册成功
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Get deviceToken from APNs success.")
        CloudPushSDK.registerDevice(deviceToken) { (res) in
            if (res!.success) {
                print("Upload deviceToken to Push Server, deviceToken: \(CloudPushSDK.getApnsDeviceToken()!)")
            } else {
                print("Upload deviceToken to Push Server failed, error: \(String(describing: res?.error))")
            }
        }
    }
    
    // APNs注册失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Get deviceToken from APNs failed, error: \(error).")
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
    
    // App处于启动状态时，通知打开回调（< iOS 10）
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Receive one notification.")
        let aps = userInfo["aps"] as! [AnyHashable : Any]
        let alert = aps["alert"] ?? "none"
        let badge = aps["badge"] ?? 0
        let sound = aps["sound"] ?? "none"
        let extras = userInfo["Extras"]
        // 设置角标数为0
        application.applicationIconBadgeNumber = 0;
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        CloudPushSDK.sendNotificationAck(userInfo)
        print("Notification, alert: \(alert), badge: \(badge), sound: \(sound), extras: \(String(describing: extras)).")
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
//                    print(json)
                    self.saveConfigToCache(data: data)
                    
                }else{
                    //token无效,请重新登录!
                    myAlert(rootView!, message: json["msg"].stringValue, handler: { action in
                        
                        if json["msg"].stringValue == "token无效,请重新登录!" {
                            myPresentView((self.window?.rootViewController)!, viewName: "loginView")
                        }
                        
                    })
                    
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
    
    func saveConfigToCache(data : JSON){
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
        UserDefaults.AppConfig.set(value: data["二维码失效时间"].description, forKey:.qrCodeInvalidTime)
        UserDefaults.AppConfig.set(value: data["科室清单"].description, forKey:.officeList)
        
        UserDefaults.AppConfig.set(value: data["教室清单"].description, forKey:.classroomList)
        UserDefaults.AppConfig.set(value: data["评价表清单"].description, forKey:.teachingActivityEvaluationList)
        UserDefaults.AppConfig.set(value: data["是否开启Mini-CEX"].description, forKey:.isOpenMiniCex)
        UserDefaults.AppConfig.set(value: data["专业基地清单"].description, forKey:.majorList)
        UserDefaults.AppConfig.set(value: data["职称清单"].description, forKey:.professionalList)
        UserDefaults.AppConfig.set(value: data["学历清单"].description, forKey:.highestdegreeList)
        UserDefaults.AppConfig.set(value: data["年级清单"].description, forKey:.gradeList)
        UserDefaults.AppConfig.set(value: data["届别清单"].description, forKey:.gradeYearList)
        UserDefaults.AppConfig.set(value: data["学员类型清单"].description, forKey:.studentTypeList)
        UserDefaults.AppConfig.set(value: data["分组清单"].description, forKey:.personGroupList)
        
        UserDefaults.AppConfig.set(value: data["使用新版本APP"].description, forKey:.isUseNewApp)
        UserDefaults.AppConfig.set(value: data["360评价是否使用"].description, forKey:.panoramicEvaluationAvailable)
        UserDefaults.AppConfig.set(value: data["出科理论是否使用"].description, forKey:.subjectTheoryAvailable)
        UserDefaults.AppConfig.set(value: data["出科技能是否使用"].description, forKey:.subjectSkillAvailable)
        UserDefaults.AppConfig.set(value: data["标签清单"].description, forKey:.tagList)
        UserDefaults.AppConfig.set(value: data["入科是否需要指定责任护士"].description, forKey:.selectNurseOfJoinOffice)
        UserDefaults.AppConfig.set(value: data["浙二视频转发IP"].description, forKey:.zeyyVideoIP)
        
    }
    

}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    // App处于前台时收到通知(iOS 10+)
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Receive a notification in foreground.")
        handleiOS10Notification(notification)
        // 通知不弹出
//        completionHandler([])
        // 通知弹出，且带有声音、内容和角标
        completionHandler([.alert, .badge, .sound])
    }
    
    // 触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userAction = response.actionIdentifier
        if userAction == UNNotificationDefaultActionIdentifier {
            print("User opened the notification.")
            // 处理iOS 10通知，并上报通知打开回执
            handleiOS10Notification(response.notification)
        }
        
        if userAction == UNNotificationDismissActionIdentifier {
            print("User dismissed the notification.")
        }
        
        let customAction1 = "action1"
        let customAction2 = "action2"
        if userAction == customAction1 {
            print("User touch custom action1.")
        }
        
        if userAction == customAction2 {
            print("User touch custom action2.")
        }
        
        completionHandler()
    }
    
    // 处理iOS 10通知(iOS 10+)
    @available(iOS 10.0, *)
    func handleiOS10Notification(_ notification: UNNotification) {
        let content: UNNotificationContent = notification.request.content
        let userInfo = content.userInfo
        // 通知时间
        let noticeDate = notification.date
        // 标题
        let title = content.title
        // 副标题
        let subtitle = content.subtitle
        // 内容
        let body = content.body
        // 角标
        let badge = content.badge ?? 0
        // 取得通知自定义字段内容，例：获取key为"Extras"的内容
        let extras = userInfo["Extras"]
        // 设置角标数为0
        UIApplication.shared.applicationIconBadgeNumber = 0
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        // 通知打开回执上报
        CloudPushSDK.sendNotificationAck(userInfo)
        print("Notification, date: \(noticeDate), title: \(title), subtitle: \(subtitle), body: \(body), badge: \(badge), extras: \(String(describing: extras)).")
    }
    
    /* 同步角标数到服务端 */
    func syncBadgeNum(_ badgeNum: UInt) {
        CloudPushSDK.syncBadgeNum(badgeNum) { (res) in
            if (res!.success) {
                print("Sync badge num: [\(badgeNum)] success")
            } else {
                print("Sync badge num: [\(badgeNum)] failed, error: \(String(describing: res?.error))")
            }
        }
    }
    
    
}

//推送相关的注册
extension AppDelegate{
    
    // 向APNs注册，获取deviceToken用于推送
    func registerAPNs(_ application: UIApplication) {
        if #available(iOS 10, *) {
            // iOS 10+
            let center = UNUserNotificationCenter.current()
            // 创建category，并注册到通知中心
            createCustomNotificationCategory()
            center.delegate = self
            // 请求推送权限
            center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                if (granted) {
                    // User authored notification
                    print("User authored notification.")
                    // 向APNs注册，获取deviceToken
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    // User denied notification
                    print("User denied notification.")
                }
            })
        } else if #available(iOS 8, *) {
            // iOS 8+
            application.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil))
            application.registerForRemoteNotifications()
        } else {
            // < iOS 8
            application.registerForRemoteNotifications(matching: [.alert,.badge,.sound])
        }
    }
    
    // 创建自定义category，并注册到通知中心
    @available(iOS 10, *)
    func createCustomNotificationCategory() {
        let action1 = UNNotificationAction.init(identifier: "action1", title: "test1", options: [])
        let action2 = UNNotificationAction.init(identifier: "action2", title: "test2", options: [])
        let category = UNNotificationCategory.init(identifier: "test_category", actions: [action1, action2], intentIdentifiers: [], options: UNNotificationCategoryOptions.customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // 初始化推送SDK
    func initCloudPushSDK() {
        // 打开Log，线上建议关闭
        CloudPushSDK.turnOnDebug()
        CloudPushSDK.asyncInit(testAppKey, appSecret: testAppSecret) { (res) in
            if (res!.success) {
                print("Push SDK init success, deviceId: \(CloudPushSDK.getDeviceId()!)")
            } else {
                print("Push SDK init failed, error: \(res!.error!).")
            }
        }
    }
    
    // 监听推送通道是否打开
    func listenOnChannelOpened() {
        let notificationName = Notification.Name("CCPDidChannelConnectedSuccess")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(channelOpenedFunc(notification:)),
                                               name: notificationName,
                                               object: nil)
    }
    
    @objc func channelOpenedFunc(notification : Notification) {
        print("Push SDK channel opened.")
    }
    
    // 注册消息到来监听
    func registerMessageReceive() {
        let notificationName = Notification.Name("CCPDidReceiveMessageNotification")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMessageReceivedFunc(notification:)),
                                               name: notificationName,
                                               object: nil)
    }
    
    // 处理推送消息
    @objc func onMessageReceivedFunc(notification : Notification) {
        print("Receive one message.")
        let pushMessage: CCPSysMessage = notification.object as! CCPSysMessage
        let title = String.init(data: pushMessage.title, encoding: String.Encoding.utf8)
        let body = String.init(data: pushMessage.body, encoding: String.Encoding.utf8)
        print("Message title: \(title!), body: \(body!).")
    }
    
}


