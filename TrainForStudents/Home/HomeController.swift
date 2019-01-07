//
//  StudentsHome.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/7/23.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeController : UIViewController{
    
    @IBOutlet weak var homeCollection: UICollectionView!
    var officeTeamJds = [JSON]()
    var messageCellLastIndex = 0
    
    override func viewDidLoad() {
        
        homeCollection.delegate = self
        homeCollection.dataSource = self
        let btn = view.viewWithTag(10001) as! UIButton
        btn.addTarget(self, action: #selector(btn_message_event), for: .touchUpInside)
        
        homeCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        
        getOfficeTeamList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeCollection.reloadData()
    }
    
    ///跳转到消息列表
    func btn_message_event(){
        //myPresentView(self, viewName: "messageListView")
        //UIApplication.shared.openURL(URL.init(string: "telprompt:13616543097")!)
    }
    
    ///跳转到待办事项
    func presentToDoList(){
        myPresentView(self, viewName: "todoListView")
    }
    
    ///6个功能按钮
    func btn_features_event(sender : UIButton){
        switch sender.tag - 10000 {
        case 1: //360评价
            myPresentView(self, viewName: "panoramicEvaluationView")
            break
        case 2: //出科理论考试
            let vc = getViewToStoryboard("publishSubjectExamView") as! PublishSubjectExamController
            vc.isSkillExam = false
            present(vc, animated: true, completion: nil)
            break
        case 3: //出科技能考试
            let vc = getViewToStoryboard("publishSubjectExamView") as! PublishSubjectExamController
            vc.isSkillExam = true
            present(vc, animated: true, completion: nil)
            break
        case 4:
            myAlert(self, message: "暂未开放!")
            break
        case 5:
            myAlert(self, message: "暂未开放!")
            break
        case 6:
            myAlert(self, message: "暂未开放!")
            break
        default:
            break
        }
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
    
    func refresh() {
        officeTeamJds.removeAll()
        getOfficeTeamList()
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
            var btn = cell.viewWithTag(30001) as! UIButton
            btn.set(image: nil, title: "考试未通过", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(30002) as! UIButton
            btn.set(image: nil, title: "缺勤天数", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(30003) as! UIButton
            btn.set(image: nil, title: "科室满意度", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(50001) as! UIButton
            btn.set(image: nil, title: "师资绩效积分", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
            btn = cell.viewWithTag(50002) as! UIButton
            btn.set(image: nil, title: "带教统计", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
            btn = cell.viewWithTag(50003) as! UIButton
            btn.set(image: nil, title: "待评事件", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
            break
        case 1,2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingCell", for: indexPath)
            let bg = cell.viewWithTag(11111) as! UILabel
            bg.clipsToBounds = true
            bg.layer.cornerRadius = 8
            var btn = cell.viewWithTag(10001) as! UIButton
            btn.addTarget(self, action: #selector(presentToDoList), for: .touchUpInside)
            btn = cell.viewWithTag(10002) as! UIButton
            btn.addTarget(self, action: #selector(presentToDoList), for: .touchUpInside)
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
            btn.set(image: nil, title: "考情登记", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn.addTarget(self, action: #selector(btn_features_event), for: .touchUpInside)
            btn = cell.viewWithTag(10006) as! UIButton
            btn.set(image: nil, title: "学员轮转", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
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
            btn_headShow.layer.cornerRadius = btn_headShow.frame.width.divided(by: 2)
            
            var lbl = cell.viewWithTag(10002) as! UILabel
            lbl.text = data["teamname"].stringValue
            lbl = cell.viewWithTag(10003) as! UILabel
            lbl = cell.viewWithTag(20001) as! UILabel
            lbl.text = data["lastmsg"].stringValue
            lbl = cell.viewWithTag(20002) as! UILabel
            lbl.clipsToBounds = true
            lbl.layer.cornerRadius = lbl.frame.width.divided(by: 2)
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
            let cell = collectionView.cellForItem(at: indexPath)
            let bg = cell?.viewWithTag(11111)
            if bg?.backgroundColor != UIColor.orange{
                bg?.backgroundColor = UIColor.orange
                let redPointTag = HUtilView.addRedPoint(view:bg!)
                bg?.restorationIdentifier = redPointTag.description
            }else{
                bg?.backgroundColor = UIColor(hex: "3186E9")
                let tag = Int(bg?.restorationIdentifier ?? "0")
                HUtilView.removeRedPoint(tag: tag!)
            }
            
            //collectionView.reloadItems(at: [indexPath])
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
            return CGSize(width: UIScreen.width.subtracting(20), height: 200)
        case 1,2:
            return CGSize(width: UIScreen.width, height: 165)
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
