//
//  CommentDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/13.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EvaluationHistoryDetailController : UIViewController{
    
    @IBOutlet weak var evaluationCollection: UICollectionView!
    
    var headData = JSON()
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        evaluationCollection.delegate = self
        evaluationCollection.dataSource = self
        self.evaluationCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.evaluationCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        (view.viewWithTag(10000) as! UILabel).text = headData["evaluatename"].stringValue
        (view.viewWithTag(10001) as! UILabel).text = headData["objectname"].stringValue
        (view.viewWithTag(10002) as! UILabel).text = headData["value"].stringValue + "分/"
        (view.viewWithTag(10003) as! UILabel).text = headData["evaluationvalue"].stringValue + "分"
        (view.viewWithTag(20001) as! UILabel).text = headData["evaluatetime"].stringValue
        (view.viewWithTag(20002) as! UILabel).text = headData["evaluatetype"].stringValue
        
        evaluationCollection.mj_header.beginRefreshing()
    }
    
    
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT+"rest/app/getMyHistoryEvaluateInfo.do"
        myPostRequest(url,["evaluateid":headData["evaluateid"].stringValue]).responseJSON(completionHandler: {resp in
            
            self.evaluationCollection.mj_header.endRefreshing()
            self.evaluationCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                print(json)
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
        getListData()
    }
    
    @objc func loadMore() {
        //getListData()
    }
    
}

extension EvaluationHistoryDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    //设置collectionView的分区个数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //设置每个分区元素的个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return jds.count * 2
        
    }
    
    //实现UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        var cellName = "c1"
        var index = 0
        
        if indexPath.item == 0{
            index = 0
            cellName = "c1"
        }else if indexPath.item % 2 == 0{
            index = indexPath.item / 2
            cellName = "c1"
        }else{
            index = (indexPath.item - 1) / 2
            cellName = "c2"
        }
        
        let data = jds[index]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        if cellName == "c1"{
            let lbl = cell.viewWithTag(10001) as? UILabel
            lbl?.text = data["itemtitle"].stringValue
        }else{
            let slider = cell.viewWithTag(10001) as! UISlider
            
            let lightNumber = data["realvalue"].intValue
            let maxStarNumber = data["maxvalue"].intValue
            
            slider.minimumValue = 0
            slider.maximumValue = Float(maxStarNumber)
            slider.value = Float(lightNumber)
            slider.isEnabled = false
            
            //展示分数
            let lbl = cell.viewWithTag(10002) as! UILabel
            lbl.text = "\(lightNumber)/\(maxStarNumber)分"
            
        }
        
        return cell
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //print(indexPath.item)
        
    }
    
    //设置cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 45)
        
    }
    
}
