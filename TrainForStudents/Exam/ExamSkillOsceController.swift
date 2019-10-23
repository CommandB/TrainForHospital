//
//  ExamSkillOsceView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/10/14.
//  Copyright © 2019 黄玮晟. All rights reserved.
//


import Foundation
import UIKit
import SwiftyJSON

class ExamSkillOsceController : HBaseViewController{
    
    @IBOutlet weak var examCollection: UICollectionView!
    
    var paramData = JSON()
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        examCollection.delegate = self
        examCollection.dataSource = self
        
        self.examCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.examCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        (view.viewWithTag(10001) as! UILabel).text = paramData["title"].stringValue
        (view.viewWithTag(20001) as! UILabel).text = "时间:\(paramData["starttime"].stringValue) 至 \(paramData["endtime"].stringValue)"
        (view.viewWithTag(30001) as! UILabel).text = "地址:\(paramData["addressname"].stringValue)"
        
        self.examCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT+"rest/app/getSkillExamQRCode.do"
        
        myPostRequest(url,["taskid":paramData["taskid"].stringValue,"personid":UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue),"ip":SERVER_PORT.substring(to: 25)]).responseJSON(completionHandler: {resp in
            self.examCollection.mj_header.endRefreshing()
            self.examCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                print(json)
                if json["code"].stringValue == "1"{
                    self.jds = json["qrcodelist"].arrayValue
                }else{
                    myAlert(self, message: "请求试卷列表失败!")
                }
                self.examCollection.reloadData()
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    @objc func refresh() {
        jds.removeAll()
        examCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
}

extension ExamSkillOsceController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = data["skillname"].stringValue
        let qrView = (cell.viewWithTag(20001) as! UIImageView)
        qrView.image = UIImage.createQR(text: data["qrcode"].stringValue, size: qrView.W)
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: collectionView.W, height: 255)
    }
    
}
