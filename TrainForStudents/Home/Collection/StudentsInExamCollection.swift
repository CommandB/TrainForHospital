//
//  StudentsInExamCollection.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/27.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class StudentsInExamCollection: UIViewController ,UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var jds = [JSON]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count=\(jds.count) \t")
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
        let btn = cell.viewWithTag(10001) as! UIButton
        btn.setCornerRadius(radius: btn.W - 2)
        btn.setImage(UIImage(named: "loginId"), for: .normal)
        let lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["personname"].stringValue
        
        print(data["personname"].stringValue)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: 60, height: 70)
    }

}

