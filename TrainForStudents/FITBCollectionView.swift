//
//  FITBCollectionView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/1/4.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

//fill in the blank question
class FITBCollectionView : BasePeiwuCollectionView , UITextFieldDelegate{
    
    var questionId = ""
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        var cell = UICollectionViewCell.init()
        //let a = jsonDataSource["answervalue"].stringValue.split(separator: ",")
        var data = JSON.init("")
        if 0 == indexPath.item{
            let cellName = "c1"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
            //获取数据
            data = jsonDataSource
            questionId = data["questionsid"].stringValue
            //渲染问题
            let lbl = (cell.viewWithTag(10001) as? UILabel)!
            let title = data["indexname"].stringValue + " " + data["title"].stringValue
            lbl.text = title
            
            lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width - boundary, cFont: (lbl.font)!)
            lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
        }else{
            let cellName = "c4"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
            //在txt被选中时用cell的tag来判断是第几个答案
            cell.tag = indexPath.item - 1
            //获取答案集里的答案
            let answerDic = parentView?.answerDic[questionId]
            var inputanswer = [Substring]()
            inputanswer = getInputanswer(dic:answerDic).0
            
            //渲染选项6
            let btn = (cell.viewWithTag(10001) as? UIButton)!
            btn.layer.cornerRadius = btn.frame.width / 2
            btn.setTitle("\(indexPath.item).", for: .normal)
            let txt = (cell.viewWithTag(10002) as? UITextField)!
            txt.text = String(inputanswer[cell.tag]).trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
            txt.delegate = self
        }
        
        
        return cell
        
    }
    
    //计算cell大小
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let labelWidth = UIScreen.width - 40 - boundary
        var lineHeight = CGFloat()
        var data = JSON.init("")
        var text = ""
        let index = indexPath.item
        let minHeight = CGFloat(40)
        
        //判断是题目还是答案
        if 0 == index{
            data = jsonDataSource
            text = data["indexname"].stringValue + " " + data["title"].stringValue
            let lineNumber = text.getLineNumberForWidth(width: labelWidth, cFont: questionFont)
            lineHeight = text.getHeight(font:questionFont)
            lineHeight.multiply(by: CGFloat(lineNumber))
            lineHeight.add(5)
            
            if lineHeight < minHeight {
                lineHeight = minHeight
            }
            return CGSize(width: UIScreen.width, height: lineHeight)
        }else{
            return CGSize(width: UIScreen.width, height: 40)
        }
        
        
        
        
        
    }
    
    //cell被选中
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        let txt = (cell?.viewWithTag(10002) as? UITextField)!
//        print("\(indexPath.item)\(txt == nil ? "" : txt.text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString text: String) -> Bool {
        
        let currentText = textField.text!
        let cell = textField.superview?.superview
        var answerStr = ""
        var answerDic = parentView?.answerDic[questionId]
        let tuple = getInputanswer(dic:answerDic)
        var inputanswer = tuple.0
        answerDic = tuple.1
        
        //把最新输入的内容和原本的text结合到一起
        inputanswer[(cell?.tag)!] = Substring.init((currentText as NSString).replacingCharacters(in: range, with: text))
        
        for s in inputanswer{
            answerStr += ",\(s == "" ? " ":s)"
        }
        answerStr = String.init(answerStr.dropFirst())
        //print(answerStr)
        answerDic!["inputanswer"] = answerStr
        parentView?.answerDic[questionId] = answerDic
        
        return true
    }

    
    ///获取用户输入的答案
    func getInputanswer(dic:Dictionary<String, String>?) -> ([Substring],Dictionary<String, String>?){
        var answerDic = dic
        var inputanswer = [Substring]()
        if answerDic == nil{
            //如果答案集里没有这个题目 则通过正确答案设置答案这个题目的答案集
            answerDic = getAnswerJson(json: jsonDataSource)
            let length = answerDic!["answervalue"]?.split(separator: ",").count
            for _ in 1...length!{
                inputanswer.append("")
            }
        }else{
            inputanswer = (answerDic!["inputanswer"]?.split(separator: ","))!
        }
        
        return (inputanswer,answerDic)
    }
    
    
}

