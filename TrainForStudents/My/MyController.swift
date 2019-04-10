//
//  MyController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/2/20.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MyController : HBaseViewController{
    
    @IBOutlet weak var messageCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        messageCollection.delegate = self
        messageCollection.dataSource = self
        
        jds = JSON([["icon":"双箭头-右蓝","title":"切换至学生端","link":"studentTabbar"],["icon":"紧急","title":"退出系统","link":"loginView"]]).arrayValue
        
        
//        self.messageCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
//        self.messageCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.bringSubview(toFront: messageCollection)
        let lbl_name = view.viewWithTag(10002) as! UILabel
        lbl_name.text = UserDefaults.User.string(forKey: .personName)
        if lbl_name.text == nil{
            lbl_name.text = ""
        }
        
        let jobNum = UserDefaults.User.string(forKey: .jobNum)
        let majorName = UserDefaults.User.string(forKey: .majorName)
        var lbl = view.viewWithTag(10003) as! UILabel
        //工号的x轴随名字长度变化
        lbl.setX(x: lbl_name.X + ((lbl_name.text?.getWidth())!) + (5))
        if jobNum != nil{
            lbl.text = "（工号：\(jobNum!)）"
        }
        
        lbl = view.viewWithTag(20001) as! UILabel
        if majorName != nil{
            lbl.text = "科室：\(majorName!)"
        }
        
    }
    
    
    func getListData(){
        self.messageCollection.mj_header.endRefreshing()
        self.messageCollection.mj_footer.endRefreshing()
        messageCollection.reloadData()
    }
    
    func refresh() {
        jds.removeAll()
        messageCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension MyController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let icon = cell.viewWithTag(10001) as! UIImageView
        icon.image = UIImage(named: data["icon"].stringValue)
        let title = cell.viewWithTag(10002) as! UILabel
        title.text = data["title"].stringValue
        
        return
        cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = jds[indexPath.item]
        let viewName = data["link"].stringValue
        if viewName.count > 0 {
            if viewName == "loginView"{
                //退出系统
                UserDefaults.standard.set(nil, forKey: LoginInfo.token.rawValue)
                r_token = ""
            }
            myPresentView(self, viewName: viewName)
            let tabBar = (appDelegate.window?.rootViewController) as! MyTabBarController
            tabBar.selectedIndex = 0
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 50)
    }
    
}
