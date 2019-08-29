//
//  FileSubviewsController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/21.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class FileSubviewsController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let tableView = UITableView()
    var data = [JSON]()
    var cataloghierarchy = [JSON]()
    
    
    var requestedData = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "返回")!.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(cancelAction))
        addChildViews()
        getPageData()
    }
    
    func addChildViews() {
        let margin = UIDevice.current.iPhoneX ? CGFloat(88): CGFloat(64)
        
        tableView.frame = CGRect.init(x: 0, y:margin, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.size.height-margin)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        tableView.backgroundColor = .red
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.view.addSubview(tableView)
    }
    
    //获取首页信息
    func getPageData(){
//        guard let jsonData = data else { return }
//        let url = SERVER_PORT+"rest/app/queryLearnSubdirectories.do"
//        myPostRequest(url, ["leanchannelid":jsonData["leanchannelid"].stringValue],  method: .post).responseString(completionHandler: {resp in
//            self.tableView.mj_header.endRefreshing()
//            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
//            //            self.deptCollection.mj_footer.endRefreshingWithNoMoreData()
//            
//            switch resp.result{
//            case .success(let respStr):
//                let json = JSON(parseJSON: respStr)
//                //                print(json)
//                if json["code"].stringValue == "1"{
//                    self.requestedData = json["cataloghierarchy"].arrayValue
//                    self.tableView.reloadData()
//                }else{
//                    myAlert(self, message: json["msg"].stringValue)
//                    print(json)
//                }
//                break
//            case .failure(let error):
//                myAlert(self, message: "查询考题类目异常!")
//                print(error)
//                break
//            }
//        })
        
    }
    
    //获取首页信息
    func getPageData111(index:NSInteger){
        let jsonData = self.requestedData[index]
        let url = SERVER_PORT+"rest/app/queryLearnSubdirectories.do"
        myPostRequest(url, ["leanchannelid":jsonData["leanchannelid"].stringValue],  method: .post).responseString(completionHandler: {resp in
            self.tableView.mj_header.endRefreshing()
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            //            self.deptCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                //                print(json)
                if json["code"].stringValue == "1"{
//                    self.requestedData = json["cataloghierarchy"].arrayValue
//                    self.tableView.reloadData()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "查询考题类目异常!")
                print(error)
                break
            }
        })
        
    }
    
    @objc func refresh() {
        self.getPageData()
    }
    
    @objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.cataloghierarchy.count
        }
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.imageView?.image = UIImage(named: "subFiles")
            cell.imageView?.contentMode = .scaleAspectFill
            cell.textLabel?.text = self.requestedData[indexPath.row]["leanchannelname"].stringValue
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//            cell.imageView?.image = UIImage(named: "subFiles")
//            cell.imageView?.contentMode = .scaleAspectFill
            cell.textLabel?.text = self.requestedData[indexPath.row]["leanchannelname"].stringValue
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.getPageData111(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.mj_header.beginRefreshing()
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


class subFileCell: UITableViewCell {
    
}
