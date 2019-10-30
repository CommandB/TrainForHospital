//
//  MyStudentDetailController.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/23.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyStudentDetailController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var myTableView = UITableView()
    var studentId = ""
    var data:JSON?{//属性后面加一对大括号称为属性监听器
        //属性即将进行改变时监听
        willSet{
        }
        //属性已经改变时进行监听
        didSet{
            self.getPageData()
//            self.myTableView.mj_header.beginRefreshing()
        }
    }
    var dataSource1:JSON!
    var dataSource2:JSON!
    var dataSource3 =  [JSON]()
    var fileType = "学员1"
    
    
    var requestedData = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        creatUI()
//        getPageData()
    }
    func creatUI(){
        myTableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - navHeight - 100), style: UITableViewStyle.plain)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.separatorStyle = .none

        myTableView.register(TitleHeaderCell.self, forCellReuseIdentifier: "TitleHeaderCell")
        myTableView.register(TurnDetailCell.self, forCellReuseIdentifier: "TurnDetailCell")
        myTableView.register(CompletionProgressCell.self, forCellReuseIdentifier: "CompletionProgressCell")
        myTableView.register(ClassRateCell.self, forCellReuseIdentifier: "ClassRateCell")
        myTableView.register(ClassActivityCell.self, forCellReuseIdentifier: "ClassActivityCell")
        myTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        
        
        self.view.addSubview(myTableView)
        
    }
    
    //获取学员信息
    func getPageData(){
        
        let url = SERVER_PORT + "rest/app/querynowstudentdetails.do"
        myPostRequest(url, ["personid":data!["personid"].stringValue,"roundokpeopleresultid":data!["roundokpeopleresultid"].stringValue]).responseJSON(completionHandler: {resp in
            self.myTableView.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json=JSON(responseJson)
                print(json)
                if json["code"].stringValue == "1"{

                    self.dataSource1 = json["studentbasiclist"].arrayValue.first
                    self.dataSource2 = json["studenttrainbasiclist"].arrayValue.first
                    self.dataSource3 = json["studenttrainlist"].arrayValue
//                    self.headView.bindData(dataSource: self.dataSource1)
                    self.myTableView.reloadData()
//
                    let headerView = TableHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 82))
                    headerView.layOutChildeView(data: self.dataSource1)
                    self.myTableView.tableHeaderView = headerView
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
    
    @objc func refresh(){
        self.myTableView.mj_header.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 {
            return 120
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderCell", for: indexPath)
            if let cell1 = cell as? TitleHeaderCell {
                cell1.bindData(index: indexPath.row)
            }
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TurnDetailCell", for: indexPath)
            if let cell1 = cell as? TurnDetailCell {
                if self.dataSource1 != nil {
                    cell1.bindData(data: self.dataSource1)
                }
            }
            return cell
        }else if indexPath.row == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletionProgressCell", for: indexPath)
            if let cell1 = cell as? CompletionProgressCell {
                if self.dataSource1 != nil {
                    cell1.bindData(data: self.dataSource1)
                }
            }
            return cell
        }else if indexPath.row == 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClassRateCell", for: indexPath)
            if let cell1 = cell as? ClassRateCell {
                if self.dataSource1 != nil {
                    cell1.bindData(data: self.dataSource2)
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClassActivityCell", for: indexPath)
            if let cell1 = cell as? ClassActivityCell {
                cell1.bindData(data: dataSource3[indexPath.row-7])
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource3.count == 0 ? 7 : (7 + self.dataSource3.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
//            myPresentView(self, viewName: "MyStudentTaskView")
            let vc = getViewToStoryboard("MyStudentTaskView")
            (vc as! TurnTaskController).isTeacherPush = true
            (vc as! TurnTaskController).studentPersonID = data!["personid"].stringValue

            //跳转
            self.present(vc, animated: true, completion: nil)
//            let vc = TurnTaskController()
//            self.present(vc, animated: true, completion: nil)
        }
        
    }
    @objc func cancelAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
