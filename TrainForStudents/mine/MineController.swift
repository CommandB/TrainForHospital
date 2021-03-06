//
//  File.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/9.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MineController : HBaseViewController{
    
    @IBOutlet weak var messageCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        messageCollection.delegate = self
        messageCollection.dataSource = self
        
        
        
        jds = JSON([["icon":"我的-选择","title":"修改个人资料","link":"changePersonInfoView"],["icon":"紧急","title":"退出系统","link":"loginView"]]).arrayValue

        
        //        self.messageCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        //        self.messageCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !isOnlyStudent(){
            jds.insert(JSON(["icon":"双箭头-右蓝","title":"切换至老师端","link":"hTabBarView"]), at: 1)
        }
        
        let lbl_name = view.viewWithTag(10002) as! UILabel
        lbl_name.text = UserDefaults.User.string(forKey: .personName)
        if lbl_name.text == nil{
            lbl_name.text = ""
        }
        
        let jobNum = UserDefaults.User.string(forKey: .jobNum)
        let majorName = UserDefaults.User.string(forKey: .personcenterofficename)
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
    
    //获取我的二维码
    @IBAction func btn_qr_inside(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT+"rest/public/GenerateQRCode.do"
        myPostRequest(url,["type":"mycode"]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let qrCode = json["qrcode"].stringValue
                    HUtilView.showImageToTagetView(target: self.view, image: UIImage.createQR(text: qrCode, size: 240))
                }else{
                    myAlert(self, message: "获取我的二维码信息失败!")
                }
            case .failure(let error):
                print(error)
            }
            
        })
        
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

extension MineController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
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
            if viewName == "hTabBarView"{
                appDelegate.window?.rootViewController = getViewToStoryboard(viewName)
                return
            }
            if viewName == "loginView"{
                //退出系统
                UserDefaults.standard.set(nil, forKey: LoginInfo.token.rawValue)
                r_token = ""
            }
            myPresentView(self, viewName: viewName)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 50)
    }
    
}
