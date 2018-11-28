//
//  PanoramicEvaluationDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/27.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PanoramicEvaluationDetailController : UIViewController{
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    var jds = JSON()
    var keys = [String]()
    var cellData = [JSON]()
    var selectedTabKey = ""
    
    override func viewDidLoad() {
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
        //getListData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let lbl = view.viewWithTag(22222) as! UILabel
        lbl.text = jds["data"]["personname"].stringValue
        keys = [String](jds["evDic"].dictionaryValue.keys)
        personCollection.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PersonSelectorController.addPersonNotificationName, object: nil)
    }
    
    func receiveNotice(notification : NSNotification){
        if notification.userInfo != nil{
            let result = notification.userInfo!["data"] as! [JSON]
            var d = jds["data"]
            //studentsCollection.reloadData()
            switch selectedTabKey {
            case "nerse2s":
                d["nurselist"] = JSON(d["nurselist"].arrayValue + result)
            case "dir2s":
                d["directorylist"] = JSON(d["directorylist"].arrayValue + result)
            case "cm2s":
                d["classmatelist"] = JSON(d["classmatelist"].arrayValue + result)
            case "se2s":
                d["secretarylist"] = JSON(d["secretarylist"].arrayValue + result)
            case "t2s":
                d["teacherlist"] = JSON(d["teacherlist"].arrayValue + result)
            case "s2t":
                d["teacherlist"] = JSON(d["teacherlist"].arrayValue + result)
            case "s2o":
                  2
            default :
                break
            }
            personCollection.reloadData()
        }
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func addPerson(sender :UIButton ){
        selectedTabKey = sender.viewParam!["key"] as! String
        let vc = getViewToStoryboard("personSelectorView") as! PersonSelectorController
        vc.officeId = jds["data"]["officeid"].intValue
        present(vc, animated: true, completion: nil)
    }
    
}

extension PanoramicEvaluationDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch keys[section] {
        case "nerse2s":
            return jds["data"]["nurselist"].count + 1
        case "dir2s":
            return jds["data"]["directorylist"].count + 1
        case "cm2s":
            return jds["data"]["classmatelist"].count + 1
        case "se2s":
            return jds["data"]["secretarylist"].count + 1
        case "t2s":
            return jds["data"]["teacherlist"].count + 1
        case "s2t":
            return jds["data"]["teacherlist"].count + 1
        case "s2o":
            return 2
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        var cell = UICollectionViewCell()
        
        if indexPath.item == 0{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            let lbl = cell.viewWithTag(10001) as! UILabel
            let btn = cell.viewWithTag(10002) as! UIButton
            btn.addTarget(self, action: #selector(addPerson), for: .touchUpInside)
            btn.viewParam = ["key" : keys[indexPath.section]]
            switch keys[indexPath.section] {
            case "nerse2s":
                cellData = jds["data"]["nurselist"].arrayValue
                lbl.text = "已选择\(jds["data"]["nurselist"].count)位护士"
            case "dir2s":
                cellData = jds["data"]["directorylist"].arrayValue
                lbl.text = "已选择\(jds["data"]["directorylist"].count)位科主任"
            case "cm2s":
                cellData = jds["data"]["classmatelist"].arrayValue
                lbl.text = "已选择\(jds["data"]["classmatelist"].count)位同科同学"
            case "se2s":
                cellData = jds["data"]["secretarylist"].arrayValue
                lbl.text = "已选择\(jds["data"]["secretarylist"].count)位科室秘书"
            case "t2s":
                cellData = jds["data"]["teacherlist"].arrayValue
                lbl.text = "已选择\(jds["data"]["nurselist"].count)位带教老师"
            case "s2t":
                cellData = jds["data"]["teacherlist"].arrayValue
                lbl.text = "已选择\(jds["data"]["teacherlist"].count)位带教老师"
            case "s2o":
                cellData = JSON([["officeid":UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue) ,"personname":UserDefaults.standard.string(forKey: LoginInfo.officeName.rawValue)]]).arrayValue
                lbl.text = "已选择1个科室"
                btn.isHidden = true
            default:
                break
            }
            
        }else{
            var data = cellData[indexPath.item - 1]
            print(data)
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            var lbl = cell.viewWithTag(10001) as! UILabel
            lbl.text = data["personname"].stringValue
            lbl = cell.viewWithTag(10002) as! UILabel
            lbl.text = "工号:"
            let btn = cell.viewWithTag(10003) as! UIButton
            
            
            //如果是科室 则隐藏工行和 删除按钮
            if data["officeid"].stringValue != ""{
                lbl.isHidden = true
                btn.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0 {
            return CGSize(width: UIScreen.width, height: 40)
        }
        return CGSize(width: UIScreen.width, height: 50)
    }
    
}
