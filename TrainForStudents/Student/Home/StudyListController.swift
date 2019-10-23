//
//  studyListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/6/24.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import AVFoundation
import AVKit

class StudyListController : HBaseViewController{
    
    @IBOutlet weak var materialCollection: UICollectionView!
    
    var deptId = 0
    var jds = [JSON]()
    
    override func viewDidLoad() {
        
        materialCollection.delegate = self
        materialCollection.dataSource = self
        
        self.materialCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.materialCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.materialCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
        
        let url = SERVER_PORT + "rest/teachingMaterial/querydeptteachingmaterial.do"
        myPostRequest(url,["teachingmaterialdeptid":deptId],  method: .post).responseString(completionHandler: {resp in
            
            self.materialCollection.mj_header.endRefreshing()
            self.materialCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
//                print(json)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                myAlert(self, message: "获取列表数据异常!")
                print(error)
                break
            }
            self.materialCollection.reloadData()
        })
        
        
        materialCollection.reloadData()
    }
    
    @objc func refresh() {
        jds.removeAll()
        materialCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
}

extension StudyListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        cell.setBorder(width: 1.5, color: .groupTableViewBackground)
        cell.setCornerRadius(radius: 4)
        (cell.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
        
        var btn = cell.viewWithTag(10002) as! UIButton
        btn.viewParam = [String:Any]()
        btn.viewParam!["fileName"] = data["reffilename"].stringValue
        btn.viewParam!["url"] = data["url"].stringValue
        
        let fileType = data["chinatype"].stringValue
        print(fileType)
        if fileType == "video"{
            btn.addTarget(self, action: #selector(downloadVideo), for: .touchUpInside)
            btn.setImage(UIImage(named: "video_play_pressed"), for: .normal)
            btn = cell.viewWithTag(10003) as! UIButton
            btn.setImage(UIImage(named: "default_video_img"), for: .normal)
            btn.isHidden = false
        }else if fileType == "image"{
            
        }else{
            btn.addTarget(self, action: #selector(downloadDocument), for: .touchUpInside)
            (cell.viewWithTag(10003) as! UIButton).isHidden = true
            btn.setImage(UIImage(named: fileType), for: .normal)
            
        }
        (cell.viewWithTag(10004) as! UILabel).text = data["create"].stringValue
        (cell.viewWithTag(10005) as! UILabel).text = data["createtime"].stringValue
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: collectionView.W, height: 200)
    }
    
    @objc func downloadDocument(sender : UIButton){
        let param = sender.viewParam
        let fileName = param!["fileName"] as! String
        let url = param!["url"] as! String
        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)
            print("\r\r测试--------------文件保存---------------\r\r")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        //开始下载
        
        Alamofire.download(url, to: destination)
            .response { response in
                //print(response)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                self.openFile(fileURL)
        }
    }
    
    @objc func downloadVideo(sender : UIButton){
        let param = sender.viewParam
        var fileURL = param!["url"] as! String
        
        if UserDefaults.AppConfig.string(forKey: .clientCode)?.lowercased() == "zeyy"{
            let zeIP = UserDefaults.AppConfig.string(forKey: .zeyyVideoIP)!
            fileURL = zeIP + fileURL.substring(from: 27)
        }
        fileURL = "http://39.104.60.22:6024/doctor_train/ui/xishou.wmv"
        print(fileURL)
        let avPlayer = AVPlayer(url: URL(string: fileURL)!)
        let avPlayerView = AVPlayerViewController()
        avPlayerView.player = avPlayer
        present(avPlayerView, animated: true, completion: nil)
    }
    
}

extension StudyListController : UIDocumentInteractionControllerDelegate{
    
    func openFile(_ filePath: URL) {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        let _docController = UIDocumentInteractionController.init(url: filePath)
        _docController.delegate = self
        //        _docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        _docController.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
}
