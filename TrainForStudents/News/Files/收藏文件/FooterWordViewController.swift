//
//  FooterWordViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/29.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
class FooterWordViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
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
        if var dataArray = UserDefaults.standard.stringArray(forKey: self.fileType+"footer") {
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
        tableView.register(FooterWordCell.classForCoder(), forCellReuseIdentifier: "FileWordCell")
        self.view.addSubview(tableView)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.requestedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileWordCell", for: indexPath)
        
        if let cell1 = cell as? FooterWordCell {
            cell1.bindData(dataSource1: self.requestedData[indexPath.row], title: "")
            cell1.addLongGes(target: self, action: #selector(longPreAction))
            return cell1
        }
        return cell
        
    }
    
    @objc func longPreAction(gesture:UILongPressGestureRecognizer) {
        guard let cell = gesture.view?.superview as? UITableViewCell else { return }
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        let alert = UIAlertController(title: "是否确认删除", message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        let action2 = UIAlertAction(title: "确认", style: .default) { (action) in
            if var dataArray = UserDefaults.standard.stringArray(forKey: self.fileType+"footer") {
                dataArray.remove(at: indexPath.row)
                UserDefaults.standard.set(dataArray, forKey: self.fileType+"footer")
                self.initData()
            }
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
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

class FooterWordCell: UITableViewCell {
    typealias funcBlock = (_ json : JSON) -> ()
    var buttonClickCallBack : funcBlock?
    var dataSource = JSON()
    
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
    }
    
    func addLongGes(target:Any,action:Selector) {
        let longPressGes = UILongPressGestureRecognizer(target: target, action: action)
        self.contentView.addGestureRecognizer(longPressGes)
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
        
  
        
        //        self.contentView.mas_updateConstraints({ (make) in
        //            make.height.equalTo(origin_y + buttonHeight + 10)
        //        })
        self.setNeedsUpdateConstraints()
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
