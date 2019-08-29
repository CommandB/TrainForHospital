//
//  NewsOfficeCell.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON


public protocol NewsOfficeCellDelegate {
    func didClickNewsOfficeCellButton(index:NSInteger, data:JSON)
}

class NewsOfficeCell: UITableViewCell {
    
    var dataSource = [JSON]()
    var delegate: NewsOfficeCellDelegate?

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.createCellUI()
        self.setNeedsUpdateConstraints()
    }
    
    func createCellUI()  {
        self.addSubview(self.titleLabel)
    }
    
    func bindData(dataSource1:[JSON],title:String) {
        if dataSource1.count == 0 {
            return
        }
        for subview in self.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        for subview in self.subviews {
            if subview is UIButton {
                subview.removeFromSuperview()
            }
        }
        
        self.dataSource = dataSource1.sorted()
        
        self.contentView.addSubview(self.titleLabel)
        titleLabel.text = title
        
        var origin_x:CGFloat = 10
        var origin_y:CGFloat = 50;
        let buttonWidth:CGFloat = (SCREEN_WIDTH-40)/3
        let buttonHeight:CGFloat = 50
        
        
        for item in dataSource {
            guard let index = dataSource.index(of: item) else { return }

            let button = UIButton()
            button.titleLabel?.textAlignment = .center
            button.titleLabel!.numberOfLines = 0
            button.titleLabel!.font = UIFont.systemFont(ofSize: 13)
            button.setTitleColor(.white, for: .normal)
            button.setTitle(item["leanchannelname"].stringValue, for: .normal)
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 3
            button.layer.borderColor = UIColor.blue.cgColor
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            button.tag = 1000+index
            
            self.addSubview(button)
            button.frame = CGRect.init(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            if button.frame.origin.x >= SCREEN_WIDTH {
                origin_x = 10
                origin_y = origin_y + buttonHeight + 10;
                button.frame = CGRect.init(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            }
            origin_x = button.frame.maxX + 10
            button.backgroundColor = .defaultColor()
            
        }
        self.contentView.snp.remakeConstraints { (make) in
            make.height.equalTo(origin_y + buttonHeight + 10)
        }
        self.setNeedsUpdateConstraints()
    }
    
    @objc func clickButton(_button:UIButton) {
        self.delegate?.didClickNewsOfficeCellButton(index: _button.tag, data: self.dataSource[_button.tag-1000])
    }
    
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        return titleLabel
    }()
    
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
