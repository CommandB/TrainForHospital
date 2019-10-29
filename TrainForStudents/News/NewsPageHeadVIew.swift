//
//  NewsPageHeadView.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

public protocol NewsPageHeadViewDelegate {
    func didClickNewsPageHeadView(json:JSON)
}

class NewsPageHeadView: UIView,UIScrollViewDelegate {
    var scrollview = UIScrollView()
    var pageControl = UIPageControl()
    var myTimer:Timer?
    let scrollViewHeight:CGFloat = 150
    var dataSource = [JSON]()
    var currentPagNumber = 0
    var delegate: NewsPageHeadViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addChildViews();
    }
    
    func addChildViews() {
        scrollview.contentSize = CGSize.init(width: SCREEN_WIDTH, height: 150)
        scrollview.delegate = self
        scrollview.bounces = false
        scrollview.showsHorizontalScrollIndicator = true
        scrollview.isPagingEnabled = true
        scrollview.isUserInteractionEnabled = true
        self.addSubview(scrollview)
        
        scrollview.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(150)
        }
        
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageTurn), for: .valueChanged)
        self.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(150)
        }
    }
    
    func bindData(dataSource:[JSON]) {
        var tempDataSource = [JSON]()
        if dataSource.count == 0 {
            let tempJson = JSON.init(["imgaurl":""])
            let temp2Json = JSON.init(["imgaburl":""])

            tempDataSource = [tempJson,temp2Json]
        }else{
            tempDataSource = dataSource
        }
        
        self.backgroundColor = UIColor.white
        for subview in self.scrollview.subviews {
            subview.removeFromSuperview()
        }
        
        self.dataSource = tempDataSource
        scrollview.contentSize = CGSize.init(width: SCREEN_WIDTH*CGFloat(tempDataSource.count), height: 0)
        pageControl.numberOfPages = tempDataSource.count
        
        for item in tempDataSource {
            guard let index = tempDataSource.index(of: item) else { return }
            let imageView = UIImageView()
            imageView.cornerRadius = 3
            imageView.layer.masksToBounds = true
            self.scrollview.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.width.equalTo(SCREEN_WIDTH - 20)
                make.height.equalTo(130)
                make.top.equalTo(10)
                make.left.equalTo((index)*Int(SCREEN_WIDTH) + 10)
            }
            
            if let url = URL.init(string: item["imgurl"].stringValue) {
                imageView.contentMode = .scaleAspectFit
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "newsDefault"), options: nil, progressBlock: nil, completionHandler: nil)
            }else{
                if index == 0 {
                    imageView.image = UIImage(named: "head_card_two")
                }else{
                    imageView.image = UIImage(named: "newsDefault")
                }
            }
            imageView.tag = 1000+index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didClickImage))
            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
        }
        myTimer?.invalidate()
        myTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
        
    }
    
    @objc func didClickImage(gesture:UITapGestureRecognizer) {
        if let imageView = gesture.view {
            let json = self.dataSource[imageView.tag-1000]
            self.delegate?.didClickNewsPageHeadView(json: json)
            
        }
    }
    
    @objc func pageTurn() {
        //        let pageNum = self.pageControl.currentPage
        //        self.scrollview.setContentOffset(CGPoint.init(x: SCREEN_WIDTH*CGFloat(pageNum), y: 0), animated: false)
    }
    
    @objc func scrollToNextPage() {
        
        if self.currentPagNumber >= self.dataSource.count {
            self.scrollview.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
            self.pageControl.currentPage = 0
            self.currentPagNumber = 0
        }else{
            self.scrollview.setContentOffset(CGPoint.init(x: SCREEN_WIDTH*CGFloat(currentPagNumber), y: 0), animated: false)
            self.pageControl.currentPage = currentPagNumber
        }
        self.currentPagNumber = self.currentPagNumber + 1
        if self.currentPagNumber >= self.dataSource.count {
            self.currentPagNumber = 0
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        myTimer?.invalidate()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.currentPagNumber = self.pageControl.currentPage
        myTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = SCREEN_WIDTH
        let pageHeigth = scrollViewHeight
        let currentPage = Int((self.scrollview.contentOffset.x-pageWidth/2)/pageWidth+1)
        if currentPage == 0 {
            self.scrollview.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: pageWidth, height: pageHeigth), animated: false)
            self.pageControl.currentPage = 0
        }else if currentPage == self.dataSource.count{
            self.scrollview.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: pageWidth, height: pageHeigth), animated: false)
            self.pageControl.currentPage = 0
        }else{
            self.pageControl.currentPage = currentPage;
        }
        scrollView.setContentOffset(CGPoint.init(x: CGFloat(self.pageControl.currentPage)*SCREEN_WIDTH, y: scrollView.contentOffset.y), animated: false)
    }
    
}
