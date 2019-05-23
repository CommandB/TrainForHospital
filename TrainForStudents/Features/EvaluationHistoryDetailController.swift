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
    var wordList = [JSON]()
    
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
                    self.wordList = json["wordslist"].arrayValue
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
        return jds.count + wordList.count
    }
    
    //实现UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        var cellName = "c1"
        var data = JSON()
        if indexPath.item >= jds.count{
            cellName = "c2"
            data = wordList[indexPath.item - jds.count]
        }else{
            data = jds[indexPath.item]
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        if cellName == "c1"{
            var lbl = cell.viewWithTag(10001) as! UILabel
            lbl.text = data["itemtitle"].stringValue
            
            
            let lightNumber = data["realvalue"].intValue
            let maxStarNumber = data["maxvalue"].intValue
            let slider = cell.viewWithTag(20001) as! UISlider
            slider.minimumValue = 0
            slider.maximumValue = Float(maxStarNumber)
            slider.value = Float(lightNumber)
            slider.isEnabled = false
            
            //展示分数
            lbl = cell.viewWithTag(20002) as! UILabel
            lbl.text = "\(lightNumber)/\(maxStarNumber)分"
            lbl.setBorderBottom(size: 1, color: .groupTableViewBackground)
            
            if UserDefaults.AppConfig.string(forKey: .clientCode) == "ZEYY"{
                let tuple = getTextForScore(lightNumber)
                lbl.text = "\(lbl.text!)\n\(tuple.0)"
                lbl.textColor = tuple.1
            }
        }else{
            var lbl = cell.viewWithTag(10001) as! UILabel
            lbl.text = data["wordtitle"].stringValue
            lbl = cell.viewWithTag(20001) as! UILabel
            lbl.text = data["wordsvalue"].stringValue
            
        }
        
        return cell
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    //设置cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 80)
        
    }
    
    func getTextForScore(_ score : Int) -> (String,UIColor){
        
        switch score {
        case 0,1,2:
            return ("不合格", UIColor(hex:"941100"))
        case 3,4:
            return ("需要改进", .red)
        case 5,6:
            return ("合格", .orange)
        case 7,8:
            return ("良好", UIColor(hex:"008F00"))
        case 9,10:
            return ("优秀", UIColor(hex:"008F00"))
        default:
            return ("", .black)
        }
        
    }
    
}
