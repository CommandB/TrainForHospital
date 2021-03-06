//
//  PeiwuCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/14.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PeiwuCollectionView : QuestionCollectionView {
    
    var selectedQuestionId = ""
    var selectedDic = [String:String]()
    //var selectedQuestionIndex = ""
    var selectedIndex :IndexPath? = nil
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        var cell = UICollectionViewCell.init()
        let subQ = jsonDataSource["sub_questions"].arrayValue
        let a = jsonDataSource["up_answers"].arrayValue
        var data = JSON.init("")
        if subQ.count > indexPath.item{
            let cellName = "c1"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
            cell.backgroundColor = UIColor.clear
            //获取数据
            data = subQ[indexPath.item]
            let qid = data["questionsid"].stringValue
            //渲染问题
            let lbl = (cell.viewWithTag(10001) as? UILabel)!
            var title = data["indexname"].stringValue + " " + data["title"].stringValue
            lbl.text = title
            lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width - boundary, cFont: (lbl.font)!)
            lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
            
            //判断此题目是否被选中
            if parentView?.answerDic[qid] != nil {  //被选中
                if qid == selectedQuestionId{
                    lbl.textColor = UIColor.init(hex: "68adf6")
                }else{
                    lbl.textColor = UIColor.init(hex: "3b454f")
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
            }else{  //没选中
                lbl.textColor = UIColor.init(hex: "3b454f")
            }
            
        }else{
            let cellName = "c2"
            cell = (myCollection?.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath))!
            //获取数据
            data = a[indexPath.item - subQ.count]
            //渲染选项
            let btn = (cell.viewWithTag(10001) as? UIButton)!
            btn.layer.cornerRadius = btn.frame.width / 2
            btn.setTitle(data["selecttab"].stringValue, for: .normal)
            btn.setTitleColor(UIColor.init(hex: "5ea3f3"), for: .normal)
            btn.backgroundColor = UIColor.init(hex: "f5f8fb")
            
            let lbl = (cell.viewWithTag(10002) as? UILabel)!
            let title = data["answervalue"].stringValue
            lbl.text = title
            lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width - boundary, cFont: (lbl.font)!)
            let y = btn.frame.origin.y + (4)
//            var y = lbl.frame.origin.y
//            if lbl.numberOfLines >= 2{
//                y = btn.frame.origin.y
//            }
            lbl.frame.origin = CGPoint(x: lbl.frame.origin.x, y: y)
            lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
            
            for (_,tab) in selectedDic {
                
                if btn.currentTitle == tab{
                    btn.setTitleColor(UIColor.white, for: .normal)
                    btn.backgroundColor = UIColor.init(hex: "ffc84c")
                    break
                }else{
                    btn.setTitleColor(UIColor.init(hex: "5ea3f3"), for: .normal)
                    btn.backgroundColor = UIColor.init(hex: "f5f8fb")
                }
                
            }
            
            
            
        }
        
        
        return cell
        
    }
    
    //计算cell大小
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var labelWidth = UIScreen.width - 40 - boundary
        let subQ = jsonDataSource["sub_questions"].arrayValue
        let a = jsonDataSource["up_answers"].arrayValue
        var lineHeight = CGFloat()
        var data = JSON.init("")
        var text = ""
        let index = indexPath.item
        var minHeight = CGFloat(40)
        
        //判断是题目还是答案
        if subQ.count > index{
            data = subQ[index]
            text = data["indexname"].stringValue + " " + data["title"].stringValue
        }else{
            labelWidth = UIScreen.width - 40 - 35 - 8 - boundary
            data = a[index - subQ.count]
            text = data["answervalue"].stringValue
            minHeight += (10)  //答案选项的cell需要增加间距
        }
        let lineNumber = text.getLineNumberForWidth(width: labelWidth, cFont: questionFont)
        lineHeight = text.getHeight(font:questionFont) + 1
        lineHeight *= CGFloat(lineNumber)
        //lineHeight.add(CGFloat(30))
        
        
        if lineHeight < minHeight {
            lineHeight = minHeight
        }
        
        
        return CGSize(width: UIScreen.width, height: lineHeight)
        
        
    }
    
    //cell被选中
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let subQ = jsonDataSource["sub_questions"].arrayValue
        let a = jsonDataSource["up_answers"].arrayValue
        //判断是题目还是答案
        if subQ.count > indexPath.item{
//            let cell = collectionView.cellForItem(at: indexPath)
//
//            print("before  selectedIndex:\(selectedIndex)  cell:\(indexPath)")
            
            //如果用户是第一次选择题目
//            if selectedIndex == nil {
//                selectedIndex = indexPath
//                cell?.backgroundColor = UIColor.init(hex: "dedede")
//            }else if selectedIndex != indexPath{    //如果用户选择的题目和上一次不同 则反选上次的题目 选中这次的题目
//                let selectedCell = collectionView.cellForItem(at: selectedIndex!)
//                selectedCell?.backgroundColor = UIColor.clear
//                cell?.backgroundColor = UIColor.init(hex: "dedede")
//            }else if selectedIndex == indexPath{
//                cell?.backgroundColor = UIColor.clear
//            }
            
//            print("after  selectedIndex:\(selectedIndex)  cell:\(indexPath)")
//            print("----------------------------------------------------") 
            
            //记录被选中的题目
            selectedIndex = indexPath
            let q = subQ[indexPath.item]
            let qid = q["questionsid"].stringValue
            if selectedQuestionId != qid {
                //如果之前选择的题目没有选答案则把选择的题目设置为nil
                if parentView?.answerDic[selectedQuestionId]?["inputanswer"] == nil{
                    parentView?.answerDic[selectedQuestionId] = nil
                }
                //设置当先被选中的题目
                selectedQuestionId = qid
                //初始化被选择中的题目
                parentView?.answerDic[qid] = getAnswerJson(json: q)
            }else{
                parentView?.answerDic[selectedQuestionId] = nil
                selectedQuestionId = ""
            }
            //把此题目的选中设置为空 让用户重新选择
            selectedDic[qid] = nil
            
//            parentView?.anwserDic[qid] = nil
            
        }else{
            if selectedQuestionId == "" {
                myAlert(parentView!, message: "请先选择题目!")
                return
            }
            
            let cell = collectionView.cellForItem(at: indexPath)
            let btn = cell?.viewWithTag(10001) as! UIButton
//            btn.backgroundColor = UIColor.init(hex: "ffc84c")
//            btn.setTitleColor(UIColor.white, for: .normal)
            
            let data = a[indexPath.item - subQ.count]
            //判断该选择有否已被选中
//            for (_,tab) in selectedDic {
//                if tab == data["selecttab"].stringValue{
//                    myAlert(parentView!, message: "改选项已匹配另一题目!")
//                    return
//                }
//            }

            parentView?.answerDic[selectedQuestionId]?["inputanswer"] = data["selecttab"].stringValue
            
//            selectedQuestionId = ""
        }
        //collectionView.reloadItems(at: [indexPath])
        
        
//        print("现在选中的id是\(selectedQuestionId)")
//        print("selectedArray : \(selectedArray.description)")
//        print("parentView?.anwserDic : \(parentView?.anwserDic.description)")
        
        collectionView.reloadData()
        
    }

}
