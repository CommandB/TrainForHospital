//
//  FIleWordViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/18.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class FIleWordViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let tableView = UITableView()
    var data:JSON?{//属性后面加一对大括号称为属性监听器
        //属性即将进行改变时监听
        willSet{
        }
        //属性已经改变时进行监听
        didSet{
            self.tableView.mj_header.beginRefreshing()
        }
    }
    var fileType = "WORD"
    
    
    var requestedData = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViews()
    }
    
    func addChildViews() {
        let margin = UIDevice.current.iPhoneX ? CGFloat(88+50+30): CGFloat(64+50+30)

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
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.view.addSubview(tableView)
    }
    
    //获取首页信息
    func getPageData(){
        guard let jsonData = data else { return }
        let url = SERVER_PORT+"rest/app/querylearnchannelfile.do"
        myPostRequest(url, ["leanchannelid":jsonData["leanchannelid"].stringValue,"filetype":fileType,"personid":UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)!],  method: .post).responseString(completionHandler: {resp in
            self.tableView.mj_header.endRefreshing()
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
//            self.deptCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                print(json)
                print("判断是否以搜藏")
                if json["code"].stringValue == "1"{
                    self.requestedData = json["data"].arrayValue
                    self.tableView.reloadData()
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
//            self.deptCollection.reloadData()
        })
        
    }
    func addFooterCollect(json:JSON){
        let url = SERVER_PORT + "rest/app/insertlearnmark.do"
        let personId = UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)!
        let personName = UserDefaults.User.string(forKey: .personName)!
        myPostRequest(url,["resourcesid":json["resourcesid"],"leanchannelid":json["leanchannelid"],"personid":personId,"personname":personName]).responseJSON(completionHandler: {resp in
            //            self.tableView.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json=JSON(responseJson)
                print(json)
                if json["code"].stringValue == "1"{
                    //                    self.tableView.reloadData()
                }else{
                    myAlert(self, message: "请求我的信息失败!")
                }
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    func requestCollectData(json:JSON) {
        var url = ""
        var isCollectionBool = false
        let personId = UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)!
        let personName = UserDefaults.User.string(forKey: .personName)!

        if json["iscollect"].stringValue == "0" {
            //执行收藏操作
            url = SERVER_PORT+"rest/app/insertlearncollect.do"
            isCollectionBool = true
        }else{
            //执行取消收藏操作
            url = SERVER_PORT+"rest/app/dellearncollect.do"
            isCollectionBool = false
        }
        myPostRequest(url,["resourcesid":json["resourcesid"],"leanchannelid":json["leanchannelid"],"personid":personId,"personname":personName]).responseJSON(completionHandler: {resp in
//            self.tableView.mj_header.endRefreshing()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json=JSON(responseJson)
                print(json)
                if json["code"].stringValue == "1"{
//                    self.tableView.reloadData()
                    myAlert(self, message: isCollectionBool == true ? "收藏成功":"取消收藏成功")
                }else{
                    myAlert(self, message: "请求我的信息失败!")
                }
            case .failure(let error):
                print(error)
            }
            
        })
//        self.tableView.reloadData()
        
    }
    
    
    
    @objc func refresh() {
        self.getPageData()
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
        addFooterCollect(json: self.requestedData[indexPath.row])
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


class FileWordCell: UITableViewCell {
    typealias funcBlock = (_ json : JSON) -> ()
    var buttonClickCallBack : funcBlock?
    var dataSource = JSON()
    var isCollectedBool = true
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.createCellUI()
        self.setUpContrains()
        self.setNeedsUpdateConstraints()
    }
    
    func createCellUI()  {
        self.contentView.addSubview(self.picView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.dateLabel)
        self.contentView.addSubview(self.passPeopleLabel)
        self.contentView.addSubview(self.collectButton)
    }
    
    func setUpContrains() {
        self.picView.mas_makeConstraints { (make) in
            make?.left.offset()(10)
            make?.size.mas_equalTo()(CGSize(width: 60, height: 60))
            make?.centerY.offset()(0)
            make?.top.offset()(10)
        }
        self.titleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.picView.mas_right)?.offset()(10)
            make?.right.offset()(0)
            make?.top.offset()(10)
        }
        self.dateLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.picView.mas_right)?.offset()(10)
            make?.centerY.right().offset()(0)
        }
        self.passPeopleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.picView.mas_right)?.offset()(10)
            make?.right.offset()(0)
            make?.bottom.offset()(-10)
        }
        self.collectButton.mas_makeConstraints { (make) in
            make?.right.offset()(-10)
            make?.bottom.offset()(-10)
            make?.size.mas_equalTo()(CGSize(width: 25, height: 25))
        }
        
    }
    
    func bindData(dataSource1:JSON,title:String) {
//        if dataSource1.count == 0 {
//            return
//        }
        self.dataSource = dataSource1
        self.picView.image = UIImage(named: "newsFilesWord")
        self.titleLabel.text = dataSource1["reffilename"].stringValue
        self.dateLabel.text = dataSource1["createtime"].stringValue
        self.passPeopleLabel.text = "上传人:"+dataSource1["createname"].stringValue

        if dataSource1["filetype"].stringValue == "WORD" {
            self.picView.image = UIImage(named: "newsFilesWord")
        }else if dataSource1["filetype"].stringValue == "EXCEL" {
            self.picView.image = UIImage(named: "newsFilesExcel")
        }else if dataSource1["filetype"].stringValue == "PDF" {
            self.picView.image = UIImage(named: "newsFilesPDF")
        }else if dataSource1["filetype"].stringValue == "PPT" {
            self.picView.image = UIImage(named: "newsFilesPPT")
        }else if dataSource1["filetype"].stringValue == "视频" {
            self.picView.image = UIImage(named: "newsFilesMP4")
        }else{
            self.picView.image = UIImage(named: "subFiles")
        }
        
        
        if dataSource["iscollect"].stringValue == "1" {
            collectButton.setImage(UIImage(named: "shoucang2"), for: .normal)
            isCollectedBool = true
            self.setNeedsUpdateConstraints()
            return;
        }else{
            isCollectedBool = false
            collectButton.setImage(UIImage(named: "shoucang1"), for: .normal)
        }
        
//        self.contentView.mas_updateConstraints({ (make) in
//            make.height.equalTo(origin_y + buttonHeight + 10)
//        })
        self.setNeedsUpdateConstraints()
    }
    
    @objc func didClickCollectionBtn(_button:UIButton) {
        if let callBack = buttonClickCallBack  {
            callBack(self.dataSource)
            if isCollectedBool == true {
                collectButton.setImage(UIImage(named: "shoucang1"), for: .normal)
                self.dataSource["iscollect"] = "0"
                isCollectedBool = false
//                self.setNeedsUpdateConstraints()
            }else{
                self.dataSource["iscollect"] = "1"
                isCollectedBool = true
                collectButton.setImage(UIImage(named: "shoucang2"), for: .normal)
            }
            
        }
        
    }
    
    
    
    lazy var picView: UIImageView = {
        let picView = UIImageView()
        picView.image = UIImage(named: " ")
        return picView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        return titleLabel
    }()
    
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textAlignment = .left
        dateLabel.textColor = .black
        return dateLabel
    }()
    lazy var passPeopleLabel: UILabel = {
        let passPeopleLabel = UILabel()
        passPeopleLabel.font = UIFont.systemFont(ofSize: 12)
        passPeopleLabel.textAlignment = .left
        passPeopleLabel.textColor = .black
        return passPeopleLabel
    }()
    
    lazy var collectButton: UIButton = {
        let collectButton = UIButton()
        collectButton.setImage(UIImage(named: "shoucang1"), for: .normal)
        collectButton.addTarget(self, action: #selector(didClickCollectionBtn), for: .touchUpInside)
        return collectButton
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
