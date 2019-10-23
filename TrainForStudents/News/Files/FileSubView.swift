//
//  FileSubView.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/21.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class FileSubView: UIView {
    var saveButtonArry = NSMutableArray()
    typealias funcBlock = (_ subViewData : JSON) -> ()
    var buttonClickCallBack : funcBlock?
    var data:[JSON] = [JSON]() {//属性后面加一对大括号称为属性监听器
        //属性即将进行改变时监听
        willSet{
        }
        //属性已经改变时进行监听
        didSet{
            setupButtonView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupButtonView()
        setupConstraints()
    }
    
//    func addChildeView() {
//        for (index, dic) in data.enumerated() {
//            let button = createButtonWithTitle(title: dic["leanchannelname"].stringValue, index: index)
//            self.addSubview(button)
//            self.saveButtonArry.add(button)
//            print("\(index): \(dic)")
//        }
//    }
    
    //布局子控件
    func setupButtonView() {
        if self.data.count == 0 {
            return;
        }
        self.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        
        var origin_x:CGFloat = 20
        var origin_y:CGFloat = 0
        let buttonHeight:CGFloat = 34
        let buttonWidth:CGFloat = (SCREEN_WIDTH-80)/3
        for (index, dic) in data.enumerated() {
            let button = createButtonWithTitle(title: dic["leanchannelname"].stringValue, index: index)
            self.addSubview(button)
            button.frame = CGRect(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            if button.frame.maxX > SCREEN_WIDTH {
                //处理换行
                origin_x = 20;
                origin_y = origin_y + buttonHeight + 20;
                
                button.frame = CGRect(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            }
            origin_x = button.frame.maxX + 20;
            button.tag = 1000+index;
        }
        self.addSubview(bottomline)
        bottomline.frame = CGRect(x: 0, y: origin_y + buttonHeight - 1, width: SCREEN_WIDTH, height: 1)
        
        self.mas_updateConstraints { (make) in
            make?.height.mas_equalTo()(origin_y + buttonHeight)
        }
        
      
        self.setNeedsUpdateConstraints()        
    }
    
    func setupConstraints() {
        self.mas_updateConstraints { (make) in
            make?.height.mas_equalTo()(0)
        }
        self.setNeedsUpdateConstraints()
    }
    
    func createButtonWithTitle(title:String, index:NSInteger) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
//        btn.tag = tag
//        if tag == 1000 {
//            btn.setTitleColor(UIColor.defaultColor(), for: .normal)
//            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//        }
        return btn
    }
    
    @objc func buttonClick(btn:UIButton) {

        if let callBack = buttonClickCallBack  {
            callBack(self.data[btn.tag-1000])
        }
        
        for item in self.saveButtonArry {
            if let button = item as? UIButton {
                button.setTitleColor(.black, for: .normal)
            }
        }
        
        btn.setTitleColor(UIColor.defaultColor(), for: .normal)
        
    }
    
    lazy var bottomline:UILabel = {
        let bottomline = UILabel()
        bottomline.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        return bottomline
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
