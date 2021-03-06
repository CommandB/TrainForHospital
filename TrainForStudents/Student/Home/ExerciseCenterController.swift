//
//  ExerciseCenterController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/3.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
//    exerciseCenterView
class ExerciseCenterController : UIViewController , UITextFieldDelegate{
    
    let hisSearchCacheKey = "exercisehisSearchCacheKey"
    
    @IBOutlet weak var deptCollection: UITableView!
    
    @IBOutlet weak var questionTypeCollection: UICollectionView!
    
    @IBOutlet weak var hisSearchCollection: UICollectionView!
    
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var view_search: UIView!
    
    @IBOutlet weak var txt_search: UITextField!
    
    var questionTypeView = QuestionTypeView()
    var hisSearchView = HistorySearchController()
    
    var jds = [JSON]()
    var hisTextArray = [JSON]()
    ///label
    let lineHeight = 15
    
    override func viewDidLoad() {
        
        //搜索框
        txt_search.delegate = self
        
        deptCollection.delegate = self
        deptCollection.dataSource = self
        deptCollection.estimatedRowHeight = 55
        deptCollection.separatorStyle = .none
        
        //deptCollection.rowHeight = UITableView.auto
        
        questionTypeView.parentView = self
        questionTypeCollection.delegate = questionTypeView
        questionTypeCollection.dataSource = questionTypeView
        
        questionTypeCollection.setX(x: deptCollection.W)
        
        let cache = UserDefaults.standard.string(forKey: hisSearchCacheKey)
        if cache != nil {
            hisTextArray = JSON(parseJSON: cache!).arrayValue
        }
        hisSearchCollection.delegate = hisSearchView
        hisSearchCollection.dataSource = hisSearchView
        hisSearchView.jds = hisTextArray.reversed()
        hisSearchView.clorsureImpl = selectedHisText(_:_:_:)
        hisSearchCollection.reloadData()
        
//        self.deptCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.deptCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.deptCollection.mj_header.beginRefreshing()
        textFieldShouldReturn(txt_search)
        deptCollection.mj_footer.endRefreshingWithNoMoreData()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        
        if scroll.contentOffset.x != 0 {
            scroll.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }else{
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btn_hotSearch_inside(_ sender: UIButton) {
        
        txt_search.text = sender.titleLabel?.text
        let _ = textFieldShouldReturn(txt_search)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        view_search.isHidden = false
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view_search.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        let _ = super.textFieldShouldReturn(textField)
        view.endEditing(true)
        deptCollection.separatorStyle = .singleLine
        
        MBProgressHUD.showAdded(to: view, animated: true)
        self.scroll.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        self.deptCollection.reloadData()
        let searchStr = textField.text ?? ""
        
        //查询题目类目
        let url = SERVER_PORT + "rest/app/getCloudQuestionDept.do"
        myPostRequest(url, ["searchvalue":searchStr],  method: .post).responseString(completionHandler: {resp in
            if searchStr.count > 0{
                self.updateHistorySearchCache(text: searchStr)
            }
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.deptCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
//                print(json)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "查询考题类目异常!")
                print(error)
                break
            }
            self.deptCollection.reloadData()
        })
        
        return true
    }

    func getListData(){
        
    }
    
    @objc func refresh() {
        //jds.removeAll()
        //getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
    
    //更新历史搜索缓存
    func updateHistorySearchCache(text : String){
        
        var index = 0
        var removeIndex = -1
        for item in hisTextArray{
            if item["text"].stringValue == text{
                removeIndex = index
                break
            }
            index += 1
        }
        if removeIndex != -1{
            hisTextArray.remove(at: removeIndex)
        }
        hisTextArray.append(JSON(["text":text]))
        
        //最多缓存7个历史搜索记录
        if hisTextArray.count > 7 {
            hisTextArray.remove(at: 0)
        }
        UserDefaults.standard.set(hisTextArray.description, forKey: hisSearchCacheKey)
        hisSearchView.jds = JSON(hisTextArray).arrayValue.reversed()
        hisSearchCollection.reloadData()
    }
    
    func selectedHisText(_ ds:[JSON], _ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void{
        txt_search.text = ds[indexPath.item]["text"].stringValue
        let _ = textFieldShouldReturn(txt_search)
    }
    
}

extension ExerciseCenterController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = jds[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = "\(data["name"].stringValue)"//(ID:\(data["questionsdeptid"].stringValue))
        let lbl = (cell.viewWithTag(20001) as! UILabel)
        lbl.text = data["linkname"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = jds[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "c1")
        let itemTitle = data["linkname"].stringValue + data["title"].stringValue
        let lineNumber = itemTitle.getLineNumberForUILabel(cell!.viewWithTag(20001) as! UILabel)

        return CGFloat(lineNumber * lineHeight + 40)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if jds.count == 0{
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        MBProgressHUD.showAdded(to: view, animated: true)
        let data = jds[indexPath.item]
        let url = SERVER_PORT + "rest/app/getQuestionCountByType.do"
        myPostRequest(url, ["questionsdeptid":data["questionsdeptid"]],  method: .post).responseString(completionHandler: {resp in

            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.deptCollection.mj_footer.endRefreshingWithNoMoreData()

            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
//                print(json)

                if json["code"].stringValue == "1"{
                    self.questionTypeView.jds = json["data"].arrayValue
                    if self.questionTypeView.jds.count == 0 {
                        myAlert(self, message: "此类目下暂无考题!")
                    }else{
                        self.questionTypeView.deptId = data["questionsdeptid"].intValue
                        self.scroll.setContentOffset(CGPoint(x: UIScreen.width, y: 0), animated: true)
                    }
                    self.questionTypeCollection.reloadData()

                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "查询题型异常!")
                print(error)
                break
            }

        })
    }
    
    
}


//题型collection delegate
class QuestionTypeView: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var jds = [JSON]()
    var deptId = 0
    var parentView : UIViewController? = nil
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = "\(data["typename"].stringValue)(\(data["count"].intValue))"
        
        var btn = cell.viewWithTag(10002) as! UIButton
        btn.viewParam = ["num":10,"questionsdeptid":deptId,"type":data["type"].intValue]
        btn.addTarget(self, action: #selector(startExercise), for: .touchUpInside)
        btn = cell.viewWithTag(10003) as! UIButton
        btn.viewParam = ["num":25,"questionsdeptid":deptId,"type":data["type"].intValue]
        btn.addTarget(self, action: #selector(startExercise), for: .touchUpInside)
        btn = cell.viewWithTag(10004) as! UIButton
        btn.viewParam = ["num":50,"questionsdeptid":deptId,"type":data["type"].intValue]
        btn.addTarget(self, action: #selector(startExercise), for: .touchUpInside)
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: CGFloat(40))
    }
    
    @objc func startExercise(sender : UIButton){
        MBProgressHUD.showAdded(to: view, animated: true)
        //查询练习题
        let url = SERVER_PORT + "rest/app/getPracticeQuestionByDept.do"
        myPostRequest(url, sender.viewParam,  method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                print(json)
                if json["code"].stringValue == "1"{
                    
                    //TODO 跳转到考试界面
                    
                    let vc = getViewToStoryboard("examView") as! ExamViewController
                    vc.isTrain = true
                    vc.exercises = json["data"].arrayValue
                    self.parentView?.present(vc, animated: true, completion: nil)
                    
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取练习题异常!")
                print(error)
                break
            }
        })
        
    }
    
}


