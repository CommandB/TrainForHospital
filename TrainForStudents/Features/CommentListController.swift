//
//  CommentListController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/13.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CommentListController : UIViewController{
    
    @IBOutlet weak var teacherCollection: UICollectionView!
    
    //@IBOutlet weak var overCollection: UICollectionView!
    
    @IBOutlet weak var btn_left: UIButton!
    
    @IBOutlet weak var btn_right: UIButton!
    
    var jds = [JSON]()
    
    var pageNumber = 0
    var beginDraggingX = CGFloat(0)
    
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    override func viewDidLoad() {
        buttonGroup = [btn_left , btn_right]
        btn_left.restorationIdentifier = "btn_left"
        btn_right.restorationIdentifier = "btn_right"
        
//        scrollView.contentSize = CGSize(width: UIScreen.width.multiplied(by: 2), height: scrollView.frame.height)
//        scrollView.delegate = self
        
        teacherCollection.delegate = self
        teacherCollection.dataSource = self
        
        
//        overCollection.delegate = overView
//        overCollection.dataSource = overView
//        overView.parentView = self
//        overCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: overView, refreshingAction: #selector(overView.refresh))
//        overCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: overView, refreshingAction: #selector(overView.loadMore))
//        overCollection.mj_header.beginRefreshing()
//        overCollection.frame.origin = CGPoint(x: UIScreen.width, y: overCollection.frame.origin.y)
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //左右滑按钮
    @IBAction func btn_inside(_ sender: UIButton) {
        tabsTouchAnimation(sender: sender)
    }
    
    func tabsTouchAnimation( sender : UIButton){
        //-----------------计算 "下标线"label的动画参数
        for b in buttonGroup {
            if b == sender{
                b.setTitleColor(UIColor.init(hex: "407BD8"), for: .normal)
            }else{
                b.setTitleColor(UIColor.black, for: .normal);
            }
        }
        
        //动画开始
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        let collectionWidth = teacherCollection.frame.width
        
        //滚动效果
        if sender.restorationIdentifier == "btn_left"{
            pageNumber -= 1
            if pageNumber < 0{
                pageNumber = 0
            }
            teacherCollection.setContentOffset(CGPoint(x: collectionWidth.multiplied(by: CGFloat(pageNumber)), y: 0), animated: true)
        }else if sender.restorationIdentifier == "btn_right"{
            pageNumber += 1
            teacherCollection.setContentOffset(CGPoint(x: collectionWidth.multiplied(by: CGFloat(pageNumber)), y: 0), animated: true)
        }
        print("pageNumber:\(pageNumber)")
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
    }
    
}


extension CommentListController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count + 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        var lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = "\(lbl.text?.description)-\(indexPath.item)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "commentHistoryDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 325, height: 150)
    }
    
}


extension CommentListController : UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginDraggingX = scrollView.contentOffset.x
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = scrollView.contentOffset.x
        
        print("endDragging =   beginDraggingX:\(beginDraggingX) : x:\(x)")
        
        if beginDraggingX < x{  //左滑
            print("左滑")
            tabsTouchAnimation(sender: btn_right)
        }else if beginDraggingX > x {   //右滑
            print("右滑")
            tabsTouchAnimation(sender: btn_left)
        }
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x

        print("endDragging =   beginDraggingX:\(beginDraggingX) : x:\(x)")

        if beginDraggingX < x{  //左滑
            print("左减速")
            tabsTouchAnimation(sender: btn_right)
        }else if beginDraggingX > x {   //右滑
            print("右减速")
            tabsTouchAnimation(sender: btn_left)
        }
    }
    
    
    
}
