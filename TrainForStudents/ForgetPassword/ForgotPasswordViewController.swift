//
//  ForgotPasswordViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class ForgotPasswordViewController: UIViewController {
    
    var countdownTime:NSInteger = 0
    var timer:Timer?
    var requestedCode:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initProperty()
        addChildViews()
        setupConstraints()
        self.phoneField.becomeFirstResponder()
    }
    
    func initProperty() {
        self.view.backgroundColor = .white
        let image = UIImage(named: "顶部固定2.png")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        let image1 = UIImage(named: "返回")!.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image1, style: .done, target: self, action: #selector(cancelAction))
        self.title = "找回密码"
    }
    
    func addChildViews() {
        self.view.addSubview(tipLabel)
        self.view.addSubview(phoneField);
        self.view.addSubview(codeField)
        self.view.addSubview(line1)
        self.view.addSubview(line2)
        self.view.addSubview(codeButton)
        self.view.addSubview(nextButton)
    }
    
    func setupConstraints() {
        self.tipLabel.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.offset()(-20)
            make?.top.offset()(30)
            make?.height.mas_equalTo()(0)
        }
        self.codeButton.mas_makeConstraints { (make) in
            make?.right.offset()(-20)
            make?.top.equalTo()(self.tipLabel.mas_bottom)
            make?.size.mas_equalTo()(CGSize(width: 80, height: 40))
        }
        self.phoneField.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.equalTo()(self.codeButton.mas_left)?.offset()(-20)
            make?.bottom.equalTo()(self.codeButton);
            make?.height.mas_equalTo()(23);
        }
        self.codeField.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.offset()(-20)
            make?.top.equalTo()(self.line1.mas_bottom)?.offset()(30);
            make?.height.mas_equalTo()(23);
        }
        self.line1.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.offset()(-20)
            make?.top.equalTo()(self.phoneField.mas_bottom)?.offset()(15);
            make?.height.mas_equalTo()(1);
        }
        self.line2.mas_makeConstraints { (make) in
            make?.left.offset()(20)
            make?.right.offset()(-20)
            make?.top.equalTo()(self.codeField.mas_bottom)?.offset()(15);
            make?.height.mas_equalTo()(1);
        }
        self.nextButton.mas_makeConstraints { (make) in
            make?.centerX.offset()(0)
            make?.height.mas_equalTo()(50)
            make?.left.offset()(20)
            make?.top.equalTo()(self.line2.mas_bottom)?.offset()(50)
        }
        
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textDidChanged(textField:UITextField) {
        if textField == self.phoneField {
            if textField.text?.length ?? 0 >= 11 {
                textField.text = textField.text?.substring(to: 11)
                self.codeButton.isEnabled = true
            }else{
                self.codeButton.isEnabled = false
            }
        }else if textField == self.codeField && textField.text?.length ?? 0 > 6 {
            textField.text = textField.text?.substring(to: 6)
        }
    }
    
    @objc func didClickVerifyCodeButton() {
        self.view.endEditing(true)
        guard let phoneno = self.phoneField.text else { return }
        let url = PORTAL_PORT+"rest/sendCode.do"
        MBProgressHUD.showAdded(to: self.view, animated: true)
        myPostRequest(url, ["phoneno":phoneno],  method: .post).responseString(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: false)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.updateConstraints()
                    self.startCountdown()
                    self.requestedCode = json["msmcode"].stringValue
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

    func updateConstraints() {
        self.tipLabel.mas_updateConstraints { (make) in
            make?.height.mas_equalTo()(40)
        }
    }
    func startCountdown() {
        countdownTime = 60
        self.codeButton.isEnabled = false
        self.codeButton.setTitle(("\(countdownTime)s"), for: .normal)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeAction), userInfo: nil, repeats: true)
    }
    
    @objc func timeAction() {
        self.countdownTime = self.countdownTime - 1;
        if self.countdownTime == 0 {
            self.timer?.invalidate()
            self.timer = nil
            self.codeButton.isEnabled = true
            self.codeButton.setTitle("重新获取", for: .normal)
            
        }else{
            self.codeButton.setTitle(("\(self.countdownTime)s"), for: .normal)
        }
    }
    
    @objc func didClickNextButton() {
        if self.phoneField.text?.length != 11 {
            myAlert(self, title: "请输入手机号", message: "", btnTitle: "OK") { (alertAction) in
                
            }
            return
        }
        if self.codeField.text?.length != 6 {
            myAlert(self, title: "请输入验证码", message: "", btnTitle: "OK") { (alertAction) in
                
            }
            return
        }
        if self.requestedCode == nil || self.requestedCode?.length == 0 || self.requestedCode != self.codeField.text {
            myAlert(self, title: "请输入验证码", message: "", btnTitle: "OK") { (alertAction) in
                
            }
        }
        let newPasswordView = SetNewPasswordViewController()
        newPasswordView.phoneno = self.phoneField.text ?? "";
        self.navigationController?.pushViewController(newPasswordView, animated: true)
    }
    
    lazy var phoneField: UITextField = {
        let phoneField = UITextField()
        phoneField.placeholder = "请输入手机号"
        phoneField.font = UIFont.systemFont(ofSize: 15)
        phoneField.keyboardType = UIKeyboardType.phonePad;
        phoneField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        return phoneField
    }()
    
    lazy var codeField: UITextField = {
        let codeField = UITextField()
        codeField.placeholder = "请输入验证码"
        codeField.font = UIFont.systemFont(ofSize: 15)
        codeField.keyboardType = UIKeyboardType.phonePad;
        codeField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        return codeField
    }()
    
    lazy var line1: UILabel = {
        let line1 = UILabel()
        line1.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        return line1
    }()
    
    lazy var line2: UILabel = {
        let line2 = UILabel()
        line2.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        return line2
    }()
    
    lazy var codeButton: UIButton = {
        let codeButton = UIButton()
        codeButton.setBackgroundImage(UIImage.yx_imageWithColor(color: RGBCOLOR(r: 56, 144, 248)), for: .normal)
        codeButton.setBackgroundImage(UIImage.yx_imageWithColor(color: RGBCOLOR(r: 210, 210, 210)), for: .disabled)
        codeButton.setTitle("获取验证码", for: .normal)
        codeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        codeButton.layer.masksToBounds = true
        codeButton.layer.cornerRadius = 4
        codeButton.isEnabled = false
        codeButton.addTarget(self, action: #selector(didClickVerifyCodeButton), for: .touchUpInside)
        return codeButton
    }()
    
    lazy var tipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.textColor = .lightGray
        tipLabel.font = UIFont.systemFont(ofSize: 13)
        tipLabel.numberOfLines = 2
        tipLabel.textAlignment = .center
        tipLabel.text = "验证码已发送到绑定的手机号\n请注意查收！"
        return tipLabel
    }()
    
    lazy var nextButton: GradientLayerBaseButton = {
        let nextButton = GradientLayerBaseButton()
        nextButton.backgroundColor = RGBCOLOR(r: 220, 220, 220)
        nextButton.setTitle("下一步", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        nextButton.layer.masksToBounds = true
        nextButton.layer.cornerRadius = 4
        nextButton.addTarget(self, action: #selector(didClickNextButton), for: .touchUpInside)
        return nextButton
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
