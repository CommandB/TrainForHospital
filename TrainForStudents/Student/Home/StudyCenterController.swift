//
//  StudyCenterController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/6/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class StudyCenterController : HBaseViewController{
    
    @IBOutlet weak var officeCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        officeCollection.delegate = self
        officeCollection.dataSource = self
        
        self.officeCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.officeCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.officeCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT + "rest/teachingMaterial/queryteachingmaterialdept_new.do"
        myPostRequest(url,["headcategoryid":0],  method: .post).responseString(completionHandler: {resp in
            
            self.officeCollection.mj_header.endRefreshing()
            self.officeCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                //print(json)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取分类数据异常!")
                print(error)
                break
            }
            self.officeCollection.reloadData()
        })
        
        
        officeCollection.reloadData()
    }
    
    @objc func refresh() {
        jds.removeAll()
        officeCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
}

extension StudyCenterController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        cell.setCornerRadius(radius: 4)
        (cell.viewWithTag(10001) as! UILabel).text = data["deptname"].stringValue
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = jds[indexPath.item]
        let vc = getViewToStoryboard("studyListView") as! StudyListController
        vc.deptId = data["teachingmaterialdeptid"].intValue
        present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: (collectionView.W - 40) / 3, height: 40)
    }
    
}

