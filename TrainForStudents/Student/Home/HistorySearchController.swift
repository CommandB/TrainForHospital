//
//  HistorySearchController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/5/8.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import SwiftyJSON

//历史搜索
typealias didSelectItemAtClorsure = (_ ds : [JSON], _ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void
class HistorySearchController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    var clorsureImpl : didSelectItemAtClorsure?
    var jds = [JSON]()
    var parentView : UIViewController? = nil
    var itemMaxWidth = 100
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = data["text"].stringValue
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
        if clorsureImpl != nil{
            clorsureImpl!(jds,collectionView,indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = jds[indexPath.item]
        let text = data["text"].stringValue
        var cellWidth = Int(text.getWidth() + 10)
        if cellWidth > itemMaxWidth{
            cellWidth = itemMaxWidth
        }
        return CGSize(width: cellWidth, height: 30)
    }
    
    
    
}
