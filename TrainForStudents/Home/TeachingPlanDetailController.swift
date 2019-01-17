//
//  TeachingPlanDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class TeachingPlanDetailController : HBaseViewController{
    
    var taskInfo = JSON()
    var qrcodeStr = ""
    var timer:Timer?
    
    override func viewDidLoad() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadAction), userInfo: nil, repeats: true)
        
        (view.viewWithTag(10001) as! UILabel).text = taskInfo["title"].stringValue
        (view.viewWithTag(20001) as! UILabel).text = taskInfo["starttime"].stringValue
        (view.viewWithTag(30001) as! UILabel).text = taskInfo["endtime"].stringValue
        (view.viewWithTag(40001) as! UILabel).text = taskInfo["addressname"].stringValue
        
        requestQRCode()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func requestQRCode() {
        let urlString = SERVER_PORT + "/rest/public/GenerateQRCode.do"
        let params = ["type":"pctask","taskid":taskInfo["taskid"].stringValue]
        
        myPostRequest(urlString, params, method: .post).responseJSON { (response) in
            switch(response.result){
            case .failure(let error):
                print(error)
            case .success(let response):
                let json = JSON(response)
                if json["code"].stringValue == "1" {
                    
                    self.qrcodeStr = json["qrcode"].stringValue
                    let imageView = self.view.viewWithTag(50001) as! UIImageView
                    imageView.image = UIImage.createQR(text: self.qrcodeStr, size: imageView.H)
                    
                }else{
                    print("error")
                }
            }
        }
    }
    
    func reloadAction() {
        if self.qrcodeStr.isEmpty {
            return
        }
        self.requestQRCode()
    }
    
}
