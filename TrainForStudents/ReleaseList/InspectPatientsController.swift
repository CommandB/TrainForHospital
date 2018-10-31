//
//  InspectPatientController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/26.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class InspectPatientsController : UIViewController{
    
    @IBOutlet weak var patientsCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        patientsCollection.delegate = self
        patientsCollection.dataSource = self
        
        self.patientsCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.patientsCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.patientsCollection.mj_header.beginRefreshing()
    }
    
    func getListData(){
        self.patientsCollection.mj_header.endRefreshing()
        self.patientsCollection.mj_footer.endRefreshing()
        patientsCollection.mj_footer.endRefreshingWithNoMoreData()
        patientsCollection.reloadData()
    }
    
    func refresh() {
        jds.removeAll()
        patientsCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension InspectPatientsController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 40)
    }
    
}
