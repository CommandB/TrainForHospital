//
//  SetNewPasswordViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/29.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class SetNewPasswordViewController: NewsBaseViewController {
    var phoneno = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "找回密码"
        addChildViews()
        setupConstraints()
        self.completeButton.becomeFirstResponder()
    }

    func addChildViews() {
        self.view.addSubview(tipLabel)
        self.view.addSubview(passwordField)
        self.view.addSubview(line1)
        self.view.addSubview(completeButton)
    }
    
    func setupConstraints() {
        self.tipLabel.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.offset()(-20)
            make?.top.offset()(30)
            make?.height.mas_equalTo()(30)
        }
        self.passwordField.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.offset()(-20)
            make?.top.equalTo()(self.tipLabel.mas_bottom)?.offset()(30);
            make?.height.mas_equalTo()(23);
        }
        self.line1.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.offset()(-20)
            make?.top.equalTo()(self.passwordField.mas_bottom)?.offset()(15);
            make?.height.mas_equalTo()(1);
        }
        self.completeButton.mas_makeConstraints { (make) in
            make?.centerX.offset()(0)
            make?.height.mas_equalTo()(50)
            make?.left.offset()(20)
            make?.top.equalTo()(self.line1.mas_bottom)?.offset()(50)
        }
        
    }
    
    @objc func textDidChanged(textField:UITextField) {
//        if textField == self.phoneField {
//            if textField.text?.length ?? 0 >= 11 {
//                textField.text = textField.text?.substring(to: 11)
//                self.codeButton.isEnabled = true
//            }else{
//                self.codeButton.isEnabled = false
//            }
//        }else if textField == self.codeField && textField.text?.length ?? 0 > 6 {
//            textField.text = textField.text?.substring(to: 6)
//        }
    }
    
    @objc func didClickNextButton() {
        if self.passwordField.text == nil {
            return;
        }
        self.view.endEditing(true)
        guard let password = self.passwordField.text?.sha1() else { return }
        let url = PORTAL_PORT+"rest/updatepassword.do"
        MBProgressHUD.showAdded(to: self.view, animated: true)
        myPostRequest(url, ["phoneno":phoneno,"password":password],  method: .post).responseString(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: false)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    myAlert(self, title: "", message: "密码修改成功", btnTitle: "确认") { (alertAction) in
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: error.localizedDescription)
                print(error)
                break
            }
        })
    }
    
    lazy var tipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.textColor = .gray
        tipLabel.font = UIFont.systemFont(ofSize: 13)
        tipLabel.textAlignment = .left
        tipLabel.text = "设置新的登陆密码"
        return tipLabel
    }()
    
    
    lazy var passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "输入新密码"
        passwordField.font = UIFont.systemFont(ofSize: 15)
        passwordField.keyboardType = UIKeyboardType.phonePad;
        passwordField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        return passwordField
    }()
    
    lazy var line1: UILabel = {
        let line1 = UILabel()
        line1.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        return line1
    }()
    
    
    lazy var completeButton: GradientLayerBaseButton = {
        let completeButton = GradientLayerBaseButton()
        completeButton.backgroundColor = RGBCOLOR(r: 220, 220, 220)
        completeButton.setTitle("完成", for: .normal)
        completeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        completeButton.layer.masksToBounds = true
        completeButton.layer.cornerRadius = 4
        completeButton.addTarget(self, action: #selector(didClickNextButton), for: .touchUpInside)
        return completeButton
    }()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
