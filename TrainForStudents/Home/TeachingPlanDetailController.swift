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
    
    
    @IBOutlet weak var infoCollection: UICollectionView!
    var jds = [JSON]()
    var taskInfo = JSON()
    var qrcodeStr = ""
    var timer:Timer?
    
    override func viewDidLoad() {
        
        infoCollection.delegate = self
        infoCollection.dataSource = self
        
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

extension TeachingPlanDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        

        return CGSize(width: UIScreen.width, height: 40)
    }
    
}
