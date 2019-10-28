//
//  ClassRateCell.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class ClassRateCell: UITableViewCell {
    
    var backWidth = (SCREEN_WIDTH - 30)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.createCellUI()
        self.setNeedsUpdateConstraints()
    }
    
    func createCellUI(){
        
    }
    
    func bindData(data:JSON){
        
        ProcessLabel.text = "\(data["trainrate"].intValue)%"
        willProcessLabel.text = data["mustjoincount"].stringValue
        didProcessLabel.text = data["actualjoincount"].stringValue
        
        self.contentView.addSubview(backView)
        self.backView.addSubview(ProcessLabel)
        self.backView.addSubview(willProcessLabel)
        self.backView.addSubview(didProcessLabel)
        
        self.backView.addSubview(classRateLabel)
        self.backView.addSubview(willJoinTimesLabel)
        self.backView.addSubview(trueJoinTimesLabel)
    }
    

    lazy var backView: UIView = {
        let backView = UIView(frame: CGRect.init(x: 15, y: 10, width: SCREEN_WIDTH - 30, height: 100))
        let backViewColor = CAGradientLayer()
        backViewColor.startPoint = CGPoint.init(x: 0.0, y: 0)
        backViewColor.endPoint = CGPoint.init(x: 1.0, y: 0)
        backViewColor.colors = [UIColor.init(hex: "#2985E9").cgColor,UIColor.init(hex: "#52CDFE").cgColor]
        backViewColor.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: 100)
        backView.layer.insertSublayer(backViewColor, at: 0)

        backView.cornerRadius = 5
        backView.layer.masksToBounds = true
        return backView
    }()
    
//    lazy var ProcessView: ProgressView = {
//        var progressProperty = ProgressProgerty.init(width: 5, progressEnd: 1, progressColor: UIColor.white)
//        let ProcessView = ProgressView.init(propressProperty: progressProperty, frame: CGRect.init(x: 30, y: 12, width: 50, height: 50),processLabelText:"90%")
//        ProcessView.setProgress(progress: 0.01, time: 1, animate: false)
//        return ProcessView
//    }()
    
    lazy var ProcessLabel: UILabel = {
        let ProcessLabel = UILabel(frame: CGRect.init(x: 0, y: 20, width: backWidth/3, height: 40))
        ProcessLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 28)
        ProcessLabel.text = "20"
        ProcessLabel.textAlignment = .center
        ProcessLabel.textColor = UIColor.white
        return ProcessLabel
    }()
    lazy var classRateLabel: UILabel = {
        let classRateLabel = UILabel(frame: CGRect.init(x: 0, y: 70, width: backWidth/3, height: 18))
        classRateLabel.font = UIFont.init(name: "PingFangSC-Medium", size:12)
        classRateLabel.textAlignment = .center
        classRateLabel.text = "到课率"
        classRateLabel.textColor = UIColor.white
        return classRateLabel
    }()
    lazy var willJoinTimesLabel: UILabel = {
        let willJoinTimesLabel = UILabel(frame: CGRect.init(x: backWidth/3, y: 70, width: backWidth/3, height: 18))
        willJoinTimesLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 12)
        willJoinTimesLabel.textAlignment = .center
        willJoinTimesLabel.text = "应该参与次数"
        willJoinTimesLabel.textColor = UIColor.white
        return willJoinTimesLabel
    }()
    lazy var trueJoinTimesLabel: UILabel = {
        let trueJoinTimesLabel = UILabel(frame: CGRect.init(x: backWidth/3 * 2, y: 70, width: backWidth/3, height: 18))
        trueJoinTimesLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 12)
        trueJoinTimesLabel.textAlignment = .center
        trueJoinTimesLabel.text = "实际参与次数"
        trueJoinTimesLabel.textColor = UIColor.white
        return trueJoinTimesLabel
    }()
    
    lazy var willProcessLabel: UILabel = {
        let willProcessLabel = UILabel(frame: CGRect.init(x: backWidth/3, y: 20, width: backWidth/3, height: 40))
        willProcessLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 28)
        willProcessLabel.text = "20"
        willProcessLabel.textAlignment = .center
        willProcessLabel.textColor = UIColor.white
        return willProcessLabel
    }()
    
    lazy var didProcessLabel: UILabel = {
        let didProcessLabel = UILabel(frame: CGRect.init(x: backWidth/3 * 2, y: 20, width: backWidth/3, height: 40))
        didProcessLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 28)
        didProcessLabel.text = "30"
        didProcessLabel.textAlignment = .center
        didProcessLabel.textColor = UIColor.white
        return didProcessLabel
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
