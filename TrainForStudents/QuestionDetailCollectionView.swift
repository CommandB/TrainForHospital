//
//  QuestionDetailCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/10.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class QuestionDetailCollectionView : UIViewController,  UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    var parentView : QuestionnaireController? = nil
    var jsonDataSource = JSON()
    let selectedColor = UIColor.init(hex: "6AAFE4")
    let unSelectedColor = UIColor.groupTableViewBackground
    var questionId = ""
    let titleFont = UIFont.systemFont(ofSize: 15)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = jsonDataSource["itemtype"].intValue
        let baseCellTotal = 2
        var anwserCellTotal = 0
        if type == 0{   //选择题
            anwserCellTotal = jsonDataSource["options"].arrayValue.count
        }else{
            anwserCellTotal = 1
        }
        return baseCellTotal + anwserCellTotal
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = jsonDataSource["itemtype"].intValue
        var cell = UICollectionViewCell()
        switch indexPath.item {
        case 0: //显示标题
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
            let lbl_title = cell.viewWithTag(10001) as! UILabel
            let titleText = jsonDataSource["title"].stringValue
            lbl_title.font = titleFont
            lbl_title.text = titleText
            //计算出需要的行数后在多加一行防止一些空格和符号显示不全
            lbl_title.numberOfLines = titleText.getLineNumberForWidth(width: lbl_title.frame.width, cFont: (lbl_title.font)!) + 1
            lbl_title.frame.size = CGSize(width: lbl_title.frame.size.width, height: getHeightForLabel(lbl: lbl_title))
        case 1: //显示提示语
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c2", for: indexPath)
            let lbl_tips = cell.viewWithTag(10001) as! UILabel
            lbl_tips.text = "(至少选择\(jsonDataSource["minchoice"].intValue)个,最多选择\(jsonDataSource["maxchoice"].intValue)个)"
        default:    //展示选项
            if type == 0{   //选择题
                let data = jsonDataSource["options"].arrayValue[indexPath.item - 2]
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c3", for: indexPath)
                cell.tag = 1000
                let btn = cell.viewWithTag(10001) as! UIButton
                btn.backgroundColor = unSelectedColor
                btn.layer.borderWidth = 2
                btn.layer.borderColor =  UIColor.darkGray.cgColor
                btn.clipsToBounds = true
                btn.layer.cornerRadius = 4
                btn.isUserInteractionEnabled = false
                
                //判断这题有没有做过
                let dic = parentView?.resultDic[data["questionid"].stringValue] as! [String:Any]
                
                if dic[data["optionid"].stringValue] != nil{
                    btn.backgroundColor = selectedColor
                    cell.tag = 9999
                }
                
                
                let lbl = cell.viewWithTag(10002) as! UILabel
                let text = data["wordsvalue"].stringValue
                lbl.text = text
                //计算出需要的行数后在多加一行防止一些空格和符号显示不全
                lbl.numberOfLines = text.getLineNumberForWidth(width: lbl.frame.width, cFont: (lbl.font)!) + 1
                lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
                
                
                //cell.backgroundColor = UIColor.blue
                //lbl.backgroundColor = UIColor.red
                
            }else if type == 1{  //简答题
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c4", for: indexPath)
                let lbl = cell.viewWithTag(10001) as! UILabel
                lbl.text = jsonDataSource["title"].stringValue
                
                questionId = jsonDataSource["questionid"].stringValue
                
                let text = parentView?.resultDic[jsonDataSource["questionid"].stringValue] as! String
                let textView = cell.viewWithTag(20001) as! UITextView
                textView.delegate = self
                textView.returnKeyType = .done
                textView.text = text
                
            }
            
            break
        }
        return cell
    }
    
    //计算cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let type = jsonDataSource["itemtype"].intValue
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        
        var lineHeight = 0
        switch indexPath.item {
            case 0:
            let titleText = jsonDataSource["title"].stringValue
            let lineNumber = titleText.getLineNumberForWidth(width: UIScreen.width.subtracting(40), cFont: titleFont)
            lineHeight = lineNumber * 20 + 10
        case 1:
            lineHeight = 40
            if type == 1{   //简答题不用显示这一行
                lineHeight = 0
            }
        default:
            //TODO
            if type == 0 {  //选择题
                let text = jsonDataSource["wordsvalue"].stringValue
                
                let lineNumber = text.getLineNumberForWidth(width: UIScreen.width.subtracting(40), cFont: titleFont)

                lineHeight = lineNumber * 20 + 10
                if lineHeight < 40{
                    lineHeight = 40
                }
            }else if type == 1{  //简答题
                lineHeight = 140
            }
            break
        }
        
        
        return CGSize(width: UIScreen.width, height: CGFloat(lineHeight))
        
    }
    
    //cell点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let type = jsonDataSource["itemtype"].intValue
        if type == 0 && indexPath.item > 1 {
            let cell = collectionView.cellForItem(at: indexPath)
            let btn = cell?.viewWithTag(10001) as! UIButton
            if cell?.tag == 1000 {  //未选中
                
                btn.backgroundColor = selectedColor
                cell?.tag = 9999
                //把选中的结果放入结果集
                let data = jsonDataSource["options"].arrayValue[indexPath.item - 2]
                var dic = parentView?.resultDic[jsonDataSource["questionid"].stringValue] as! [String:Any]
                dic[data["optionid"].stringValue] = ""
                parentView?.resultDic[jsonDataSource["questionid"].stringValue] = dic
            }else{  //已选中
                btn.backgroundColor = unSelectedColor
                cell?.tag = 1000
                
                //反选答案
                let data = jsonDataSource["options"].arrayValue[indexPath.item - 2]
                var dic = parentView?.resultDic[jsonDataSource["questionid"].stringValue] as! [String:Any]
                dic.removeValue(forKey: data["optionid"].stringValue)
                parentView?.resultDic[jsonDataSource["questionid"].stringValue] = dic
            }
            //collectionView.reloadItems(at: [indexPath])
        }
        parentView?.hiddenKeyBoard()
    }
    
    ///根据lbl的lineNumbner计算lbl的高度
    func getHeightForLabel(lbl : UILabel) -> CGFloat{
        
        return CGFloat(lbl.numberOfLines * 17)
    }
    
}

extension QuestionDetailCollectionView : UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        parentView?.resultDic[questionId] = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text.contains("\n") {
            parentView?.hiddenKeyBoard()
            return false
        }
        return true
        
    }
    
}
