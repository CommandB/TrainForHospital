//
//  FilesCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/14.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class FilesCollectionView : UICollectionView , UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    var jds = [JSON]()
    
    init(rect:CGRect){
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        
        super.init(frame: rect, collectionViewLayout: layout)
        
        self.backgroundColor = UIColor.groupTableViewBackground
        self.delegate = self
        self.dataSource = self
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "fileCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fileCell", for: indexPath)
        cell.backgroundColor = UIColor.white
        let icon = UIImageView.init(frame: CGRect(x: 25, y: 10, width: 45, height: 45))
        icon.image = UIImage(named: "ppt")
        
        let lbl_title = UILabel(frame: CGRect(x: 75, y: 10, width: UIScreen.width.subtracting(75), height: 22))
        lbl_title.text = "标题..."
        lbl_title.font = UIFont.systemFont(ofSize: 16)
        
        let lbl_creater = UILabel(frame: CGRect(x: 75, y: 35, width: 150, height: 20))
        lbl_creater.text = "上传人：张三"
        lbl_creater.font = UIFont.systemFont(ofSize: 14)
        
        let lbl_date = UILabel(frame: CGRect(x: 250, y: 38, width: UIScreen.width.subtracting(260), height: 16))
        lbl_date.text = "2018-07-23 10:30"
        lbl_date.font = UIFont.systemFont(ofSize: 12)
        lbl_date.textColor = UIColor.init(hex: "979797")
        lbl_date.textAlignment = .right
        
        cell.addSubview(icon)
        cell.addSubview(lbl_title)
        cell.addSubview(lbl_creater)
        cell.addSubview(lbl_date)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 65)
    }
}
