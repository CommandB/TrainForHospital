//
//  OpenFileViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/25.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import QuickLook
import MediaPlayer
import AVFoundation
import AVKit

class OpenFileViewController: NewsBaseViewController,UIDocumentInteractionControllerDelegate,UIWebViewDelegate {
    var data = JSON()
    var webView = UIWebView()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = data["reffilename"].stringValue
        
        let image = UIImage(named: "xiazai")!
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(dowoloadAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        addWebview()
        self.loadUrl()
        
        //添加足迹
        addFooter()
    }
    
    func addFooter() {
        
        
        if var dataArray = UserDefaults.standard.stringArray(forKey: data["filetype"].stringValue+"footer") {
            for data in dataArray {
                let json1 = JSON(parseJSON: data)
                if json1["resourcesid"] == self.data["resourcesid"] {
                    return
                }
            }
            dataArray.append(data.description)
        }else{
            let newArray = [data.description]
            UserDefaults.standard.set(newArray, forKey:data["filetype"].stringValue+"footer")
        }
    }
    
    func addWebview() {
        let topMargin:CGFloat = UIDevice.current.iPhoneX ? 88 : 64;
        webView.frame = CGRect(x: 0, y: topMargin, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-topMargin)
        webView.delegate = self
        self.view.addSubview(webView)
    }
    
    func loadUrl() {

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(self.data["reffilename"].stringValue)

        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)        
        if fileExists {
                let urlReq = URLRequest(url: fileURL)
                webView.loadRequest(urlReq)
        }else {
            if let urlStr = data["url"].string,let URL = URL(string: urlStr){
                let urlReq = URLRequest(url: URL)
                webView.loadRequest(urlReq)
//                AVPlayerViewController *ctrl = [[AVPlayerViewController alloc] init];
//
//                                        ctrl.player= [[AVPlayeralloc]initWithURL:url];
//
//                                        [self presentViewController:ctrl animated:YES completion:nil];
//                let urlReq = URLRequest(url: URL)
//                let avvc = AVPlayerViewController()
//                avvc.player = AVPlayer.init(url: URL)
//                self.present(avvc, animated: true, completion: nil)
//                webView.loadRequest(urlReq)
            }
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        MBProgressHUD.showMessage("加载中...", to: self.view)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
    @objc func dowoloadAction() {
        let fileURL = data["url"].stringValue

        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(self.data["reffilename"].stringValue)
            print("\r\r测试--------------文件保存---------------\r\r")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        MBProgressHUD.showMessage("下载中...", to: self.view)
        //开始下载
        Alamofire.download(fileURL, to: destination)
            .response { response in
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                //print(response)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(self.data["reffilename"].stringValue)
                self.openFile(fileURL)
        }
    }
    
    func openFile(_ filePath: URL) {
        let urlReq = URLRequest(url: filePath)
        webView.loadRequest(urlReq)
        return;
        
        let _docController = UIDocumentInteractionController.init(url: filePath)
        _docController.delegate = self
        //        _docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
