//
//  NewsChannelCell.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

protocol NewsChannelCellDelegate {
    func didClickButton(dataSource:[JSON], index:NSInteger)
}


class NewsChannelCell: UITableViewCell {

    var dataSource = [JSON]()
    var delegate: NewsChannelCellDelegate?

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.isUserInteractionEnabled = true
        self.createCellUI()
    }
    
    
    func createCellUI()  {
       
    }
    
    func bindData(dataSource:[JSON]) {
        if dataSource.count == 0 {
            return
        }
        self.dataSource = dataSource
        
        for subview in self.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        var origin_x:CGFloat = 0
        var origin_y:CGFloat = 10;
        let buttonWidth:CGFloat = SCREEN_WIDTH/4
        let buttonHeight:CGFloat = 80

        var defaultArr = ["收藏","足迹","刷题","直播"]
        
        for item in defaultArr {
            guard let index = defaultArr.index(of: item) else { return }

            let button = NewsChannelView()
            if index == 0{
                button.topView.image = UIImage(named: "learn_collection")
            }else if index == 1 {
                button.topView.image = UIImage(named: "learn_footprint")
            }else if index == 2 {
                button.topView.image = UIImage(named: "learn_brush_problem")
            }else if index == 3 {
                button.topView.image = UIImage(named: "learn_live_broadcast")
            }
            button.tag = 1000+index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
            button.addGestureRecognizer(tapGesture)
            button.isUserInteractionEnabled = true
            
            button.textLabel.text = defaultArr[index]
            button.tag = index + 1000;
            self.addSubview(button)
            button.frame = CGRect.init(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            if button.frame.origin.x > SCREEN_WIDTH {
                origin_x = 0
                origin_y = origin_y + buttonHeight + 10;
                button.frame = CGRect.init(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            }
            origin_x = button.frame.maxX
        }
        origin_x = 0;
        origin_y = origin_y + buttonHeight + 10;
        
        for item in dataSource {
            guard let index = dataSource.index(of: item) else { return }

            let button = NewsChannelView()
            button.topView.image = UIImage(named: "learn_other")
            button.tag = index + 1004;
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
            button.addGestureRecognizer(tapGesture)
            button.isUserInteractionEnabled = true

            button.textLabel.text = item["leanchannelname"].stringValue
            self.addSubview(button)
            button.frame = CGRect.init(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            if button.frame.origin.x >= SCREEN_WIDTH {
                origin_x = 0
                origin_y = origin_y + buttonHeight + 10;
                button.frame = CGRect.init(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            }
            origin_x = button.frame.maxX
            button.tag = 1004+index
        }
        self.contentView.snp.remakeConstraints { (make) in
            make.height.equalTo(origin_y + buttonHeight + 10)
        }
    }
    
    @objc func handleGesture(gesture:UITapGestureRecognizer) {
        if let channelView = gesture.view {
            self.delegate?.didClickButton(dataSource: self.dataSource, index: channelView.tag-1000)
        }
    }
    
//    @objc func handleGesture(gesture:UIGestureRecognizer) {
//        if let view = gesture.view {
//            self.delegate?.didClickButton(index: view.tag-1000)
//        }
//
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

