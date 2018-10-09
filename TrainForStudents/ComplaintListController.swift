//
//  ComplaintListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/9/27.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ComplaintListController : MyBaseUIViewController{
    
    
    @IBOutlet weak var complaintCollection: UICollectionView!
    
    @IBOutlet weak var addView: UIView!
    
    let complaintView = ComplaintListCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barView = view.viewWithTag(11111)
        let titleView = view.viewWithTag(22222) as! UILabel
        let title = UserDefaults.standard.string(forKey: AppConfiguration.complaintTitle.rawValue)
        super.setNavigationBarColor(views: [barView,titleView], titleIndex: 1,titleText: title ?? "")
        
        complaintView.parentView = self
        complaintCollection.registerNoDataCellView()
        complaintCollection.delegate = complaintView
        complaintCollection.dataSource = complaintView

        
        self.complaintCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.complaintCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.complaintCollection.mj_header.beginRefreshing()
        
        addView.isHidden = true
        
        var btn = addView.viewWithTag(20001) as! UIButton
        btn.addTarget(self, action: #selector(btn_cancel_inside), for: .touchUpInside)
        btn = addView.viewWithTag(20002) as! UIButton
        btn.addTarget(self, action: #selector(btn_submit_inside), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        complaintView.initLimitPage()
        complaintCollection.reloadData()
        getListData()
    }
    
    //返回按钮
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_complaintAdd_inside(_ sender: UIButton) {
        //myPresentView(self, viewName: "complaintAddView")
        addView.isHidden = false
        (addView.viewWithTag(10001) as! UITextView).text = ""
    }
    
    
    //获取数据
    func getListData(){
        
        let url = SERVER_PORT+"rest/proposalchannel/getGjwhisper.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            
            self.complaintCollection.mj_header.endRefreshing()
            self.complaintCollection.mj_footer.endRefreshing()
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    let arrayData = json["data"].arrayValue
                    //判断是否在最后一页
                    if(arrayData.count>0){
                        self.complaintView.jsonDataSource = json["data"].arrayValue
                    }else{
                        self.complaintCollection.mj_footer.endRefreshingWithNoMoreData()
                    }
                    self.complaintCollection.reloadData()
                }else{
                    myAlert(self, message: "请求悄悄话列表失败!")
                }
                
                self.complaintView.pageIndex += 1    //页码增加
                
                
            case .failure(let error):
                print(error)
            }
            
        })
        
        
    }
    
    func btn_cancel_inside(){
        addView.isHidden = true
    }
    
    func btn_submit_inside(){
        
        let text = (addView.viewWithTag(10001) as! UITextView).text
        
        if text == "" {
            myAlert(self, message: "悄悄话内容不能为空!")
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT+"rest/proposalchannel/addproposal.do"
        myPostRequest(url,["making":text]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    self.addView.isHidden = true
                    self.complaintCollection.mj_header.beginRefreshing()
                }else{
                    myAlert(self, message: "发布悄悄话列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    override func refresh() {
        self.complaintView.jsonDataSource.removeAll()
        complaintCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    override func loadMore() {
        getListData()
    }
    
}
