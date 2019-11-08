//
//  FooterViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/29.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class FooterViewController: NewsBaseViewController,UIScrollViewDelegate {

    var data:JSON?
    var dataArray:[JSON] = [JSON]()
    
    var headView = FileDownHeadView()
    
    var scrollView = UIScrollView()
    var taskType = 1000
    
    var pageIndex = 0
    
    var titleStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initProperty()
        addSubViews()
    }
    
    func initProperty() {
        let image = UIImage(named: "返回")!.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(cancelAction))
        self.title = "我的足迹"
        self.dataArray.append(data ?? JSON())
    }
    
    func addSubViews() {
        let height:CGFloat = UIDevice.current.iPhoneX ? 88 : 64
        
        self.view.addSubview(headView)
        headView.mas_makeConstraints { (make) in
            make?.height.equalTo()(50)
            make?.top.equalTo()(self.view)?.offset()(height)
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
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH*5, height: 0)
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
            //            UITableView.appearance().estimatedRowHeight = 0;
            //            UITableView.appearance().estimatedSectionHeaderHeight = 0;
            //            UITableView.appearance().estimatedSectionFooterHeight = 0;
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        let firstVC = FooterWordViewController()
        let secondVC = FooterWordViewController()
        let thirdVC = FooterWordViewController()
        let fourthVC = FooterWordViewController()
        let fifthVC = FooterWordViewController()
        firstVC.fileType = "WORD"
        secondVC.fileType = "EXCEL"
        thirdVC.fileType = "PDF"
        fourthVC.fileType = "PPT"
        fifthVC.fileType = "视频"
        
        
        firstVC.view.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        secondVC.view.frame = CGRect.init(x: SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        thirdVC.view.frame = CGRect.init(x: SCREEN_WIDTH*2, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        fourthVC.view.frame = CGRect.init(x: SCREEN_WIDTH*3, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        fifthVC.view.frame = CGRect.init(x: SCREEN_WIDTH*4, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        
        self.addChildViewController(firstVC)
        self.addChildViewController(secondVC)
        self.addChildViewController(thirdVC)
        self.addChildViewController(fourthVC)
        self.addChildViewController(fifthVC)
        
        self.scrollView.addSubview(firstVC.view)
        self.scrollView.addSubview(secondVC.view)
        self.scrollView.addSubview(thirdVC.view)
        self.scrollView.addSubview(fourthVC.view)
        self.scrollView.addSubview(fifthVC.view)
        
    }
    
    //获取子目录
    func getPageData(pageIndex:NSInteger){
        guard let jsonData = self.dataArray.last else { return }
        let url = SERVER_PORT+"rest/app/queryLearnSubdirectories.do"
        myPostRequest(url, ["leanchannelid":jsonData["leanchannelid"].stringValue],  method: .post).responseString(completionHandler: {resp in
            //            self.deptCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    
                    if json["cataloghierarchy"].array == nil || json["cataloghierarchy"].arrayValue.count == 0 {
                        self.dataArray.removeLast()
                        return
                    }
                    
                    
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                self.dataArray.removeLast()
                myAlert(self, message: "查询考题类目异常!")
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
        self.refreshOrderList()
    }
    
    func refreshOrderList() {
        switch taskType {
        case 1000:
            //            self.firstVC.tableView.mj_header.beginRefreshing();
            break
        case 1001:
            //            self.secondVC.tableView.mj_header.beginRefreshing();
            break
        case 1002:
            //            self.thirdVC.tableView.mj_header.beginRefreshing()
            break
        case 1003:
            //            self.fourthVC.tableView.mj_header.beginRefreshing()
            break
        case 1004:
            //            self.fifthVC.tableView.mj_header.beginRefreshing()
            break
        default:
            break
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = NSInteger(scrollView.contentOffset.x/SCREEN_WIDTH)
        self.headView.endScrollViewWithIndex(index:index)
        if 1000+index == self.taskType {
            return
        }
        self.taskType = 1000+index
        self.refreshOrderList()
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
