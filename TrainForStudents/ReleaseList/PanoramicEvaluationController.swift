//
//  PanoramicEvaluationController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/26.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

/*
 
 老师--学生
 秘书--学生
 主任--学生
 护士--学生
 同学--学生
 学生--老师
 学生--科室
 
 */


class PanoramicEvaluationController : UIViewController{
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    var jds = [JSON]()
    ///各种评价表的dic
    var evDic = [String : JSON]()
    
    override func viewDidLoad() {
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
        self.personCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.personCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        
        let lbl = view.viewWithTag(10001) as! UILabel
        lbl.setCornerRadius(radius: lbl.W.divided(by: 2))
        let btn = view.viewWithTag(30002) as! UIButton
        btn.addTarget(self, action: #selector(presentDimension), for: .touchUpInside)
        
        self.personCollection.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PanoramicEvaluationDetailController.callbackNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice2), name: EvaluationDimensionController.callbackNotificationName, object: nil)
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        
        let url = SERVER_PORT + "rest/app/release360evaluate.do"
        let officeId = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)
        
        var param = ["officeid":officeId , "studentlist" : jds] as [String : Any]
        
        for key in evDic.keys{
            switch key{
            case "nerse2s":
                param["NurseEvStudent"] = evDic[key]!
            case "dir2s":
                param["DirectorEvStudent"] = evDic[key]!
            case "cm2s":
                param["ClassmateEvStudent"] = evDic[key]!
            case "se2s":
                param["SecretaryEvStudent"] = evDic[key]!
            case "t2s":
                param["TeacherEvStudent"] = evDic[key]!
            case "s2t":
                param["StudentEvTeacher"] = evDic[key]!
            case "s2o":
                param["StudentEvOffice"] = evDic[key]!
            default:
                break
            }
        }
        
        myPostRequest(url, param, method: .post).responseString(completionHandler: {resp in
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    myAlert(self, message: "发布成功!")
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "发布异常!")
                print(error)
                break
            }
        })
    }
    
    func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: PanoramicEvaluationDetailController.callbackNotificationName, object: nil)
        //print("处理通知")
        if notification.userInfo != nil{
            let result = notification.userInfo!["data"] as! JSON
            let index = notification.userInfo!["indexPath"] as! IndexPath
            jds[index.item] = result
            //print(jds[index.item])
        }
    }
    
    func receiveNotice2(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: EvaluationDimensionController.callbackNotificationName, object: nil)
        //print("处理通知")
        if notification.userInfo != nil{
            let result = notification.userInfo!["data"] as! [String : JSON]
            evDic = result
        }
    }
    
    func presentDimension(){
        let vc = getViewToStoryboard("evaluationDimensionView") as! EvaluationDimensionController
        vc.evDic = evDic
        present(vc, animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT + "rest/app/getPreExitOfficePerson.do"
        let officeId = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)
        myPostRequest(url, ["officeid":officeId ,"month":"201908" ,"fortype":"evaluation"], method: .post).responseString(completionHandler: {resp in
            self.personCollection.mj_header.endRefreshing()
            self.personCollection.mj_footer.endRefreshing()
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    let data = json["data"].arrayValue
                    let lbl = self.view.viewWithTag(20001) as! UILabel
                    lbl.text = "出科人员清单(\(data.count))"
                    self.jds = data
                    
                    //evDic
                    self.evDic["nerse2s"] = json["NurseEvStudent"]
                    self.evDic["dir2s"] = json["DirectorEvStudent"]
                    self.evDic["cm2s"] = json["ClassmateEvStudent"]
                    self.evDic["se2s"] = json["SecretaryEvStudent"]
                    self.evDic["t2s"] = json["TeacherEvStudent"]
                    self.evDic["s2t"] = json["StudentEvTeacher"]
                    self.evDic["s2o"] = json["StudentEvOffice"]
                    
                    var total = 0
                    for k in self.evDic.keys{
                        if self.evDic[k]?.count != 0{
                            total += 1
                        }
                    }
                    (self.view.viewWithTag(30001) as! UILabel).text = "共\(total)个评价维度"
                    
                    
                    self.personCollection.reloadData()
                    self.personCollection.mj_footer.endRefreshingWithNoMoreData()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取人员列表异常!")
                print(error)
                break
            }
        })
        
        personCollection.reloadData()
    }
    
    func refresh() {
        jds.removeAll()
        personCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension PanoramicEvaluationController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let btn_avatar = cell.viewWithTag(10001) as! UIButton
        btn_avatar.setCornerRadius(radius: btn_avatar.W.divided(by: 2))
        var lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["personname"].stringValue
        lbl = cell.viewWithTag(10003) as! UILabel
        lbl.text = ""
        lbl = cell.viewWithTag(10004) as! UILabel
        lbl.text = "\(data["starttime"].stringValue) - \(data["endtime"].stringValue)"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = getViewToStoryboard("panoramicEvaluationDetailDetail") as! PanoramicEvaluationDetailController
        vc.jds["evDic"] = JSON(evDic)
        vc.jds["data"] = jds[indexPath.item]
        vc.parentIndexPath = indexPath
        present(vc, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 55)
    }
    
}
