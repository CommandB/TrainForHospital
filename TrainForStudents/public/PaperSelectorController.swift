//
//  PaperSelectorController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/21.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PaperSelectorController : HBaseViewController{
    
    @IBOutlet weak var paperCollection: UICollectionView!
    
    var jds = [JSON]()
    let questionsView = DirectoryCollectionView()
    var selectedIndex = IndexPath()
    var questionCache = [String:[JSON]]()
    
    override func viewDidLoad() {
        
        paperCollection.delegate = self
        paperCollection.dataSource = self
        
        
        self.paperCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.paperCollection.mj_header.beginRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.paperCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        
    }
    
    func getListData(){
        self.paperCollection.mj_header.endRefreshing()
        
        let url = SERVER_PORT + "rest/app/getTheoryExercisesList.do"
        //下载试卷
        myPostRequest(url, method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    
                    self.jds = json["data"].arrayValue
                    
                    self.paperCollection.reloadData()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "加载试卷异常!")
                print(error)
                break
            }
        })
        
        
    }
    
    func refresh() {
        jds.removeAll()
        getListData()
    }
    
    func requestQuestions(exercisesId :String ,collection : UICollectionView){
        
        MBProgressHUD.showAdded(to: collection, animated: true)
        let url = SERVER_PORT + "rest/app/getTheoryExercisesDetail.do"
        myPostRequest(url, ["exercisesid": exercisesId], method: .post).responseString(completionHandler :{resp in
            MBProgressHUD.hideAllHUDs(for: collection, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.questionsView.jsonDataSource = json["data"].arrayValue
                    
                    //缓存考题
                    self.questionCache[exercisesId] = json["data"].arrayValue
                    collection.reloadData()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "加载试卷异常!")
                print(error)
                break
            }
        })
        
    }
    
    
}

extension PaperSelectorController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 20
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let exercisesId = data["exercisesid"].stringValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        (cell.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
        (cell.viewWithTag(20001) as! UILabel).text = data["creater"].stringValue
        (cell.viewWithTag(20002) as! UILabel).text = data["score"].stringValue + "分"
        
        
        if selectedIndex == indexPath{
            let questionsCollection = cell.viewWithTag(30001) as! UICollectionView
            questionsCollection.delegate = questionsView
            questionsCollection.dataSource = questionsView
            questionsCollection.register(TitleReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
            
            questionsView.jsonDataSource = [JSON]()
            questionsCollection.reloadData()
            
            if let questionData = questionCache[exercisesId]{
                print("用了缓存")
                questionsView.jsonDataSource = questionData
            }else{
                print("请求的试卷ID=\(exercisesId)")
                requestQuestions(exercisesId: exercisesId, collection: questionsCollection)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedIndex == indexPath{
            selectedIndex = IndexPath()
        }else{
            selectedIndex = indexPath
        }
        collectionView.reloadData()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if selectedIndex == indexPath{
            return CGSize(width: UIScreen.width, height: 238)
        }else{
            return CGSize(width: UIScreen.width, height: 60)
        }
        
    }
    
}
