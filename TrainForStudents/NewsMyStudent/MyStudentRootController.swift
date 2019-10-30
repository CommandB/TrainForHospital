//
//  MyStudentRootController.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
class MyStudentRootController: UIViewController,UIScrollViewDelegate {
    var data:JSON?
    var dataArray:[JSON] = [JSON]()
    
    var headView:StudentsHeaderView!
    
    var scrollView = UIScrollView()
    var taskType = 1000
    

    
    var pageIndex = 0
    
    var titleStr = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        initProperty()
//        addSubViews()
        getPageData()
    }
    
    func initProperty() {
        buildTitileView()
//        self.dataArray.append(data ?? JSON())
    }
    
    func addSubViews() {
        let height:CGFloat = UIDevice.current.iPhoneX ? 88 : 64
        
        headView = StudentsHeaderView()
        headView.addScrollview(arr: self.dataArray)
        self.view.addSubview(headView)
        headView.mas_makeConstraints { (make) in
            make?.height.equalTo()(100)
            make?.top.equalTo()(height)
            make?.left.right().equalTo()(self.view)
        }
        headView.buttonClickCallBack = { (tag) in
            self.changeViewWithTag(type: tag)
        }
        
        self.view.addSubview(scrollView)
        scrollView.mas_makeConstraints { (make) in
            make?.top.equalTo()(headView.mas_bottom)
            make?.left.right().offset()(0)
            make?.bottom.offset()(0)
        }
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH*CGFloat(self.dataArray.count), height: 0)
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        
        for i in 0..<self.dataArray.count {
            let contentVC = MyStudentDetailController()
            contentVC.view.frame = CGRect.init(x: SCREEN_WIDTH * CGFloat(i), y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - height - 100)
            contentVC.data = dataArray[i]
            self.addChildViewController(contentVC)
            contentVC.fileType = "WORD"
            
            self.scrollView.addSubview(contentVC.view)
        }
    }
    
    //获取我的学员子目录
    func getPageData(){
        let url = SERVER_PORT+"rest/app/queryTeacheringStudent.do"
        myPostRequest(url, method: .post).responseString(completionHandler: {[weak self] resp in
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self?.dataArray = json["data"].array!
                    if json["data"].array == nil || json["data"].arrayValue.count == 0 {
                        myAlert(self ?? MyStudentRootController(), message: "暂无学员")
//                        self?.dataArray.removeLast()
                        return
                    }
                    
                    self?.addSubViews()
//                    self?.firstVC.data = self?.dataArray.last
                }else{
                    myAlert(self ?? MyStudentRootController(), message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                self?.dataArray.removeLast()
                myAlert(self ?? MyStudentRootController(), message: "查询考题类目异常!")
                print(error)
                break
            }
            //            self.deptCollection.reloadData()
        })
        
    }
    
    
    
    func changeViewWithTag(type:NSInteger) {
        self.scrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(type-1000), y:self.scrollView.contentOffset.y)
        if type == self.taskType {
            return
        }
        self.taskType = type
//        self.refreshOrderList()
    }
    
    func refreshOrderList() {
//            self.firstVC.myTableView.mj_header.beginRefreshing();
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = NSInteger(scrollView.contentOffset.x/SCREEN_WIDTH)
        self.headView.endScrollViewWithIndex(index:index)
        if 1000+index == self.taskType {
            return
        }
        self.taskType = 1000+index
//        self.refreshOrderList()
    }
    
    @objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func publishAction() {
        
    }
    
    func buildTitileView() {
        self.view.addSubview(titleView)
        titleView.isUserInteractionEnabled = true
        let height = UIDevice.current.iPhoneX ? 88 : 64
        self.titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        self.titleView.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.titleView).offset(-10)
        }
        self.titleView.addSubview(backBtn)
        self.backBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.height.width.equalTo(44)
        }
        
    }
    @objc func cancelCurrentVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    lazy var titleView : UIImageView = {
        let titleView = UIImageView()
        titleView.image = UIImage(named: "顶部固定2.png")
        return titleView
    }()
    
    lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "我的学员"
        titleLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var backBtn : UIButton = {
        let backBtn = UIButton()
        backBtn.setImage(UIImage.init(named: "navBackWhiteImage"), for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(cancelCurrentVC), for: UIControlEvents.touchUpInside)
        return backBtn
    }()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

