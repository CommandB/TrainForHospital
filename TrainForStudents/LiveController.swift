//
//  LiveController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/4/16.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation


class LiveController : MyBaseUIViewController,PLPlayerDelegate {
    
    @IBOutlet weak var tbl_liveMessageList: UITableView!
    
    //教材
    @IBOutlet weak var liveMessageCollection: UICollectionView!
    
    let liveMessageView = LiveMessageCollectionView()
    
    var player : PLPlayer = PLPlayer()
//    let liveMessageTableView = LiveMessageTableView()
    var button = UIButton()
    var back = UIButton()
    var streamURL : URL!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //支持横屏
        appDelegate.blockRotation = true
        
//        liveMessageTableView.parentView = self
//        tbl_liveMessageList.dataSource = liveMessageTableView
//        tbl_liveMessageList.delegate = liveMessageTableView
//        tbl_liveMessageList.separatorStyle = .none
//        tbl_liveMessageList.rowHeight = UITableViewAutomaticDimension
        
        liveMessageView.parentView = self
        liveMessageCollection.dataSource = liveMessageView
        liveMessageCollection.delegate = liveMessageView

        MyNotificationUtil.addKeyBoardWillChangeNotification(self)
        NotificationCenter.default.addObserver(self, selector: #selector(LiveController.receiverNotification), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
    }
    
    func createView(){

        //rtmp://live.hkstv.hk.lxdns.com/live/hks
        //初始化 PLPlayerOption 对象 可以更改需要修改的 option 属性键所对应的值
        let option = PLPlayerOption.default()
        option.setOptionValue(15, forKey: PLPlayerOptionKeyTimeoutIntervalForMediaPackets)

        //let url:URL = URL.init(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks")!
        //初始化 PLPlayer
        player = PLPlayer.init(url: streamURL, option: option)!
        player.launchView?.image = UIImage.init(named: "backImage")
        player.delegate = self
        player.isBackgroundPlayEnable = false

        //self.player.delegateQueue = DispatchQoS.default

        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //获取视频输出视图并添加为到当前 UIView 对象的 Subview
        view.addSubview(player.playerView!)
        player.playerView?.backgroundColor = UIColor.black
        player.playerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(view)
            make.left.right.equalTo(view)
            make.height.equalTo(view.frame.width/16*9)
        })
        button = UIButton.init(type: .custom)
//        button.backgroundColor = UIColor.blue
//        button.alpha = 0.5
        button.addTarget(self, action: #selector(buttonclick(button:)), for: .touchUpInside)
        button.frame = (player.playerView?.frame)!
        view.addSubview(button)
        button.snp.makeConstraints({ make in
            make.height.width.equalTo(player.playerView!)
        })

        back = UIButton.init(type: .custom)
        back.frame = CGRect(x: 10, y: 25, width: 40, height: 20)
        back.setTitle("返回", for: .normal)
        back.setImage(UIImage(named: "返回.png"), for: .normal)
        back.alpha = 0.7
        back.addTarget(self, action: #selector(btn_back_event(button:)), for: .touchUpInside)
        view.addSubview(back)

        player.play()

    }
    
    func buttonclick(button:UIButton)  {
        if button.isSelected {
            player.pause()
            button.setImage(UIImage(named: "暂停.png"), for: .normal)
        }else{
            if player.status == .statusPaused{
                player.resume()
            }else{
                player.play()
            }
            
        }
        button.isSelected = !button.isSelected
    }
    
    func btn_back_event(button:UIButton)  {
        dismiss(animated: true, completion: nil)
    }
    
    func receiverNotification(){
        let orient = UIDevice.current.orientation
        switch orient {
        case .portrait :
            print("屏幕正常竖向")
            player.playerView?.snp.removeConstraints()
            player.playerView?.snp.makeConstraints({ (make) in
                make.top.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(view.frame.width/16*9)
            })
            button.snp.removeConstraints()
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(view.frame.width/16*9)
            })
            
            break
        case .portraitUpsideDown:
            print("屏幕倒立")
            break
        case .landscapeLeft:
            print("屏幕左旋转")
            player.playerView?.snp.removeConstraints()
            player.playerView?.snp.makeConstraints({ (make) in
                make.top.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(view)
            })
            button.snp.removeConstraints()
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(view)
            })
            break
        case .landscapeRight:
            print("屏幕右旋转")
            player.playerView?.snp.removeConstraints()
            player.playerView?.snp.makeConstraints({ (make) in
                make.top.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(view)
            })
            button.snp.removeConstraints()
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(view)
            })
            break
        default:
            break
        }
    }
    
    // 实现 <PLPlayerDelegate> 来控制流状态的变更
    func player(_ player: PLPlayer, stoppedWithError error: Error?) {
        // 当发生错误时，会回调这个方法
        print(error.debugDescription)
        if player.status == .statusError{
            player.resume()
        }
    }
    
    func player(_ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
        // 除了 Error 状态，其他状态都会回调这个方法
        if state == .statusPlaying{
            button.setImage(UIImage(), for: .normal)
        }
        print(state.rawValue)
    }
    
}
