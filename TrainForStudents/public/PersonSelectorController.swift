//
//  PersonSelectorController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/24.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PersonSelectorController: HBaseViewController {
    
    static var addStudentsNotificationName = NSNotification.Name(rawValue: "addStudentsNotification")
    @IBOutlet weak var personCollection: UICollectionView!
    
    var jds = [JSON]()
    var selectedList = [IndexPath:JSON]()
    var cellIsSelected = [IndexPath:Bool]()
    
    override func viewDidLoad() {
        
        personCollection.delegate = self
        personCollection.dataSource = self
        personCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        personCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        let txt = view.viewWithTag(10001) as! UITextField
        txt.delegate = self
        var btn = view.viewWithTag(20001) as! UIButton
        btn.set(image: UIImage(named: "未选择-小"), title: "当前科室", titlePosition: .left, additionalSpacing: -35.0, state: .normal)
        btn.addTarget(self, action: #selector(touchCheckbox), for: .touchUpInside)
        btn = view.viewWithTag(20002) as! UIButton
        btn.set(image: UIImage(named: "未选择-小"), title: "所有人员", titlePosition: .left, additionalSpacing: -35.0, state: .normal)
        btn.addTarget(self, action: #selector(touchCheckbox), for: .touchUpInside)
        btn = view.viewWithTag(20003) as! UIButton
        btn.set(image: UIImage(named: "未选择-小"), title: "本科室", titlePosition: .left, additionalSpacing: -35.0, state: .normal)
        btn.addTarget(self, action: #selector(touchCheckbox), for: .touchUpInside)
        
        
        personCollection.mj_header.beginRefreshing()
        
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        print(selectedList)
        var data = [JSON]()
        for v in selectedList.values{
            data.append(v)
        }
        NotificationCenter.default.post(name: PersonSelectorController.addStudentsNotificationName, object: self, userInfo: ["data":data])
        dismiss(animated: true, completion: nil)
    }
    
    func touchCheckbox(btn :UIButton){
        super.hiddenKeyBoard()
        if btn.isSelected{
            btn.setImage(UIImage(named: "未选择-小"), for: .normal)
        }else{
            btn.setImage(UIImage(named: "选择-小"), for: .normal)
        }
        btn.isSelected = !btn.isSelected
    }
    
    //下载数据
    func getListData(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "/rest/app/searchPerson.do"
        myPostRequest(url,["officeid":143]).responseJSON(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.personCollection.mj_header.endRefreshing()
            self.personCollection.mj_footer.endRefreshing()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    self.jds = json["data"].arrayValue
                    //print(self.jds)
                    self.personCollection.mj_footer.endRefreshingWithNoMoreData()
                }else{
                    myAlert(self, message: "请求人员列表失败!")
                }
                
                
                self.personCollection.reloadData()
                
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    func refresh() {
        jds.removeAll()
        personCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func loadMore() {
        getListData()
    }
    
}


extension PersonSelectorController : UICollectionViewDelegate ,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let data = jds[indexPath.item]
        var lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["name"].stringValue
        lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = "【\(data["type"].stringValue)】"
        let btn = cell.viewWithTag(10003) as! UIButton
        if cellIsSelected[indexPath] ?? false{
            btn.setImage(UIImage(named: "选择-大"), for: .normal)
        }else{
            btn.setImage(UIImage(named: "未选择-大"), for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.hiddenKeyBoard()
        let data = jds[indexPath.item]
        if cellIsSelected[indexPath] ?? false{
            selectedList.removeValue(forKey: indexPath)
        }else{
            selectedList[indexPath] = data
        }
        cellIsSelected[indexPath] = !(cellIsSelected[indexPath] ?? false)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 40)
    }
    
    
}

extension PersonSelectorController{
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        refresh()
        return true
    }
}
