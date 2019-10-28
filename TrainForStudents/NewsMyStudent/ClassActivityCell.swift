//
//  ClassActivityCell.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class ClassActivityCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.createCellUI()
        self.setNeedsUpdateConstraints()
    }
    
    func createCellUI(){
        
    }
    
    func bindData(data:JSON){
        if data["starttime"].stringValue == "" {
            return
        }
        let str = data["starttime"].stringValue.substring(to: 18)
        dayTimeLabel.text = str.getDateNum(type: .dateTypeDate)
        
        detailTimeLabel.text = str.getDateNum(type: .dateTypeMinit)
        
        activityNameLabel.text = data["traintypename"].stringValue
        self.contentView.addSubview(dayTimeLabel)
        self.contentView.addSubview(detailTimeLabel)
        self.contentView.addSubview(activityNameLabel)
    }
    
    
    lazy var dayTimeLabel: UILabel = {
        let dayTimeLabel = UILabel(frame: CGRect.init(x: 16, y: 10, width: SCREEN_WIDTH/3, height: 22))
        dayTimeLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        dayTimeLabel.textColor = UIColor.black
        return dayTimeLabel
    }()
    
    lazy var detailTimeLabel: UILabel = {
        let detailTimeLabel = UILabel(frame: CGRect.init(x: SCREEN_WIDTH/3, y: 12, width: SCREEN_WIDTH/3, height: 22))
        detailTimeLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        detailTimeLabel.textAlignment = .center
        detailTimeLabel.textColor = UIColor.black
        return detailTimeLabel
    }()
    
    lazy var activityNameLabel: UILabel = {
        let activityNameLabel = UILabel(frame: CGRect.init(x: SCREEN_WIDTH/3 * 2, y: 12, width: SCREEN_WIDTH/3 - 15, height: 22))
        activityNameLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        activityNameLabel.textAlignment = .right
        activityNameLabel.textColor = UIColor.black
        return activityNameLabel
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
