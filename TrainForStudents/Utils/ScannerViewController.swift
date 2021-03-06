//
//  ScannerViewController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/11.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SwiftyJSON
import GTMBarcodeScanner

typealias sendResultValueClosure = (_ string:String , _ vc : UIViewController)->Void
class ScannerViewController: UIViewController /*,GTMBarcodeCoreDelegate*/ , AVCaptureMetadataOutputObjectsDelegate ,UIAlertViewDelegate {
    

    @IBOutlet weak var btn_back: UIButton!
    
    var myClosure : sendResultValueClosure?
    var scanRectView:UIView!
    var device:AVCaptureDevice!
    var input:AVCaptureDeviceInput!
    var output:AVCaptureMetadataOutput!
    var session:AVCaptureSession!
    var preview:AVCaptureVideoPreviewLayer!
    var uploadPhoto = UIImage()
    var videoZoomFactor = CGFloat(0)
    let animateView = UIImageView()
    
    override func viewDidLoad() {
        
        //添加缩放手势
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchDid(_:)))
        self.view.addGestureRecognizer(pinchGesture)


        myClosure = myClosureImpl
        btn_back.layer.cornerRadius = 8
        btn_back.clipsToBounds = true

        let app = (UIApplication.shared.delegate) as! AppDelegate
        let tabBar = (app.window?.rootViewController) as! UITabBarController
        tabBar.hidesBottomBarWhenPushed = true

        do{
            self.device = AVCaptureDevice.default(for: AVMediaType.video)
            device.isFocusModeSupported(.autoFocus)

            self.input = try AVCaptureDeviceInput(device: device)

            self.output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            self.session = AVCaptureSession()
            if UIScreen.main.bounds.size.height<500 {
                self.session.sessionPreset = AVCaptureSession.Preset.vga640x480
            }else{
                self.session.sessionPreset = AVCaptureSession.Preset.high
            }

            self.session.addInput(self.input)
            self.session.addOutput(self.output)

            self.output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            //计算中间可探测区域
            let windowSize = UIScreen.main.bounds.size
            let scanSize = CGSize(width:windowSize.width*3/4, height:windowSize.width*3/4)
            var scanRect = CGRect(x:(windowSize.width-scanSize.width)/2,
                                  y:(windowSize.height-scanSize.height)/2,
                                  width:scanSize.width, height:scanSize.height)
            //计算rectOfInterest 注意x,y交换位置
            scanRect = CGRect(x:scanRect.origin.y/windowSize.height,
                              y:scanRect.origin.x/windowSize.width,
                              width:scanRect.size.height/windowSize.height,
                              height:scanRect.size.width/windowSize.width);
            //设置可探测区域
            self.output.rectOfInterest = scanRect

            self.preview = AVCaptureVideoPreviewLayer(session:self.session)
            self.preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.preview.frame = UIScreen.main.bounds
            self.view.layer.insertSublayer(self.preview, at:0)

            //添加中间的探测区域绿框
            self.scanRectView = UIView();
            self.view.addSubview(self.scanRectView)
            self.scanRectView.frame = CGRect(x:0, y:0, width:scanSize.width,
                                             height:scanSize.height);
            self.scanRectView.center = CGPoint( x:UIScreen.main.bounds.midX,
                                                y:UIScreen.main.bounds.midY)
            self.scanRectView.layer.borderColor = UIColor.orange.cgColor
            self.scanRectView.layer.borderWidth = 1.5;
            
            let lineH = CGFloat(10)
            let f = CGRect(x: scanRectView.X, y: scanRectView.Y, width: scanRectView.H, height: lineH)
            
            animateView.frame = f
            animateView.contentMode = .center
            animateView.image = UIImage(named: "qrcode_scan_line_green" , in: Bundle(for: BarcodeScanner.self) ,compatibleWith: nil)
            
            view.addSubview(animateView)
            
            
            //开始捕获
            self.session.startRunning()
        }catch _ {
            //打印错误消息
            let alertController = UIAlertController(title: "提醒",
                                                    message: "请在iPhone的\"设置-隐私-相机\"选项中,允许本程序访问您的相机",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }

        
        
//        let scanner = BarcodeScanner.create(view: self.view)
//
//        // 风格设置
//        scanner.makeStyle { (make) in
//            let color = UIColor.init(red: 255/255, green: 157/255, blue: 0/255, alpha: 1)
//            make.positionUpVal(44)
//            make.anglePosition(ScanViewStyle.AnglePosition.inner)
//            make.angleLineWeight(5)
//            make.angleLineLength(18)
//            make.isShowRetangleBorder(true)
//            make.width(280)
//            make.height(280)
//            make.retangleLineWeight(1/UIScreen.main.scale)
//            make.animateType(ScanViewStyle.Animation.lineMove)
//            make.colorOfAngleLine(color)
//            make.colorOfRetangleLine(color)
//            make.colorOutside(UIColor.init(red: 199/255, green: 211/255, blue: 224/255, alpha: 0.5))
//            make.soundSource(forName: "VoiceSearchOn", andType: "wav")
//        }
//
//        // 配置
//        scanner.config { (make) in
//            make.autoCloser(true)       // 自动拉近镜头
//            make.caputureImage(true)    // 记录扫码的源图片
//            make.printLog(true)         // 调试信息打印控制
//        }
//
//        // 设置代理
//        scanner.delegate = self
//
//        // 开始扫码
//        scanner.start()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.session.startRunning()
        
//        selectedTabBarIndex = 2
        
        if self.scanRectView == nil {
            myAlert(self, message: "请打开相机权限")
            return
        }
        UIView.animate(withDuration: 2.5, delay:0, options:[.curveLinear , .repeat], animations: {
            self.animateView.setY(y: self.scanRectView.Y + self.scanRectView.H - 10)
        }) { (true) in
            self.animateView.setY(y: self.scanRectView.Y)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        let app = (UIApplication.shared.delegate) as! AppDelegate
        let tabBar = (app.window?.rootViewController) as! UITabBarController
        tabBar.hidesBottomBarWhenPushed = false
    }
    
    //摄像头捕获
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var stringValue:String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue

            if stringValue != nil{
                self.session.stopRunning()
            }
        }
        self.session.stopRunning()

        myClosure!(stringValue! , self)

//        输出结果
//        let alertController = UIAlertController(title: "二维码",
//                                                message: stringValue,preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
//            action in
//            self.dismiss(animated: true, completion: nil)
//            //继续扫描
//            //self.session.startRunning()
//        })
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true, completion: nil)

    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
//        let tabBar = self.tabBarController
//        tabBar?.selectedIndex = selectedTabBarIndex
//        if selectedTabBarIndex == 3 {
//            tabBar?.selectedIndex = 0
//        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pinchDid(_ recognizer:UIPinchGestureRecognizer) {
        do {
            try device.lockForConfiguration()
        }catch{
            
        }
        //在监听方法中可以实时获得捏合的比例
        let scale = recognizer.scale
        print(scale)
        videoZoomFactor *= ( scale - 1 ) / 10 + 1
        if videoZoomFactor < 1{
            videoZoomFactor = 1
        }else if videoZoomFactor > 5{
            videoZoomFactor = 5
        }
        print("videoZoomFactor:\(videoZoomFactor)")
        device.videoZoomFactor = videoZoomFactor
        device.unlockForConfiguration()
        
    }
    
    func myClosureImpl(_ val : String , vc : UIViewController){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT+"rest/taskSignResult/sign.do"
        myPostRequest(url,["qrcode":val]).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let signMsg = json["msg"].stringValue
                    //不需要上传照片则直接关闭view
                    let takePhoto = UserDefaults.AppConfig.string(forKey: .scanCheckInTakePhoto)
                    if takePhoto == "0" || true{    //暂时不需要拍照 直接扫码
                        myAlert(vc, title: "签到", message: signMsg, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                        })
                    }else{
                        //上传照片
                        let taskId = json["data"]["taskid"].stringValue
                        let imgDir = ["file":self.uploadPhoto]
                        let uplaodImageUrl = SERVER_PORT+"rest/taskSignResult/UploadSignImg.do"
                        uploadImage(uplaodImageUrl, images: imgDir, parameters: ["taskid":taskId], completionHandler: {resp in
                            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                            switch resp.result{
                            case .success(let responseJson):
                                
                                let json = JSON(responseJson)
                                if json["code"].stringValue == "1"{
                                    myAlert(vc, title: "签到，恭喜您已成功报道！", message: signMsg, handler: { action in
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                }else{
                                    myAlert(self, message: "签到失败!\(json["msg"].stringValue)")
                                }
                            case .failure(let error):
                                print(error)
                            }
                            
                        })
                    }
                    
                }else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    myAlert(vc, message: json["msg"].stringValue , handler : { action in
//                        self.tabBarController?.selectedIndex = selectedTabBarIndex
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            case .failure(let error):
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                print(error)
            }
            
        })
        
    }
    
}
