//
//  ComplaintReplyController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/9/27.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ComplaintReplyController : MyBaseUIViewController{
    
    var data = JSON()
    let lineHeight = 20
    
    @IBOutlet weak var replyCollection: UICollectionView!
    
    let replyView = ComplaintReplyCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barView = view.viewWithTag(11111)
        let titleView = view.viewWithTag(22222) as! UILabel
        super.setNavigationBarColor(views: [barView,titleView], titleIndex: 1,titleText: "回复")
        
        replyView.parentView = self
        replyCollection.registerNoDataCellView()
        replyCollection.delegate = replyView
        replyCollection.dataSource = replyView
        
        let btn_submit = view.viewWithTag(30002) as! UIButton
        btn_submit.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        MyNotificationUtil.addKeyBoardWillChangeNotification(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let contentLbl = view.viewWithTag(10001) as! UILabel
        let text = data["making"].stringValue
        let tn = text.getLineNumberForUILabel(contentLbl)
        //collection距离屏幕下边框的距离
        let collectionMarginBottom = 52
        contentLbl.numberOfLines = 0
        contentLbl.text = text
        contentLbl.frame.size = CGSize(width: contentLbl.frame.size.width, height: CGFloat(lineHeight * tn))
        
        let f = contentLbl.frame
        let dateLbl = view.viewWithTag(10002) as! UILabel
        dateLbl.frame = CGRect(x: f.origin.x, y: f.origin.y.adding(f.size.height).adding(10), width: f.size.width, height: 20)
        dateLbl.text = data["makingtime"].stringValue.substring(to: 16)
        dateLbl.textColor = UIColor.gray
        dateLbl.font = UIFont.systemFont(ofSize: 13)
        dateLbl.textAlignment = .right
        
        
        //计算collection的y轴
        replyCollection.frame.origin = CGPoint(x: 0, y: dateLbl.frame.origin.y.adding(30))
        //计算collection的高度
        let h = UIScreen.height.subtracting(replyCollection.frame.origin.y).subtracting(CGFloat(collectionMarginBottom))
        replyCollection.frame.size = CGSize(width: replyCollection.frame.width, height: h)
        self.replyView.isanonymous = self.data["isanonymous"].boolValue
        replyView.jsonDataSource = data["gjwhisperreply"].arrayValue
        
        replyCollection.reloadData()
        
        (view.viewWithTag(30001) as! UITextField).delegate = self
        
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hiddenKeyBoard()
        return true
    }
    
    //返回按钮
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func submit(){
        let content = (view.viewWithTag(30001) as! UITextField).text
        
        if content == ""{
            myAlert(self, message: "回复内容不能为空!")
            return 
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT+"rest/proposalchannel/addreplyproposal.do"
        myPostRequest(url,["reply":content,"whisperid":data["whisperid"].stringValue]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let item = ["reply":content ,"replytime":DateUtil.getCurrentDateTime(),"personid":json["respondentid"].stringValue]
                    self.replyView.jsonDataSource.append(JSON.init(item))
                    self.replyCollection.reloadData()
                    //清空text
                    (self.view.viewWithTag(30001) as! UITextField).text = ""
                }else{
                    myAlert(self, message: "回复悄悄话列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
}
