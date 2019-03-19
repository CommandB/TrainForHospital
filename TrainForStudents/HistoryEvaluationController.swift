//
//  HistoryEvaluationController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/27.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class HistoryEvaluationController : MyBaseUIViewController{
    
    @IBOutlet weak var evaluationCollection: UICollectionView!
    
    let evaluationView = HistoryEvaluationCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barView = view.viewWithTag(10001)
        let titleView = view.viewWithTag(20001) as! UILabel
        
        super.setNavigationBarColor(views: [barView,titleView], titleIndex: 1,titleText: "历史评价")
        
        evaluationView.parentVC = self
        evaluationCollection.registerNoDataCellView()
        evaluationCollection.delegate = evaluationView
        evaluationCollection.dataSource = evaluationView
        
        self.evaluationCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.evaluationCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        evaluationCollection.mj_header.beginRefreshing()
    }
    
    //返回按钮
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //获取历史评价
    func getEvaluationDatasource(){
        
        let url = SERVER_PORT+"rest/taskEvaluation/queryHistory.do"
        myPostRequest(url,["pageindex":evaluationView.jsonDataSource.count , "pagesize":20]).responseJSON(completionHandler: {resp in
            self.evaluationCollection.mj_header.endRefreshing()
            self.evaluationCollection.mj_footer.endRefreshing()
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let data = json["data"].arrayValue
                    if data.count == 0 {
                        self.evaluationCollection.mj_footer.endRefreshingWithNoMoreData()
                    }
                    self.evaluationView.jsonDataSource += data
                    self.evaluationCollection.reloadData()
                }else{
                    myAlert(self, message: "请求历史考评列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    override func refresh() {
        evaluationView.jsonDataSource.removeAll()
        evaluationCollection.reloadData()
        evaluationCollection.mj_footer.resetNoMoreData()
        getEvaluationDatasource()
    }
    
    override func loadMore() {
        getEvaluationDatasource()
    }
    
}
