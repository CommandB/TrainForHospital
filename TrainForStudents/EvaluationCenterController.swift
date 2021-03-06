//
//  EvaluationCenterController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/26.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import GTMRefresh

class EvaluationCenterController : MyBaseUIViewController , UIScrollViewDelegate{
    
    
    @IBOutlet weak var examCollection: UICollectionView!
    
    @IBOutlet weak var evaluationCollection: UICollectionView!
    
    @IBOutlet weak var questionnaireCollection: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    

    @IBOutlet weak var btn_1: UIButton!
    @IBOutlet weak var btn_2: UIButton!
    @IBOutlet weak var btn_3: UIButton!
    
    @IBOutlet weak var btn_btnList: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var lbl_markLine: UILabel!
    
    @IBOutlet weak var btn_exam: UIButton!
    
    @IBOutlet weak var btn_evaluation: UIButton!
    
    @IBOutlet weak var btn_questionnaire: UIButton!
    
    
    let examView = WaitExamTaskCollectionView()
    let evaluationView = WaitEvanluationTaskCollectionView()
    let questionnaireView = QuestionnaireCollectionView()
    
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    var panStartX = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barView = view.viewWithTag(11111)
        let titleView = view.viewWithTag(22222)
        let bg = view.viewWithTag(33333)
        //圆角
        bg?.layer.cornerRadius = 4
        bg?.clipsToBounds = true
        let bg2 = view.viewWithTag(44444)
        //阴影
//        bg2?.layer.shadowColor = UIColor(hex: "d2d9e1").cgColor
//        bg2?.backgroundColor = UIColor.clear
        bg2?.layer.shadowColor = UIColor.black.cgColor
        bg2?.layer.shadowRadius = 4
        bg2?.layer.shadowOffset = CGSize(width: 0, height: 0)
        bg2?.layer.shadowOpacity = 0.2
        
        
        
        
        super.setNavigationBarColor(views: [barView,titleView], titleIndex: 1,titleText: "考评中心")
        
        //待考collection
        examView.parentView = self
        examCollection.delegate = examView
        examCollection.dataSource = examView
        examCollection.gtm_addRefreshHeaderView(refreshBlock: {
            self.examView.refresh()
        })
        examCollection.gtm_addLoadMoreFooterView(loadMoreBlock: {
            self.examView.loadMore()
        })
        examCollection.registerNoDataCellView()
        
        //待评collection
        evaluationView.parentView = self
        evaluationCollection.delegate = evaluationView
        evaluationCollection.dataSource = evaluationView
        
        self.evaluationCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: evaluationView, refreshingAction: #selector(evaluationView.refresh))
        self.evaluationCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: evaluationView, refreshingAction: #selector(evaluationView.loadMore))

        evaluationCollection.registerNoDataCellView()
        evaluationCollection.frame.origin = CGPoint(x: UIScreen.width, y: evaluationCollection.frame.origin.y)
        
        //问卷
        questionnaireView.parentView = self
        questionnaireCollection.delegate = questionnaireView
        questionnaireCollection.dataSource = questionnaireView
        questionnaireCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: questionnaireView, refreshingAction: #selector(questionnaireView.refresh))
        questionnaireCollection.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: questionnaireView, refreshingAction: #selector(questionnaireView.loadMore))
        
        questionnaireCollection.frame.origin = CGPoint(x: UIScreen.width * 2, y: evaluationCollection.frame.origin.y)
        
        //上部3个按钮
        btn_1.layer.cornerRadius = btn_1.frame.width / 2
        btn_2.layer.cornerRadius = btn_1.frame.width / 2
        btn_3.layer.cornerRadius = btn_1.frame.width / 2
        
        //用作待考,待评,问卷左右滑动的容器
        scrollView.contentSize = CGSize(width: UIScreen.width * 3, height: scrollView.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        
        //tab的下划线及tab需要的一些设置
        lbl_markLine.clipsToBounds = true
        lbl_markLine.layer.cornerRadius = 1
        buttonGroup = [btn_exam , btn_evaluation,btn_questionnaire]
        btn_exam.restorationIdentifier = "btn_exam"
        
        examView.initLimitPage()
        
        getExamDatasource()
        getEvaluationDatasource()
        //提交调查问卷成功
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionnaireCommitSuccess), name: NSNotification.Name(rawValue: "QuestionnaireCommitSuccess"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        selectedTabBarIndex = 3
        
        super.viewWillAppear(true)
        buttonView.isHidden = true
        btn_btnList.tag = 0
        
        evaluationCollection.mj_header.beginRefreshing()
        questionnaireCollection.mj_header.beginRefreshing()
        
    }
    
    //右上角 + 按钮
    @IBAction func btn_btnList_inside(_ sender: UIButton) {
        if sender.tag == 0 {
            buttonView.isHidden = false
            sender.tag = 1
        }else{
            buttonView.isHidden = true
            sender.tag = 0
        }
    }
    
    //历史考试
    @IBAction func btn_historyExam_inside(_ sender: UIButton) {
        myPresentView(self, viewName: "historyExamView")
    }
    
    //历史评价
    @IBAction func btn_historyEvaludation_inside(_ sender: UIButton) {
        myPresentView(self, viewName: "historyEvaluationView")
    }
    //历史问卷
    @IBAction func btn_historyQuestionnaire_inside(_ sender: UIButton) {
        //myPresentView(self, viewName: "historyEvaluationView")
    }
    
    //待考任务 待评任务 调查问卷 按钮
    @IBAction func btn_undone_inside(_ sender: UIButton) {
        buttonView.isHidden = true
        btn_btnList.tag = 0
        tabsTouchAnimation(sender: sender)
    }
    
    //待评任务 按钮
//    @IBAction func btn_over_inside(_ sender: UIButton) {
//        buttonView.isHidden = true
//        btn_btnList.tag = 0
//        tabsTouchAnimation(sender: sender)
//    }
    
    
    @IBAction func btn_123_inside(_ sender: UIButton) {

        //let vc = getViewToStoryboard("mockExamCeneterView") as! MockExamCenterController
        switch sender.tag {
        case 10001:
//            vc.titleBarText = "出科模拟考试"
            getExerises(3)
            break
        case 10002:
//            vc.titleBarText = "年度模拟考试"
            getExerises(5)
            break
        case 10003:
//            vc.titleBarText = "结业模拟考试"
            getExerises(4)
            break
        default:
            myAlert(self, message: "系统异常!")
        }
//        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func startExamAction(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = self.examCollection.indexPath(for: cell)
        let exercisesid = self.examView.jsonDataSource[(indexPath?.row)!]["exercisesid"].stringValue
        let taskid = self.examView.jsonDataSource[(indexPath?.row)!]["taskid"].stringValue
        
        let vc = getViewToStoryboard("examView") as! ExamViewController
        let url = SERVER_PORT + "rest/questions/queryExercisesQuestions.do"
        //        let url = "http://120.77.181.22:8080/cloud_doctor_train/rest/questions/queryExercisesQuestions.do"
        myPostRequest(url,["exercisesid" : exercisesid,"taskid":taskid]).responseJSON(completionHandler: { resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch  resp.result{
            case .success(let result):
                let json = JSON(result)
                if json["code"].intValue == 1 {
                    vc.exercises = json["data"].arrayValue
                    vc.exerciseId = exercisesid
                    vc.taskId = self.examView.jsonDataSource[(indexPath?.row)!]["taskid"].stringValue
                    vc.passscore = self.examView.jsonDataSource[(indexPath?.row)!]["passscore"].stringValue
                    vc.marking = self.examView.jsonDataSource[(indexPath?.row)!]["marking"].intValue
                    
                    vc.isSimulation = true
                    vc.isTheoryExam = true
                    self.present(vc, animated: true, completion: nil)
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = scrollView.contentOffset.x
        if x < UIScreen.width / 2{
//            print("滑动到待考")
            tabsTouchAnimation(sender: btn_exam)
        }else if x > UIScreen.width / 2 && x < UIScreen.width + UIScreen.width / 2{
//            print("滑动到待评")
            tabsTouchAnimation(sender: btn_evaluation)
        }else{
            tabsTouchAnimation(sender: btn_questionnaire)
        }
//        print(x)
//        print("只是松手")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        print("触发了减速")
        let x = scrollView.contentOffset.x
        if x < UIScreen.width / 2{
            tabsTouchAnimation(sender: btn_exam)
        }else if x > UIScreen.width / 2 && x < UIScreen.width + UIScreen.width / 2{
            tabsTouchAnimation(sender: btn_evaluation)
        }else{
            tabsTouchAnimation(sender: btn_questionnaire)
        }
    }
    
    
    
    //获取待考任务
    func getExamDatasource(){
        
        if examView.isLastPage{
            examCollection.endLoadMore(isNoMoreData:true)
            return
        }
        
        let url = SERVER_PORT+"rest/taskexam/query.do"
        myPostRequest(url,["pageindex": examView.pageIndex * pageSize , "pagesize":pageSize]).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    let arrayData = json["data"].arrayValue
                    //判断是否在最后一页
                    if arrayData.count < self.pageSize{
                        self.examView.isLastPage = true
                    }
                    
                    self.examView.jsonDataSource += json["data"].arrayValue
                    //修改上拉刷新和下拉加载的状态
                    self.examCollection.endRefreshing(isSuccess: true)
                    self.examCollection.endLoadMore(isNoMoreData: self.examView.isLastPage)
                    
                    self.examCollection.reloadData()
                }else{
                    self.examCollection.endRefreshing(isSuccess: false)
                    myAlert(self, message: "请求待考任务列表失败!")
                }
                self.examView.pageIndex += 1    //页码增加
                
            case .failure(let error):
                self.examCollection.endRefreshing(isSuccess: false)
                print(error)
            }
            
        })
        
    }
    
    //获取待评任务
    func getEvaluationDatasource(){
        print("获取待评数据...")
        let url = SERVER_PORT+"rest/taskEvaluation/query.do"
        myPostRequest(url,["pageindex": evaluationView.jsonDataSource.count, "pagesize":pageSize]).responseJSON(completionHandler: {resp in
            
            self.evaluationCollection.mj_header.endRefreshing()
            self.evaluationCollection.mj_footer.endRefreshing()
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    
                    let arrayData = json["data"].arrayValue
                    //判断是否在最后一页
                    if arrayData.count < self.pageSize{
                        self.evaluationCollection.mj_footer.endRefreshingWithNoMoreData()
                    }
                    
                    self.evaluationView.jsonDataSource += json["data"].arrayValue
                    
                    self.evaluationCollection.reloadData()
                }else{
                    myAlert(self, message: "请求待评任务列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    //获取问卷调查
    func getQuestionnaireDatasource(){
        
        let url = SERVER_PORT+"rest/questionnaire/queryAllQuestionnaire.do"
        myPostRequest(url,["personid":UserDefaults.standard.string(forKey: LoginInfo.personId.rawValue)!]).responseJSON(completionHandler: {resp in
            self.questionnaireCollection.mj_header.endRefreshing()
            self.questionnaireCollection.mj_footer.endRefreshingWithNoMoreData()
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    self.questionnaireView.jsonDataSource = json["data"].arrayValue
                    self.questionnaireCollection.reloadData()
                }else{
                    myAlert(self, message: "请求调查问卷列表失败!")
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
    }
    
    func tabsTouchAnimation( sender : UIButton){
        //-----------------计算 "下标线"label的动画参数
        
        for b in buttonGroup {
            if b == sender{
                b.setTitleColor(UIColor(hex:"407BD8"), for: .normal)
            }else{
                b.setTitleColor(UIColor.init(hex: "3B454F"), for: .normal);
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
        //滑动效果
        //        if sender.restorationIdentifier == "btn_over"{
        //            undoneCollection.frame = CGRect(origin: undoneCollection.frame.origin , size: CGSize(width: 0, height: undoneCollection.frame.size.height))
        //        }else{
        //            undoneCollection.frame = CGRect(origin: undoneCollection.frame.origin , size: CGSize(width: UIScreen.width, height: undoneCollection.frame.size.height))
        //        }
        //滚动效果
        if sender.restorationIdentifier == "btn_exam"{
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }else if sender.restorationIdentifier == "btn_over"{
            scrollView.setContentOffset(CGPoint(x: UIScreen.width, y: 0), animated: true)
        }else if sender.restorationIdentifier == "btn_questionnaire"{
            scrollView.setContentOffset(CGPoint(x: UIScreen.width * 2, y: 0), animated: true)
        }
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
        //print("btn_x = \(btn_x)")
        //print("lbl_markLine.frame = \(lbl_markLine.frame)")
    }
    
    func getExerises(_ type : Int){
        MBProgressHUD.showAdded(to: view, animated: true)
        let vc = getViewToStoryboard("examView") as! ExamViewController
        let url = SERVER_PORT + "rest/questions/queryExercisesQuestions.do"
//        let url = "http://120.77.181.22:8080/cloud_doctor_train/rest/questions/queryExercisesQuestions.do"
        myPostRequest(url,["exercisestype" : type]).responseJSON(completionHandler: { resp in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch  resp.result{
            case .success(let result):
                let json = JSON(result)
                if json["code"].intValue == 1 {
                    vc.exercises = json["data"].arrayValue
                    vc.exerciseId = json["exercisesid"].stringValue
                    vc.isSimulation = true
                    vc.isTheoryExam = false
                    self.present(vc, animated: true, completion: nil)
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    //提交调查问卷成功
    @objc func QuestionnaireCommitSuccess() {
        self.questionnaireView.jsonDataSource.removeAll()
        getQuestionnaireDatasource()
    }
    
    
}
