//
//  CommentHistoryListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/13.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EvaluationHistoryListController : UIViewController{
    
    static var defaultNoticeName = NSNotification.Name(rawValue: "selectedEvaluationNotificationName")
    
    @IBOutlet weak var evaluationCollection: UICollectionView!
    
    var jds = [JSON]()
    var isHistory = true
    var viewTitle = ""
    
    override func viewDidLoad() {
        
        evaluationCollection.delegate = self
        evaluationCollection.dataSource = self
        
        if isHistory{
            self.evaluationCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
            self.evaluationCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        }else{
            (view.viewWithTag(22222) as! UILabel).text = viewTitle
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isHistory{
            self.evaluationCollection.mj_header.beginRefreshing()
        }
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //获取历史评价
    func getListData(){
        
        evaluationCollection.reloadData()
        
        let url = SERVER_PORT+"rest/app/getMyHistoryEvaluateTask.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            
            self.evaluationCollection.mj_header.endRefreshing()
            self.evaluationCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                
                if json["code"].stringValue == "1"{
                    
                    self.jds = json["data"].arrayValue
                    self.evaluationCollection.reloadData()
                    
                }else{
                    myAlert(self, message: "请求历史评价失败!")
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

extension EvaluationHistoryListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = data["objectname"].stringValue
        if isHistory{
            (cell.viewWithTag(10002) as! UILabel).text = data["value"].stringValue + "分/"
        }else{
            (cell.viewWithTag(10002) as! UILabel).text = ""
        }
        
        if isHistory{
            (cell.viewWithTag(10003) as! UILabel).text = data["evaluationvalue"].stringValue + "分"
        }else{
            (cell.viewWithTag(10003) as! UILabel).text = ""
        }
        
        (cell.viewWithTag(20001) as! UILabel).text = data["evaluatename"].stringValue
        (cell.viewWithTag(30001) as! UILabel).text = data["evaluatetime"].stringValue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isHistory{
            let vc = getViewToStoryboard("evaluationHistoryDetailView") as! EvaluationHistoryDetailController
            vc.headData = jds[indexPath.item]
            present(vc, animated: true, completion: nil)
        }else{
            NotificationCenter.default.post(name: EvaluationHistoryListController.defaultNoticeName, object: nil, userInfo: ["index":indexPath.item])
            dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 80)
    }
    
}
