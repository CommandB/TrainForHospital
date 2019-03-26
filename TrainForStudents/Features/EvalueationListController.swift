//
//  EvalueationListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/25.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EvaluationListController : HBaseViewController{
    
    @IBOutlet weak var evaluationCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        evaluationCollection.delegate = self
        evaluationCollection.dataSource = self
        
        
        evaluationCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        evaluationCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        evaluationCollection.mj_header.beginRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.evaluationCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){

        let url = SERVER_PORT+"rest/taskEvaluation/query.do"
        myPostRequest(url,["pageindex": jds.count , "pagesize":10]).responseJSON(completionHandler: {resp in
            
            self.evaluationCollection.mj_header.endRefreshing()
            self.evaluationCollection.mj_footer.endRefreshing()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    let arrayData = json["data"].arrayValue
                    //判断是否在最后一页
                    if arrayData.count < 10{
                        self.evaluationCollection.mj_footer.endRefreshingWithNoMoreData()
                    }
                    
                    self.jds += json["data"].arrayValue
                    self.evaluationCollection.reloadData()
                }else{
                    myAlert(self, message: "请求待评任务列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
        
    }
    
    @objc func refresh() {
        jds.removeAll()
        evaluationCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
}

extension EvaluationListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //实现UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cellName = "c1"
        let json = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        var lbl = cell.viewWithTag(10001) as? UILabel
        lbl?.text = json["title"].stringValue
        lbl = cell.viewWithTag(20001) as? UILabel
        lbl?.text = "\(json["evaluatetypename"].stringValue)"
        lbl = cell.viewWithTag(20002) as? UILabel
        lbl?.text = json["personname"].stringValue
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width, height: 80)
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = jds[indexPath.item]
        let vc = getViewToStoryboard("evaluationDetailView") as! EvaluationDetailController
        vc.isReadonly = false
        vc.headData = data
        present(vc, animated: true, completion: nil)
    }
    
}

