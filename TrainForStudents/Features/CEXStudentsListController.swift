//
//  CEXStudentsListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/18.
//  Copyright © 2018 黄玮晟. All rights reserved.
//


import Foundation
import UIKit
import SwiftyJSON

class CEXStudentsListController : HBaseViewController {
    
    @IBOutlet weak var students_collection: UICollectionView!
    
    var collectionDs = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.viewWithTag(22222)?.setBorderBottom(size: 1, color: UIColor.groupTableViewBackground)
        
        self.view.backgroundColor = .white
        
        students_collection.delegate = self
        students_collection.dataSource = self
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshAction))
        header?.setTitle("", for: .idle)
        self.students_collection.mj_header = header
        self.students_collection.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    @IBAction func btn_back_tui(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_history_tui(_ sender: UIButton) {
        //dismiss(animated: true, completion: nil)
    }
    
    
    func btn_score_tui(sender :UIButton){
        let vc = getViewToStoryboard("cexCheckView") as! CEXCheckController
        let index = (sender.superview?.superview?.tag)!
        let json = collectionDs[index]
        vc.studentId = json["personid"].intValue
        vc.studentName = json["personname"].stringValue
        //print(sender.superview?.superview?.tag)
        present(vc, animated: true, completion: nil)
    }
    
    func loadData(){
        let url = SERVER_PORT + "rest/app/getMiniCexStudent.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            self.students_collection?.mj_header.endRefreshing()
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    self.collectionDs = json["data"].arrayValue
                    print(self.collectionDs)
                    self.students_collection?.reloadData()
                }else{
                    
                }
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    func refreshAction() {
        collectionDs.removeAll()
        loadData()
    }
    
}



extension CEXStudentsListController :UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        let json = collectionDs[indexPath.item]
        cell.tag = indexPath.item
        
        let sex = json["sex"].stringValue == "1" ? "男":"女"
        (cell.viewWithTag(10002) as! UILabel).text = "\(json["personname"])(\(sex))"
        (cell.viewWithTag(20001) as! UILabel).text = "暂无数据 ~ 暂无数据"
        (cell.viewWithTag(10003) as! UIButton).addTarget(self, action: #selector(btn_score_tui), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width, height: 80)
    }
    
}
