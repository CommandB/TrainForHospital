//
//  TurnDetailCell.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class TurnDetailCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.createCellUI()
        self.setNeedsUpdateConstraints()
    }
    
    func createCellUI(){
        
    }
    
    func bindData(data:JSON){
        timeLabel.text = data["roundtime"].stringValue
        dayLabel.text = data["roundsurplus"].stringValue
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(dayLabel)
    }
    
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: CGRect.init(x: 16, y: 12, width: SCREEN_WIDTH/2, height: 18))
        timeLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 13)
        timeLabel.textColor = UIColor.black
        return timeLabel
    }()
    
    lazy var dayLabel: UILabel = {
        let dayLabel = UILabel(frame: CGRect.init(x: SCREEN_WIDTH/2, y: 12, width: SCREEN_WIDTH/2 - 15, height: 18))
        dayLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 13)
        dayLabel.textAlignment = .right
        dayLabel.textColor = UIColor.init(hex: "#3186E9")
        return dayLabel
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
