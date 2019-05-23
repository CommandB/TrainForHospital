//
//  StudyController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/3/8.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import BMPlayer
import Alamofire

class StudyController : HBaseViewController{
    
    var taskId = ""
    @IBOutlet weak var player: BMCustomPlayer!
    var webView = UIWebView()
    var materialData = JSON()
    var tagGtr = UITapGestureRecognizer()
    var isHistory = false
    var isFull = false
    
    override func viewDidLoad() {

        (view.viewWithTag(40001) as! UIButton).isHidden = isHistory
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //支持横屏
        appDelegate.blockRotation = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        player.pause()
        player.playerLayer?.prepareToDeinit()
        player = nil
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        if isFull{
            isFull = false
            UIView.animate(withDuration: 0.3, animations: {
                self.webView.frame = self.player.frame
            })
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_submit_inside(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT+"rest/app/studyCommit.do"
        myPostRequest(url,["taskid":taskId]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):

                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    myAlert(self, message: "上报成功!",handler:{action in
                        self.dismiss(animated: true, completion: nil)
                    })
                }else{
                    myAlert(self, message: "上报失败..!")
                }

            case .failure(let error):
                print(error)
            }

        })
        //dismiss(animated: true, completion: nil)
    }
    
    func getData(){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT+"rest/app/getStudyInfo.do"
        myPostRequest(url,["taskid":taskId]).responseJSON(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let data = json["data"]
                    self.materialData = data
                    (self.view.viewWithTag(10001) as! UILabel).text = data["title"].stringValue
                    (self.view.viewWithTag(30001) as! UILabel).text = data["note"].stringValue
                    //let placeholder = self.view.viewWithTag(20001)!
                    let fileURL = data["url"].stringValue
                    let url = URL(string: fileURL)
                    if fileURL.contains("resources/video"){
                        
                        //视频播放
                        self.player.parentView = self
                        self.player.markView = self.view.viewWithTag(20001)
                        
                        self.player.backBlock = { [unowned self] (isFullScreen) in
                            if isFullScreen == true {
                                return
                            }
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                        
                        let res1 = BMPlayerResourceDefinition(url: url!,
                                                              definition: "标清")
                        let asset = BMPlayerResource(name: "",
                                                     definitions: [res1],
                                                     cover: url)
                        
                        self.player.setVideo(resource: asset)
                    }else{
                        //文档浏览
                        self.webView = UIWebView(frame: self.player.frame)
                        self.webView.delegate = self
                        self.player.superview?.addSubview(self.webView)
                        let request = URLRequest(url: url!)
                        self.webView.loadRequest(request)
                        self.webView.addGestureRecognizer(self.tagGtr)
                        self.tagGtr.addTarget(self, action: #selector(self.wordFill))
                        
                        let lbl = UILabel()
                        lbl.frame.origin = CGPoint(x: 0, y: 0)
                        lbl.frame.size = self.webView.frame.size
                        lbl.text = "加载中..."
                        lbl.tag = 10001
                        lbl.textAlignment = .center
                        lbl.font = UIFont.systemFont(ofSize: 13)
                        lbl.textColor = UIColor.init(hex: "9BA6AE")
                        self.webView.addSubview(lbl)
                    }
                }else{
                    myAlert(self, message: "下载学习资料失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    //浏览office的webview的点击事件
    @objc func wordFill (){
        if !isFull{
            isFull = true
            UIView.animate(withDuration: 0.3, animations: {
                
                self.webView.setX(x: 0)
                self.webView.setY(y: 70)
                self.webView.setWidth(width: UIScreen.width)
                self.webView.setHight(height: UIScreen.height - 70)
                
            })
        }
        
        
//        let url = materialData["url"].stringValue
//        let fileName = materialData["title"].stringValue
//
//
//        //        //指定下载路径和保存文件名
//        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let fileURL = documentsURL.appendingPathComponent(fileName)
//            print("\r\r测试--------------文件保存---------------\r\r")
//            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
//            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//        }
//
//        //        //开始下载
//        Alamofire.download(url, to: destination)
//            .response { response in
////                print(response)
//                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                let fileURL = documentsURL.appendingPathComponent(fileName)
//                self.openFile(fileURL)
//        }
        
    }
    
}

extension StudyController : UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension StudyController: UIDocumentInteractionControllerDelegate{
    func openFile(_ filePath: URL) {
        let _docController = UIDocumentInteractionController.init(url: filePath)
        _docController.delegate = self
        //        _docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        _docController.presentPreview(animated: true)
//        _docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
//        present(_docController, animated: true, completion: nil)
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

extension StudyController : UIWebViewDelegate{
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        webView.viewWithTag(10001)?.isHidden = false
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let lbl = webView.viewWithTag(10001) as! UILabel
        lbl.isHidden = true
        lbl.text = ""
        
    }
    
}
