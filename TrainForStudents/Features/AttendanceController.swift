//
//  AttendanceController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/25.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class AttendanceController : HBaseViewController{
    
    @IBOutlet weak var calendarCollection: UICollectionView!
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    @IBOutlet weak var tagCollection: UICollectionView!
    
    var personTagView = AttendancePersonTagCollectionView()
    var tagView = AttendanceTagCollectionView()
    var calendarView = AttendanceCalendarCollectinView()
    
    var jds = [JSON]()
    
    var monthList = [String]()
//    var dayDic = [String:[Date]]()
    
    var tagListBackgroundView = UIView()
    //标签collection距离屏幕顶部的距离
    var tagColletionToTopDistance = 175
    //已选中的日期
    var selectedDate = DateUtil.dateToString(Date())
    //当前设置的科室
    var officeId = "0"
    //选中的人
    var selectedPersonId = "0"
    //添加选择科室
    var officePicker = UIPickerView()
    let officePickerImpl = HSimplePickerViewImpl()
    
    override func viewDidLoad() {
        
        officeId = UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)!
        
        calendarView.parentView = self
        calendarCollection.delegate = calendarView
        calendarCollection.dataSource = calendarView
        
        calendarCollection.register(CollectionReusableViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: calendarView.sectionHeaderId)
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
//        tagView.jds = JSON([["text":"病假"],["text":"名字很长的假"],["text":"事假"],["text":"早上加班"],["text":"大夜班"],["text":"旷工"],["text":"例假"],["text":"迟到"],["text":"名字比很长更长的假"]]).arrayValue
//        tagCollection.reloadData()
        
        //显示头部星期文本
        let weekText = ["日","一","二","三","四","五","六"]
        for i in 0..<weekText.count{
            let width = UIScreen.width / 7
            let lbl = UILabel(frame: CGRect(x: width * CGFloat(i), y: 70, width: width, height: 30))
            lbl.textAlignment = .center
            lbl.text = weekText[i]
            if i == 0 || i == 6{
                lbl.textColor = .red
            }
//            lbl.setBorder(width: 1, color: .gray)
            view.addSubview(lbl)
        }
        
        let currentDate = Date()
        
        //初始化前后六个月的数据
        monthList =  calendarView.getAfterTwoMonths(date: currentDate)
        
        //生成数据
        calendarView.generationData(mList: monthList)
        
        calendarCollection.setContentOffset(CGPoint(x: 0, y: calendarCollection.W * 2.5 ), animated: true)
        
        //添加前2个月的数据
        let mList = calendarView.getBeforeTwoMonths(date: currentDate.prevMonth)
        calendarView.generationData(mList: mList)
        monthList = mList + monthList
        
        calendarView.monthList = monthList
//        calendarView.dayDic = dayDic
        
        //加载可以选择的tag
        tagView.parentView = self
        tagView.jds = UserDefaults.AppConfig.json(forKey: .tagList).arrayValue
        tagCollection.delegate = tagView
        tagCollection.dataSource = tagView
        tagCollection.reloadData()
        tagCollection.setY(y: UIScreen.height)
        if tagView.jds.count < 6{
            tagCollection.setHight(height: CGFloat(tagView.jds.count * 40))
        }
        
        let btn = UIButton(frame: CGRect(x: UIScreen.width - 30 - 20, y: 100, width: 30, height: 30))
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        btn.setCornerRadius(radius: 15)
        btn.setTitle("x", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(btn_dismissTagListView(sender:)), for: .touchUpInside)
//        btn.setCornerRadius(radius: 4)
        btn.setBorder(width: 1, color: .lightGray)
        tagListBackgroundView.frame = view.frame
        tagListBackgroundView.backgroundColor = .groupTableViewBackground
//        tagListBackgroundView.setY(y: UIScreen.height)
        tagListBackgroundView.alpha = 0
        tagListBackgroundView.addSubview(btn)

        view.addSubview(tagListBackgroundView)
        view.bringSubview(toFront: tagCollection)
        //添加切换科室
        addChangeOfficeBtn()
    }
    
    @objc func btn_dismissTagListView(sender : UIButton){
        let opt : UIView.AnimationOptions = .curveEaseOut
        //隐藏bg
        UIView.animate(withDuration: 0.3, delay:0, options:opt, animations: {
            self.tagListBackgroundView.alpha = 0
//            self.tagListBackgroundView.setY(y: UIScreen.height)
        }) { (true) in
            
        }
        
        //隐藏tagCollection
        UIView.animate(withDuration: 0.3, delay:0, options:opt, animations: {
            self.tagCollection.alpha = 0
            self.tagCollection.setY(y: UIScreen.height)
        }) { (true) in
            
        }
        
    }
    
    func addChangeOfficeBtn(){
        let btnView = UITextField(frame: CGRect(x: UIScreen.width - 88, y: 20, width: 88, height: 44))
        btnView.font = UIFont.systemFont(ofSize: 18)
        btnView.textAlignment = .center
        btnView.text = "切换科室"
        btnView.textColor = .white
        officePicker = officePickerImpl.getOfficeManagerPickerView()
        officePickerImpl.titleKey = "officename"
        officePickerImpl.clorsureImpl = addrClosureImpl
        btnView.inputView = officePicker
        self.view.addSubview(btnView)
    }
    
    func addrClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        let data = ds[row]
        officeId = data["officeid"].stringValue
        getListData()
    }
    
    @objc func showAddTagView(sender: UIButton){
        
        if let param = sender.viewParam{
            selectedPersonId = param["personId"] as! String
        }
        
        let opt : UIView.AnimationOptions = .curveEaseIn
        UIView.animate(withDuration: 0.2, delay:0, options:opt, animations: {
            self.tagListBackgroundView.alpha = 0.8
//            self.tagListBackgroundView.setY(y: 0)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay:0, options:opt, animations: {
            self.tagCollection.alpha = 1
            self.tagCollection.setY(y: 175)
        }, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getListData()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //
    func getListData(){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT+"rest/app/getPersonLabel.do"
        myPostRequest(url,["signtime":selectedDate , "officeid":officeId]).responseJSON(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
//                print(json)
                if json["code"].stringValue == "1"{
                    self.jds = json["data"].arrayValue
                    self.personCollection.reloadData()
                }else{
                    myAlert(self, message: "请求人员数据失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })

    }
    
    
    @objc func refresh() {
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
    
    
}

//人员collection
extension AttendanceController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["personname"].stringValue
        
        let personTagScroll = cell.viewWithTag(10002) as! UIScrollView
        
        //先清除所有子视图
        for subview in personTagScroll.subviews{
            subview.removeFromSuperview()
        }
        
//        let separator = 5
        var index = 0
        var preView = UIView()
        for label in data["labellist"].arrayValue{
            //生成标签数据
            let btn = UIButton()
            btn.setBorder(width: 1, color: .groupTableViewBackground)
            btn.setCornerRadius(radius: 4)
            btn.titleLabel?.font = .systemFont(ofSize: 14)
            btn.titleLabel?.textAlignment = .center
            btn.setY(y: 8)
            btn.setHight(height: 28)
            btn.setWidth(width: label["labelname"].stringValue.getWidth() + 15)
            btn.tag = label["serialid"].intValue
            if index == 0{
                btn.setX(x: 0)
            }else{
                btn.moveToAfter(target: preView,space: 10)
            }
            btn.setTitleColor(.black, for: .normal)
            btn.setTitle(label["labelname"].stringValue, for: .normal)
            btn.addTarget(self, action: #selector(removeTag(sender:)), for: .touchUpInside)
            personTagScroll.addSubview(btn)
            HUtilView.addRedPoint(view: btn,isClose: true)
            
            preView = btn
            index += 1
        }
        
        personTagScroll.contentSize = CGSize(width: preView.X + preView.W + 10, height: preView.H)
        
        let btn_add = (cell.viewWithTag(10003) as! UIButton)
        btn_add.addTarget(self, action: #selector(showAddTagView(sender:)), for: .touchUpInside)
        btn_add.viewParam = ["personId":data["personid"].stringValue]
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: 45)
    }
    
    @objc func removeTag(sender: UIButton){
        
        myConfirm(self, message: "确定删除此标签吗?", okTitle: "确定", okHandler: { action in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let url = SERVER_PORT+"rest/app/cancelPersonLabel.do"
            myPostRequest(url,["serialid":sender.tag]).responseJSON(completionHandler: {resp in
                
//                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                switch resp.result{
                case .success(let responseJson):
                    let json = JSON(responseJson)
                    if json["code"].stringValue == "1"{
                        self.getListData()
                    }else{
                        myAlert(self, message: "删除标签失败!")
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
            })
        })
        
    }
    
}


//人员列表里已分配的tagCollectin
class AttendancePersonTagCollectionView :UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var jds = [JSON]()
    var selectedTagIndex = IndexPath()
    var parentView : AttendanceController?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("jds.count:\(jds.count)")
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        cell.setCornerRadius(radius: 4)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["labelname"].stringValue
        
        if selectedTagIndex == indexPath{
            cell.setBorder(width: 2, color: .red)
        }else{
            cell.setBorder(width: 1, color: .groupTableViewBackground)
        }
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTagIndex = indexPath
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = jds[indexPath.item]
        return CGSize(width: data["labelname"].stringValue.getWidth() + 15, height: 30)
    }
    
}


class AttendanceCalendarCollectinView : UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    let sectionHeaderId = "CollectionReusableViewHeader"
    
    var parentView : AttendanceController?
    var monthList = [String]()
    var dayDic = [String:[Date]]()
    var selectedDate = DateUtil.dateToString(Date())
    //选中的日期cell的IndexPath
    var selectedCalendarCellIndex = IndexPath()
    
    ///获取当前传入时间的月份以及后2个月的时间
    func getAfterTwoMonths(date : Date) -> [String]{
        var curDate = date
        var _mList = [String]()
        for _ in 0...2{
            _mList.append(DateUtil.dateMonthOfYearToString(curDate))
            curDate = curDate.nextMonth
        }
        return _mList
    }
    ///获取当前传入时间的月份以及之前2个月的时间
    func getBeforeTwoMonths(date : Date) -> [String]{
        var curDate = date
        var _mList = [String]()
        for _ in 0...2{
            _mList.append(DateUtil.dateMonthOfYearToString(curDate))
            curDate = curDate.prevMonth
        }
        return _mList.reversed()
    }
    
    ///根据传入的月份生成对应的日期数据
    func generationData( mList : [String]){
        for key in mList{
            let date = DateUtil.formatString(key, pattern: DateUtil.monthOfYearPattern)
            var dayList = DateUtil.getAlldayOfMonth(date)
            var ds = [Date]()
            for _ in 1..<dayList[0].weekday{
                ds.append(Date(timeIntervalSince1970: 0))
            }
            
            ds = ds + dayList
            dayDic[key] = ds
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dayDic[monthList[section]]!.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = dayDic[monthList[indexPath.section]]![indexPath.item]
//        print("cell:\(indexPath) \t data:\(data)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.setCornerRadius(radius: (cell.W - 8) / 2)
        if data.year == 1970{
            lbl.text = ""
        }else{
            lbl.text = data.day.description
        }
        
        if indexPath == selectedCalendarCellIndex || selectedDate == DateUtil.dateToString(data){
            lbl.backgroundColor = UIColor.init(hex: "3186E9")
            lbl.textColor = .white
        }else{
            lbl.backgroundColor = .white
            if data.weekday == 1 || data.weekday == 7{
                lbl.textColor = .red
            }else{
                lbl.textColor = .black
            }
        }
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCalendarCellIndex = indexPath
        selectedDate = DateUtil.dateToString(dayDic[monthList[indexPath.section]]![indexPath.item])
        parentView?.selectedDate = selectedDate
        parentView?.getListData()
        parentView?.calendarCollection.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.W / CGFloat(7)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    //设置section的header高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: 375, height: 30)
    }
    
    //渲染每个section的header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader{
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderId, for: indexPath) as! CollectionReusableViewHeader
            let key = monthList[indexPath.section]
            reusableView.label.text = key
            reusableView.label.textAlignment = .center
            
            return reusableView
        }
        return UICollectionReusableView()
    }
    
}

extension AttendanceCalendarCollectinView : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        print(scrollView.contentOffset)
        //当用户滚动到最后一页时扩充数据源
        let boundary = scrollView.contentSize.height - ((scrollView.contentSize.height / CGFloat(monthList.count)) * 2)
        if scrollView.contentOffset.y >= boundary{
            let date = DateUtil.formatString(monthList.last!, pattern: DateUtil.monthOfYearPattern)
            let mList = getAfterTwoMonths(date: date.nextMonth)
            generationData(mList: mList)
            monthList += mList
            parentView?.calendarCollection.reloadData()
        }
        //print(monthList)
    }
    
}


class CollectionReusableViewHeader: UICollectionReusableView {
    
    var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label = UILabel(frame: CGRect(x: 20, y: 0, width: UIScreen.width - 40, height: 30))
        self.label.setBorderBottom(size: 1, color: .groupTableViewBackground)
        self.addSubview(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//tagListCollectin
class AttendanceTagCollectionView :UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var jds = [JSON]()
    var parentView : AttendanceController?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["name"].stringValue
        lbl.setBorderBottom(size: 1, color: UIColor(hex: "3186E9"))
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.reloadData()
        let data = jds[indexPath.item]
        MBProgressHUD.showAdded(to: view, animated: true)
        let url = SERVER_PORT+"rest/app/setPersonLabel.do"
        myPostRequest(url,["labelid":data["labelid"].stringValue,"bepersonid":parentView?.selectedPersonId ,"signtime":parentView?.selectedDate]).responseJSON(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
//                print(json)
                if json["code"].stringValue == "1"{
                    self.parentView?.getListData()
                    self.parentView?.btn_dismissTagListView(sender: UIButton())
                }else{
                    myAlert(self, message: "设置标签失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.W, height: 40)
    }
    
}
