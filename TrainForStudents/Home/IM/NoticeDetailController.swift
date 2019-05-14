//
//  NoticeDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/3.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class NoticeDetailController : HBaseViewController{
    
    var noticeJson = JSON()
    
    var size12LineHeight = CGFloat(16)
    
    override func viewDidLoad() {
        
        var lbl = view.viewWithTag(22222) as? UILabel
        lbl?.setBorderBottom(size: 1, color: .red)
        
        lbl = view.viewWithTag(10001) as? UILabel
        lbl?.text = noticeJson["createtime"].stringValue
        
        lbl = view.viewWithTag(10001) as? UILabel
        lbl?.text = "发布人:\(noticeJson["createloginname"].stringValue)"
        
        lbl = view.viewWithTag(20001) as? UILabel
        let content = noticeJson["noticemsg"].stringValue
        
        //计算展示大纲label的行数与高度
        lbl?.text = content
        let lineNum = content.getLineNumberForUILabel(lbl!)
        lbl?.numberOfLines = lineNum
        lbl?.frame.size = CGSize(width: (lbl?.frame.width)!, height: size12LineHeight * CGFloat(lineNum))
        
        print(noticeJson)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.replyCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_history_inside(_ sender: UIButton) {
        let vc = getViewToStoryboard("noticeListView") as! NoticeListController
        vc.teamId = noticeJson["teamid"].intValue
        present(vc, animated: true, completion: nil)
    }
    
}
