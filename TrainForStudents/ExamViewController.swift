//
//  ExamViewController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/12.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ExamViewController : MyBaseUIViewController{
    
    var taskId = ""
    var exerciseId = ""
    var marking = 0
    var isSimulation = false
    var exercises = [JSON]()    //考卷内容
    var currentType = JSON.init("") //当前题型
    var typeIndex = 0
    var questionIndex = 0
    
    ///存储已选择的答案
    var answerDic = [String:Dictionary<String, String>]()
    
    let questionTypeTitle = "    %@【%@】 共%d道 每道%d分 共%d分"
    
    var fromView = UIViewController()
    
    @IBOutlet weak var lbl_questionType: UILabel!
    
    @IBOutlet weak var lbl_prompt: UIView!
    
    @IBOutlet weak var btn_prev: UIButton!
    
    @IBOutlet weak var btn_next: UIButton!
    
    @IBOutlet weak var btn_complete: UIButton!
    
    @IBOutlet weak var resultView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var isTheoryExam = false
    var passscore = "0"
    
    //未完成 collection
    @IBOutlet weak var questionCollection: UICollectionView!
    
    var questionView = QuestionCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionlayout = UICollectionViewFlowLayout()
        questionlayout.minimumLineSpacing = 3
        questionlayout.minimumInteritemSpacing = 0
        
        questionCollection.collectionViewLayout = questionlayout
        MyNotificationUtil.addKeyBoardWillChangeNotification(self)
        resultView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var cacheAnswerDic = UserDefaults.Exam.any(forKey: .answerDic) as! [String : [String : Dictionary<String, String>]]
        cacheAnswerDic[taskId] = answerDic
        // 将当前答案保存到应用缓存中
        UserDefaults.Exam.set(value: cacheAnswerDic, forKey: .answerDic)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //读取应用中缓存的答案
        let dic = UserDefaults.Exam.any(forKey: .answerDic)
        if dic != nil{
            let cacheAnswerDic = dic as! [String : [String : Dictionary<String, String>]]
            if cacheAnswerDic[taskId] != nil{
                self.answerDic = cacheAnswerDic[taskId]!
            }
            
        }
        
        currentType = exercises[typeIndex]
        
        //初始化题型标题
        lbl_questionType.text = String(format: questionTypeTitle, arguments: [currentType["indexname"].stringValue,currentType["typename"].stringValue,currentType["count"].intValue,currentType["score"].intValue,currentType["count"].intValue * currentType["score"].intValue])
        promptSwap(currentType["typename"].stringValue)
        
        btn_complete.isHidden = true
        btn_prev.isEnabled = !isFirstQuestion()
        btn_next.isEnabled = !isLastQuestion()
        if isLastQuestion() {
            btn_complete.isHidden = false
        }
        
        initCollection()
        
    }
    
    
    ///返回按钮
    @IBAction func btn_back_inside(_ sender: UIButton) {
        
        myConfirm(self, message:"是否退出考试?" ,
                  okHandler:{action in
                    
                // 将当前答案保存到应用缓存中
//                UserDefaults.Exam.set(value: self.answerDic, forKey: .answerDic)
                self.dismiss(animated: true, completion: nil)
                    
        } , cancelHandler:{action in
            
        })
        
    }
    
    //上一题
    @IBAction func btn_prev_inside(_ sender: UIButton) {
        
        questionIndex -= 1
        //如果已是当前题型最后一题 则切换到下一题型
        if questionIndex < 0{
            switchQuestionType(isNext: false)
        }
        //获取当前题目
        let question = (currentType["questions"].arrayValue)[questionIndex]
        //重新初始化展示题目的collection
        initCollection()
        //展示考题
        questionView.jsonDataSource = question
        questionCollection.reloadData()
        //设置按钮
        btn_next.isEnabled = !isLastQuestion()
        btn_prev.isEnabled = !isFirstQuestion()
        btn_complete.isHidden = true
    }
    
    //下一题
    @IBAction func btn_next_inside(_ sender: UIButton) {
        
        //判断当前题目是否已全部作答
        let curQuestion = questionView.jsonDataSource
        let qType = curQuestion["type"].intValue
        if qType == 3 {    //配伍题
            var isComplete = true
            for sbq in curQuestion["sub_questions"].arrayValue {
                let qid = sbq["questionsid"].stringValue
                let a = answerDic[qid]
                if a == nil || a!["inputanswer"] == nil || a!["inputanswer"] == "" {
                    isComplete = false
                    isAnswered(qid: qid,quesionJson: curQuestion,initAnswer: a == nil)
                }
            }
            if isComplete{
                nextQeustion()
            }
        }else{
            let qid = curQuestion["questionsid"].stringValue
            if(qType == 5){   //填空题
                let a = answerDic[qid]
                let qid = curQuestion["questionsid"].stringValue
                if a == nil {
                    isAnswered(qid: qid,quesionJson: curQuestion)
                }else{
                    let inputanswer = a!["inputanswer"]
                    let sbStr = inputanswer?.split(separator: ",")
                    var isComplete = true
                    for str in sbStr! { //根据填空题答案的格式来判断是否完成题目
                        if str == "" || str == " "{
                            isComplete = false
                            isAnswered(qid: qid,quesionJson: curQuestion,initAnswer: false)
                        }
                    }
                    if isComplete{
                        nextQeustion()
                    }
                    
                }
            }else{  //其余题型
                let qid = curQuestion["questionsid"].stringValue
                let a = answerDic[qid]
                if a == nil || a!["inputanswer"] == nil || a!["inputanswer"] == ""{
                    isAnswered(qid: qid,quesionJson: curQuestion)
                }else{
                    nextQeustion()
                }
            }
            
        }
        
    }
    
    //完成
    @IBAction func btn_complete_inside(_ sender: UIButton) {
        
        //判断当前题目是否已全部作答
        var isComplete = true
        let curQuestion = questionView.jsonDataSource
        let qType = curQuestion["type"].intValue
        if qType == 3 {    //配伍题
            for sbq in curQuestion["sub_questions"].arrayValue {
                let qid = sbq["questionsid"].stringValue
                let a = answerDic[qid]
                if a == nil || a!["inputanswer"] == nil || a!["inputanswer"] == "" {
                    isComplete = false
                    isSubmit(qid: qid,quesionJson: curQuestion,initAnswer: a == nil)
                }
            }
        }else{
            let qid = curQuestion["questionsid"].stringValue
            if(qType == 5){   //填空题
                let a = answerDic[qid]
                let qid = curQuestion["questionsid"].stringValue
                if a == nil {
                    isComplete = false
                    isSubmit(qid: qid,quesionJson: curQuestion)
                }else{
                    let inputanswer = a!["inputanswer"]
                    let sbStr = inputanswer?.split(separator: ",")
                    for str in sbStr! { //根据填空题答案的格式来判断是否完成题目
                        if str == "" || str == " "{
                            isComplete = false
                            isSubmit(qid: qid,quesionJson: curQuestion,initAnswer: false)
                        }
                    }
                    
                }
            }else{  //其余题型
                let qid = curQuestion["questionsid"].stringValue
                let a = answerDic[qid]
                if a == nil || a!["inputanswer"] == nil || a!["inputanswer"] == ""{
                    isComplete = false
                    isSubmit(qid: qid,quesionJson: curQuestion)
                }
            }
            
        }
        
        if isComplete{

            hiddenKeyBoard()

            myConfirm(self, message:"是否确认提交试卷?" ,
                      okHandler:{action in

                        self.submitAnswer()

            } , cancelHandler:{action in

            })
        }
        
        
    }
    
    func isAnswered(qid : String , quesionJson : JSON , initAnswer : Bool = true) {
        myConfirm(self, message: "本题未做完,是否进入下一题" , okHandler : { action in
            if initAnswer{
                let qcv = QuestionCollectionView()
                self.answerDic[qid] = qcv.getAnswerJson(json: quesionJson)
            }
            self.nextQeustion()
        })
    }
    
    func isSubmit(qid : String , quesionJson : JSON , initAnswer : Bool = true) {
        myConfirm(self, message: "本题未做完,是否提交试卷" , okHandler : { action in
            if initAnswer{
                let qcv = QuestionCollectionView()
                self.answerDic[qid] = qcv.getAnswerJson(json: quesionJson)
            }
            self.hiddenKeyBoard()
            self.submitAnswer()
        })
    }
    
    func nextQeustion(){
        //TODO 进入下一题的代码写这里
        self.questionIndex += 1
        //如果已是当前题型最后一题 则切换到下一题型
        if self.questionIndex >= self.currentType["questions"].arrayValue.count{
            self.self.switchQuestionType(isNext: true)
        }
        //获取当前题目
        let question = (self.currentType["questions"].arrayValue)[self.questionIndex]
        //重新初始化展示题目的collection
        self.initCollection()
        //展示考题
        self.questionView.jsonDataSource = question
        self.questionCollection.reloadData()
        //设置按钮
        self.btn_next.isEnabled = !self.isLastQuestion()
        self.btn_prev.isEnabled = !self.isFirstQuestion()
        if self.isLastQuestion() {
            self.btn_complete.isHidden = false
        }
    }
    
    //提交考试答案
    func submitAnswer(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        var answerList = [Dictionary<String, String>]()
        
        for (_,v) in answerDic{
            answerList.append(v)
        }
        
        var url = SERVER_PORT + "rest/exercises/commitPaper.do"
        
        if isTheoryExam {
            url = SERVER_PORT + "rest/exercises/theoryCommitPaper.do"
        }
        //print(exerciseId,taskId)
        //print(anwserList)
        
        myPostRequest(url,["commit_questions":answerList , "exercisesid": exerciseId , "taskid" : taskId, "passscore" :passscore, "request_source": "request_ios"] , timeoutInterval : 120).responseJSON(completionHandler: { resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch  resp.result{
            case .success(let result):
                let json = JSON(result)
                print(json)
                if json["code"].intValue == 1 {
                    self.resultView.isHidden = false
                    if self.marking == 1 {
                        var lbl = self.resultView.viewWithTag(30000) as! UILabel
                        lbl.isHidden = true
                        lbl = self.resultView.viewWithTag(30001) as! UILabel
                        lbl.isHidden = true
                        lbl = self.resultView.viewWithTag(20001) as! UILabel
                        lbl.text = "已提交成功，请等待老师阅卷"
                        let btn = self.resultView.viewWithTag(40002) as! UIButton
                        btn.isHidden = false
                    }else{
                        if json["ispass"].stringValue == "1"{
                            let imageView = self.resultView.viewWithTag(10001) as! UIImageView
                            imageView.image = UIImage(named: "通过了.png")
                            var lbl = self.resultView.viewWithTag(20001) as! UILabel
                            lbl.text = "恭喜你顺利通过抽考!"
                            lbl = self.resultView.viewWithTag(30001) as! UILabel
                            lbl.text = json["score"].stringValue
                            let btn = self.resultView.viewWithTag(40002) as! UIButton
                            btn.isHidden = false
                            if self.isSimulation{   //模拟考和抽考区分处理
                                //btn.setTitle("返回", for: .normal)
                            }

                        }else{
                            let imageView = self.resultView.viewWithTag(10001) as! UIImageView
                            imageView.image = UIImage(named: "没通过.png")
                            var lbl = self.resultView.viewWithTag(20001) as! UILabel
                            lbl.text = "考试不合格!"
                            lbl = self.resultView.viewWithTag(30001) as! UILabel
                            lbl.text = json["score"].stringValue
                            if self.isSimulation{   //模拟考和抽考区分处理
                                let btn = self.resultView.viewWithTag(40002) as! UIButton
                                btn.isHidden = false
                                //btn.setTitle("返回", for: .normal)
                            }else{
                                var btn = self.resultView.viewWithTag(40001) as! UIButton
                                btn.isHidden = false
                                btn = self.resultView.viewWithTag(40003) as! UIButton
                                btn.isHidden = false
                            }

                        }
                    }

                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }

            case .failure(let error):
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                debugPrint(error)
            }
        })
        
    }
    
    
    //目录
    @IBAction func btn_directory_inside(_ sender: UIButton) {
        let vc = getViewToStoryboard("directoryView") as! DirectoryController
        vc.directoryView.jsonDataSource = exercises
        vc.presentedController = self
        present(vc, animated: true, completion: nil)
    }
    
    //返回任务中心
    @IBAction func btn_toTaskCenter_inside(_ sender: UIButton) {
        
        //置顶tabBar显示任务中心
        let app = (UIApplication.shared.delegate) as! AppDelegate
        let tabBar = (app.window?.rootViewController) as! UITabBarController
        tabBar.selectedIndex = 0
        
        var root = presentingViewController
        while let parent = root?.presentingViewController{
            root = parent
        }
        root?.dismiss(animated: true, completion: nil)
    }
    
    //返回视频中心
    @IBAction func btn_toVideo_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    ///初始化展示题目的collection
    func initCollection(){
        //获取当前题目
        let question = (currentType["questions"].arrayValue)[questionIndex]
        
        if question["type"].stringValue == "0"{   //单选题
            questionView = RadioCollectionView()
        }else if question["type"].stringValue == "2"{     //多选题
            questionView = CheckboxCollectionView()
        }else if question["type"].stringValue == "3"{     //配伍题
            questionView = PeiwuCollectionView()
        }else if question["type"].stringValue == "4"{   //简答题
            questionView = ShortAnswerCollectionView()
        }else if question["type"].stringValue == "5"{   //填空题
            questionView = FITBCollectionView()
        }else if question["type"].stringValue == "6"{   //名词解释
            questionView = ShortAnswerCollectionView()
        }else if question["type"].stringValue == "8"{   //病例题
            questionView = RecordsCollectionView()
        }else if question["type"].stringValue == "9"{   //论述题
            questionView = ShortAnswerCollectionView()
        }else if question["type"].stringValue == "10"{
            questionView = RadioCollectionView()
        }
        
        
        questionView.myCollection = questionCollection
        questionView.parentView = self
        questionView.jsonDataSource = question
        questionView.cellTotal = getCellTotalForQuestion(json: question)
        
        questionCollection.delegate = questionView
        questionCollection.dataSource = questionView
        
    }
    
    
    ///根据题目计算collection需要显示几个cell
    func getCellTotalForQuestion(json : JSON) -> Int{
        
        if json["type"].stringValue == "0"{ //单选题
            return json["answers"].arrayValue.count + 1
        }else if json["type"].stringValue == "2"{ //多选题
            return json["answers"].arrayValue.count + 1
        }else if json["type"].stringValue == "3"{ //配伍题
            return json["sub_questions"].arrayValue.count + json["up_answers"].arrayValue.count
        }else if json["type"].stringValue == "4"{   //简答题
            return 2
        }else if json["type"].stringValue == "5"{   //填空题
            let answers = json["answervalue"].stringValue.split(separator: ",")
            return answers.count + 1
        }else if json["type"].stringValue == "6"{ //名词解释
            return 2
        }else if json["type"].stringValue == "8"{ //病例题
            var total = 1
            let subQ = json["sub_questions"].arrayValue
            
            for json in subQ {
                total += json["answers"].arrayValue.count
            }
            total += subQ.count
            return total
        }else if json["type"].stringValue == "9"{ //论述题
            return 2
        }else if json["type"].stringValue == "10"{
            return json["answers"].arrayValue.count + 1
        }
        
        return 0
    }
    
    ///切换题型
    func switchQuestionType(isNext : Bool){
        
        if isNext{
            typeIndex += 1
            //获取题型
            currentType = exercises[typeIndex]
            //初始化题目索引
            questionIndex = 0
        }else{
            typeIndex -= 1
            //获取题型
            currentType = exercises[typeIndex]
            //初始化题目索引
            questionIndex = currentType["questions"].arrayValue.count - 1
        }
        
        //初始化题型标题
        lbl_questionType.text = String(format: questionTypeTitle, arguments: [currentType["indexname"].stringValue,currentType["typename"].stringValue,currentType["count"].intValue,currentType["score"].intValue,currentType["count"].intValue * currentType["score"].intValue])
        promptSwap(currentType["typename"].stringValue)
        
        btn_prev.isEnabled = !isFirstQuestion()
        btn_next.isEnabled = !isLastQuestion()
        
    }
    
    ///切换提示信息的显示与隐藏
    func promptSwap(_ typeName : String){
        if typeName == "配伍题"{
            lbl_prompt.isHidden = false
        }else{
            lbl_prompt.isHidden = true
        }
    }
    
    ///判断当前是否第一题
    func isFirstQuestion() -> Bool{
        if typeIndex == 0 && questionIndex == 0 {
            return true
        }
        return false
    }
    
    ///判断当前是否最后一题
    func isLastQuestion() -> Bool{
        if (exercises.count - 1) == typeIndex{
            if (currentType["questions"].arrayValue.count - 1) == questionIndex{
                return true
            }
        }
        return false
    }
    
}
