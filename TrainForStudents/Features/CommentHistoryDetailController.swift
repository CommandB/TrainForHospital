//
//  CommentDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/13.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CommentHistoryDetailController : UIViewController{
    
    @IBOutlet weak var commentCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        commentCollection.delegate = self
        commentCollection.dataSource = self
        
        
    }

    
    @IBAction func btn_back_inside(_ sender: UIButton) {
                dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        commentCollection.reloadData()
    }
    
    func refresh() {
        jds.removeAll()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}

extension CommentHistoryDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        var starview = cell.viewWithTag(30001)
        if starview != nil{
            starview?.removeFromSuperview()
        }
        
        let lbl = cell.viewWithTag(20001)
        starview = ZYStarRateView.init(frame: (lbl?.frame)!, starCount: 5, currentStar: 2, rateStyle: .half) { (current) -> (Void) in
            print(current)
        }
        starview?.tag = 30001
        cell.addSubview(starview!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "commentView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 70)
    }
    
}
