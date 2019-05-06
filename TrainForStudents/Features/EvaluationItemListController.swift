//
//  EvaluationItemListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/13.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EvaluationItemListController : UIViewController{
    
    @IBOutlet weak var cardCollection: UICollectionView!
    
    @IBOutlet weak var detailCollection: UICollectionView!
    
    @IBOutlet weak var btn_left: UIButton!
    
    @IBOutlet weak var btn_right: UIButton!
    
    @IBOutlet weak var btn_list: UIButton!
    
    @IBOutlet weak var btn_all: UIButton!
    
    @IBOutlet weak var btn_train: UIButton!
    
    @IBOutlet weak var btn_subject: UIButton!
    
    let mark_uncheck = "⚪️"
    let mark_checked = "🔘"
    var selectedBtnTag = 0
    
    var detailView = EvaluationItemViewController()
    
    var initData = JSON()
    var jds = [JSON]()
    var dataList = [JSON]()
    
    var pageNumber = 0
    var beginDraggingX = CGFloat(0)
    var score = 0
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    override func viewDidLoad() {
        buttonGroup = [btn_left , btn_right]
        btn_left.restorationIdentifier = "btn_left"
        btn_right.restorationIdentifier = "btn_right"
        
        cardCollection.delegate = self
        cardCollection.dataSource = self
        
        detailView.parentView = self
        detailCollection.delegate = detailView
        detailCollection.dataSource = detailView
        
        getCardListData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: EvaluationHistoryListController.defaultNoticeName, object: nil)
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btn_history_inside(_ sender: UIButton) {
        myPresentView(self, viewName: "evaluationHistoryListView")
    }
    
    //左右滑按钮
    @IBAction func btn_inside(_ sender: UIButton) {
        tabsTouchAnimation(sender: sender)
    }
    
    //提交按钮
    @IBAction func btn_submit_inside(_ sender: UIButton) {
        
        var index = 1
        for item in detailView.jsonDataSource{
            if item.1["get_value"].intValue == 0{
                myAlert(self, message: "请评价第\(index)题!")
                return
            }
            index += 1
        }
        
        let data = jds[pageNumber]
        let url = SERVER_PORT+"rest/evaluation/commitEvaluationResult.do"
        myPostRequest(url,JSON(["items":detailView.jsonDataSource , "taskid":data["taskid"].stringValue, "evaluateid": data["buid"].stringValue]).dictionaryObject).responseJSON(completionHandler: {resp in
            switch resp.result{
            case .success(let responseJson):
                
                let json=JSON(responseJson)
                if json["code"].stringValue == "1"{
                    myAlert(self, message: "评价完成!" , handler: {action in
                        //self.dismiss(animated: true, completion: nil)
                        self.getCardListData()
                    })
                }else{
                    myAlert(self, message: "评价失败!\(json["msg"].stringValue)")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    //未评列表
    @IBAction func btn_list_inside(_ sender: UIButton) {
        let vc = getViewToStoryboard("evaluationHistoryListView") as! EvaluationHistoryListController
        vc.jds = dataList
        vc.viewTitle = "评价列表"
        vc.isHistory = false
        present(vc, animated: true, completion: nil)
        
        
    }
    
    //全部 培训 出科
    @IBAction func btn_sort_inside(_ sender: UIButton) {
        
        if sender.tag == selectedBtnTag{
            return
        }
        selectedBtnTag = sender.tag
        btn_all.setTitle(mark_uncheck + "全部", for: .normal)
        btn_train.setTitle(mark_uncheck + "培训评价", for: .normal)
        btn_subject.setTitle(mark_uncheck + "出科评价", for: .normal)
        
        var taskType = ""
        switch sender.tag {
        case 10011:
            btn_all.setTitle(mark_checked + "全部", for: .normal)
        case 10012:
            taskType = "培训评价"
            btn_train.setTitle(mark_checked + "培训评价", for: .normal)
        case 10013:
            taskType = "出科评价"
            btn_subject.setTitle(mark_checked + "出科评价", for: .normal)
        default:
            break
        }
        
        //过滤评价数据
        if taskType == ""{
            jds = dataList
        }else{
            jds.removeAll()
            for item in dataList{
                if item["tasktype"].stringValue == taskType{
                    jds.append(item)
                }
            }
        }
        pageNumber = 0
        if self.jds.count > 0{
            self.changeIndex(self.pageNumber + 1)
            self.getDetailDatasource(self.jds[0]["evaluationid"].stringValue)
            self.btn_left.isEnabled = true
            self.btn_right.isEnabled = true
        }else{
            self.changeIndex(0)
            self.btn_left.isEnabled = false
            self.btn_right.isEnabled = false
        }
        self.cardCollection.reloadData()
        cardCollection.setContentOffset(CGPoint(x: cardCollection.W * CGFloat(pageNumber), y: 0), animated: true)
    }
    
    func getCardListData(){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        pageNumber = 0
        
        let url = SERVER_PORT+"rest/app/getMyEvaluateTask.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    self.jds  = json["data"].arrayValue
                    self.dataList = self.jds
                    
                    //如果有待评数据 则默认把第一个待评的 评价详情给加载出来
                    if self.jds.count > 0{
                        self.changeIndex(self.pageNumber + 1)
                        self.getDetailDatasource(self.jds[0]["evaluationid"].stringValue)
                    }else{
                        self.changeIndex(0)
                        self.btn_left.isEnabled = false
                        self.btn_right.isEnabled = false
                    }
                    self.cardCollection.reloadData()
                    
                    if !self.initData.isEmpty{
                        var index = 0
                        for o in self.jds{
                            if o["buid"].stringValue == self.initData["evaluationid"].stringValue{
                                self.pageNumber = index - 1
                                self.tabsTouchAnimation(sender: self.btn_right)
                                break
                            }
                            index += 1
                        }
                    }
                    
                }else{
                    myAlert(self, message: "请求待评任务列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    //获取评价详情
    func getDetailDatasource(_ evaluationId : String){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let url = SERVER_PORT+"rest/evaluation/query.do"
        myPostRequest(url,["evaluationid": evaluationId]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    self.detailView.jsonDataSource = json["data"]
                    for item in json["data"].arrayValue{
                        let index = self.detailView.jsonDataSource.arrayValue.index(of: item)
                        self.detailView.jsonDataSource[index!]["get_value"].stringValue = "0"
                    }
                    self.detailCollection.reloadData()
                }else{
                    myAlert(self, message: "请求评价详情失败!")
                }
                (self.view.viewWithTag(88888) as! UILabel).text = "总得分：0分"
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    func tabsTouchAnimation( sender : UIButton){
        //-----------------计算 "下标线"label的动画参数
        for b in buttonGroup {
            if b == sender{
                b.setTitleColor(UIColor.init(hex: "407BD8"), for: .normal)
            }else{
                b.setTitleColor(UIColor.black, for: .normal);
            }
        }
        
        //动画开始
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        
        let collectionWidth = cardCollection.frame.width
        
        //滚动效果
        if sender.restorationIdentifier == "btn_left"{
            //边界控制
            if pageNumber == 0 {
                return
            }
            pageNumber -= 1
            if pageNumber < 0{
                pageNumber = 0
            }
            cardCollection.setContentOffset(CGPoint(x: collectionWidth * CGFloat(pageNumber), y: 0), animated: true)
        }else if sender.restorationIdentifier == "btn_right"{
            //边界控制
            if jds.count == 0 || pageNumber == jds.count - 1{
                return
            }
            pageNumber += 1
            if pageNumber >= jds.count{
                pageNumber = jds.count - 1
            }
            cardCollection.setContentOffset(CGPoint(x: collectionWidth * CGFloat(pageNumber), y: 0), animated: true)
        }
        //print("pageNumber:\(pageNumber)")
        if pageNumber < jds.count{
            getDetailDatasource(jds[pageNumber]["evaluationid"].stringValue)
        }
        changeIndex(pageNumber + 1)
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
    }
    
    ///改变左上角 待评价(xx/xxx)
    func changeIndex(_ num : Int){
        self.btn_list.setTitle("待评价(\(num)/\(jds.count))", for: .normal)
    }
    
    @objc func receiveNotice(notification : NSNotification){
        
        if notification.userInfo != nil{
            let index = notification.userInfo!["index"] as! Int
            pageNumber = index
            cardCollection.setContentOffset(CGPoint(x: cardCollection.W * CGFloat(index), y: 0), animated: true)
            changeIndex(pageNumber + 1)
            getDetailDatasource(jds[pageNumber]["evaluationid"].stringValue)
        }
        
    }
    
}


extension EvaluationItemListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if jds.count == 0{
            return 1
        }
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        if jds.count == 0{
            (cell.viewWithTag(20001) as! UILabel).text = "暂无数据"
            return cell
        }
        let data = jds[indexPath.item]
        let btn = cell.viewWithTag(10001) as! UIButton
        btn.setTitle(data["content1"].stringValue, for: .normal)
        var lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["content2"].stringValue
        lbl = cell.viewWithTag(10003) as! UILabel
        lbl.text = data["content3"].stringValue
        lbl = cell.viewWithTag(10004) as! UILabel
        lbl.text = data["content4"].stringValue
        lbl = cell.viewWithTag(10005) as! UILabel
        lbl.text = data["content5"].stringValue
        lbl = cell.viewWithTag(10006) as! UILabel
        lbl.text = data["content6"].stringValue
        lbl = cell.viewWithTag(10007) as! UILabel
        lbl.text = data["content7"].stringValue
        (cell.viewWithTag(20001) as! UILabel).text = ""
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "commentHistoryDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: 150)
    }
    
}


extension EvaluationItemListController : UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginDraggingX = scrollView.contentOffset.x
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = scrollView.contentOffset.x

//        print("endDragging =   beginDraggingX:\(beginDraggingX) : x:\(x)")

        if beginDraggingX < x{  //左滑
            print("左滑")
            
            //边界控制
            if jds.count == 0 || pageNumber == jds.count - 1{
                return
            }
            
            pageNumber += 1
            if pageNumber > jds.count{
                pageNumber = jds.count
            }
        }else if beginDraggingX > x {   //右滑
            //边界控制
            if pageNumber == 0 {
                return
            }
            pageNumber -= 1
            if pageNumber < 0{
                pageNumber = 0
            }
            print("右滑")
        }
        changeIndex(pageNumber + 1)
        getDetailDatasource(jds[pageNumber]["evaluationid"].stringValue)
    }

    
}


class EvaluationItemViewController : UIViewController,UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var parentView : EvaluationItemListController? = nil
    var jsonDataSource = JSON([:])
    var isReadonly = false
    
    //设置collectionView的分区个数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //设置每个分区元素的个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return jsonDataSource.count * 2
        
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
        
        let data = jsonDataSource[index]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        if cellName == "c1"{
            let lbl = cell.viewWithTag(10001) as? UILabel
            lbl?.text = data["itemtitle"].stringValue
        }else{
            let slider = cell.viewWithTag(10001) as! UISlider
            let selectedNumber = data["get_value"].int
            var lightNumber = 0
            if selectedNumber != nil{
                lightNumber = selectedNumber!
            }
            
            //如果用户有改变分数 则用这个我自己 增加 的字段显示
            lightNumber = data["score"].intValue
            
            let maxStarNumber = data["numbervalue"].intValue * data["starsvalue"].intValue
            
            slider.viewParam = ["index":index ,"maxValue" : maxStarNumber ,"indexPath":indexPath]
            slider.minimumValue = 0
            slider.maximumValue = Float(maxStarNumber)
            slider.value = Float(lightNumber)
            slider.addTarget(self, action: #selector(setScore), for: .valueChanged)
            
            //展示分数
            let lbl = cell.viewWithTag(10002) as! UILabel
            lbl.text = "\(lightNumber)/\(maxStarNumber)分"
            
        }
        
        return cell
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(indexPath.item)
        
    }
    
    //设置cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 45)
        
    }
    
    @objc func setScore(sender : UISlider){
        
        let indexPath = sender.viewParam!["indexPath"] as! IndexPath
        let index = sender.viewParam!["index"] as! Int
        //四舍五入
        let score = lroundf(sender.value)
        let numberValue = jsonDataSource[index]["numbervalue"].intValue
        jsonDataSource[index]["score"] = JSON(score)
        jsonDataSource[index]["get_value"] = JSON(score / numberValue)
        parentView!.detailCollection.reloadItems(at: [indexPath])
        
        var total = 0
        for item in jsonDataSource{
            total += item.1["score"].intValue
        }
        (parentView?.view.viewWithTag(88888) as! UILabel).text = "总得分：\(total)分"
        
    }
}
