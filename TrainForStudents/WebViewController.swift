//
//  WebViewController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/9/3.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController : MyBaseUIViewController ,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler{
    
    var webView: WKWebView!
    var viewTitlte = ""
    var webUrl = ""
    
    //返回
    @IBAction func btn_back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        let barView = view.viewWithTag(11111)
        let titleView = view.viewWithTag(22222) as! UILabel
        
        super.setNavigationBarColor(views: [barView,titleView], titleIndex: 1,titleText: viewTitlte)
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        webView = WKWebView.init(frame: view.viewWithTag(10001)!.frame)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.backgroundColor = UIColor.groupTableViewBackground
        
        let nsUrl = NSURL(string: webUrl)!
        webView.load(NSURLRequest(url: nsUrl as URL) as URLRequest)
        print(webUrl)
        view.addSubview(webView)
        
    }
    
    //重载网页的alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        myAlert(self,title: webView.title!, message: message , btnTitle:"好的", handler: { (alertAction) -> Void in
            completionHandler()
        })
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("一个系统消息:\(message.name)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载了...\(String(describing: webView.url))")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("内容开始返回了\(String(describing: webView.url))")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("导航也错了!! \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("报错了:\(error)")
    }
    
}
