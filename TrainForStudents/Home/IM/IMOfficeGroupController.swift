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
        //self.messageCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func btn_bottomBtnGroup_inside(sender : UIButton){
        
        switch sender.tag {
        case 40001:
            let vc = getViewToStoryboard("createNoticeView") as! CreateNoticeController
            vc.office = officeInfo
            present(vc, animated: true, completion: nil)
        default:
            break
        }
        
    }
    
    func getListData(){
        self.messageCollection.mj_header.endRefreshing()
        messageCollection.reloadData()
    }
    
    func refresh() {
        //jds.removeAll()
        getListData()
    }

    
}

extension IMOfficeGroupController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //let data = jds[indexPath.item]
        var cell = UICollectionViewCell()
        if indexPath.item == 0{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noticeCell", for: indexPath)
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "systemMessageCell", for: indexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hiddenKeyBoard()
        if indexPath.item == 0{
            let fakeData = ["teamid":officeInfo["teamid"].stringValue ,"msg":"我们是共产主义接班人..你们是资本主义接班人..我们是共产主义接班人..你们是资本主义接班人..我们是共产主义接班人..你们是资本主义接班人..我们是共产主义接班人..你们是资本主义接班人..我们是共产主义接班人..你们是资本主义接班人.."]
            let vc = getViewToStoryboard("noticeDetailView") as! NoticeDetailController
            vc.noticeJson = JSON(fakeData)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0{
            return CGSize(width: UIScreen.width - 15, height: 100)
        }else{
            return CGSize(width: UIScreen.width, height: 20)
        }
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 55)
    }
    
}
