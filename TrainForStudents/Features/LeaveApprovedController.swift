//
//  FeaturesControler.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/22.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class LeaveApprovedController : UIViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var undoneCollection: UICollectionView!
    
    @IBOutlet weak var overCollection: UICollectionView!
    
    @IBOutlet weak var lbl_markLine: UILabel!
    
    @IBOutlet weak var btn_undone: UIButton!
    
    @IBOutlet weak var btn_over: UIButton!
    
    let undoneView = LeaveUndoneCollection()
    
    let overView = LeaveOverCollection()
    
    
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    override func viewDidLoad() {
        buttonGroup = [btn_undone , btn_over]
        btn_undone.restorationIdentifier = "btn_undone"
        btn_over.restorationIdentifier = "btn_over"
        
        scrollView.contentSize = CGSize(width: UIScreen.width.multiplied(by: 2), height: scrollView.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        undoneCollection.delegate = undoneView
        undoneCollection.dataSource = undoneView
        undoneView.parentView = self
        undoneCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: undoneView, refreshingAction: #selector(undoneView.refresh))
        undoneCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: undoneView, refreshingAction: #selector(undoneView.loadMore))
        undoneCollection.mj_header.beginRefreshing()
        
        overCollection.delegate = overView
        overCollection.dataSource = overView
        overView.parentView = self
        overCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: overView, refreshingAction: #selector(overView.refresh))
        overCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: overView, refreshingAction: #selector(overView.loadMore))
        overCollection.mj_header.beginRefreshing()
        overCollection.frame.origin = CGPoint(x: UIScreen.width, y: overCollection.frame.origin.y)

    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //未审批 按钮
    @IBAction func btn_undone_inside(_ sender: UIButton) {
        
        tabsTouchAnimation(sender: sender)
    }
    
    //已审批 按钮
    @IBAction func btn_over_inside(_ sender: UIButton) {
        
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
        
        let btn_x = sender.frame.origin.x                      //按钮x轴
        let btn_middle = sender.frame.size.width / 2           //按钮中线
        let lbl_half = lbl_markLine.frame.size.width / 2       //下标线的一半宽度
        //计算下标线的x轴位置
        let target_x = btn_x + btn_middle - lbl_half
        let target_y = lbl_markLine.frame.origin.y
        
        
        //动画开始
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        lbl_markLine.frame = CGRect(origin: CGPoint(x:target_x,y:target_y), size: lbl_markLine.frame.size)
        
        //滚动效果
        if sender.restorationIdentifier == "btn_undone"{
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }else if sender.restorationIdentifier == "btn_over"{
            scrollView.setContentOffset(CGPoint(x: UIScreen.width, y: 0), animated: true)
        }
        
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
    }
    
}

extension LeaveApprovedController : UIScrollViewDelegate{
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = scrollView.contentOffset.x
        if x < UIScreen.width.divided(by: 2){
            tabsTouchAnimation(sender: btn_undone)
        }else{
            tabsTouchAnimation(sender: btn_over)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        if x < UIScreen.width.divided(by: 2){
            tabsTouchAnimation(sender: btn_undone)
        }else{
            tabsTouchAnimation(sender: btn_over)
        }
    }
    
}
