//
//  SelectAdressController.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/11/4.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectAdressController: UIViewController,UITextFieldDelegate {

    var callback:((String,String)->())?
    var TextField:UITextField!
    var selectField:UITextField!
    let addrPicker = UIPickerView()
    var addrPickerDs = [JSON]()
    
    var adress = ""
    var adressID = "-1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        buildTitileView()
        
        TextField = UITextField.init(frame: CGRect.init(x: 0, y: UIDevice.current.iPhoneX ? 88 : 64, width: SCREEN_WIDTH, height: 44))
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 44))
        leftLabel.textColor = UIColor.black
        leftLabel.backgroundColor = UIColor.init(hex: "#DDDDDE")
        leftLabel.font = UIFont.init(name: "PingFang-Regular", size: 16)
        leftLabel.text = " 地址："
        TextField.leftView = leftLabel
//        _PWtextField.leftViewMode=UITextFieldViewModeAlways;
        TextField.leftViewMode = .always
        TextField.backgroundColor = UIColor.init(hex: "#DDDDDE")
        TextField.font = UIFont.init(name: "PingFang-Regular", size: 16)
        self.view.addSubview(TextField)
        
        selectField = UITextField.init(frame: CGRect.init(x: 30, y: 150 , width: SCREEN_WIDTH - 60, height: 44))
        selectField.text = "选择地址"
        selectField.textAlignment = .center
        selectField.textColor = .blue
        selectField.borderColor = UIColor.blue
        selectField.borderWidth = 1
        selectField.tag = 90016
        selectField.delegate = self
        selectField.inputView = addrPicker
        self.view.addSubview(selectField)
        
        let saveBtn = UIButton.init(frame: CGRect.init(x: 30, y: 250 , width: SCREEN_WIDTH - 60, height: 44))
        saveBtn.setTitle("保存地址", for: UIControlState.normal)
        saveBtn.setTitleColor(UIColor.white, for: .normal)
        saveBtn.backgroundColor = .blue
        saveBtn.addTarget(self, action: #selector(saveClick), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveBtn)
        addPickerView()
    }
    
    func addPickerView(){
        addrPicker.delegate = self
        addrPicker.dataSource = self
        let classroomList = UserDefaults.AppConfig.json(forKey: .classroomList).arrayValue
//        classroomList.insert(["facilitiesname":""], at: 0)
        addrPickerDs = classroomList
    }
    
    @objc func saveClick(){
        if TextField.text == "" {
            myAlert(self, message: "请输入地址")
        }else{
            self.callback!(TextField.text!,adressID)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func buildTitileView() {
        self.view.addSubview(titleView)
        titleView.isUserInteractionEnabled = true
        let height = UIDevice.current.iPhoneX ? 88 : 64
        self.titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        self.titleView.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.titleView).offset(-10)
        }
        self.titleView.addSubview(backBtn)
        self.backBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.height.width.equalTo(44)
        }
        
    }
    @objc func cancelCurrentVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    lazy var titleView : UIImageView = {
        let titleView = UIImageView()
        titleView.image = UIImage(named: "顶部固定2.png")
        return titleView
    }()
    
    lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "添加地址"
        titleLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var backBtn : UIButton = {
        let backBtn = UIButton()
        backBtn.setImage(UIImage.init(named: "navBackWhiteImage"), for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(cancelCurrentVC), for: UIControlEvents.touchUpInside)
        return backBtn
    }()

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == TextField {
            adressID = "-1"
            return true
        }else{
            return true
        }
    }
    
    
}
extension SelectAdressController : UIPickerViewDelegate , UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return addrPickerDs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return addrPickerDs[row]["facilitiesname"].stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let addr = addrPickerDs[row]["facilitiesname"].stringValue
        adressID = addrPickerDs[row]["facilitiesid"].stringValue
        adress = addr
        self.TextField.text = addr
    }
    
    
}
