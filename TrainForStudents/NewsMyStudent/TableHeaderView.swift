//
//  TableHeaderView.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class TableHeaderView: UIView {

    var jsonContentarr = [String]()
    var titlearr = ["专业基础:","电话:","学历/学位:","年级:"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
//        layOutChildeView()
    }
    
    
    
    func layOutChildeView(data:JSON) {
        jsonContentarr = [data["majorname"].stringValue, data["phoneno"].stringValue, data["highestdegree"].stringValue, data["grade"].stringValue]
        
        self.addSubview(backView)
        backView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.top.equalTo(15)
            ConstraintMaker.right.equalTo(-15)
            ConstraintMaker.bottom.equalTo(-5)
        }
        for i in 0..<titlearr.count {
            let contentLabel = UILabel.init(frame: CGRect.init(x: ((i % 2) == 1 ? (SCREEN_WIDTH - 60) / 2 + 15 : 15), y: (10 + CGFloat(i / 2) * 23) , width: (SCREEN_WIDTH - 60) / 2, height: 20))
            contentLabel.text = titlearr[i] + " " + jsonContentarr[i]
            contentLabel.textColor = UIColor.init(hex: "#FFFFFF", alpha: 0.75)
            contentLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
            backView.addSubview(contentLabel)
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    lazy var backView : UIImageView = {
        let backView = UIImageView()
        backView.backgroundColor = UIColor.init(hex: "#3186E9", alpha: 0.8)
        backView.cornerRadius = 5
        backView.layer.masksToBounds = true
        return backView
    }()
    
    
    
}
