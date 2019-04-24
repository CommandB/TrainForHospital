//
//  StudentHomeController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/8.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class StudentHomeController : HBaseViewController, UINavigationControllerDelegate{
    
    @IBOutlet weak var homeCollection: UICollectionView!
    
    var officeTeamJds = [JSON]()
    var turnTaskJds = JSON()
    var taskJds = [JSON]()
    var messageCellLastIndex = 0
    let defaultCellCount = 4
    
    override func viewDidLoad() {
        
        homeCollection.delegate = self
        homeCollection.dataSource = self
        
        self.homeCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        
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
    
    func getListData(){
        self.homeCollection.mj_header.endRefreshing()
        self.homeCollection.mj_footer.endRefreshing()
        homeCollection.reloadData()
    }
    
    ///获取待办事项
    func getTurnTask(){
        let url = SERVER_PORT + "rest/app/getRoundStudentNowInfo.do"
        myPostRequest(url,  method: .post).responseString(completionHandler: {resp in
            
            self.homeCollection.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                print(json)
                if json["code"].stringValue == "1"{
                    if json["data"].arrayValue.count > 0{
                        self.turnTaskJds = json["data"].arrayValue[0]
                    }
                    
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取轮转信息异常!")
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
                    self.messageCellLastIndex = self.defaultCellCount + self.officeTeamJds.count
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
    
    @objc func refresh() {
        officeTeamJds.removeAll()
        getTask()
        getTurnTask()
        getOfficeTeamList()
    }
    
    
}

extension StudentHomeController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultCellCount + officeTeamJds.endIndex
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        switch indexPath.item {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "turnTaskCell", for: indexPath)
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
            
            (cell.viewWithTag(10001) as! UILabel).text = turnTaskJds["officename"].stringValue
            (cell.viewWithTag(10002) as! UILabel).text = turnTaskJds["roundstarttime"].stringValue + " ~ " + turnTaskJds["roundendtime"].stringValue
            (cell.viewWithTag(20001) as! UILabel).text = turnTaskJds["teachername"].stringValue
            (cell.viewWithTag(30001) as! UILabel).text = turnTaskJds["isovertheoryexam"].intValue == 0 ? "否" : "去"
            (cell.viewWithTag(30002) as! UILabel).text = turnTaskJds["isoverskillexam"].intValue == 0 ? "否" : "去"
            (cell.viewWithTag(40001) as! UILabel).text = turnTaskJds["evaluationsum"].arrayValue.description
            (cell.viewWithTag(40002) as! UILabel).text = turnTaskJds["traincount"].intValue.description
            
            break
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingCell", for: indexPath)
            if taskJds.count == 0 {
                let bg = cell.viewWithTag(11111) as! UILabel
                bg.text = "暂无待办"
                //bg置顶
                cell.bringSubview(toFront: bg)
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
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuresCell", for: indexPath)
            var btn = cell.viewWithTag(10001) as! UIButton
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10002) as! UIButton
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10003) as! UIButton
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10003) as! UIButton
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10004) as! UIButton
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            let btn4_title = UserDefaults.AppConfig.string(forKey: .complaintTitle)
            if btn4_title != nil && btn4_title != ""{
                btn.setTitle(btn4_title, for: .normal)
            }
            break
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classTitleCell", for: indexPath)
            break
        case defaultCellCount...messageCellLastIndex:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath)
            let data = officeTeamJds[indexPath.item - defaultCellCount]
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
        case defaultCellCount...messageCellLastIndex:
            let data = officeTeamJds[indexPath.item - defaultCellCount]
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
            return CGSize(width: UIScreen.width - (20), height: 150)
        case 1:
            return CGSize(width: UIScreen.width, height: 165)
        case 2:
            return CGSize(width: UIScreen.width, height: 120)
        case 3:
            return CGSize(width: UIScreen.width, height: 40)
        case defaultCellCount...messageCellLastIndex:
            return CGSize(width: UIScreen.width, height: 60)
        default:
            return CGSize(width: UIScreen.width, height: 100)
        }
    }
    
    ///跳转到待办事项
    @objc func presentToDoList(sender :UIButton){
        let vc = getViewToStoryboard("todoListView") as! ToDoListController
        present(vc, animated: true, completion: nil)
    }
    
    ///4个功能按钮
    @objc func btn_features_event(sender : UIButton){
        switch sender.tag - 10000 {
        case 1: //待考任务
            let vc = getViewToStoryboard("examListView") as! ExamListController
            vc.isInvigilation = false
            present(vc, animated: true, completion: nil)
            break
        case 10004:
            
            break
        case 2: //题目练习
            myPresentView(self, viewName: "exerciseCenterView")
            break
        case 3: //待评任务
            myPresentView(self, viewName: "evaluationItemList")
            break
        case 4://悄悄话
            myPresentView(self, viewName: "complaintListView")
            break
        default:
            break
        }
    }
    
}

extension StudentHomeController : UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let photo = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: {
            let vc = getViewToStoryboard("scannerView") as! ScannerViewController
            vc.uploadPhoto = photo
            self.present(vc, animated: true, completion: nil)
        })
        
    }
}
