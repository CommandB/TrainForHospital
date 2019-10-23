//
//  NewsPageControlCell.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/7.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
class NewsPageControlCell: UITableViewCell,UIScrollViewDelegate {
    var scrollview = UIScrollView()
    var pageControl = UIPageControl()
    var myTimer:Timer?
    let scrollViewHeight:CGFloat = 150
    var dataSource = [JSON]()
    var currentPagNumber = 0
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.isUserInteractionEnabled = true
        self.createCellUI()
    }
    
    
    func createCellUI()  {
        scrollview.contentSize = CGSize.init(width: SCREEN_WIDTH, height: 150)
        scrollview.delegate = self
        scrollview.bounces = false
        scrollview.showsHorizontalScrollIndicator = true
        scrollview.isPagingEnabled = true
        self.addSubview(scrollview)
        
        scrollview.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(150)
        }
        scrollview.backgroundColor = UIColor.red
        
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
        if dataSource.count == 0 {
            return
        }
        
        self.dataSource = dataSource
        scrollview.contentSize = CGSize.init(width: SCREEN_WIDTH*CGFloat(self.dataSource.count), height: 0)
        pageControl.numberOfPages = dataSource.count
        
        for item in dataSource {
            guard let index = dataSource.index(of: item) else { return }
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            self.scrollview.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(150)
                make.top.equalToSuperview()
                make.left.equalTo((index)*Int(SCREEN_WIDTH))
            }
            
            if let url = URL.init(string: item["imgurl"].stringValue) {
                imageView.kf.setImage(with: url)
            }
            imageView.image = UIImage.init(named: "picture")
        }
        myTimer?.invalidate()
        myTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
        
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
        self.currentPagNumber = self.pageControl.currentPage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
