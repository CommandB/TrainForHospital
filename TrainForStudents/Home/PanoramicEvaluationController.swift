//
//  PanoramicEvaluationController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/26.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

/*
 
 老师--学生
 秘书--学生
 主任--学生
 护士--学生
 同学--学生
 学生--老师
 学生--科室
 
 */


class PanoramicEvaluationController : HBaseViewController{
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    let datePicker = UIPickerView()
    
    var jds = [JSON]()
    ///各种评价表的dic
    var evDic = [String : JSON]()
    
    var officeId = 0
    var officePicker = UIPickerView()
    let officePickerImpl = HSimplePickerViewImpl()
    
    override func viewDidLoad() {
        
        datePicker.delegate = self
        datePicker.dataSource = self
        datePicker.setWidth(width: UIScreen.width)
        datePicker.setHight(height: 250)
        datePicker.setY(y: UIScreen.height - (250))
        datePicker.isHidden = true
        datePicker.backgroundColor = UIColor(hex:"D0D3D9")
        datePicker.selectRow(1, inComponent: 0, animated: true)
        view.addSubview(datePicker)
        
        
        officeId = UserDefaults.standard.integer(forKey: LoginInfo.officeId.rawValue)
        let officeList = UserDefaults.AppConfig.json(forKey: .officeList).arrayValue
        var myManager = [JSON]()
        for office in officeList{
            if office["ismymanage"].intValue == 1{
                myManager.append(office)
            }
        }
        
        //判断当前科室在数据源中的索引..方便显示
        var index = 0
        for office in myManager{
            if office["officeid"].intValue == officeId{
                break
            }
            index += 1
        }
        
        officePicker = officePickerImpl.getDefaultPickerView()
        officePickerImpl.titleKey = "officename"
        officePickerImpl.clorsureImpl = addrClosureImpl
        officePickerImpl.dataSource = myManager
        officePicker.selectRow(index, inComponent: 0, animated: true)
        
        let txt = view.viewWithTag(10000) as! TextFieldForNoMenu
        txt.inputView = officePicker
        txt.text = UserDefaults.standard.string(forKey: LoginInfo.officeName.rawValue)
        txt.delegate = self
        
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
        self.personCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.personCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        var btn = view.viewWithTag(10001) as! UIButton
        btn.setTitle("\(Date().month)月", for: .normal)
        btn.setCornerRadius(radius: btn.W / 2)
        btn.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        let lbl = view.viewWithTag(10002) as! UILabel
        lbl.text = "\(Date().year)"
        
        btn = view.viewWithTag(30002) as! UIButton
        btn.addTarget(self, action: #selector(presentDimension), for: .touchUpInside)
        
        self.personCollection.mj_header.beginRefreshing()
        
        //增加手势 在点击view之后 隐藏pdatepicker
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closePickerView))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        datePicker.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PanoramicEvaluationDetailController.callbackNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice2), name: EvaluationDimensionController.callbackNotificationName, object: nil)
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        
        myConfirm(self, message: "是否确认发布?" ,okTitle: "是" ,cancelTitle: "否", okHandler : { action in
            self.sureSubmit()
        })
        
    }
    
    @objc func showDatePicker(sender: UIButton){
        hiddenKeyBoard()
        datePicker.isHidden = !datePicker.isHidden
    }
    
    //确认发布
    func sureSubmit(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "rest/app/release360evaluate.do"
        let officeId = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)
        
        var param = ["officeid":officeId , "studentlist" : jds] as [String : Any]
        
        for key in evDic.keys{
            switch key{
            case "nerse2s":
                param["NurseEvStudent"] = evDic[key]!
            case "dir2s":
                param["DirectorEvStudent"] = evDic[key]!
            case "cm2s":
                param["ClassmateEvStudent"] = evDic[key]!
            case "se2s":
                param["SecretaryEvStudent"] = evDic[key]!
            case "t2s":
                param["TeacherEvStudent"] = evDic[key]!
            case "s2t":
                param["StudentEvTeacher"] = evDic[key]!
            case "s2o":
                param["StudentEvOffice"] = evDic[key]!
            default:
                break
            }
        }
        
        myPostRequest(url, param, method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    myAlert(self, message: "发布成功!" , handler : {action in
                        self.dismiss(animated: true, completion: nil)
                    })
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "发布异常!")
                print(error)
                break
            }
        })
    }
    
    @objc func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: PanoramicEvaluationDetailController.callbackNotificationName, object: nil)
        //print("处理通知")
        if notification.userInfo != nil{
            let result = notification.userInfo!["data"] as! JSON
            let index = notification.userInfo!["indexPath"] as! IndexPath
            jds[index.item] = result
            //print(jds[index.item])
        }
    }
    
    @objc func receiveNotice2(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: EvaluationDimensionController.callbackNotificationName, object: nil)
        //print("处理通知")
        if notification.userInfo != nil{
            let result = notification.userInfo!["data"] as! [String : JSON]
            evDic = result
        }
    }
    
    @objc func presentDimension(){
        let vc = getViewToStoryboard("evaluationDimensionView") as! EvaluationDimensionController
        vc.evDic = evDic
        present(vc, animated: true, completion: nil)
    }
    
    func getListData(){
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let url = SERVER_PORT + "rest/app/getPreExitOfficePerson.do"
        var month = (view.viewWithTag(10001) as! UIButton).title(for: .normal)
        let year = (view.viewWithTag(10002) as! UILabel).text
        if (month?.count)! < 3{
            month = "0" + month!
        }
        let paramMonth = (year! + month!).replacingOccurrences(of: "月", with: "")
        
        //print("paramMonth:\(paramMonth)")
        myPostRequest(url, ["officeid":officeId ,"month":paramMonth ,"fortype":"evaluation"], method: .post).responseString(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.personCollection.mj_header.endRefreshing()
            self.personCollection.mj_footer.endRefreshing()
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    let data = json["data"].arrayValue
                    let lbl = self.view.viewWithTag(20001) as! UILabel
                    lbl.text = "出科人员清单(\(data.count))"
                    self.jds = data
                    
                    //evDic
                    self.evDic["nerse2s"] = json["NurseEvStudent"]
                    self.evDic["dir2s"] = json["DirectorEvStudent"]
                    self.evDic["cm2s"] = json["ClassmateEvStudent"]
                    self.evDic["se2s"] = json["SecretaryEvStudent"]
                    self.evDic["t2s"] = json["TeacherEvStudent"]
                    self.evDic["s2t"] = json["StudentEvTeacher"]
                    self.evDic["s2o"] = json["StudentEvOffice"]
                    
                    var total = 0
                    for k in self.evDic.keys{
                        if self.evDic[k]?.count != 0{
                            total += 1
                        }
                    }
                    (self.view.viewWithTag(30001) as! UILabel).text = "共\(total)个评价维度"
                    
                    
                    self.personCollection.reloadData()
                    self.personCollection.mj_footer.endRefreshingWithNoMoreData()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取人员列表异常!")
                print(error)
                break
            }
        })
        
        personCollection.reloadData()
    }
    
    @objc func refresh() {
        jds.removeAll()
        personCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
    @objc func closePickerView(){
        datePicker.isHidden = true
    }
    
    func addrClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        let text = ds[row]["officename"].stringValue
        let txt = view.viewWithTag(10000) as! TextFieldForNoMenu
        txt.text = text
        officeId = ds[row]["officeid"].intValue
        getListData()
    }
    
}

extension PanoramicEvaluationController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let btn_avatar = cell.viewWithTag(10001) as! UIButton
        btn_avatar.setCornerRadius(radius: btn_avatar.W / 2)
        var lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["personname"].stringValue
        lbl = cell.viewWithTag(10003) as! UILabel
        lbl.text = ""
        lbl = cell.viewWithTag(10004) as! UILabel
        lbl.text = "\(data["starttime"].stringValue) - \(data["endtime"].stringValue)"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = getViewToStoryboard("panoramicEvaluationDetailDetail") as! PanoramicEvaluationDetailController
        vc.jds["evDic"] = JSON(evDic)
        vc.jds["data"] = jds[indexPath.item]
        vc.parentIndexPath = indexPath
        present(vc, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 60)
    }
    
}

extension PanoramicEvaluationController : UIPickerViewDelegate , UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return 3
        }else{
            return 12
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let year = Date().year - 1
            return String(year + row)
        }else{
            return String(row + 1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            let year = Date().year - 1 + row
            (view.viewWithTag(10002) as! UILabel).text = "\(year)"
        }else{
            let month = row + 1
            (view.viewWithTag(10001) as! UIButton).setTitle("\(month)月", for: .normal)
        }
        getListData()
    }
    
}

extension PanoramicEvaluationController : UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let pointer = touch.location(in: self.view)
//        print(pointer.y.description + "----" + datePicker.Y.description)
        if pointer.y > datePicker.Y{
            return false
        }else if NSStringFromClass((touch.view?.superview!.classForCoder)!) == "UICollectionViewCell"{
            return false
        }
        return true
    }
    
}

extension PanoramicEvaluationController : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        datePicker.isHidden = true
        return true
    }
    
}
