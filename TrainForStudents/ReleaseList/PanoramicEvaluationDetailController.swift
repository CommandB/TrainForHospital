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
    
    static var callbackNotificationName = NSNotification.Name(rawValue: "callbackNotificationName")
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    var parentIndexPath = IndexPath()
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
        keys = ([String](jds["evDic"].dictionaryValue.keys)).sorted()
        
        print("接受通知")
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PersonSelectorController.addPersonNotificationName, object: nil)
    }
    
    func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self)
        print("处理通知")
        if notification.userInfo != nil{
            let result = notification.userInfo!["data"] as! [JSON]
            var d = jds["data"]
            //studentsCollection.reloadData()
            switch selectedTabKey {
            case "nerse2s":
                jds["data"]["nurselist"] = JSON(d["nurselist"].arrayValue + result)
            case "dir2s":
                jds["data"]["directorylist"] = JSON(d["directorylist"].arrayValue + result)
            case "cm2s":
                jds["data"]["classmatelist"] = JSON(d["classmatelist"].arrayValue + result)
            case "se2s":
                jds["data"]["secretarylist"] = JSON(d["secretarylist"].arrayValue + result)
            case "t2s":
                jds["data"]["teacherlist"] = JSON(d["teacherlist"].arrayValue + result)
            case "s2t":
                jds["data"]["teacherlist"] = JSON(d["teacherlist"].arrayValue + result)
            case "s2o":
                  2
            default :
                break
            }
        }
        personCollection.reloadData()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        NotificationCenter.default.post(name: PanoramicEvaluationDetailController.callbackNotificationName, object: nil, userInfo: ["data":jds["data"],"indexPath": parentIndexPath])
        dismiss(animated: true, completion: nil)
    }
    
    func addPerson(sender :UIButton ){
        selectedTabKey = sender.viewParam!["key"] as! String
        let vc = getViewToStoryboard("personSelectorView") as! PersonSelectorController
        vc.officeId = jds["data"]["officeid"].intValue
        present(vc, animated: true, completion: nil)
    }
    
    func removePerson(sender :UIButton){
        let key = sender.viewParam!["key"] as! String
        let index = sender.viewParam!["index"] as! Int
        
        
//        switch key {
//        case "nerse2s":
//            jds["data"]["nurselist"].arrayValue.remove(at: index)
//        case "dir2s":
//            jds["data"]["directorylist"].arrayValue.remove(at: index)
//        case "cm2s":
//            jds["data"]["classmatelist"].arrayValue.remove(at: index)
//        case "se2s":
//            jds["data"]["secretarylist"].arrayValue.remove(at: index)
//        case "t2s":
//            jds["data"]["teacherlist"].arrayValue.remove(at: index)
//        case "s2t":
//            jds["data"]["teacherlist"].arrayValue.remove(at: index)
//        case "s2o":
//            break
//        default :
//            break
//        }
        let jsonKey = getJsonKey(key: key)
        var arr = jds["data"][jsonKey].arrayValue
        arr.remove(at: index)
        jds["data"][jsonKey] = JSON(arr)
        personCollection.reloadData()
    }
    
    func getJsonKey(key : String) -> String{
        
        switch key {
        case "nerse2s":
            return "nurselist"
        case "dir2s":
            return "directorylist"
        case "cm2s":
            return "classmatelist"
        case "se2s":
            return "secretarylist"
        case "t2s":
            return "teacherlist"
        case "s2t":
            return "teacherlist"
        case "s2o":
            return "officelist"
        default :
            break
        }
        return ""
    }
    
}







extension PanoramicEvaluationDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return keys.count
    }
    
    //设置每个section有几个item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch keys[section] {
//        case "nerse2s":
//            return jds["data"]["nurselist"].count + 1
//        case "dir2s":
//            return jds["data"]["directorylist"].count + 1
//        case "cm2s":
//            return jds["data"]["classmatelist"].count + 1
//        case "se2s":
//            return jds["data"]["secretarylist"].count + 1
//        case "t2s":
//            return jds["data"]["teacherlist"].count + 1
//        case "s2t":
//            return jds["data"]["teacherlist"].count + 1
//        case "s2o":
//            return 2
//        default:
//            break
//        }
        let key = getJsonKey(key: keys[section])
        if key == "officelist"{
            return 2
        }
        return jds["data"][key].count + 1
    }
    
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if indexPath.item == 0{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            let lbl = cell.viewWithTag(10001) as! UILabel
            let btn = cell.viewWithTag(10002) as! UIButton
            btn.addTarget(self, action: #selector(addPerson), for: .touchUpInside)
            btn.viewParam = ["key" : keys[indexPath.section]]
            btn.isHidden = false
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
            let index = indexPath.item - 1
            var data = cellData[index]
            //print(data)
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            var lbl = cell.viewWithTag(10001) as! UILabel
            lbl.text = data["personname"].stringValue
            lbl = cell.viewWithTag(10002) as! UILabel
            lbl.text = "工号:"
            let btn = cell.viewWithTag(10003) as! UIButton
            btn.viewParam = ["key" : keys[indexPath.section] ,"index" : index]
            btn.addTarget(self, action: #selector(removePerson(sender:)), for: .touchUpInside)
            //如果是科室 则隐藏工号和 删除按钮
            if data["officeid"].stringValue != ""{
                lbl.isHidden = true
                btn.isHidden = true
            }else{
                lbl.isHidden = false
                btn.isHidden = false
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
