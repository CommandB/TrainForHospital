//
//  TeachingPlanDetailController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class TeachingPlanDetailController : HBaseViewController{
    
    @IBOutlet weak var infoCollection: UICollectionView!
    
    @IBOutlet weak var personList_view: UIView!
    
    var jds = JSON()
    var taskInfo = JSON()
    var imageCollectionView = TeachingPlanDetailImageView()
    var personListCollectionView = TeachingPlanDetailPersonListView()
    var timer = Timer()
    var isStudents = false
    
    override func viewDidLoad() {
        
        infoCollection.delegate = self
        infoCollection.dataSource = self
        
        self.infoCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.infoCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        self.infoCollection.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.bringSubview(toFront: personList_view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
        timer = Timer()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    //获取界面上的数据
    func getListData(){
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        var param = ["trainid":taskInfo["trainid"].stringValue] as [String : Any]
        
        let url = SERVER_PORT + "rest/app/getTrainDetail.do"
        myPostRequest(url,param).responseJSON(completionHandler: {resp in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.infoCollection.mj_header.endRefreshing()
            self.infoCollection.mj_footer.endRefreshingWithNoMoreData()
            
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                //print(json)
                if json["code"].stringValue == "1"{
                    let data = json["data"]
                    self.jds = json["data"]
                    
                    //需要签到 才更新二维码
                    if self.jds["sign"].intValue != 0 && !self.isStudents{
                        self.timer.invalidate()
                        let timeInterval = UserDefaults.AppConfig.any(forKey: .qrCodeInvalidTime) as! NSString
                        self.timer = Timer.scheduledTimer(timeInterval: timeInterval.doubleValue , target: self, selector: #selector(self.refreshQrCode), userInfo: nil, repeats: true)
                    }
                    
                    (self.view.viewWithTag(10001) as! UILabel).text = data["traintypename"].stringValue
                    (self.view.viewWithTag(20001) as! UILabel).text = data["creater"].stringValue
                    
                    let startDate = data["starttime"].stringValue.substring(to: 18)
                    let endDate = data["endtime"].stringValue.substring(to: 18)
                    let dateText = startDate.substring(to: 16) + " - " + endDate.substring(from: 11).substring(to: 5)
                    (self.view.viewWithTag(30001) as! UILabel).text = dateText + "(\(DateUtil.getWeek(DateUtil.stringToDateTime(startDate))))"
                    
                    (self.view.viewWithTag(40001) as! UILabel).text = data["addressname"].stringValue
                    
                    //过滤确认参加 和已签到的 人数
                    var confirmStuList = [JSON]()
                    var signedStuList = [JSON]()
                    for stu in self.jds["studentlist"].arrayValue{
                        if stu["answer"].stringValue == "确认参加"{
                            confirmStuList.append(stu)
                        }
                        if stu["issign"].stringValue == "1"{
                            signedStuList.append(stu)
                        }
                    }
                    self.jds["confirmStuList"] = JSON(confirmStuList)
                    self.jds["signedStuList"] = JSON(signedStuList)
                    
                    self.infoCollection.reloadData()
                }else{
                    
                }
            case .failure(let error):
                print(error)
            }
            
        })
    }
    
    @objc func selectImage(){
        //选择图片
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        let alertSheet = UIAlertController(title: "提示", message: "请选择照片", preferredStyle: .actionSheet)
        
        //注册"相册"按钮
        alertSheet.addAction(UIAlertAction(title: "相册", style: .default, handler: { action in
            
            self.present(picker, animated: true, completion: nil)
            
        }))
        
        //注册"照相"按钮
        alertSheet.addAction(UIAlertAction(title: "照相", style: .default, handler: { action in
            
            if LBXPermissions.isGetPhotoPermission() {
                picker.sourceType = .camera
                
                self.present(picker, animated: true, completion: nil)
                
            }else{
                myAlert(self, message: "没有相机权限")
            }
            
        }))
        
        ///注册"取消"
        alertSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
            
        }))
        
        present(alertSheet, animated: true, completion: nil)
    }
    
    ///更新二维码
    @objc func refreshQrCode(){
//        print("更新二维码了...\(DateUtil.getCurrentDateTime())")
        let url = SERVER_PORT + "rest/app/getTrainQRCode.do"
        myPostRequest(url,["trainid":taskInfo["trainid"]], method: .post).responseJSON(completionHandler: { resp in
            
            switch resp.result{
                case .success(let respJson):
                    let json = JSON(respJson)
                    if json["code"].intValue == 1{
                        print(json["qrcode"])
                        self.jds["qrcode"] = json["qrcode"]
                        self.infoCollection.reloadData()
                    }else{
                        myAlert(self, message: "更新二维码失败!")
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
            }
            
        })
        
    }
    
    @objc func refresh() {
        jds = JSON()
        infoCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        
    }
    
}

extension TeachingPlanDetailController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if jds.isEmpty{
            return 0
        }
        return 7 + jds["evaluatedetail"].arrayValue.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if indexPath.item < 7{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c\(indexPath.item+1)", for: indexPath)
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c8", for: indexPath)
        }
        
        cell.setBorder(width: 1, color: .groupTableViewBackground)
        switch indexPath.item {
        case 0:
            //主讲人
            (cell.viewWithTag(10003) as! UILabel).text = jds["teachers"].stringValue
            break
        case 1:
            //讲课素材
            (cell.viewWithTag(10003) as! UILabel).text = "\(jds["trainfile"].arrayValue.count)"
            (cell.viewWithTag(10004) as! UIButton).addTarget(self, action: #selector(presentFileList), for: .touchUpInside)
            break
        case 2:
            //确认参加人数
            let btn = cell.viewWithTag(10005) as! UIButton
            btn.viewParam = [String:Any]()
            btn.viewParam!["title"] = "参加人员"
            btn.viewParam!["data"] = jds["studentlist"].arrayValue
            btn.viewParam!["isSignList"] = false
            btn.addTarget(self, action: #selector(presentPersonList), for: .touchUpInside)
            let left = (cell.viewWithTag(10003) as! UILabel)
            left.text = jds["confirmStuList"].arrayValue.count.description
            let right = (cell.viewWithTag(10004) as! UILabel)
            right.text = "/\(jds["studentlist"].arrayValue.count)"
            right.setWidthFromText()
            right.moveToBefore(target: btn, space: -50)
            left.moveToBefore(target: right)
            break
        case 3:
            
            //已签到人数
            let btn = cell.viewWithTag(10005) as! UIButton
            btn.viewParam = [String:Any]()
            btn.viewParam!["title"] = "签到人员"
            btn.viewParam!["data"] = jds["studentlist"].arrayValue
            btn.viewParam!["isSignList"] = true
            btn.addTarget(self, action: #selector(presentPersonList), for: .touchUpInside)
            let left = (cell.viewWithTag(10003) as! UILabel)
            left.text = jds["signedStuList"].arrayValue.count.description
            let right = (cell.viewWithTag(10004) as! UILabel)
            right.text = "/\(jds["studentlist"].arrayValue.count)"
            right.setWidthFromText()
            right.moveToBefore(target: btn, space: -50)
            left.moveToBefore(target: right)
            let qrcodeStr = jds["qrcode"].stringValue
            if !qrcodeStr.isEmpty{
                let imageView = cell.viewWithTag(20001) as! UIImageView
                imageView.image = UIImage.createQR(text: qrcodeStr, size: imageView.H)
            }
            
            if jds["sign"].intValue == 0 {
                cell.viewWithTag(10006)?.isHidden = false
            }else{
                cell.viewWithTag(10006)?.isHidden = true
            }
            
            break
        case 4:
            //图片
            let uploadImageBtn = cell.viewWithTag(10003) as! UIButton
            uploadImageBtn.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
            
            let imageCollection = cell.viewWithTag(20001) as! UICollectionView
            imageCollectionView = TeachingPlanDetailImageView()
            imageCollection.delegate = imageCollectionView
            imageCollection.dataSource = imageCollectionView
            imageCollectionView.parentview = self.view
            imageCollectionView.jds = jds["piclist"].arrayValue
            imageCollection.reloadData()
            
            break
        case 5:
            cell.setBorder(width: 0, color: .groupTableViewBackground)
            let _data = jds["evaluateinfo"].arrayValue[0]
            let lbl_content = cell.viewWithTag(10002) as! UILabel
            lbl_content.text = "\(_data["finerate"].intValue)%，共\(_data["completecount"].intValue)人  "
            lbl_content.setWidthFromText()
            let lbl_suffix = cell.viewWithTag(10003) as! UILabel
            lbl_suffix.moveToAfter(target: lbl_content,space: 0)
            break
        case 6:
            (cell.viewWithTag(10001) as! UIButton).addTarget(self, action: #selector(regist(sender:)), for: .touchUpInside)
            (cell.viewWithTag(20001) as! UIButton).addTarget(self, action: #selector(leave(sender:)), for: .touchUpInside)
            let lbl = (cell.viewWithTag(30001) as! UILabel)
            let answer = jds["answer"].intValue
            if answer == 1{
                lbl.text = jds["answerreason"].stringValue
                lbl.isHidden = false
            }else if answer == 99{
                lbl.text = "请假:\(jds["answerreason"].stringValue)"
                lbl.isHidden = false
            }else{
                lbl.isHidden = true
            }
            break
        default:
            cell.setBorder(width: 0, color: .groupTableViewBackground)
            cell.setBorderTop(size: 1, color: .groupTableViewBackground)
            let evArray = jds["evaluatedetail"].arrayValue
            let index = indexPath.item - 7
            let item = evArray[index]
            (cell.viewWithTag(10001) as! UILabel).text = "\(index+1).\(item["itemtitle"].stringValue)"
            let lbl_bg = (cell.viewWithTag(10002) as! UILabel)
            let lbl_progress = (cell.viewWithTag(10003) as! UILabel)
            let lbl_rate = (cell.viewWithTag(10004) as! UILabel)
            let rate = item["scorevalue"].doubleValue / item["sumscore"].doubleValue
            lbl_rate.text = "\(Int(rate*100))%"
            lbl_progress.setWidth(width: lbl_bg.W * CGFloat(rate))
            if rate >= 0.6{
                lbl_rate.textColor = UIColor(hex: "3186E9")
                lbl_progress.backgroundColor = UIColor(hex: "9BDE4C")
            }else{
                lbl_rate.textColor = UIColor(hex: "F74747")
                lbl_progress.backgroundColor = UIColor(hex: "F74747")
            }
            break
        }
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var result = CGSize()
        let cellWidth = collectionView.W - (5)
        switch indexPath.item {
        case 0://主讲人
            result = CGSize(width: cellWidth, height: 40)
        case 1://讲课素材
            result = CGSize(width: cellWidth, height: 40)
        case 2://确认参加人数
            result = CGSize(width: cellWidth, height: 40)
            if isStudents{
                result = CGSize(width: cellWidth, height: 0)
            }
        case 3://已签到人数
            result = CGSize(width: cellWidth, height: 220)
            if jds["sign"].intValue == 0 {
                result = CGSize(width: cellWidth, height: 40)
            }
            if isStudents{
                result = CGSize(width: cellWidth, height: 0)
            }
        case 4://现场照片
            result = CGSize(width: cellWidth, height: 130)
            if isStudents{
                result = CGSize(width: cellWidth, height: 0)
            }
        case 5://好评度
            result = CGSize(width: cellWidth, height: 30)
            if isStudents{
                result = CGSize(width: cellWidth, height: 0)
            }
        case 6://答复
            result = CGSize(width: cellWidth, height: 0)
            if isStudents{
                result = CGSize(width: cellWidth, height: 160)
            }
        default:
            result = CGSize(width: cellWidth, height: 65)
        }
        return result
    }
    
    //查看附件
    @objc func presentFileList(sender: UIButton){
        if jds["trainfile"].arrayValue.count == 0{
            return
        }
        let vc = getViewToStoryboard("OtherFilesController") as! OtherFilesController
        vc.dataSource = jds["trainfile"].arrayValue
        self.present(vc, animated: true, completion: nil)
    }
    
    ///显示人员列表
    @objc func presentPersonList(sender: UIButton){
        
        personListCollectionView.collectionTitle = sender.viewParam!["title"] as! String
        personListCollectionView.personList = sender.viewParam!["data"] as! [JSON]
        personListCollectionView.isSignList = sender.viewParam!["isSignList"] as! Bool
        
        personListCollectionView.parentView = self
        
        let personCollection = personList_view.viewWithTag(100001) as! UICollectionView
        personCollection.delegate = personListCollectionView
        personCollection.dataSource = personListCollectionView
        personCollection.reloadData()
        personCollection.setCornerRadius(radius: 4)
        personCollection.setBorder(width: 1, color: .gray)
        
        //计算一下有多少数据 来定位collection的位置
        let cellCount = personListCollectionView.personList.count + 1
        var collectionHeight = CGFloat(personListCollectionView.cellHeight * cellCount)
        let maxHeight = UIScreen.height - (150)
        if collectionHeight > maxHeight{
            collectionHeight = maxHeight
        }
        personCollection.setHight(height: collectionHeight)
        let y = (UIScreen.height - CGFloat(collectionHeight)) / 2
        personCollection.setY(y: y)
        
        personList_view.isHidden = false
        
    }
    
    @objc func regist(sender : UIButton){
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT + "rest/app/trainAnswer.do"
        myPostRequest(url,["trainid":taskInfo["trainid"],"answer":"1", "answerreason":"准时参加"], method: .post).responseJSON(completionHandler: { resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respJson):
                let json = JSON(respJson)
                if json["code"].intValue == 1{
                    self.refresh()
                }else{
                    myAlert(self, message: "回复失败!")
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            
        })
    }
    
    @objc func leave(sender : UIButton){
        
        var txt = UITextField()
        
        let alert = UIAlertController(title: "提示", message: "请输入请假原因", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let url = SERVER_PORT + "rest/app/trainAnswer.do"
            myPostRequest(url,["trainid":self.taskInfo["trainid"],"answer":"99","answerreason":txt.text], method: .post).responseJSON(completionHandler: { resp in
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                switch resp.result{
                case .success(let respJson):
                    let json = JSON(respJson)
                    if json["code"].intValue == 1{
                        self.refresh()
                    }else{
                        myAlert(self, message: "报名失败!")
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
                
            })

        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { action in
            
        }))
        
        alert.addTextField(configurationHandler: { textFiled in
            txt = textFiled
            
        })

        present(alert, animated: true, completion: nil)
        
        
        
    }
    
}

//图片的collectionView
extension TeachingPlanDetailController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        myConfirm(picker, message: "确认上传此照片吗?", okHandler :{ action in
            
            self.dismiss(animated: true, completion: nil)
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let after = image.compressImage(maxLength: 1024*1024, resize: UIScreen.width)
            image = UIImage(data: after!)!
//            image = image.resizeImage(newSize: CGSize(width: image.size.width.divided(by: 3), height: image.size.height.divided(by: 3)))
            
            
            let imageData = UIImageJPEGRepresentation(image, 1)
            print("imageData:\(imageData!.count)")
            if imageData?.count == 0 {
                myAlert(self, message: "请选择上传的图片!")
                return
            }
            
            let url = SERVER_PORT + "rest/app/TrainImgAdd.do"
            
            var param = [String:Any]()
            param["taskid"] = self.taskInfo["taskid"].stringValue
            param["context"] = ""
            param["trainid"] = self.taskInfo["trainid"].stringValue
            
            var imgDir = [String:UIImage]()
            //根据记录的下标读取需要上传的图片
            
            imgDir[arc4random().description] = image
            
            uploadImage(url, images: imgDir, parameters: param, completionHandler: {resp in
                switch resp.result{
                case .success(let responseJson):
                    
                    let json = JSON(responseJson)
                    if json["code"].stringValue == "1"{
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        myAlert(self, message: "图片上传成功!" , handler : { action in
                            self.refresh()
                        })
                        
                    }else{
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        myAlert(self, message: "图片上传失败!\(json["msg"].stringValue)")
                    }
                    
                case .failure(let error):
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    print(error)
                }
            })
            
            
            
        }, cancelHandler :{ action in
            
        })
        
    }
    
}

class TeachingPlanDetailImageView : UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var parentview: UIView? = nil
    var jds = [JSON()]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if jds.count == 0 {
            return 1
        }
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  jds.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            return cell
        }
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let data = jds[indexPath.item]
        let imageUrl = URL(string: data["url"].stringValue)!
        let imageView = cell.viewWithTag(10001) as! UIImageView
        
        do{
//            let image = try UIImage(data: Data.init(contentsOf: imageUrl))!
//            print("url:\(imageUrl)")
//            print("image:\(image.size)")
//            print("大小:\(UIImageJPEGRepresentation(image, 1)?.count)")
            
            imageView.kf.setImage(with: ImageResource(downloadURL: imageUrl))
            
            
        }catch{}
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = jds[indexPath.item]
        let imageUrl = data["url"].stringValue
        do{
            
            //判断缓存中是否存在.. 不存在则先下载 .. 存在则直接从缓存中读取图片
            if ImageCache.default.isImageCached(forKey: imageUrl).cached{
                let image = ImageCache.default.retrieveImageInDiskCache(forKey: imageUrl)!
                HUtilView.showImageToTagetView(target: parentview! ,image: image)
            }else{
                ImageDownloader.default.downloadImage(with: URL(string: imageUrl)!, completionHandler: {image, error, url, originalData in
                    HUtilView.showImageToTagetView(target: self.parentview! ,image: image!)
                })
            }
            
            
        }catch{}
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if jds.count == 0 {
            return CGSize(width: collectionView.W, height: 75)
        }
        return CGSize(width: 100, height: 75)
    }
    
}

///查看人员情况的collection
class TeachingPlanDetailPersonListView: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    let cellHeight = 40
    var parentView :TeachingPlanDetailController? = nil
    var collectionTitle = ""
    var personList = [JSON]()
    var isSignList = true
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return personList.count + 1
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if indexPath.item == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            (cell.viewWithTag(10001) as! UILabel).text = collectionTitle
            (cell.viewWithTag(10002) as! UIButton).addTarget(self, action: #selector(dissmissToParent), for: .touchUpInside)
        }else{
            let data = personList[indexPath.item - 1]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            (cell.viewWithTag(10001) as! UILabel).text = data["personname"].stringValue
            let lbl_status = cell.viewWithTag(10002) as! UILabel
            if isSignList{
                if data["issign"].stringValue == "0"{
                    lbl_status.textColor = .red
                    lbl_status.text = "未签到"
                }else{
                    lbl_status.textColor = UIColor(hex: "3186E9")
                    lbl_status.text = "已签到"
                }
            }else{
                let txt = data["answer"].stringValue
                if txt == "暂未回应"{
                    lbl_status.textColor = .red
                }else{
                    lbl_status.textColor = UIColor(hex: "3186E9")
                }
                lbl_status.text = txt
            }
            
        }
        
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: CGFloat(cellHeight))
    }
    
    @objc func dissmissToParent(){
        parentView?.personList_view.isHidden = true
    }
    
}
