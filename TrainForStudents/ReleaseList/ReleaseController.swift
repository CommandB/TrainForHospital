//
//  ReleaseController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/31.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ReleaseController : UIViewController{
    
    @IBOutlet weak var btnCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        let currentDate = Date()
        (view.viewWithTag(10001) as! UILabel).text = "\(currentDate.day)"
        (view.viewWithTag(10002) as! UILabel).text = DateUtil.getWeek(currentDate)
        (view.viewWithTag(10003) as! UILabel).text = "\(currentDate.month)/\(currentDate.year)"
        
        btnCollection.delegate = self
        btnCollection.dataSource = self
        
        jds = UserDefaults.AppConfig.json(forKey: .teachingActivityType).arrayValue
        
        btnCollection.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        let app = (UIApplication.shared.delegate) as! AppDelegate
        let tabBar = (app.window?.rootViewController) as! MyTabBarController
        tabBar.selectedIndex = selectedTabBarIndex
        dismiss(animated: true, completion: nil)
    }
    
    
    
}


extension ReleaseController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        let i = jds.count - collectionView.numberOfItems(inSection: indexPath.section)
        let index = indexPath.item + i
        let btn = cell.viewWithTag(10001) as! UIButton
        if index >= 0 {
            btn.isHidden = false
            let data = jds[index]
            let title = data["traintypename"].stringValue
            var icon = UIImage(named: "fb-\(title)")
//            if icon?.size == nil{
                icon = UIImage(named: "其他教学活动")
//            }
            btn.setImage(icon, for: .normal)
            btn.setTitle(title, for: .normal)
        }else{
            btn.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = getViewToStoryboard("inspectView") as! InspectController
        
        let i = jds.count - collectionView.numberOfItems(inSection: indexPath.section)
        let index = indexPath.item + i
        if index >= 0 {
            vc.trainType = jds[index]
            present(vc, animated: true, completion: nil)
        }
    }
    
    
}
