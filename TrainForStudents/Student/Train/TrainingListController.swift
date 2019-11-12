//
//  TrainListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class TrainingListController : HBaseViewController{
    
    
    @IBOutlet weak var txt_office: UITextField!
    
    @IBOutlet weak var txt_searchTitle: UITextField!
    
    @IBOutlet weak var trainingCollection: UICollectionView!
    
    var jds = [JSON]()
    var trainingList = [JSON]()
    var officePicker = UIPickerView()
    var officePickerViewImpl = HSimplePickerViewImpl()
    
    override func viewDidLoad() {
        
        trainingCollection.delegate = self
        trainingCollection.dataSource = self
        
        officePicker = officePickerViewImpl.getDefaultPickerView()
        officePickerViewImpl.titleKey = "officename"
        officePickerViewImpl.clorsureImpl = selectedOffice
        
        txt_office.inputView = officePicker
        txt_office.delegate = self
        
        txt_searchTitle.delegate = self
        
        self.trainingCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.trainingCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.trainingCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        hiddenKeyBoard()
        let url = SERVER_PORT + "rest/app/queryAutonomyTrain.do"
        myPostRequest(url).responseJSON(completionHandler: { resp in
            
            self.trainingCollection.mj_header.endRefreshing()
            self.trainingCollection.mj_footer.endRefreshing()
            self.trainingCollection.mj_footer.endRefreshingWithNoMoreData()
            switch resp.result{
            case .success(let respStr):
                let json = JSON(respStr)
                if json["code"].intValue == 1{
                    self.trainingList = json["data"].arrayValue
                    self.jds = json["data"].arrayValue
                    
                    var pickerViewDs = [JSON]()
                    var officeIDARR = [String]()
                    //取出所有培训中的科室
                    
                    //把科室解析成pickerview能识别的结构
                    pickerViewDs.append(JSON(["officename":"全部","officeid":"-1"]))
                    for item in self.jds{
                        if !officeIDARR.contains(item["officeid"].stringValue) {
                            pickerViewDs.append(JSON(["officename":item["officename"].stringValue,"officeid":item["officeid"].stringValue]))
                            
                        }
                        officeIDARR.append(item["officeid"].stringValue)
                    }
                    //刷新pickerview
                    self.officePickerViewImpl.dataSource = pickerViewDs
                    self.officePicker.reloadAllComponents()
                    
                }else{
                    print(json)
                    myAlert(self, message: json["msg"].stringValue)
                }
            case .failure(let err):
                print(err)
            }
            self.trainingCollection.reloadData()
            
        })
        
    }
    
    @objc func refresh() {
        jds.removeAll()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
    func selectedOffice(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        
        if row == 0{
            jds = trainingList
        }else{
            let data = ds[row]
            jds = [JSON]()
            for item in trainingList{
                if item["officeid"] == data["officeid"]{
                    jds.append(item)
                }
            }
        }
        
        
        trainingCollection.reloadData()
        
    }
    
    
    
    @objc func btn_submit(sender: UIButton){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT + "rest/app/txaddAutonomyTrain.do"
        myPostRequest(url,sender.viewParam).responseJSON(completionHandler: { resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(respStr)
                print(json)
                if json["code"].intValue == 1{
                    myAlert(self, message: "参加培训报名成功!")
                    self.getListData()
                }else{
                    print(json)
                    myAlert(self, message: json["msg"].stringValue)
                }
            case .failure(let err):
                print(err)
            }
            
        })
        
    }
    
}

extension TrainingListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        (cell.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
        (cell.viewWithTag(20001) as! UILabel).text = "\(data["starttime"].stringValue) ~ \(data["endtime"].stringValue)"
        (cell.viewWithTag(30001) as! UILabel).text = data["teachernames"].stringValue
        (cell.viewWithTag(30002) as! UILabel).text = data["isneedsignname"].stringValue
        let btn = (cell.viewWithTag(40001) as! UIButton)
        btn.viewParam = data.dictionaryValue
        btn.addTarget(self, action: #selector(btn_submit(sender:)), for: .touchUpInside)
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
        hiddenKeyBoard()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: collectionView.W - 20, height: 135)
    }
    
}

extension TrainingListController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hiddenKeyBoard()
        if txt_searchTitle!.text! == ""{
            jds = trainingList
            return true
        }
        
        jds = [JSON]()
        for item in trainingList{
            let title = item["title"].stringValue
            
            if title.contains(txt_searchTitle!.text!){
                jds.append(item)
            }
        }
        trainingCollection.reloadData()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        jds = trainingList
        trainingCollection.reloadData()
        return true
    }
    
}
