//
//  IMOfficeGroupController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/3.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class IMOfficeGroupController : HBaseViewController{
    
    @IBOutlet weak var messageCollection: UICollectionView!
    
    var officeInfo = JSON()
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        messageCollection.delegate = self
        messageCollection.dataSource = self
        
        (view.viewWithTag(11111) as! UILabel).text = officeInfo["teamname"].stringValue
        
        self.messageCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        
        messageCollection.mj_header.beginRefreshing()
        
        var btn = view.viewWithTag(40001) as! UIButton
        btn.addTarget(self, action: #selector(btn_bottomBtnGroup_inside(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(40002) as! UIButton
        btn.addTarget(self, action: #selector(btn_bottomBtnGroup_inside(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(40003) as! UIButton
        btn.addTarget(self, action: #selector(btn_bottomBtnGroup_inside(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(40004) as! UIButton
        btn.addTarget(self, action: #selector(btn_bottomBtnGroup_inside(sender:)), for: .touchUpInside)
        
        
        MyNotificationUtil.addKeyBoardWillChangeNotification(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        messageCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //设置
    @IBAction func btn_setting_inside(_ sender: UIButton) {
        let vc = getViewToStoryboard("teamSettingView") as! TeamSettingController
        vc.office = officeInfo
        present(vc, animated: true, completion: nil)
    }
    
    func btn_bottomBtnGroup_inside(sender : UIButton){
        
        switch sender.tag {
        case 40001:
            //
            break
        default:
            break
        }
        
    }
    
    func getNoticeData(){
        
        let url = SERVER_PORT + "rest/app/queryTeamNotice.do"
        myPostRequest(url,["teamid":officeInfo["teamid"].stringValue ,"pageindex":0 ,"pagesize":1] ,method: .post).responseString(completionHandler: {resp in
            self.messageCollection.mj_header.endRefreshing()
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    var dataArr = json["data"].arrayValue
                    dataArr[0]["type"] = JSON(1)
                    self.jds.append(dataArr[0])
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取公告失败!")
                print(error)
                break
            }
            self.messageCollection.reloadData()
        })
        
    }
    
    func getListData(){
        //self.messageCollection.mj_header.endRefreshing()
        //messageCollection.reloadData()
        getNoticeData()
    }
    
    func refresh() {
        jds.removeAll()
        getListData()
    }

    
}

extension IMOfficeGroupController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let msgType = data["type"].intValue
        var cell = UICollectionViewCell()
        
        switch msgType {
        case 1: //公告
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noticeCell", for: indexPath)
            let content = cell.viewWithTag(30001) as! UILabel
            content.text = data["noticemsg"].stringValue
        case 2: //系统消息  如:加群,退群
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "systemMessageCell", for: indexPath)
        case 3: //非自己发送的消息
            break
        case 4: //自己发送的消息
            break
        default:
            break
        }
        
        return cell
    }
    
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hiddenKeyBoard()
        let data = jds[indexPath.item]
        if data["type"].intValue == 1{  //公告
            let vc = getViewToStoryboard("noticeDetailView") as! NoticeDetailController
            vc.noticeJson = JSON(data)
            present(vc, animated: true, completion: nil)
        }
    }
    
    //设置cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        let msgType = data["type"].intValue
        
        switch msgType {
        case 1: //公告
            return CGSize(width: UIScreen.width - 15, height: 100)
        case 2: //系统消息  如:加群,退群
            return CGSize(width: UIScreen.width, height: 20)
        case 3: //普通消息
            break
        default:
            break
        }
        return CGSize(width: UIScreen.width, height: 20)
    }
    
}
