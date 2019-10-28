//
//  TitleHeaderCell.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit

class TitleHeaderCell: UITableViewCell {

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.createCellUI()
        self.setNeedsUpdateConstraints()
    }
    
    func createCellUI(){
        
    }
    
    func bindData(index:Int){
        switch index {
        case 0:
            titleLabel.text = "轮转周期"
            self.contentView.addSubview(PointImageView)
            break
        case 2:
            titleLabel.text = "大纲完成进度"
            break
        case 4:
            titleLabel.text = "综合到课率"
            break
        case 6:
            titleLabel.text = "近一周教学活动"
            break
        default:
            break
        }
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(lineView)
        self.contentView.addSubview(SeparatorView)
    }
    
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.init(x: 25, y: 10, width: SCREEN_WIDTH/2, height: 22))
        titleLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        titleLabel.textColor = UIColor.init(hex: "#313131")
        return titleLabel
    }()
    
    lazy var lineView: UIView = {
        let lineView = UIView(frame: CGRect.init(x: 15, y: 11, width: 5, height: 21))
        lineView.backgroundColor = UIColor.init(hex: "#3186E9")
        return lineView
    }()
    
    lazy var SeparatorView: UIView = {
        let SeparatorView = UIView(frame: CGRect.init(x: 0, y: 40, width: SCREEN_WIDTH, height: 0.5))
        SeparatorView.backgroundColor = UIColor.init(hex: "#DDDDDE")
        return SeparatorView
    }()
    
    lazy var PointImageView: UIImageView = {
        let PointImageView = UIImageView.init(frame: CGRect.init(x: SCREEN_WIDTH - 15 - 5, y: 11, width: 5, height: 15))
        PointImageView.image = UIImage(named:"")
        return PointImageView
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
