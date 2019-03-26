//
//  ToDoDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/22.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ToDoDetailController : UIViewController{
    
    @IBOutlet weak var toDoCollection: UICollectionView!
    
    var jds = [JSON]()
    
    /// open close
    var cellSwitch = [IndexPath:Bool]()
    
    override func viewDidLoad() {
        jds.append(JSON(["cellName":"headerCell"]))
        jds.append(JSON(["cellName":"bodyCell"]))
        
        toDoCollection.delegate = self
        toDoCollection.dataSource = self
        
        self.toDoCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.toDoCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
//        self.toDoCollection.mj_header.beginRefreshing()
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        self.toDoCollection.mj_header.endRefreshing()
        self.toDoCollection.mj_footer.endRefreshing()
        toDoCollection.reloadData()
    }
    
    @objc func refresh() {
        jds.removeAll()
        toDoCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
}

extension ToDoDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cellName = "c1"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        let headerBtn = cell.viewWithTag(10001) as! UIButton
        headerBtn.clipsToBounds = true
        headerBtn.layer.cornerRadius = 4
        
        //背景色
        var lbl = cell.viewWithTag(30001)
        lbl?.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        lbl?.layer.borderWidth = 1
        lbl?.clipsToBounds = true
        lbl?.layer.cornerRadius = 4
        lbl = cell.viewWithTag(60001)
        lbl?.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        lbl?.layer.borderWidth = 1
        lbl?.clipsToBounds = true
        lbl?.layer.cornerRadius = 4
        
        if cellSwitch[indexPath] ?? false{
            cell.viewWithTag(50001)?.isHidden = true
            cell.viewWithTag(50002)?.isHidden = true
        }else{
            cell.viewWithTag(50001)?.isHidden = false
            cell.viewWithTag(50002)?.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //点击cell时修改状态并刷新此cell
        if cellSwitch[indexPath] ?? false {
            cellSwitch[indexPath] = false
        }else{
            cellSwitch[indexPath] = true
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if jds.count == 1 || cellSwitch[indexPath] ?? false{
            return CGSize(width: UIScreen.width, height: 603)
        }else{
            return CGSize(width: UIScreen.width, height: 290)
        }
    }
    
}
