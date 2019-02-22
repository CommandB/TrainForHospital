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
    
    var officeId = 0
    var notReload = false
    var isSkillExam = false
    
    static var defaultNoticeName = NSNotification.Name(rawValue: "paperSelectorDefaultNoticeName")
    
    @IBOutlet weak var paperCollection: UICollectionView!
    
    var jds = [JSON]()
    let questionsView = DirectoryCollectionView()
    var selectedIndex = IndexPath()
    var questionCache = [String:[JSON]]()
    
    override func viewDidLoad() {
        
        paperCollection.delegate = self
        paperCollection.dataSource = self
        
        if officeId == 0 {
            officeId = UserDefaults.standard.integer(forKey: LoginInfo.officeId.rawValue)
        }
        
        self.paperCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        
        //如果已经有缓存 则不用重新加载
        if notReload{
            jds = UserDefaults.AppConfig.json(forKey: .subjectExamPaper).arrayValue
            if jds.count == 0{
                self.paperCollection.mj_header.beginRefreshing()
            }else{
                paperCollection.reloadData()
            }
        }else{
            getListData()
        }
        print("notReload:\(notReload)")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.paperCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        
        
        if selectedIndex != IndexPath(){
            NotificationCenter.default.post(name: PaperSelectorController.defaultNoticeName, object: nil, userInfo: ["data":jds[selectedIndex.section].arrayValue[selectedIndex.item - 1]])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        self.paperCollection.mj_header.endRefreshing()
        
        var url = ""
        if isSkillExam{
            url = SERVER_PORT + "rest/app/getSkillExercisesList.do"
        }else{
            url = SERVER_PORT + "rest/app/getTheoryExercisesList.do"
        }
        //下载试卷
        myPostRequest(url, ["officeid":officeId], method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    
                    self.jds = [JSON]()
                    self.jds.append(json["dataByMe"])
                    self.jds.append(json["dataByOffice"])
                    self.jds.append(json["data"])
                    //缓存试卷
                    UserDefaults.AppConfig.set(value: self.jds.description, forKey: .subjectExamPaper)
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
    
    ///请求试题
    func requestQuestions(exercisesId :String ,vn:String ,collection : UICollectionView){
        
        MBProgressHUD.showAdded(to: collection, animated: true)
        let url = SERVER_PORT + "rest/app/getTheoryExercisesDetail.do"
        myPostRequest(url, ["exercisesid": exercisesId , "versionnumber":""], method: .post).responseString(completionHandler :{resp in
            MBProgressHUD.hideAllHUDs(for: collection, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    let data = json["data"].arrayValue
                    self.questionsView.jsonDataSource = data
                    
                    //缓存考题
                    self.questionCache[exercisesId] = data
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if jds.count > section{
            let count = jds[section].arrayValue.count
            if count > 0{
                //因为第一个cell要显示分类 所以显示的总数要+1
                return count + 1
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            
            switch indexPath.section{
                case 0:
                    (cell.viewWithTag(10001) as! UILabel).text = "我的试卷"
                case 1:
                    (cell.viewWithTag(10001) as! UILabel).text = "科室试卷"
                case 2:
                    (cell.viewWithTag(10001) as! UILabel).text = "全部试卷"
                default:
                    break
            }
            
            return cell
        }else{
            let data = jds[indexPath.section].arrayValue[indexPath.item - 1]
            let exercisesId = data["exercisesid"].stringValue
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            
            cell.viewWithTag(10000)?.isHidden = true
            (cell.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
            (cell.viewWithTag(20001) as! UILabel).text = data["creater"].stringValue
            (cell.viewWithTag(20002) as! UILabel).text = data["score"].stringValue + "分"
            
            
            if selectedIndex == indexPath{
                cell.viewWithTag(10000)?.isHidden = false
                
                if !isSkillExam{
                    
                    let questionsCollection = cell.viewWithTag(30001) as! UICollectionView
                    questionsCollection.delegate = questionsView
                    questionsCollection.dataSource = questionsView
                    questionsCollection.register(TitleReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
                    
                    questionsView.jsonDataSource = [JSON]()
                    questionsCollection.reloadData()
                    
                    if let questionData = questionCache[exercisesId]{
                        print("读取已缓存的试题")
                        questionsView.jsonDataSource = questionData
                    }else{
                        print("请求的试卷ID=\(exercisesId)")
                        requestQuestions(exercisesId: exercisesId, vn: data["versionnumber"].stringValue, collection: questionsCollection)
                    }
                }
                
                
            }
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.item == 0{
            return false
        }
        if selectedIndex == indexPath{
            selectedIndex = IndexPath()
        }else{
            selectedIndex = indexPath
        }
        collectionView.reloadData()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0{
            return CGSize(width: UIScreen.width, height: 40)
        }else if selectedIndex == indexPath && !isSkillExam{
            return CGSize(width: UIScreen.width, height: 238)
        }else{
            return CGSize(width: UIScreen.width, height: 60)
        }
        
    }
    
}
