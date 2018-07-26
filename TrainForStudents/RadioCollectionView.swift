//
//  RadioCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/15.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RadioCollectionView : PeiwuCollectionView{

    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        var cell = UICollectionViewCell.init()
        let a = jsonDataSource["answers"].arrayValue
        var data = JSON.init("")
        if 0 == indexPath.item{
            let cellName = "c1"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
            //获取数据
            data = jsonDataSource
            let qid = data["questionsid"].stringValue
            //渲染问题
            let lbl = (cell.viewWithTag(10001) as? UILabel)!
            var title = data["indexname"].stringValue + " " + data["title"].stringValue
            lbl.text = title

            //计算出需要的行数后在多加一行防止一些空格和符号显示不全
            lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width - boundary, cFont: (lbl.font)!) + 1
            lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
            
            if qid == selectedQuestionId{
                lbl.textColor = UIColor.init(hex: "68adf6")
            }
            //获取题目对应被选的答案
            let inputanswer = parentView?.answerDic[qid]?["inputanswer"]
            if inputanswer != nil && inputanswer != ""{
                //在题目结尾展示答案
                title.insert(Character.init(inputanswer!), at: title.endIndex)
                lbl.text = title
            }
            //被选中则需要把题目对应被选中的答案也带出来
            selectedDic[qid] = parentView?.answerDic[qid]?["inputanswer"]

        }else{
            let cellName = "c2"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
            //cell.backgroundColor = UIColor.red
            cell.tag = 0
            //获取数据
            data = a[indexPath.item - 1]
            let questionId = jsonDataSource["questionsid"].stringValue
            var answerDic = parentView?.answerDic[questionId]
            //渲染选项
            let btn = (cell.viewWithTag(10001) as? UIButton)!
            btn.layer.cornerRadius = btn.frame.width / 2
            btn.setTitle(data["selecttab"].stringValue, for: .normal)
            //关闭按钮动画
//            btn.adjustsImageWhenDisabled = false
//            btn.adjustsImageWhenHighlighted = false
//            btn.showsTouchWhenHighlighted = false
//            btn.reversesTitleShadowWhenHighlighted = false
            let lbl = (cell.viewWithTag(10002) as? UILabel)!
            let title = data["answervalue"].stringValue
            lbl.text = title
            //lbl.backgroundColor = UIColor.green
            lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width - boundary, cFont: (lbl.font)!)
            let y = btn.frame.origin.y.adding(4)
//            var y = lbl.frame.origin.y
//            if lbl.numberOfLines >= 2{
//               y = btn.frame.origin.y
//            }
            lbl.frame.origin = CGPoint(x: lbl.frame.origin.x, y: y)
            lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
            
            if answerDic != nil{
                if btn.currentTitle == answerDic!["inputanswer"]{
                    btn.setTitleColor(UIColor.white, for: .normal)
                    btn.backgroundColor = UIColor.init(hex: "ffc84c")
                }else{
                    btn.setTitleColor(UIColor.init(hex: "5ea3f3"), for: .normal)
                    btn.backgroundColor = UIColor.init(hex: "f5f8fb")
                }
            }else{
                btn.setTitleColor(UIColor.init(hex: "5ea3f3"), for: .normal)
                btn.backgroundColor = UIColor.init(hex: "f5f8fb")
            }
            
        }
        
        //print("cell.tag=\(cell.tag)")
        return cell
        
    }
    
    //计算cell大小
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var labelWidth = UIScreen.width - 40 - boundary
        let a = jsonDataSource["answers"].arrayValue
        var lineHeight = CGFloat()
        var data = JSON.init("")
        var text = ""
        let index = indexPath.item
        var minHeight = CGFloat(40)
        
        //判断是题目还是答案
        if 0 == index{
            data = jsonDataSource
            text = data["indexname"].stringValue + " " + data["title"].stringValue
        }else{
            labelWidth = UIScreen.width - 40 - 35 - 8 - boundary
            data = a[index - 1]
            text = data["answervalue"].stringValue
            minHeight.add(10)  //答案选项的cell需要增加间距
        }
        var lineNumber = text.getLineNumberForWidth(width: labelWidth, cFont: questionFont)
        if indexPath.item == 0{
            lineNumber = lineNumber + 1
        }
        
        lineHeight = text.getHeight(font:questionFont)
        lineHeight.multiply(by: CGFloat(lineNumber))
        lineHeight.add(5)
        
        if lineHeight < minHeight {
            lineHeight = minHeight
        }
        
        
        return CGSize(width: UIScreen.width, height: lineHeight)
        
    }
    
    //cell被选中
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        let questionId = jsonDataSource["questionsid"].stringValue
        var answerDic = parentView?.answerDic[questionId]
        if answerDic == nil{
            answerDic = getAnswerJson(json: jsonDataSource)
        }
        
        let cell = collectionView.cellForItem(at: indexPath)
        let btn = cell?.viewWithTag(10001) as! UIButton
        if cell?.tag == 0 {
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.backgroundColor = UIColor.init(hex: "ffc84c")
            answerDic?["inputanswer"] = btn.currentTitle
            cell?.tag = 1
        }else{
            btn.setTitleColor(UIColor.init(hex: "5ea3f3"), for: .normal)
            btn.backgroundColor = UIColor.init(hex: "f5f8fb")
            answerDic?["inputanswer"] = ""
            cell?.tag = 0
        }
        parentView?.answerDic[questionId] = answerDic
        parentView?.questionCollection.reloadData()
        
    }
    
    
}
