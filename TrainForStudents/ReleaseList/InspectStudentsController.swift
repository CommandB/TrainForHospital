//
//  InspectStudentsController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/26.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class InspectStudentsController : UIViewController{
    
    @IBOutlet weak var studentsCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        studentsCollection.delegate = self
        studentsCollection.dataSource = self
        
//        self.studentsCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
//        self.studentsCollection.mj_footer = MJRefreshAutoNormalFooter.init()
//        self.studentsCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        
        
        let btn_addStudents = view.viewWithTag(10001) as! UIButton
        btn_addStudents.addTarget(self, action: #selector(addStudents), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.studentsCollection.mj_header.beginRefreshing()
        print("接收通知.....")
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PersonSelectorController.addStudentsNotificationName, object: nil)
    }
    
    func addStudents(){
        myPresentView(self, viewName: "personSelectorView")
    }
    
    func receiveNotice(notification : NSNotification){
        if notification.userInfo != nil{
            jds = notification.userInfo!["data"] as! [JSON]
            studentsCollection.reloadData()
        }
    }
    
//    func refresh() {
//        self.studentsCollection.mj_header.endRefreshing()
//        self.studentsCollection.mj_footer.endRefreshing()
//        studentsCollection.mj_footer.endRefreshingWithNoMoreData()
//        studentsCollection.reloadData()
//    }
    
//    func loadMore() {
//        getListData()
//    }
    
}

extension InspectStudentsController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        cell.tag = indexPath.item
        var lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["personname"].stringValue
        lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["officename"].stringValue
        let btn = cell.viewWithTag(10003) as! UIButton
        btn.addTarget(self, action: #selector(removeStudents), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 40)
    }
    
    func removeStudents(sender : UIButton){
        if sender.superview?.tag != nil{
            jds.remove(at: sender.superview!.tag)
            studentsCollection.reloadData()
        }
    }
    
}
