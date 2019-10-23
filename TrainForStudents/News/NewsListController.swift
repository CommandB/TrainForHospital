//
//  NewsListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/19.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class NewsListController : UIViewController,UITableViewDelegate,UITableViewDataSource,NewsPageHeadViewDelegate,NewsChannelCellDelegate,NewsOfficeCellDelegate{
    func didClickButton(index: NSInteger) {
        
    }
    
    var dataSource1 = [JSON]()
    var dataSource2 = [JSON]()
    var dataSource3 = [String : JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        let image = UIImage(named: "顶部固定2.png")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
        
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
//        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        self.title = "学习平台"
        addChildViews()
        setupConstraints()
    }
    
    func addChildViews() {
//        self.buildTitileView()
        self.buildTableView()
    }
    
    func setupConstraints() {
       
    }
    //获取首页信息
    func getPageData(){
        
        let url = SERVER_PORT+"rest/app/queryLearnChannelData.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            self.tableView.mj_header.endRefreshing()

            switch resp.result{
            case .success(let responseJson):
                
                let json=JSON(responseJson)
                if json["code"].stringValue == "1"{
                    self.dataSource1.removeAll()
                    self.dataSource2.removeAll()
                    self.dataSource3.removeAll()
                    
                    self.dataSource1 = json["banner"].arrayValue
                    self.dataSource2 = json["headcategory"].arrayValue
                    self.dataSource3 = json["data"].dictionaryValue
                    self.headView.bindData(dataSource: self.dataSource1)
                    self.tableView.reloadData()
                    
//                    self.selfView.jsonDataSource = json["data"]
//                    self.selfCollection.reloadData()
                    
                }else{
                    myAlert(self, message: "请求我的信息失败!")
                }
            case .failure(let error):
//                self.tableView.endRefreshing(isSuccess: false)
//                self.selfCollection.endRefreshing(isSuccess: false)
                print(error)
            }
            
        })
        
    }
    
    @objc func refresh() {
        self.getPageData()
    }
    
    func buildTitileView() {
        self.view.addSubview(titleView)
        let height = UIDevice.current.iPhoneX ? 88 : 64
        self.titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        self.view.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.titleView).offset(-10)
        }
    }
    
    func buildTableView() {
        self.view.addSubview(self.tableView)
        let height:CGFloat = UIDevice.current.iPhoneX ? 88 : 64
        let bottomMargin = UIDevice.current.iPhoneX ? 83 : 49

        self.tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(height)
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }
        self.tableView.tableHeaderView = headView
    }
    
    /////tableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataSource3.count == 0 {
            return 0;
        }
        return 1+self.dataSource3.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsChannelCell", for: indexPath)
            if let cell1 = cell as? NewsChannelCell {
                cell1.bindData(dataSource: self.dataSource2)
                cell1.delegate = self
            }
            return cell
        }else   {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsOfficeCell", for: indexPath)
            if let cell1 = cell as? NewsOfficeCell {
                let key = self.dataSource3.keys.sorted()[indexPath.section-1]
                
//                let key = ([String](self.dataSource3.keys))[indexPath.section-1]
                cell1.bindData(dataSource1: self.dataSource3[key]?.arrayValue ?? [JSON](), title: key)
                cell1.delegate = self
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10;
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        headView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 10)
        headView.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        return headView
    }
    
    ////NewsPageHeadViewDelegate
    func didClickNewsPageHeadView(json:JSON) {
        let vc = BaseFileViewController()
        vc.data = json;
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    ////NewsChannelCellDelegate
    func didClickButton(dataSource:[JSON], index:NSInteger) {
        if index == 0 {
            let vc = CollectViewController()
//            vc.data = json;
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed = false

        }else if index == 1 {
            let vc = FooterViewController()
            //            vc.data = json;
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
        else if index == 2 {
            myPresentView(self, viewName: "exerciseCenterView")
        }else if index == 3 {
            myAlert(self, message: "该功能尚未开放")
        }
        else if index >= 4{
            let vc = BaseFileViewController()
            vc.data = dataSource[index-4];
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
    }
    
    ////NewsChannelCellDelegate
    func didClickNewsOfficeCellButton(index:NSInteger, data:JSON) {
        let vc = BaseFileViewController()
        vc.data = data;
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    
    lazy var titleView : UIImageView = {
        let titleView = UIImageView()
        titleView.image = UIImage(named: "顶部固定2.png")
        return titleView
    }()
    
    lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "学习平台"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.register(NewsPageControlCell.self, forCellReuseIdentifier: "NewsPageControlCell")
        tableView.register(NewsChannelCell.self, forCellReuseIdentifier: "NewsChannelCell")
        tableView.register(NewsOfficeCell.self, forCellReuseIdentifier: "NewsOfficeCell")
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
//        tableView.backgroundColor = RGBCOLOR(r: 240, 240, 240)
//        tableView.isUserInteractionEnabled = true
        
        return tableView
    }()
    
    lazy var headView: NewsPageHeadView = {
        let headView = NewsPageHeadView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 150))
        headView.delegate = self
        return headView
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.mj_header.beginRefreshing()
//        myAlert(self, message: "暂未开放,敬请期待!", handler:{action in
//            let app = (UIApplication.shared.delegate) as! AppDelegate
//            let tabBar = (app.window?.rootViewController) as! MyTabBarController
//            tabBar.selectedIndex = selectedTabBarIndex
//        })
    }
    
}
