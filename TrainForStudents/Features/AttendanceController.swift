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
    
    @IBOutlet weak var dateCollection: UICollectionView!
    
    @IBOutlet weak var tagCollection: UICollectionView!
    
    var tagView = AttendanceTagCollectionView()
    
    let sectionHeaderId = "CollectionReusableViewHeader"
    var monthList = [String]()
    var dayDic = [String:[Date]]()
    var jds = [Date]()
    var selectedCellIndex = IndexPath()
    
    override func viewDidLoad() {
        
        dateCollection.delegate = self
        dateCollection.dataSource = self
        
        dateCollection.register(CollectionReusableViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderId)
        
        tagCollection.delegate = tagView
        tagCollection.dataSource = tagView
        tagView.jds = JSON([["text":"病假"],["text":"名字很长的假"],["text":"事假"],["text":"早上加班"],["text":"大夜班"],["text":"旷工"],["text":"例假"],["text":"迟到"],["text":"名字比很长更长的假"]]).arrayValue
        tagCollection.reloadData()
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
        monthList = getBeforeTwoMonths(date: currentDate.prevMonth) + getAfterTwoMonths(date: currentDate)
        
        //生成数据
        generationData(mList: monthList)
        
        dateCollection.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.messageCollection.mj_header.beginRefreshing()
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getListData(){
//        self.messageCollection.mj_header.endRefreshing()
//        self.messageCollection.mj_footer.endRefreshing()
//        messageCollection.reloadData()
    }
    
    @objc func refresh() {
        jds.removeAll()
//        messageCollection.mj_footer.resetNoMoreData()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
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
    
}

extension AttendanceController : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset)
        //当用户滚动到最后一页时扩充数据源
        let boundary = scrollView.contentSize.height - ((scrollView.contentSize.height / CGFloat(monthList.count)) * 2)
        if scrollView.contentOffset.y >= boundary{
            let date = DateUtil.formatString(monthList.last!, pattern: DateUtil.monthOfYearPattern)
            let mList = getAfterTwoMonths(date: date.nextMonth)
            generationData(mList: mList)
            monthList += mList
            dateCollection.reloadData()
        }
        //print(monthList)
    }
    
}

extension AttendanceController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
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
        lbl.setCornerRadius(radius: lbl.W / 2)
        if data.year == 1970{
            lbl.text = ""
        }else{
            lbl.text = data.day.description
        }
        
        if indexPath == selectedCellIndex{
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
        selectedCellIndex = indexPath
        collectionView.reloadData()
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
//            let days = dayDic[key]
//            print("header:\(key)")
            reusableView.label.text = key
            reusableView.label.textAlignment = .center
            
            return reusableView
        }
        return UICollectionReusableView()
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




class AttendanceTagCollectionView :UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var jds = [JSON]()
    var selectedTagIndex = IndexPath()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        cell.setCornerRadius(radius: 4)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["text"].stringValue
        
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
        return CGSize(width: data["text"].stringValue.getWidth() + 15, height: 30)
    }

}


class AttendancePersonCollectionView :UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    var jds = [JSON]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return jds.count
    }
    
    //渲染cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        let lbl = cell.viewWithTag(10001) as! UILabel
        lbl.text = data["text"].stringValue
        
        
        return cell
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        selectedCellIndex = indexPath
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        
        return CGSize(width: collectionView.W, height: 45)
    }
    
}
