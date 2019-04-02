//
//  HistorySkillExamController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/26.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class HistorySkillExamController : HBaseViewController{
    
    @IBOutlet weak var questionCollection: UICollectionView!
    
    @IBOutlet weak var btn_prev: UIButton!
    
    @IBOutlet weak var btn_next: UIButton!
    
    var jds = [JSON]()
    var paramData = JSON()
    var questionIndex = 0
    
    override func viewDidLoad() {
        
        questionCollection.delegate = self
        questionCollection.dataSource = self
        getListData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.questionCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_prev_inside(_ sender: UIButton) {
        
        btn_next.isHidden = false
        questionIndex -= 1
        
        if questionIndex == 0 {
            btn_prev.isHidden = true
        }
        
        questionCollection.reloadData()
    }
    
    @IBAction func btn_next_inside(_ sender: UIButton) {
        
        btn_prev.isHidden = false
        questionIndex += 1
        
        if questionIndex == jds.count - 1 {
            btn_next.isHidden = true
        }
        
        questionCollection.reloadData()
    }
    
    func getListData(){
        
        
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT+"rest/app/getSkillExamInfo.do"
        
        myPostRequest(url,["personid":paramData["buid"].intValue, "examroomid":paramData["examroomid"].stringValue]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                                //print(json)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                    (self.view.viewWithTag(10001) as! UILabel).text = self.jds[0]["questionstitle"].stringValue
                    
                    if self.jds.count > 1{
                        self.btn_next.isHidden = false
                    }
                    
                }else{
                    myAlert(self, message: "请求考试列表失败!")
                }
                self.questionCollection.reloadData()
            case .failure(let error):
                print(error)
            }
            
        })
    }
}

extension HistorySkillExamController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if jds.count == 0{
            return 0
        }
        return jds[questionIndex]["item"].arrayValue.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[questionIndex]["item"].arrayValue[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let itemTitle = data["indexname"].stringValue + data["title"].stringValue
        (cell.viewWithTag(10001) as! UILabel).text = itemTitle
        (cell.viewWithTag(10002) as! UILabel).text = "\(data["getscore"].stringValue)/\(data["score"].stringValue)"
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let lineHeight = 16
        let data = jds[questionIndex]["item"].arrayValue[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let itemTitle = data["indexname"].stringValue + data["title"].stringValue
        let lineNumber = itemTitle.getLineNumberForUILabel(cell.viewWithTag(10001) as! UILabel)
        
        return CGSize(width: collectionView.W, height: CGFloat(lineNumber * lineHeight + 20))
    }
    
}
