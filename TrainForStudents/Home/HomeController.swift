//
//  StudentsHome.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/7/23.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeController : HBaseViewController, UINavigationControllerDelegate{
    
    @IBOutlet weak var homeCollection: UICollectionView!
    
    var lbl_markLine: UILabel!
    
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    var officeTeamJds = [JSON]()
    var statisticJds = JSON()
    var taskJds = [JSON]()
    var teachingJds = [JSON]()
    var messageCellLastIndex = 0
    var selectedPanelKey = ""
    
    override func viewDidLoad() {
        
        homeCollection.delegate = self
        homeCollection.dataSource = self
        let btn = view.viewWithTag(10001) as! UIButton
        btn.addTarget(self, action: #selector(btn_message_event), for: .touchUpInside)
        
        homeCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeCollection.mj_header.beginRefreshing()
    }
    
    //扫一扫
    @IBAction func btn_scanner_inside(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        if LBXPermissions.isGetPhotoPermission() {
            let takePhoto = UserDefaults.AppConfig.string(forKey: .scanCheckInTakePhoto)
            if takePhoto == "0" || true{    //暂时不需要拍照 直接扫码
                //不需要照片则直接打开扫码界面
                let vc = getViewToStoryboard("scannerView") as! ScannerViewController
                self.present(vc, animated: true, completion: nil)
            }else{
                //先拍照在扫码
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
        }else{
            myAlert(self, message: "没有相机权限")
        }
        
    }
    
    ///跳转到消息列表
    @objc func btn_message_event(){
        //myPresentView(self, viewName: "messageListView")
        //UIApplication.shared.openURL(URL.init(string: "telprompt:13616543097")!)
    }
    
    ///跳转到待办事项
    @objc func presentToDoList(sender :UIButton){
        let vc = getViewToStoryboard("todoListView") as! ToDoListController
//        if (sender.restorationIdentifier?.contains("task"))!{
//            vc.dataArr = taskJds
//        }else{
//            vc.dataArr = teachingJds
//        }
        present(vc, animated: true, completion: nil)
    }
    
    ///6个功能按钮
    @objc func btn_features_event(sender : UIButton){
        switch sender.tag - 10000 {
        case 1: //360评价
            if UserDefaults.AppConfig.string(forKey: .panoramicEvaluationAvailable) == "1"{
                myPresentView(self, viewName: "panoramicEvaluationView")
            }else{
                myAlert(self, message: "暂无使用权限")
            }
            
            break
        case 2: //出科理论考试
            if UserDefaults.AppConfig.string(forKey: .subjectTheoryAvailable) == "1"{
                let vc = getViewToStoryboard("publishSubjectExamView") as! PublishSubjectExamController
                vc.isSkillExam = false
                present(vc, animated: true, completion: nil)
            }else{
                myAlert(self, message: "暂无使用权限")
            }
            
            break
        case 3: //出科技能考试
            if UserDefaults.AppConfig.string(forKey: .subjectSkillAvailable) == "1"{
                let vc = getViewToStoryboard("publishSubjectExamView") as! PublishSubjectExamController
                vc.isSkillExam = true
                present(vc, animated: true, completion: nil)
            }else{
                myAlert(self, message: "暂无使用权限")
            }
            break
        case 4://入科安排
//                        myPresentView(self, viewName: "evaluationItemList")
//            myAlert(self, message: "暂未开放!")
            let vc = getViewToStoryboard("joinOfficeView") as! JoinOfficeController
            self.present(vc, animated: true, completion: nil)
            break
        case 5:
            let vc = getViewToStoryboard("examListView") as! ExamListController
            vc.isInvigilation = true
            present(vc, animated: true, completion: nil)
            break
        case 6:
            //现场技能考试
            myPresentView(self, viewName: "publishStillView")
            
            break
        default:
            break
        }
    }
    
    ///获取最上方教学活动的统计数据
    func getStatisticData(){
        
        let url = SERVER_PORT + "rest/app/getHomeInfo.do"
        myPostRequest(url,  method: .post).responseString(completionHandler: {resp in
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.statisticJds = json
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取统计数据异常!")
                print(error)
                break
            }
            self.homeCollection.reloadData()
        })
    }
    
    ///获取待办事项
    func getTask(){
        let url = SERVER_PORT + "rest/app/getMyTask.do"
        myPostRequest(url, ["task_state":"0" ,"pageindex":0 ,"pagesize":100],  method: .post).responseString(completionHandler: {resp in
            
            self.homeCollection.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)

                if json["code"].stringValue == "1"{
                    self.taskJds = json["data"].arrayValue
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取待办任务异常!")
                print(error)
                break
            }
            self.homeCollection.reloadData()
        })
    }
    
    //我的带教
    func getTeaching(){
        let url = SERVER_PORT + "rest/task/queryTeacherTask.do"
        myPostRequest(url, ["task_state":"1,2" ,"pageindex":0 ,"pagesize":100],  method: .post).responseString(completionHandler: {resp in
            
            self.homeCollection.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                //                print(json)
                if json["code"].stringValue == "1"{
                    self.teachingJds = json["data"].arrayValue
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取带教任务异常!")
                print(error)
                break
            }
            self.homeCollection.reloadData()
        })
    }
    
    ///获取科室社群列表
    func getOfficeTeamList(){
        
        let url = SERVER_PORT + "rest/app/getTeamList.do"
        myPostRequest(url,  method: .post).responseString(completionHandler: {resp in
            
            self.homeCollection.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.officeTeamJds = json["data"].arrayValue
                    self.messageCellLastIndex = 5 + self.officeTeamJds.count
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取社群列表异常!")
                print(error)
                break
            }
            self.homeCollection.reloadData()
        })
        
    }
    
    //第一栏 的更多按钮
    @objc func showMoreTeachingData(){
        let vc = getViewToStoryboard("teachingStatisticsView") as! TeachingStatisticsController
        vc.jds = statisticJds[selectedPanelKey].arrayValue
        present(vc, animated: true, completion: nil)
    }
    //第一栏 顶部两个按钮 切换老师和秘书的统计面板
    @objc func panelSwitch(sender : UIButton){
        selectedPanelKey = sender.restorationIdentifier!
        tabsTouchAnimation(sender: sender)
        self.homeCollection.reloadData()
        
    }
    
    @objc func refresh() {
        officeTeamJds.removeAll()
        getTask()
        getOfficeTeamList()
        getStatisticData()
//        getTeaching()
    }
    
    func tabsTouchAnimation( sender : UIButton){
        //-----------------计算 "下标线"label的动画参数
        
        for b in buttonGroup {
            if b == sender{
                b.alpha = 1
            }else{
                b.alpha = 0.7
            }
        }
        
        let btn_x = sender.frame.origin.x                      //按钮x轴
        let btn_middle = sender.frame.size.width / 2           //按钮中线
        let lbl_half = lbl_markLine.frame.size.width / 2       //下标线的一半宽度
        //计算下标线的x轴位置
        let target_x = btn_x + btn_middle - lbl_half
        let target_y = lbl_markLine.frame.origin.y
        
        //动画开始
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        lbl_markLine.frame = CGRect(origin: CGPoint(x:target_x,y:target_y), size: lbl_markLine.frame.size)
        
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
        
    }
    
}

extension HomeController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 + officeTeamJds.endIndex
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        switch indexPath.item {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statisticCell", for: indexPath)
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
            lbl_markLine = cell.viewWithTag(10003) as! UILabel
            lbl_markLine.clipsToBounds = true
            lbl_markLine.layer.cornerRadius = 1
            if statisticJds.isEmpty{
                break
            }
            
            
            let btn_panel_1 = cell.viewWithTag(10001) as! UIButton
            let btn_panel_2 = cell.viewWithTag(10002) as! UIButton
            buttonGroup = [btn_panel_1 ,btn_panel_2]
            
            if selectedPanelKey.isEmpty{
                lbl_markLine.setX(x: btn_panel_1.X + 20)
            }
            
            btn_panel_1.addTarget(self, action: #selector(panelSwitch), for: .touchUpInside)
            btn_panel_2.addTarget(self, action: #selector(panelSwitch), for: .touchUpInside)
            if statisticJds["teacherpanel"].arrayValue.count > 0{
                btn_panel_1.restorationIdentifier = "teacherpanel"
                btn_panel_1.isHidden = false
                btn_panel_1.isEnabled = true
                btn_panel_1.setX(x: 50)
                selectedPanelKey = selectedPanelKey == "" ? "teacherpanel" : selectedPanelKey
            }
            
            if  statisticJds["secretarypanel"].arrayValue.count > 0{
                if btn_panel_1.isHidden{
                    btn_panel_1.restorationIdentifier = "secretarypanel"
                    btn_panel_1.isHidden = false
                    btn_panel_1.isEnabled = true
                    selectedPanelKey = "secretarypanel"
                    //如果秘书面板没有数据 则把老师面板的按钮居中
                    btn_panel_1.setX(x: (collectionView.W - btn_panel_1.W) / 2)
                    lbl_markLine.setX(x: (collectionView.W - lbl_markLine.W) / 2)
                }else{
                    btn_panel_2.restorationIdentifier = "secretarypanel"
                    btn_panel_2.isHidden = false
                    btn_panel_2.isEnabled = true
                }
            }else{
                btn_panel_2.isHidden = true
                //如果秘书面板没有数据 则把老师面板的按钮居中
                btn_panel_1.setX(x: (collectionView.W - btn_panel_1.W) / 2)
                lbl_markLine.setX(x: (collectionView.W - lbl_markLine.W) / 2)
            }
            
            for i in 0...4{
                if i >= statisticJds[selectedPanelKey].arrayValue.count{
                    break
                }
                let data = statisticJds[selectedPanelKey].arrayValue[i]
                (cell.viewWithTag(20001 + i) as! UILabel).text = data["times"].stringValue
                (cell.viewWithTag(30001 + i) as! UIButton).setTitle(data["traintypename"].stringValue, for: .normal)
            }
            
            (cell.viewWithTag(30006) as! UIButton).addTarget(self, action: #selector(showMoreTeachingData), for: .touchUpInside)
            break
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingCell", for: indexPath)
            if taskJds.count == 0 {
                let bg = cell.viewWithTag(11111) as! UILabel
                bg.text = "暂无待办"
                //bg置顶
                cell.bringSubview(toFront: bg)
                (cell.viewWithTag(10001) as! UIButton).setTitle("", for: .normal)
                (cell.viewWithTag(10002) as! UIButton).setTitle("", for: .normal)
                (cell.viewWithTag(20001) as! UILabel).text = ""
                (cell.viewWithTag(30001) as! UILabel).text = ""
                (cell.viewWithTag(40001) as! UILabel).text = ""
                break
            }
            let data = taskJds[0]
            let bg = cell.viewWithTag(11111) as! UILabel
            bg.text = ""
            //bg置底
            cell.sendSubview(toBack: bg)
            bg.clipsToBounds = true
            bg.layer.cornerRadius = 8
            var btn = cell.viewWithTag(10001) as! UIButton
            btn.addTarget(self, action: #selector(presentToDoList), for: .touchUpInside)
            btn.setTitle(taskJds.count.description, for: .normal)
            btn.restorationIdentifier = "btn_task1"
            btn = cell.viewWithTag(10002) as! UIButton
            btn.addTarget(self, action: #selector(presentToDoList), for: .touchUpInside)
            btn.restorationIdentifier = "btn_task2"
            
            (cell.viewWithTag(20001) as! UILabel).text = "[\(data["tasktype"].stringValue)]\(data["title"].stringValue)"
            //(cell.viewWithTag(20002) as! UILabel).text = ""
            (cell.viewWithTag(30001) as! UILabel).text = "时间:\(data["starttime"].stringValue)"
            (cell.viewWithTag(40001) as! UILabel).text = "地址:\(data["addressname"].stringValue)"
            
            break
        case 2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingCell", for: indexPath)
            if teachingJds.count == 0 {
                break
            }
            let data = teachingJds[0]
            let bg = cell.viewWithTag(11111) as! UILabel
            bg.clipsToBounds = true
            bg.layer.cornerRadius = 8
            var btn = cell.viewWithTag(10001) as! UIButton
            btn.addTarget(self, action: #selector(presentToDoList), for: .touchUpInside)
            btn.setTitle(teachingJds.count.description, for: .normal)
            btn.restorationIdentifier = "btn_teaching1"
            btn = cell.viewWithTag(10002) as! UIButton
            btn.addTarget(self, action: #selector(presentToDoList), for: .touchUpInside)
            btn.restorationIdentifier = "btn_teaching2"
            
            (cell.viewWithTag(20001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(20002) as! UILabel).text = ""
            (cell.viewWithTag(30001) as! UILabel).text = "时间:\(data["starttime_show"].stringValue)"
            (cell.viewWithTag(40001) as! UILabel).text = "地址:\(data["addr"].stringValue)"
            
            break
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuresCell", for: indexPath)
            var btn = cell.viewWithTag(10001) as! UIButton
            btn.set(image: nil, title: "360评价", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10002) as! UIButton
            btn.set(image: nil, title: "出科理论考试", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10003) as! UIButton
            btn.set(image: nil, title: "出科技能考试", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10004) as! UIButton
            btn.set(image: nil, title: "入科安排", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10005) as! UIButton
            btn.set(image: nil, title: "监考任务", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10006) as! UIButton
            btn.set(image: nil, title: "现场考试", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            break
        case 4:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classTitleCell", for: indexPath)
            break
        case 5...messageCellLastIndex:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath)
            let data = officeTeamJds[indexPath.item - 5]
            let btn_headShow = cell.viewWithTag(10001) as! UIButton
            btn_headShow.clipsToBounds = true
            btn_headShow.layer.cornerRadius = btn_headShow.frame.width / 2
            
            var lbl = cell.viewWithTag(10002) as! UILabel
            lbl.text = data["teamname"].stringValue
            lbl = cell.viewWithTag(10003) as! UILabel
            lbl.text = ""
            let lastMsgDateStr = data["lastmsgtime"].stringValue.substring(from: 0).substring(to: 18)
            let lastMsgDate = DateUtil.stringToDateTime(lastMsgDateStr)
            if lastMsgDate.isYesterday{
                lbl.text = "昨天 "
            }else {
                if !lastMsgDate.isToday{
                    lbl.text = "\(lastMsgDate.month)-\(lastMsgDate.day) "
                }
            }
            lbl.text = "\(lbl.text!)\(lastMsgDate.hour):\(lastMsgDate.minute)"
            
            lbl = cell.viewWithTag(20001) as! UILabel
            lbl.text = data["lastmsg"].stringValue
            lbl = cell.viewWithTag(20002) as! UILabel
            lbl.clipsToBounds = true
            lbl.layer.cornerRadius = lbl.frame.width / 2
            lbl.isHidden = true
            break
        default:
            print("怎么到这里起来了..")
            break
        }
        
        return cell
    }
    
    //cell选中
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 1,2:
//            let cell = collectionView.cellForItem(at: indexPath)
//            let bg = cell?.viewWithTag(11111)
//            if bg?.backgroundColor != UIColor.orange{
//                bg?.backgroundColor = UIColor.orange
//                let redPointTag = HUtilView.addRedPoint(view:bg!)
//                bg?.restorationIdentifier = redPointTag.description
//            }else{
//                bg?.backgroundColor = UIColor(hex: "3186E9")
//                let tag = Int(bg?.restorationIdentifier ?? "0")
//                HUtilView.removeRedPoint(tag: tag!)
//            }
            
            //collectionView.reloadItems(at: [indexPath])
            break
        case 5...messageCellLastIndex:
            let data = officeTeamJds[indexPath.item - 5]
            let vc = getViewToStoryboard("officeGroupView") as! IMOfficeGroupController
            vc.officeInfo = data
            present(vc, animated: true, completion: nil)
            
            break
        default:
            break
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.item {
        case 0:
            return CGSize(width: UIScreen.width - (20), height: 200)
        case 1:
//            if taskJds.count > 0{
                return CGSize(width: UIScreen.width, height: 165)
//            }else{
//                return CGSize(width: UIScreen.width, height: 0)
//            }
        case 2:
            if teachingJds.count > 0{
                return CGSize(width: UIScreen.width, height: 165)
            }else{
                return CGSize(width: UIScreen.width, height: 0)
            }
        case 3:
            return CGSize(width: UIScreen.width, height: 160)
        case 4:
            return CGSize(width: UIScreen.width, height: 40)
        case 5...messageCellLastIndex:
            return CGSize(width: UIScreen.width, height: 60)
        default:
            return CGSize(width: UIScreen.width, height: 100)
        }
    }
    
}

extension HomeController : UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let photo = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: {
            let vc = getViewToStoryboard("scannerView") as! ScannerViewController
            vc.uploadPhoto = photo
            self.present(vc, animated: true, completion: nil)
        })
        
    }
}

