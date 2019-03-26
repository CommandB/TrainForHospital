//
//  EvaluationDetailCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/27.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EvaluationDetailCollectionView : UIViewController,  UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    var parentVC : EvaluationDetailController? = nil
    var jsonDataSource = JSON([:])
    var isReadonly = false
    
    //设置collectionView的分区个数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //设置每个分区元素的个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return jsonDataSource.count * 2
        
    }
    
    //实现UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        var cellName = "c1"
        var index = 0
        
        if indexPath.item == 0{
            index = 0
            cellName = "c1"
        }else if indexPath.item % 2 == 0{
            index = indexPath.item / 2
            cellName = "c1"
        }else{
            index = (indexPath.item - 1) / 2
            cellName = "c2"
        }
        
        let data = jsonDataSource[index]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        if cellName == "c1"{
            let lbl = cell.viewWithTag(10001) as? UILabel
            lbl?.text = data["itemtitle"].stringValue
        }else{
            let slider = cell.viewWithTag(10001) as! UISlider
            let selectedNumber = data["get_value"].int
            var lightNumber = data["starsvalue"].intValue
            if selectedNumber != nil{
                lightNumber = selectedNumber!
            }
            if isReadonly { //只读
                lightNumber = data["numbervalue"].intValue
                slider.isEnabled = false
            }
            let maxStarNumber = data["starsvalue"].intValue * data["numbervalue"].intValue
            
            slider.viewParam = ["index":index ,"maxValue" : maxStarNumber ,"indexPath":indexPath]
            slider.minimumValue = 0
            slider.maximumValue = Float(maxStarNumber)
            slider.value = Float(lightNumber)
            slider.addTarget(self, action: #selector(setScore), for: .valueChanged)
            
            //展示分数
            let lbl = cell.viewWithTag(10002) as! UILabel
            lbl.text = "\(lightNumber)/\(maxStarNumber)分"
            
        }
        
        return cell
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(indexPath.item)
        
    }
    
    //设置cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 45)
        
    }
    
    @objc func setScore(sender : UISlider){
        
        let indexPath = sender.viewParam!["indexPath"] as! IndexPath
        let index = sender.viewParam!["index"] as! Int
        //四舍五入
        let score = lroundf(sender.value)
        jsonDataSource[index]["get_value"] = JSON(score)
        parentVC!.detailCollection.reloadItems(at: [indexPath])
    }
    
}
