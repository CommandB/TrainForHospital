//
//  NewsChannelView.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SnapKit
class NewsChannelView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addChildViews();
    }
    
    func addChildViews() {
        self.addSubview(topView)
        self.addSubview(textLabel)
        self.topView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        self.textLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(30)
        }
        
        
    }
    
    lazy var topView:UIImageView = {
        let topView = UIImageView()
        topView.backgroundColor = UIColor.white
        topView.isUserInteractionEnabled = true
        return topView
    }()
    
    lazy var textLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .lightGray
        titleLabel.isUserInteractionEnabled = true
        return titleLabel
    }()
    
    
}
