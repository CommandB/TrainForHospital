//
//  PublishSubjectExamController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/26.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PublishSubjectExamController : HBaseViewController{
    
    var isSkillExam = false
    var notReload = false
    @IBOutlet weak var studentsCollection: UICollectionView!
    
    var officeId = 0
    var basicData = [JSON]()
    var jds = [JSON]()
    let datePicker = UIPickerView()
    var officePicker = UIPickerView()
    let officePickerImpl = HSimplePickerViewImpl()
    
    var isSelectedAll = false
    var selectedStudents = [IndexPath:JSON]()
    
    override func viewDidLoad() {
        
        studentsCollection.delegate = self
        studentsCollection.dataSource = self
        
        datePicker.delegate = self
        datePicker.dataSource = self
        
        let officeList = UserDefaults.AppConfig.json(forKey: .officeList).arrayValue
        var myManager = [JSON]()
        for office in officeList{
            if office["ismymanage"].intValue == 1{
                myManager.append(office)
            }
        }
        
        officePicker = officePickerImpl.getDefaultPickerView()
        officePickerImpl.titleKey = "officename"
        officePickerImpl.clorsureImpl = addrClosureImpl
        officePickerImpl.dataSource = myManager
        
        var txt = view.viewWithTag(10000) as! TextFieldForNoMenu
        txt.inputView = officePicker
        txt.text = UserDefaults.standard.string(forKey: LoginInfo.officeName.rawValue)
        
        txt = view.viewWithTag(10001) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        
        let currentDate = Date()
        (view.viewWithTag(10002) as! UILabel).text = "\(currentDate.month)月"
        (view.viewWithTag(10003) as! UILabel).text = "\(currentDate.year)"
        
        var btn = view.viewWithTag(10004) as! UIButton
        btn.addTarget(self, action: #selector(btn_selectorExam_inside), for: .touchUpInside)
        btn.setCornerRadius(radius: 4)
        btn.setBorder(width: 1, color: (btn.titleLabel?.textColor)!)
        
        btn = view.viewWithTag(30001) as! UIButton
        btn.addTarget(self, action: #selector(btn_sort), for: .touchUpInside)
        btn = view.viewWithTag(30002) as! UIButton
        btn.addTarget(self, action: #selector(btn_sort), for: .touchUpInside)
        
        btn = view.viewWithTag(40002) as! UIButton
        btn.addTarget(self, action: #selector(btn_selectAll), for: .touchUpInside)
        
        self.studentsCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.studentsCollection.mj_header.beginRefreshing()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: PaperSelectorController.defaultNoticeName, object: nil)
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_next_inside(_ sender: UIButton) {
        
        var hasSelectedStu = false
        for item in basicData{
            if item["exercisesid"].intValue > 0{
                hasSelectedStu = true
            }
        }
        
        if !hasSelectedStu{
            myAlert(self, message: "请至少给一位学员分配试卷!")
            return
        }
        
        let vc = getViewToStoryboard("publishSubjectExamDetailView") as! PublishSubjectExamDetailController
        vc.jds = basicData
        vc.isSkillExam = isSkillExam
        present(vc, animated: true, completion: nil)
    }
    
    
    //选好试卷的 callback
    @objc func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: PaperSelectorController.defaultNoticeName, object: nil)
        if notification.userInfo != nil{
            notReload = true
            let paper = notification.userInfo!["data"] as! JSON
            
            //把试卷内容组合到学员信息里
            for indexPath in selectedStudents.keys{
                for item in paper{
                    basicData[indexPath.item][item.0] = item.1
                }
            }
            //清除已选学员
            selectedStudents.removeAll()
            if isSelectedAll{
                btn_selectAll(sender: (view.viewWithTag(40002) as! UIButton))
            }
            
            var hasExercises = 0
            for item in basicData{
                if item["exercisesid"].intValue > 0{
                    hasExercises += 1
                }
            }
            
            (view.viewWithTag(40001) as! UIButton).setTitle("安排已分配试卷的学员考试(\(hasExercises)人)", for: .normal)
            refreshStudentsCollection()
        }
    }
    
    //选试卷
    @objc func btn_selectorExam_inside(_ sender: UIButton) {
        if selectedStudents.count == 0 {
            myAlert(self, message: "请先选择学员!")
            return
        }
        let vc = getViewToStoryboard("paperSelectorView") as! PaperSelectorController
        vc.notReload = notReload
        vc.officeId = officeId
        vc.isSkillExam = isSkillExam
        present(vc, animated: true, completion: nil)
    }
    
    ///已分配 未分配
    @objc func btn_sort(sender : UIButton){
        selectedStudents = [IndexPath:JSON]()
        hiddenKeyBoard()
        if isSelectedAll{
            btn_selectAll(sender: (view.viewWithTag(40002) as! UIButton))
        }
        if sender.isSelected{
            sender.setImage(UIImage(named: "未选择-大"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "选择-大"), for: .normal)
        }
        sender.isSelected = !sender.isSelected
        refreshStudentsCollection()
    }
    
    ///刷新学生列表
    func refreshStudentsCollection(){
        
        jds = [JSON]()
        let b1 = view.viewWithTag(30001) as! UIButton
        let b2 = view.viewWithTag(30002) as! UIButton
        if b1.isSelected && b2.isSelected{
            jds = basicData
        }else if b1.isSelected{ //未分配
            for stu in basicData{
                if stu["exercisesid"].intValue == 0{
                    jds.append(stu)
                }
            }
        }else if b2.isSelected{ //已分配
            for stu in basicData{
                if stu["exercisesid"].intValue > 0{
                    jds.append(stu)
                }
            }
        }else{
            jds = basicData
        }
        
        studentsCollection.reloadData()
    }
    
    ///全选
    @objc func btn_selectAll(sender : UIButton){
        if isSelectedAll{
            isSelectedAll = false
            selectedStudents.removeAll()
            sender.setImage(UIImage(named: "未选择-大"), for: .normal)
        }else{
            isSelectedAll = true
            sender.setImage(UIImage(named: "选择-大"), for: .normal)
            
            for (index,stu) in jds.enumerated(){
                let indexPath = IndexPath(item: index, section: 0)
                selectedStudents[indexPath] = stu
            }
            
        }
        refreshStudentsCollection()
    }
    
    func getListData(){
        
        var month = (view.viewWithTag(10002) as! UILabel).text
        let year = (view.viewWithTag(10003) as! UILabel).text
        if (month?.count)! < 3{
            month = "0" + month!
        }
        let paramMonth = (year! + month!).replacingOccurrences(of: "月", with: "")
        
        //清除已选学生
        selectedStudents.removeAll()
        if isSelectedAll{
            btn_selectAll(sender: (view.viewWithTag(40002) as! UIButton))
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT + "rest/app/getPreExitOfficePerson.do"
        let officeId = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)
        myPostRequest(url, ["officeid":officeId ,"month":paramMonth ,"fortype":"exam"], method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.studentsCollection.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    
                    let data = json["data"].arrayValue
                    self.basicData = data
                    self.jds = data
                    self.refreshStudentsCollection()
                    (self.view.viewWithTag(40001) as! UIButton).setTitle("安排已分配试卷的学员考试(0人)", for: .normal)
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
    }
    
    @objc func refresh() {
        jds.removeAll()
        //studentsCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    func addrClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        let text = ds[row]["officename"].stringValue
        let txt = view.viewWithTag(10000) as! UITextField
        txt.text = text
        officeId = ds[row]["officeid"].intValue
        //如果重新选择了科室 则需要重新加载
        notReload = false
    }
    
}

extension PublishSubjectExamController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
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
        
        let btn = cell.viewWithTag(10004) as! UIButton
        if selectedStudents[indexPath] == nil{
            btn.setImage(UIImage(named: "未选择-大"), for: .normal)
        }else{
            btn.setImage(UIImage(named: "选择-大"), for: .normal)
        }
        
        lbl = cell.viewWithTag(10005) as! UILabel
        lbl.text = jds[indexPath.item]["title"].stringValue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hiddenKeyBoard()
        if selectedStudents[indexPath] == nil{
            selectedStudents[indexPath] = jds[indexPath.item]
        }else{
            selectedStudents[indexPath] = nil
        }
        if selectedStudents.count == 0 && isSelectedAll{
            btn_selectAll(sender: (view.viewWithTag(40002) as! UIButton))
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 60)
    }
    
}


extension PublishSubjectExamController : UIPickerViewDelegate , UIPickerViewDataSource{
    
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
            (view.viewWithTag(10003) as! UILabel).text = "\(year)"
        }else{
            let month = row + 1
            (view.viewWithTag(10002) as! UILabel).text = "\(month)月"
        }
        getListData()
    }
    
}

extension PublishSubjectExamController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hiddenKeyBoard()
        return true
    }
    
}
