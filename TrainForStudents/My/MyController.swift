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
        
       
//        jds = JSON([["icon":"双箭头-右蓝","title":"切换至学生端","link":"tabBarView"],["icon":"紧急","title":"退出系统","link":"loginView"]]).arrayValue
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        var studentView = "tabBarView"
//        if UserDefaults.AppConfig.string(forKey: .isUseNewApp) == "1"{
//            studentView = "studentTabbar"
//        }
        
        jds = JSON([["icon":"双箭头-右蓝","title":"切换至学生端","link":"studentTabbar"],["icon":"人员-2","title":"我的学员","link":"myStudentView"],["icon":"紧急","title":"设置","link":"settingsView"]]).arrayValue
        //,["icon":"我的-选择","title":"修改个人资料","link":"changePersonInfoView"],
        view.bringSubview(toFront: messageCollection)
        let lbl_name = view.viewWithTag(10002) as! UILabel
        lbl_name.text = UserDefaults.User.string(forKey: .personName)
        if lbl_name.text == nil{
            lbl_name.text = ""
        }
        
        let jobNum = UserDefaults.User.string(forKey: .jobNum)
        let officeName = UserDefaults.standard.string(forKey: LoginInfo.officeName.rawValue)
        var lbl = view.viewWithTag(10003) as! UILabel
        //工号的x轴随名字长度变化
        lbl.setX(x: lbl_name.X + ((lbl_name.text?.getWidth())!) + (5))
        if jobNum != nil{
            lbl.text = "（工号：\(jobNum!)）"
        }
        
        lbl = view.viewWithTag(20001) as! UILabel
        if officeName != nil{
            lbl.text = "科室：\(officeName!)"
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
        
        return cell
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
                myPresentView(self, viewName: viewName)
                let tabBar = (appDelegate.window?.rootViewController) as! MyTabBarController
                tabBar.selectedIndex = 0
            }else if viewName == "tabBarView" || viewName == "studentTabbar"{
                appDelegate.window?.rootViewController = getViewToStoryboard(viewName)
            }else if viewName == "myStudentView"{
                let vc = MyStudentRootController()
                self.parent?.hidesBottomBarWhenPushed = true
                self.present(vc, animated: true, completion: nil)
            }else{
                myPresentView(self, viewName: viewName)
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 50)
    }
    
}
