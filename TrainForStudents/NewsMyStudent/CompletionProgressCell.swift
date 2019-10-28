//
//  CompletionProgressCell.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class CompletionProgressCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.createCellUI()
        self.setNeedsUpdateConstraints()
    }
    
    func createCellUI(){
        
    }
    
    func bindData(data:JSON){
        
        processLabel.text = "\(data["completionrate"].intValue)%"
        
        let processrate:Float = data["completionrate"].floatValue / 100.0
        
        ProcessView.frame = CGRect.init(x: 16, y: 14, width: CGFloat(processrate) * (SCREEN_WIDTH - 100), height: 20)
        ProcessView.backgroundColor = UIColor.init(hex: "#9BDE4C", alpha: 1)
        
        self.contentView.addSubview(backProcessView)
        self.contentView.addSubview(ProcessView)
        self.contentView.addSubview(processLabel)
    }
    
    
    lazy var backProcessView: UIView = {
        let backProcessView = UIView(frame: CGRect.init(x: 16, y: 14, width: SCREEN_WIDTH - 100, height: 20))
        backProcessView.backgroundColor = UIColor.init(hex: "#EEEEEE", alpha: 1)
        backProcessView.cornerRadius = 10
        backProcessView.layer.masksToBounds = true
        return backProcessView
    }()
    
    lazy var ProcessView: UIView = {
        let ProcessView = UIView(frame: CGRect.init(x: 16, y: 14, width: SCREEN_WIDTH - 110, height: 20))
        ProcessView.backgroundColor = UIColor.init(hex: "#9BDE4C", alpha: 1)
        ProcessView.cornerRadius = 10
        ProcessView.layer.masksToBounds = true
        return ProcessView
    }()
    
    
    lazy var processLabel: UILabel = {
        let processLabel = UILabel(frame: CGRect.init(x: SCREEN_WIDTH - 84, y: 10, width: 84 - 15, height: 30))
        processLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 21)
        processLabel.textAlignment = .right
        processLabel.textColor = UIColor.init(hex: "#3186E9")
        return processLabel
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
