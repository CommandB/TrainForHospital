//
//  TeachingStatisticsController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/16.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class TeachingStatisticsController : HBaseViewController{
    
    @IBOutlet weak var teachingTypeCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        teachingTypeCollection.delegate = self
        teachingTypeCollection.dataSource = self
        
        self.teachingTypeCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.teachingTypeCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.teachingTypeCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        self.teachingTypeCollection.mj_header.endRefreshing()
        self.teachingTypeCollection.mj_footer.endRefreshing()
        teachingTypeCollection.reloadData()
    }
    
    func refresh() {
        teachingTypeCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    
}

extension TeachingStatisticsController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
//        let btn_icon
        (cell.viewWithTag(10001) as! UIButton).setImage(UIImage(named: data["traintypename"].stringValue), for: .normal)
        (cell.viewWithTag(10002) as! UILabel).text = data["traintypename"].stringValue
        (cell.viewWithTag(10003) as! UILabel).text = data["times"].stringValue
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 45)
    }
    
}
