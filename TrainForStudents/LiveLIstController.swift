//
//  LiveLIstController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/4/17.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation

class LiveListController: MyBaseUIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tbl_liveList: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barView = view.viewWithTag(11111)
        let titleView = view.viewWithTag(22222) as! UILabel
        
        super.setNavigationBarColor(views: [barView,titleView], titleIndex: 1,titleText: "直播列表")
        
        tbl_liveList.delegate = self
        tbl_liveList.dataSource = self
        tbl_liveList.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        tbl_liveList.estimatedRowHeight = 270
        tbl_liveList.rowHeight = UITableViewAutomaticDimension
    }
    
    //返回
    @IBAction func btn_back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return jsonDataSource.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "c1")
        cell?.selectionStyle = .none
        
        let lbl = cell?.viewWithTag(10001) as! UILabel
        lbl.numberOfLines = 0
        let imgView = cell?.viewWithTag(20001) as! UIImageView
        
        if indexPath.item == 0{
            lbl.text = "九华云直播平台 -- 浙江医院呼吸内科正在直播一场很厉害的教学活动巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉"
            imgView.image = UIImage(named: "cover1.jpg")
            
        }else if indexPath.item == 1{
            lbl.text = "香港电视台"
            imgView.image = UIImage(named: "cover2.jpg")
        }
        
        let num = lbl.text?.getLineNumberForUILabel(lbl)
        lbl.frame.size = CGSize(width: lbl.frame.width, height: lbl.frame.height.multiplied(by: CGFloat(num!)))
        
        imgView.snp.makeConstraints({(make) in
//            make.height.equalTo(imgView.frame.width/16*9)
//            make.height.equalTo(194)
//            make.width.equalTo(100)
//            make.width.equalTo(imgView)
            make.top.equalTo(lbl.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-35)
            make.right.equalToSuperview().offset(-20)
        })
        imgView.layer.cornerRadius = 8
        imgView.layer.masksToBounds = true
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        cell?.contentView.addSubview(icon)
        
        icon.image = UIImage(named: "播放.png")
        icon.snp.makeConstraints({ make in
            make.center.equalTo(imgView)
        })
        
        return cell!
        
    }
    
    //cell的高度
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 270
//    }
    
    //section的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let liveController = getViewToStoryboard("liveView") as! LiveController
        if indexPath.item == 0{
            liveController.streamURL = URL(string: "rtmp://193.112.181.137:1935/live/mystream")
        }else if indexPath.item == 1{
            liveController.streamURL = URL(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks")
        }
        present(liveController, animated: true, completion: nil)
        
    }
    
}
