//
//  QuestionnaireCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/10.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class QuestionnaireCollectionView : MyBaseCollectionView{
    
    var parentView : EvaluationCenterController? = nil
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cellName = "c1"
        let json = jsonDataSource[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        var lbl = cell.viewWithTag(10001) as? UILabel
        lbl?.text = json["questionname"].stringValue
        lbl = cell.viewWithTag(20001) as? UILabel
        lbl?.text = json["endtime"].stringValue.substring(to: 16)
        lbl = cell.viewWithTag(20002) as? UILabel
        lbl?.text = json["creatername"].stringValue
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width, height: 80)
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = jsonDataSource[indexPath.item]
        let vc = getViewToStoryboard("questionnaireView") as! QuestionnaireController
        vc.sheetId = data["sheetid"].stringValue
        parentView?.present(vc, animated: true, completion: nil)
    }
    
    @objc public override func refresh() {
        jsonDataSource = [JSON]()
//        parentView?.questionnaireCollection.mj_footer.resetNoMoreData()
        parentView?.getQuestionnaireDatasource()
    }
    
    @objc override func loadMore() {
        parentView?.questionnaireCollection.mj_footer.endRefreshingWithNoMoreData()
    }
    
    
}

