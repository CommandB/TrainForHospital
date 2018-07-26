//
//  WebViewTestController.swift
//  TrainForHospital
//
//  Created by 黄玮晟 on 2018/5/18.
//  Copyright © 2018年 geely. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewTestController : UIViewController{
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.purple
        
        webView = WKWebView.init(frame: view.frame)
        webView.backgroundColor = UIColor.blue
//        let htmlDir = URL.init(string: "file:///html/")
//        let url = Bundle.main.url(forResource: "goods2.htm", withExtension: nil)
        //webView.load(URLRequest.init(url: URL.init(string: "http://www.baidu.com")!))
        
        let url = Bundle.main.path(forResource: "goods2", ofType: "htm")
        webView.load(URLRequest(url: URL(fileURLWithPath: url!)))
        
        view.addSubview(webView)
        
    }
    
}
