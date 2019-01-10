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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
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
//                    self.codeImageView.image =                self.setupQRCodeImage(json["qrcode"].stringValue, image: nil)
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
