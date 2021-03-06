//
//  OfficeTeacherController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/8.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class OfficeTeacherController : UIViewController{
    
    let cellUpperDistance = 35
    let studentLabelheight = 20
    
    @IBOutlet weak var teacher_collection: UICollectionView!
    
    @IBOutlet weak var nurseCollection: UICollectionView!
    
    var nurseView = JoinOfficeNurseCollectionView()
    
    var tagListBackgroundView = UIView()
    
    var selectNurseOfJoinOffice = "0"
    var office = JSON()
    var collectionDs = [JSON]()
    var selectedPerson = [String:JSON]()
    //被选中的学生
    var selectedStudents = [String:JSON]()
    ///被选中的护士
    var selectedNurseId = ""
    var selectedNurseName = ""
    
    override func viewDidLoad() {
        
        loadNurseList()
        
        selectNurseOfJoinOffice = UserDefaults.AppConfig.string(forKey: .selectNurseOfJoinOffice)!
        
        //加载可以选择的tag
        nurseView.parentView = self
        nurseView.jds = UserDefaults.AppConfig.json(forKey: .tagList).arrayValue
        nurseCollection.delegate = nurseView
        nurseCollection.dataSource = nurseView
        nurseCollection.reloadData()
        nurseCollection.setY(y: UIScreen.height)
        if nurseView.jds.count < 6{
            nurseCollection.setHight(height: CGFloat(nurseView.jds.count * 40))
        }
        
        let btn = UIButton(frame: CGRect(x: UIScreen.width - 30 - 20, y: 100, width: 30, height: 30))
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        btn.setCornerRadius(radius: 15)
//        btn.setTitle("x", for: .normal)
        btn.setImage(UIImage(named: "关闭-叉"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(btn_dismissNurseListView(sender:)), for: .touchUpInside)
        //        btn.setCornerRadius(radius: 4)
        btn.setBorder(width: 1, color: .lightGray)
        tagListBackgroundView.frame = view.frame
        tagListBackgroundView.backgroundColor = .groupTableViewBackground
        //        tagListBackgroundView.setY(y: UIScreen.height)
        tagListBackgroundView.alpha = 0
        tagListBackgroundView.addSubview(btn)
        
        view.addSubview(tagListBackgroundView)
        view.bringSubview(toFront: nurseCollection)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        teacher_collection.dataSource = self
        teacher_collection.delegate = self
        teacher_collection.reloadData()
        
        loadTeacherInfo()
    }
    
    
    //返回
    @IBAction func btn_back_tui(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //入科登记
    @IBAction func btn_joinOffice_tui(_ sender: UIButton) {
        if selectedPerson.count == 0 {
            myAlert(self, message: "请选择带教老师!")
            return
        }
        if selectedStudents.count == 0{
            myAlert(self, message: "请选择带教老师!")
            return
        }
        if nurseView.jds.count > 0 && selectNurseOfJoinOffice == "1"{
            
            if selectedNurseId == "0" || selectedNurseId.isEmpty{
                myAlert(self, message: "未选择责任护士，无法进行入科登记！")
                return
            }
            
        }
        
        let teacher = selectedPerson.values.first
        
        var stus = [Dictionary<String, String>]()
        for s in selectedStudents{
            var json = Dictionary<String, String>()
            json["studentid"] = s.value["personid"].stringValue
            json["roundokpeopleresultid"] = s.value["roundokpeopleresultid"].stringValue
            stus.append(json)
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "rest/app/studentJoinOffice.do"
        myPostRequest(url,["teacherid":teacher!["personid"].stringValue, "studentlist":stus , "nurseid":selectedNurseId ,"nursename":selectedNurseName]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    myAlert(self, message: "入科成功")
                    //初始化数据,防止重复提交
                    self.selectedStudents = [String:JSON]()
                    self.selectedPerson = [String:JSON]()
                    //重新加载列表
                    self.loadTeacherInfo()
                }else{
                    myAlert(self, message: "入科失败,\(json["msg"].stringValue)")
                }
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    func loadTeacherInfo(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "rest/app/getOfficeTeachers.do"
        myPostRequest(url,["officeid":office["officeid"].stringValue]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    self.collectionDs = json["data"].arrayValue
                    //print(self.collectionDs)
                    self.teacher_collection.reloadData()
                }else{
                    
                }
            case .failure(let error):
                
                print(error)
            }
            
        })
    }
    
    func loadNurseList(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "rest/app/queryOfficeNurse.do"
        myPostRequest(url,["officeid":office["officeid"].stringValue]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                print(json)
                if json["code"].stringValue == "1"{
                    
                    self.nurseView.jds = json["data"].arrayValue
                    self.nurseCollection.reloadData()
                }else{
                    
                }
            case .failure(let error):
                
                print(error)
            }
            
        })
    }
    
    @objc func btn_dismissNurseListView(sender : UIButton){
        let opt : UIView.AnimationOptions = .curveEaseOut
        //隐藏bg
        UIView.animate(withDuration: 0.3, delay:0, options:opt, animations: {
            self.tagListBackgroundView.alpha = 0
            //            self.tagListBackgroundView.setY(y: UIScreen.height)
        })
        
        //隐藏tagCollection
        UIView.animate(withDuration: 0.3, delay:0, options:opt, animations: {
            self.nurseCollection.alpha = 0
            self.nurseCollection.setY(y: UIScreen.height)
        })
        
    }
    
    func showAddNurseView(){

        let opt : UIView.AnimationOptions = .curveEaseIn
        UIView.animate(withDuration: 0.2, delay:0, options:opt, animations: {
            self.tagListBackgroundView.alpha = 0.8
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay:0, options:opt, animations: {
            self.nurseCollection.alpha = 1
            self.nurseCollection.setY(y: 175)
        }, completion: nil)
        
    }
    
}

extension OfficeTeacherController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        //防止重影
        for v in cell.subviews[0].subviews{
            if v.tag <= 10000{
                v.removeFromSuperview()
            }
        }
        
        let data = collectionDs[indexPath.item]
        let btn = cell.viewWithTag(10001) as! UIButton
        btn.clipsToBounds = true
        btn.cornerRadius = btn.frame.width / 2
        if selectedPerson[data["personid"].stringValue] != nil {
            btn.backgroundColor = UIColor.init(hex: "5EA3F3")
        }else{
            btn.backgroundColor = UIColor.groupTableViewBackground
        }
        let lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = "\(data["personname"])"
        
        let studentList = data["studentlist"].arrayValue
        var index = 0
        for stu in studentList{
            
            if index == 0{
                let lf = lbl.frame
                let line = UILabel(frame: CGRect.init(x: lf.origin.x, y: lf.origin.y + (lf.height) + (5), width: lf.width, height: 1))
                line.backgroundColor = UIColor.lightGray
                cell.subviews[0].addSubview(line)
            }
            
            let y = studentLabelheight * index + cellUpperDistance
            let stuLbl = UILabel(frame: lbl.frame)
            stuLbl.font = UIFont.boldSystemFont(ofSize: 13)
            stuLbl.textColor = UIColor.lightGray
            stuLbl.text = "\(stu["personname"])   \(stu["starttime"]) ~ \(stu["endtime"])"
            stuLbl.frame.origin = CGPoint(x: Int.init(stuLbl.frame.origin.x), y: y)
            cell.subviews[0].addSubview(stuLbl)
            
            index += 1
        }
        
        return cell
    }
    
    
    //计算cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = collectionDs[indexPath.item]
        let studentList = data["studentlist"].arrayValue
        if studentList.count == 0 {
            return CGSize(width: collectionView.frame.width, height: 35)
        }else{
            let height = studentLabelheight * studentList.count + cellUpperDistance
            return CGSize(width: collectionView.frame.width, height: CGFloat.init(height))
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItem(collectionView, indexPath: indexPath)
        if "1" == selectNurseOfJoinOffice{
            if nurseView.jds.count == 0 {
                myAlert(self, message: "暂无责任护士,可先不指定!")
            }else{
                showAddNurseView()
            }
        }
    }
    
    func selectItem(_ collectionView: UICollectionView, indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let data = collectionDs[indexPath.item]
        let btn = cell.viewWithTag(10001) as! UIButton
        let personid = data["personid"].stringValue
        //判断是否已被选中
        if selectedPerson[personid] == nil{
            selectedPerson = [personid:data]
            btn.backgroundColor = UIColor(hex: "5EA3F3")
        }else{
            selectedPerson.removeValue(forKey: personid)
            btn.backgroundColor = UIColor.groupTableViewBackground
        }
        collectionView.reloadData()
    }
}

class JoinOfficeNurseCollectionView :UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var jds = [JSON]()
    var parentView : OfficeTeacherController?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["personname"].stringValue
        lbl.setBorderBottom(size: 1, color: UIColor(hex: "3186E9"))
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = jds[indexPath.item]
        parentView?.selectedNurseId = data["personid"].stringValue
        parentView?.selectedNurseName = data["personname"].stringValue
        parentView?.btn_dismissNurseListView(sender: UIButton())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: 40)
    }
    
}
