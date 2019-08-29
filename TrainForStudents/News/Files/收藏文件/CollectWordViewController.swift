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
            initData()
        }
    }
    
    
    var requestedData = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViews()
    }
    
    func initData() {
        self.requestedData.removeAll()
        if var dataArray = UserDefaults.standard.stringArray(forKey: self.fileType) {
            for data in dataArray {
                let json1 = JSON(parseJSON: data)
               self.requestedData.append(json1)
            }
            self.tableView.reloadData()
        }else{
            requestedData = [JSON]()
        }
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
        //        guard let index = self.requestedData.index(of: json) else { return }
        
        if var dataArray = UserDefaults.standard.stringArray(forKey: self.fileType) {
            for data in dataArray {
                let json1 = JSON(parseJSON: data)
                if json1["resourcesid"] == json["resourcesid"] {
                    guard let index = dataArray.index(of: data) else { return  }
                    dataArray.remove(at: index)
                    UserDefaults.standard.set(dataArray, forKey: self.fileType)
                    self.initData()
                    return
                }
            }
            dataArray.append(json.description)
            UserDefaults.standard.set(dataArray, forKey: self.fileType)
        }else{
            var array = [String]()
            array.append(json.description)
            UserDefaults.standard.set(array, forKey: self.fileType)
        }
        self.tableView.reloadData()
        
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
