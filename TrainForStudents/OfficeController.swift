//
//  OfficeController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/8/9.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON

class OfficeController: MyBaseUIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var notice_collection: UICollectionView!
    
    var collectionDs = [JSON]()
    let boundary = CGFloat(9)
    let lineHeight = 16.5
    
    override func viewDidLoad() {
        
        let barView = view.viewWithTag(11111)
        let titleView = view.viewWithTag(22222) as! UILabel
        let backgroundView = view.viewWithTag(33333) as! UILabel
        
        super.setNavigationBarColor(views: [barView,titleView,backgroundView], titleIndex: 1,titleText: "科室")
        
        notice_collection.delegate = self
        notice_collection.dataSource = self
        //注册section Header
        notice_collection.register(NoticeHeaderReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        self.notice_collection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshAction))
        self.notice_collection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreAction))
        self.notice_collection.mj_header.beginRefreshing()
        
        var btn = view.viewWithTag(20001) as! UIButton
        btn.set(image: UIImage(named: "office_person"), title: "科室人员", titlePosition: .bottom, additionalSpacing: 10.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_nav_tui), for: .touchUpInside)
        btn = view.viewWithTag(20002) as! UIButton
        btn.set(image: UIImage(named: "office_plan"), title: "教学计划", titlePosition: .bottom, additionalSpacing: 10.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_nav_tui), for: .touchUpInside)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = notice_collection.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        
        let data = collectionDs[indexPath.section]
        let title = data["title"].stringValue
        let msg = data["msg"].stringValue
        
        var lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = title
        lbl.numberOfLines = 0
        //title的行数
        let tn = Double.init(title.getLineNumberForUILabel(lbl))
        lbl.text = "\(title)"
        lbl.frame.size = CGSize(width: lbl.frame.size.width, height: CGFloat(lineHeight*tn))
        
        //分割线
        let dividing = cell.viewWithTag(20001) as! UILabel
        var frame = CGRect()
        frame.origin = CGPoint(x: dividing.frame.origin.x, y: lbl.frame.height.adding(lbl.frame.origin.y))
        frame.size = dividing.frame.size
        dividing.frame = frame
        
        lbl = cell.viewWithTag(30001) as! UILabel
        lbl.text = msg
        lbl.numberOfLines = 0
        //正文的行数
        let mn = Double.init(msg.getLineNumberForUILabel(lbl))
        lbl.text = "\(msg)"
        lbl.frame.size = CGSize(width: lbl.frame.size.width, height: CGFloat(lineHeight*mn))
        lbl.frame.origin = CGPoint(x: lbl.frame.origin.x, y: dividing.frame.origin.y.adding(1))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let data = collectionDs[indexPath.section]
        let title = data["title"].stringValue
        let msg = data["msg"].stringValue
        //title的行数
        let tn = title.getLineNumberForWidth(width: 300, cFont: UIFont.systemFont(ofSize: 13))
        //正文的行数
        let mn = msg.getLineNumberForWidth(width: 300, cFont: UIFont.systemFont(ofSize: 13))
        let contentHeight = lineHeight*Double.init(tn+mn)
        return CGSize(width: UIScreen.width.subtracting(40), height: CGFloat(contentHeight + 20))
        
    }
    
    //展示section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind{
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath) as! NoticeHeaderReusableView
            if collectionDs.count > 0{
                let data = collectionDs[indexPath.section]
                
                header.name!.text = "\t"+data["createloginname"].stringValue
                header.date!.text = "\(data["createtime"].stringValue.prefix(19))"
            }
            
            return header
        default:
            return HeaderReusableView()
        }
    }
    
    //分组的头部视图的尺寸，在这里控制分组头部视图的高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize.init(width: UIScreen.width, height: CGFloat(35))
    }
    
    func loadData(){
        let url = SERVER_PORT+"drest/app/queryOfficeNotice.do"
        myPostRequest(url,["officeid":UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue), "pageindex":collectionDs.count, "pagesize":20]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.notice_collection.mj_footer.endRefreshing()
            self.notice_collection.mj_header.endRefreshing()
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    self.collectionDs += json["data"].arrayValue
                    if json["data"].arrayValue.count == 0{
                        self.notice_collection.mj_footer.endRefreshingWithNoMoreData()
                    }
                    self.notice_collection.reloadData()
                }else{
                    myAlert(self, message: "读取公告失败")
                }
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    func refreshAction() {
        collectionDs.removeAll()
        self.notice_collection.mj_footer.resetNoMoreData()
        loadData()
    }
    
    func loadMoreAction() {
        loadData()
    }
    
    func btn_nav_tui(sender : UIButton){
        switch sender.tag {
        case 20001:
//            let vc = OfficePeopleViewController()
//            vc.office = currentOffice
//            let nav = UINavigationController(rootViewController: vc)
//            self.present(nav, animated: true, completion: nil)
            break
        case 20002:
//            let vc = SmallLectureViewController()
//            vc.office = currentOffice
//            let nav = UINavigationController(rootViewController: vc)
//            self.present(nav, animated: true, completion: nil)
            break
            
            
        default: break
            
        }
    }
    
}

class NoticeHeaderReusableView: UICollectionReusableView {
    var name:UILabel!
    var date:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        //
        let width = UIScreen.width
        name = UILabel(frame: CGRect.init(x: 0, y: 5, width: width, height: 30))
        name.backgroundColor = UIColor.clear
        name.textAlignment = .left
        name.font = UIFont.systemFont(ofSize: 13)
        name.textColor = UIColor.darkGray
        
        date = UILabel(frame: CGRect.init(x: 0, y: 5, width: width, height: 30))
        date.backgroundColor = UIColor.clear
        date.textAlignment = .center
        date.font = UIFont.systemFont(ofSize: 13)
        date.textColor = UIColor.darkGray
        
        self.addSubview(name!)
        self.addSubview(date!)
        //self.backgroundColor = UIColor.white
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

