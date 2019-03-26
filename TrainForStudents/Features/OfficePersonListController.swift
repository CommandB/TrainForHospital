//
//  OfficePersonListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/14.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class OfficePersonListController : HBaseViewController{
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    var jds = [JSON]()
    var officeId = "0"
    
    override func viewDidLoad() {
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
        personCollection.backgroundColor = UIColor(hex: "f5f8fb")
        
        personCollection.register(TitleReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        
        self.personCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.personCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.personCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        if officeId == "0" || officeId.isEmpty{
            officeId = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)!
        }
        
        let url = SERVER_PORT + "rest/app/getOfficePerson.do"
        myPostRequest(url, ["officeid":officeId], method: .post).responseJSON(completionHandler: { resp in
            
            self.personCollection.mj_header.endRefreshing()
            self.personCollection.mj_footer.endRefreshing()
            self.personCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result {
            case .success(let respStr):
                let json = JSON(respStr)
                if json["code"].intValue == 1{
                    self.jds = json["officepersonlist"].arrayValue
                    self.personCollection.reloadData()
                    print(self.jds)
                }else{
                    myAlert(self, message: "读取科室人员信息异常!")
                    print(json)
                }
            case .failure(let error):
                print(error)
            }
            
            
        })
        
    }
    
    @objc func refresh() {
        jds.removeAll()
        personCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    
    
}

extension OfficePersonListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds[section]["my_data_list"].arrayValue.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.section]["my_data_list"].arrayValue[indexPath.item]
        let name = data["personname"].stringValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        cell.setCornerRadius(radius: 4)
        let lbl = (cell.viewWithTag(10001) as! UILabel)
        lbl.text = name
        if name.count > 4{
            lbl.font = UIFont.systemFont(ofSize: 13)
        }else{
            lbl.font = UIFont.systemFont(ofSize: 15)
        }
        
        
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: 80, height: 30)
    }
    
    //展示section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind{
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath) as! TitleReusableView
            
            header.headerLb!.text = "  "+jds[indexPath.section]["rolename"].stringValue
            header.headerLb.font = UIFont.systemFont(ofSize: 17)
            header.headerLb.backgroundColor = UIColor.groupTableViewBackground
            
            return header
        default:
            return TitleReusableView()
        }
    }
    
    //分组的头部视图的尺寸，在这里控制分组头部视图的高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = 35
        return CGSize.init(width: UIScreen.main.bounds.size.width, height: CGFloat(height))
    }
    
}
