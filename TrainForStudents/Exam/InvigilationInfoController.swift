//
//  InvigilationInfoController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/13.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class InvigilationInfoController : HBaseViewController{
    
    @IBOutlet weak var stuCollection: UICollectionView!
    
    var paramData = JSON()
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        stuCollection.delegate = self
        stuCollection.dataSource = self
        
        (self.view.viewWithTag(10001) as! UILabel).text = paramData["title"].stringValue
        self.stuCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.stuCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.stuCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT + "rest/app/getExamInfoByTeacher.do"
        myPostRequest(url,["examroomid":paramData["buid"]], method: .post).responseJSON(completionHandler: { resp in
            self.stuCollection.mj_header.endRefreshing()
            self.stuCollection.mj_footer.endRefreshingWithNoMoreData()
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            switch resp.result{
            case .success(let respJson):
                let json = JSON(respJson)
                if json["code"].intValue == 1{
                    let data = json["data"]
                    
                    (self.view.viewWithTag(20001) as! UILabel).text = data["addressname"].stringValue
                    (self.view.viewWithTag(30001) as! UILabel).text = data["starttime"].stringValue
                    self.jds = data["studentlist"].arrayValue
                    self.stuCollection.reloadData()
                }else{
                    myAlert(self, message: "获取参考学员列表失败!")
                }
                
            case .failure(let error):
                print(error)
                break
            }
            
            
        })
        
    }
    
    @objc func refresh() {
        jds.removeAll()
        getListData()
    }
    
    @objc func loadMore() {
        
    }
    
}

extension InvigilationInfoController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = data["personname"].stringValue
        cell.setBorder(width: 1, color: .groupTableViewBackground)
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let width = (collectionView.W + 15) / 3
        return CGSize(width: width, height: 40)
    }
    
}
