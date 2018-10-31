//
//  ToDoListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/19.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ToDoListController : UIViewController{
    
    @IBOutlet weak var toDoCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        jds.append(JSON(["cellName":"headerCell"]))
        jds.append(JSON(["cellName":"bodyCell"]))
        
        toDoCollection.delegate = self
        toDoCollection.dataSource = self
        
        self.toDoCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.toDoCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.toDoCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        self.toDoCollection.mj_header.endRefreshing()
        self.toDoCollection.mj_footer.endRefreshing()
        toDoCollection.reloadData()
    }
    
    func refresh() {
        jds.removeAll()
        toDoCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension ToDoListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cellName = data["cellName"].stringValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        let cellName = data["cellName"].stringValue
        if cellName == "headerCell"{
            return CGSize(width: UIScreen.width, height: 50)
        }else if cellName == "bodyCell"{
            return CGSize(width: UIScreen.width, height: 110)
        }
        return CGSize(width: UIScreen.width.subtracting(20), height: 0)
    }
    
}
