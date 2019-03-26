//
//  ExamListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/16.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ExamListController : HBaseViewController{
    
    @IBOutlet weak var examCollection: UICollectionView!
    
    var jds = [JSON]()
    var isInvigilation = false
    
    override func viewDidLoad() {
        
        examCollection.delegate = self
        examCollection.dataSource = self
        
        (view.viewWithTag(11111) as! UILabel).text = "待考任务"
        if isInvigilation{
            (view.viewWithTag(11111) as! UILabel).text = "监考任务"
        }
        
        
        self.examCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.examCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.examCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        //待考任务
        var url = SERVER_PORT+"rest/app/getMyExamTask.do"
        if isInvigilation{
            //监考任务
            url = SERVER_PORT+"rest/app/getMySuperviseExamTask.do"
        }
        
        myPostRequest(url).responseJSON(completionHandler: {resp in
            self.examCollection.mj_header.endRefreshing()
            self.examCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
//                print(json)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                }else{
                    myAlert(self, message: "请求考试列表失败!")
                }
                self.examCollection.reloadData()
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
        getListData()
    }
    
}

extension ExamListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        if data["ishistory"].intValue == 1{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
        }
        (cell.viewWithTag(10001) as! UILabel).text = data["tasktype"].stringValue
        (cell.viewWithTag(10002) as! UILabel).text = data["butype"].stringValue
        (cell.viewWithTag(20001) as! UILabel).text = data["title"].stringValue
        let startDate = DateUtil.stringToDateTime(data["starttime"].stringValue)
        let endDateStr = data["endtime"].stringValue
        (cell.viewWithTag(30001) as! UILabel).text = "\(startDate.year)年\(startDate.month)月\(startDate.day)日"
        (cell.viewWithTag(30002) as! UILabel).text = DateUtil.getWeek(startDate)
        
        let lbl_examTime = (cell.viewWithTag(40001) as! UILabel)
        lbl_examTime.text = "\(data["starttime"].stringValue.substring(from: 11).substring(to: 5))"
        if !endDateStr.isEmpty{
            lbl_examTime.text = "\(lbl_examTime.text!)-\(endDateStr.substring(from: 11).substring(to: 5))"
        }
        
        (cell.viewWithTag(50001) as! UILabel).text = data["addr"].stringValue
        
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
        var data = jds[indexPath.item]
        if isInvigilation{
            if data["ishistory"].intValue == 1{
                if data["butype"].stringValue == "理论考试监考"{
                    let vc = getViewToStoryboard("invigilationInfoView") as! InvigilationInfoController
                    vc.paramData = data
                    present(vc, animated: true, completion: nil)
                }else{
                    //跳转到
                    
                    let url = SERVER_PORT + "rest/app/getSkillExamInfo.do"
                    
                    myPostRequest(url, ["personid":data["buid"].intValue, "examroomid":data["examroomid"].stringValue] , method: .post).responseJSON(completionHandler: {resp in
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        
                        switch resp.result{
                        case .success(let respJson):
                            let json = JSON(respJson)
                            print(json)
                            
                        case .failure(let err):
                            print(err)
                            break
                        }
                        
                    })
                    
                }
            }else{  //非历史
                if data["butype"].stringValue == "理论考试监考"{
                    let vc = getViewToStoryboard("invigilationInfoView") as! InvigilationInfoController
                    vc.paramData = data
                    present(vc, animated: true, completion: nil)
                }else{
                    let vc = getViewToStoryboard("skillExamInfoView") as! SkillExamInfoController
                    data["bepersonid"] = data["buid"]
                    vc.paramData = data
                    present(vc, animated: true, completion: nil)
                }
            }
            
        }else{
            if data["ishistory"].intValue == 1{
                
            }else{  //非历史
                if data["butype"].stringValue == "理论考试"{
                    let vc = getViewToStoryboard("examInfoForStuView") as! ExamInfoForStuController
                    vc.paramData = data
                    present(vc, animated: true, completion: nil)
                }else{
                    let vc = getViewToStoryboard("examInfoForStuView") as! ExamInfoForStuController
                    vc.paramData = data
                    present(vc, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 160)
    }
    
}
