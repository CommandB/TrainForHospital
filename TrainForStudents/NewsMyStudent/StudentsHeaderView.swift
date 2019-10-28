//
//  StudentsHeaderView.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/25.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class StudentsHeaderView: UIView {

    var saveButtonArry = NSMutableArray()
    var saveLabelArry = [UILabel]()

    typealias funcBlock = (_ tag : NSInteger) -> ()
    var buttonClickCallBack : funcBlock?
    
    var btnWidth = SCREEN_WIDTH/4
    var titles = [String]()
    var images = [String]()
    
    var currentLabel:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
//        addScrollview()
//        addChildeView()
        
    }
    func addScrollview(arr:[JSON]){
        if arr.count == 0 {return}
        for i in arr {
            titles.append(i["personname"].stringValue)
            images.append("blue_user_circle")
        }
        self.addSubview(self.headerScrollView)
        self.headerScrollView.contentSize = CGSize.init(width: CGFloat(titles.count) * SCREEN_WIDTH / 4, height: 0)
        addChildeView()
    }
    
    
    func addChildeView() {
        for index in 0..<titles.count {
            createButtonWithTitleImage(title: titles[index],image: images[index], index: index)
        }
        layOutChildeView()
        self.headerScrollView.addSubview(self.indicatorview)
    }
    //布局子控件
    func layOutChildeView() {
        
//        guard let firstButton = self.viewWithTag(1000) else { return }
        self.indicatorview.frame = CGRect.init(x: 0, y: 98, width: btnWidth, height: 2)
    }
    
    func createButtonWithTitleImage(title:String,image:String, index:Int){
        let imageView = UIImageView.init(frame: CGRect.init(x: (btnWidth - 50)/2 + btnWidth * CGFloat(index), y: 10, width: 50, height: 50))
        imageView.image = UIImage.init(named: image)
        self.headerScrollView.addSubview(imageView)
        
        let label = UILabel.init(frame: CGRect.init(x: btnWidth * CGFloat(index), y: 70, width: btnWidth, height: 20))
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.text = title
        label.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        self.headerScrollView.addSubview(label)
        saveLabelArry.append(label)
        if index == 0 {
            label.textColor = UIColor.defaultColor()
            currentLabel = label
        }
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect.init(x: btnWidth * CGFloat(index), y: 0, width: btnWidth, height: 98)
        
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        btn.tag = index + 1000
        
        self.headerScrollView.addSubview(btn)
    }
    
    @objc func buttonClick(btn:UIButton) {
        self.indicatorview.setX(x: btn.X)

        if let callBack = buttonClickCallBack {
            callBack(btn.tag)
        }
        currentLabel.textColor = UIColor.black
        saveLabelArry[btn.tag - 1000].textColor = UIColor.defaultColor()
        currentLabel = saveLabelArry[btn.tag - 1000]
        
    }
    
    func endScrollViewWithIndex(index:NSInteger) {
        guard let selectedButton = self.viewWithTag(1000+index) as? UIButton else { return }
        
        self.indicatorview.setX(x: selectedButton.X)
        
        currentLabel.textColor = UIColor.black
        saveLabelArry[index].textColor = UIColor.defaultColor()
        currentLabel = saveLabelArry[index]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    //懒加载
    //指示的view
    lazy var indicatorview:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.defaultColor()
        return view
    }()
    
    lazy var headerScrollView:UIScrollView = {
        let headerScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        headerScrollView.backgroundColor = UIColor.white
        return headerScrollView
    }()
}
