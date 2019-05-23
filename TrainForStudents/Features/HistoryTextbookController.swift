//
//  File.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/5/18.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class HistoryTextbookController : HBaseViewController{
    
    @IBOutlet weak var textbookCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        textbookCollection.delegate = self
        textbookCollection.dataSource = self
        
        self.textbookCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.textbookCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textbookCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT + "rest/app/queryHistorytask.do"
        
        myPostRequest(url, method: .post).responseJSON { response in
            self.textbookCollection.mj_header.endRefreshing()
            self.textbookCollection.mj_footer.endRefreshingWithNoMoreData()
            switch(response.result){
            case .success(let response):
                let json = JSON(response)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                    self.textbookCollection.reloadData()
                }else{
                    print(json)
                    myAlert(self, message: "加载历史教材失败!")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    @objc func refresh() {
        jds.removeAll()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
}

extension HistoryTextbookController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
        (cell.viewWithTag(20001) as! UILabel).text = data["endtime"].stringValue
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = jds[indexPath.item]
        let vc = getViewToStoryboard("studyView") as! StudyController
        vc.taskId = data["buid"].stringValue
        vc.isHistory = true
        present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 70)
    }
    
}
