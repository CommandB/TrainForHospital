//
//  EvaluationListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/28.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EvaluationDimensionController : HBaseViewController{
    
    static var callbackNotificationName = NSNotification.Name(rawValue: "evDimensionNotificationName")
    
    @IBOutlet weak var evCollection: UICollectionView!
    
    var jds = [JSON]()
    var pds = [JSON]()
    var evDic = [String : JSON]()
    var keys = [String]()
    var pickerView = UIPickerView()
    var selectedKey = ""
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        
        evCollection.delegate = self
        evCollection.dataSource = self
        pds = UserDefaults.AppConfig.json(forKey: .teachingActivityEvaluationList).arrayValue
        //view.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        
        MyNotificationUtil.addKeyBoardWillChangeNotification(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        keys = evDic.keys.sorted()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        NotificationCenter.default.post(name: EvaluationDimensionController.callbackNotificationName, object: nil, userInfo: ["data":evDic])
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        evCollection.reloadData()
    }
    
    deinit {
        
    }
    
    
}

extension EvaluationDimensionController {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedKey = textField.viewParam!["key"] as! String
        selectedIndexPath = textField.viewParam!["indexPath"] as! IndexPath
        
        let selectedEvid = evDic[selectedKey]!["evaluationtableid"].intValue
        var index = 0
        if selectedEvid != 0{
            //如果有已选的评价表 则把pickview滚动到对应的位置
            for o in pds{
                if o["evaluationid"].intValue == selectedEvid{
                    break
                }
                index += 1
            }
        }
        pickerView.selectRow(index, inComponent: 0, animated: true)
        return true
    }
    
}

extension EvaluationDimensionController : UIPickerViewDelegate , UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pds[row]["evaluationname"].stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        evDic[selectedKey]?["evaluationtableid"] = pds[row]["evaluationid"]
        evDic[selectedKey]?["evaluationtablename"] = pds[row]["evaluationname"]
        let cell = evCollection.cellForItem(at: selectedIndexPath)!
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = "评价表: \(pds[row]["evaluationname"].stringValue)"
    }
    
}

extension EvaluationDimensionController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let key = keys[indexPath.item]
        let data = evDic[key]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: key, for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = "评价表: \(data!["evaluationtablename"].stringValue)"
        let txt = cell.viewWithTag(10002) as! TextFieldForNoMenu
        txt.inputView = pickerView
        txt.setWidth(width: 70)
        txt.viewParam = ["key":key , "indexPath":indexPath]
        txt.delegate = self
        
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hiddenKeyBoard()
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: UIScreen.width, height: 140)
    }
    
}
