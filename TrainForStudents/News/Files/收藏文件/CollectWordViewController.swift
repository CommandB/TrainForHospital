//
//  CollectWordViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/28.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class CollectWordViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let tableView = UITableView()

    var fileType:String = "WORD"{//属性后面加一对大括号称为属性监听器
        //属性即将进行改变时监听
        willSet{
        }
        //属性已经改变时进行监听
        didSet{
        }
    }
    
    
    var requestedData = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViews()
        getPageData(fileType: fileType)
    }
    
    func addChildViews() {
        let margin = UIDevice.current.iPhoneX ? CGFloat(88+50): CGFloat(64+50)
        
        tableView.frame = CGRect.init(x: 0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.size.height-margin)
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(FileWordCell.classForCoder(), forCellReuseIdentifier: "FileWordCell")
        self.view.addSubview(tableView)
    }
    
    func requestCollectData(json:JSON) {
        var url = ""
        var isCollectionBool = false
        let persionId = UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)!
        let persionName = UserDefaults.User.string(forKey: .personName)!
        
        if json["iscollect"].stringValue == "0" {
            //执行收藏操作
            url = SERVER_PORT+"rest/app/insertlearncollect.do"
            isCollectionBool = true
        }else{
            //执行取消收藏操作
            url = SERVER_PORT+"rest/app/dellearncollect.do"
            isCollectionBool = false
        }
        myPostRequest(url,["resourcesid":json["resourcesid"],"leanchannelid":json["leanchannelid"],"personid":persionId,"personname":persionName]).responseJSON(completionHandler: {resp in
            //            self.tableView.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json=JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    //                    self.tableView.reloadData()
                    myAlert(self, message: isCollectionBool == true ? "收藏成功":"取消收藏成功")
                    self.getPageData(fileType: self.fileType)
                }else{
                    myAlert(self, message: "请求我的信息失败!")
                }
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    func getPageData(fileType:String){
        let url = SERVER_PORT + "rest/app/querylearncollect.do"
        let persionID = UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)!
        myPostRequest(url, ["personid":persionID,"filetype":fileType],  method: .post).responseString(completionHandler: {resp in
            //            self.deptCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                print(json)
                print("我的收藏数据请求")
                if json["code"].stringValue == "1"{
                    if json["data"].arrayValue.count == 0 {
                        self.requestedData = json["data"].arrayValue
                    }else{
                        self.requestedData = json["data"].arrayValue
                    }
                    
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
//                self.dataArray.removeLast()
                myAlert(self, message: "查询考题类目异常!")
                print(error)
                break
            }
            self.tableView.reloadData()
        })
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.requestedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileWordCell", for: indexPath)
        if let cell1 = cell as? FileWordCell {
            cell1.bindData(dataSource1: self.requestedData[indexPath.row], title: "")
            cell1.buttonClickCallBack = { (json) in
                self.requestCollectData(json: json)
            }
            return cell1
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = OpenFileViewController()
        vc.data = self.requestedData[indexPath.row]
        self.parent?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        //        self.hidesBottomBarWhenPushed = false
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        self.tableView.mj_header.beginRefreshing()
        //        myAlert(self, message: "暂未开放,敬请期待!", handler:{action in
        //            let app = (UIApplication.shared.delegate) as! AppDelegate
        //            let tabBar = (app.window?.rootViewController) as! MyTabBarController
        //            tabBar.selectedIndex = selectedTabBarIndex
        //        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
