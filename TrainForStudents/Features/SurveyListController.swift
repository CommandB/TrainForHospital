//
//  SurveyListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/5/5.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SurveyListController : HBaseViewController{
    
    @IBOutlet weak var surveyCollection: UICollectionView!
    
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        surveyCollection.delegate = self
        surveyCollection.dataSource = self
        
        self.surveyCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.surveyCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.surveyCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){

        let url = SERVER_PORT+"rest/questionnaire/queryAllQuestionnaire.do"
        myPostRequest(url,["personid":UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)!]).responseJSON(completionHandler: {resp in
            self.surveyCollection.mj_header.endRefreshing()
            self.surveyCollection.mj_footer.endRefreshingWithNoMoreData()
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                    self.surveyCollection.reloadData()
                }else{
                    myAlert(self, message: "请求调查问卷列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })

    }
    
    @objc func refresh() {
        jds.removeAll()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
}

extension SurveyListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cellName = "c1"
        let json = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        print(jds)
        var lbl = cell.viewWithTag(10001) as? UILabel
        lbl?.text = json["questionname"].stringValue
        lbl = cell.viewWithTag(20001) as? UILabel
        lbl?.text = json["endtime"].stringValue
//        .substring(to: 16)
        lbl = cell.viewWithTag(20002) as? UILabel
        lbl?.text = json["creater"].stringValue
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width, height: 80)
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = jds[indexPath.item]
        let vc = getViewToStoryboard("questionnaireView") as! QuestionnaireController
        vc.sheetId = data["sheetid"].stringValue
        present(vc, animated: true, completion: nil)
    }
    
}
