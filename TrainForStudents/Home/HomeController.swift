//
//  StudentsHome.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/7/23.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import UIKit

class HomeController : UIViewController{
    
    @IBOutlet weak var homeCollection: UICollectionView!
    
    override func viewDidLoad() {
        
        homeCollection.delegate = self
        homeCollection.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeCollection.reloadData()
    }
    
}

extension HomeController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        switch indexPath.item {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statisticCell", for: indexPath)
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
            var btn = cell.viewWithTag(30001) as! UIButton
            btn.set(image: nil, title: "考试未通过", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(30002) as! UIButton
            btn.set(image: nil, title: "缺勤天数", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(30003) as! UIButton
            btn.set(image: nil, title: "科室满意度", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(50001) as! UIButton
            btn.set(image: nil, title: "师资绩效积分", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
            btn = cell.viewWithTag(50002) as! UIButton
            btn.set(image: nil, title: "带教统计", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
            btn = cell.viewWithTag(50003) as! UIButton
            btn.set(image: nil, title: "待评事件", titlePosition: .bottom, additionalSpacing: 20.0, state: .normal)
            break
        case 1,2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingCell", for: indexPath)
            let bg = cell.viewWithTag(11111) as! UILabel
            bg.clipsToBounds = true
            bg.layer.cornerRadius = 8
            break
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuresCell", for: indexPath)
            var btn = cell.viewWithTag(10001) as! UIButton
            btn.set(image: nil, title: "360评价", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(10002) as! UIButton
            btn.set(image: nil, title: "出科考试", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(10003) as! UIButton
            btn.set(image: nil, title: "教学督查", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(20001) as! UIButton
            btn.set(image: nil, title: "入科安排", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(20002) as! UIButton
            btn.set(image: nil, title: "考情登记", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            btn = cell.viewWithTag(20003) as! UIButton
            btn.set(image: nil, title: "学员轮转", titlePosition: .bottom, additionalSpacing: 30.0, state: .normal)
            break
        case 4:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classTitleCell", for: indexPath)
            break
        case 5,6:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath)
            let btn_headShow = cell.viewWithTag(10001) as! UIButton
            btn_headShow.clipsToBounds = true
            btn_headShow.layer.cornerRadius = btn_headShow.frame.width.divided(by: 2)
            var lbl = cell.viewWithTag(10002) as! UILabel
            lbl = cell.viewWithTag(10003) as! UILabel
            lbl = cell.viewWithTag(20001) as! UILabel
            lbl = cell.viewWithTag(20002) as! UILabel
            lbl.clipsToBounds = true
            lbl.layer.cornerRadius = lbl.frame.width.divided(by: 2)
            break
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.item {
        case 0:
            return CGSize(width: UIScreen.width.subtracting(20), height: 200)
        case 1,2:
            return CGSize(width: UIScreen.width, height: 165)
        case 3:
            return CGSize(width: UIScreen.width, height: 160)
        case 4:
            return CGSize(width: UIScreen.width, height: 40)
        case 5,6:
            return CGSize(width: UIScreen.width, height: 60)
        default:
            return CGSize(width: UIScreen.width, height: 100)
        }
    }
    
}
