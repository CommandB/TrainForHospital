//
//  ImageForCollectionCellView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/4/15.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

class ImageCollectionForExamView : UIViewController,  UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    var jds = [JSON]()
    var parentView : UIView? = nil
    
    //设置collectionView的分区个数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    //实现UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell = UICollectionViewCell.init()
        var data = jds[indexPath.item]
        let cellName = "c1"
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        
        //渲染图片
        let imageView = (cell.viewWithTag(10001) as? UIImageView)!
        let imageUrl = URL(string: data["url"].stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        imageView.kf.setImage(with: ImageResource(downloadURL: imageUrl))
        
//        collectionView.backgroundColor = .red
//        cell.backgroundColor = .blue
        
        return cell
        
    }
    
    //点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = jds[indexPath.item]
        let imageUrl = (data["url"].stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        do{
            
            //判断缓存中是否存在.. 不存在则先下载 .. 存在则直接从缓存中读取图片
            if ImageCache.default.isImageCached(forKey: imageUrl).cached{
                let image = ImageCache.default.retrieveImageInDiskCache(forKey: imageUrl)!
                HUtilView.showImageToTagetView(target: parentView! ,image: image)
            }else{
                ImageDownloader.default.downloadImage(with: URL(string: imageUrl)!, completionHandler: {image, error, url, originalData in
                    HUtilView.showImageToTagetView(target: self.parentView! ,image: image!)
                })
            }
            
            
        }catch{}
        
    }
    
    //计算cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
        
    }
    
}
