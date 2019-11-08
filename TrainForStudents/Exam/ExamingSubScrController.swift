//
//  ExamingSubScrController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/18.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class ExamingSubScrController: UIViewController {
    
    var scrollViewHeigh:CGFloat = 0
    var sptext:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let scrollView = UIScrollView()
//        init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: scrollViewHeigh))
        self.view.addSubview(scrollView)

        scrollView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.right.top.equalToSuperview()
            ConstraintMaker.height.equalTo(scrollViewHeigh)
        }
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        
        containerView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.top.right.equalToSuperview()
            ConstraintMaker.height.greaterThanOrEqualTo(scrollView).offset(1)
            
        }
        
        
        let lbl = UILabel()
        lbl.text = sptext
        lbl.textColor = UIColor.init(hex: "#313131")
        lbl.font = UIFont.init(name: "PingFang-Regular", size: 15)
        lbl.numberOfLines = 0
        containerView.addSubview(lbl)
        
        lbl.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.equalToSuperview().offset(20)
            ConstraintMaker.width.equalTo(SCREEN_WIDTH - 40)
            ConstraintMaker.top.equalToSuperview().offset(20)
            ConstraintMaker.bottom.lessThanOrEqualTo(containerView).offset(-15)

        }
        scrollView.contentSize = CGSize.init(width: 0, height: lbl.frame.maxY + 20)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
