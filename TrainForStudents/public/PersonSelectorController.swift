//
//  PersonSelectorController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/24.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PersonSelectorController: HBaseViewController {
    
    static var addPersonDefaultNotificationName = NSNotification.Name(rawValue: "addPersonNotification")
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    @IBOutlet weak var btn_all: UIButton!
    
    @IBOutlet weak var btn_stu: UIButton!
    
    @IBOutlet weak var btn_teacher: UIButton!
    
    @IBOutlet weak var btn_nurse: UIButton!
    
    @IBOutlet weak var lbl_markLine: UILabel!
    
    var singleSelect = false
    
    var notificationName = ""
    
    //按钮的集合
    var buttonGroup = [UIButton]()
    
    ///collection DataSource
    var jds = [String : [JSON]]()
    ///排序后的key
    var sortedKeys = [String]()
    ///选中的人员数据
    var selectedList = [String:JSON]()
    ///已全选的section
    var sectionIsSelected = [IndexPath:Bool]()
    ///是否全选 (只控制是否选中)
    var isSelectedAll = false
    ///培训学员是否全选
    var isSelectedAllStu = false
    ///培训学员是否全选
    var isSelectedAllTeacer = false
    ///培训学员是否全选
    var isSelectedAllNurse = false
    
    ///当前查询的科室
    var officeId = 0
    
    /// 所有人员 {首字母:[A,B,C]}
    var allPersonDir = [String:[JSON]]()
    ///培训学员 {首字母:[A,B,C] 年级:[一,二,三] 人员类型[实习,见习]}
    var studentsDir = [String:[String:[JSON]]]()
    ///科室医生 {首字母:[A,B,C] 人员类型[带教老师,学术秘书,科主任,其他医生]}
    var teacherDir = [String:[String:[JSON]]]()
    ///护士 {首字母:[A,B,C] 人员类型[护士长,其他]}
    var nurseDir = [String:[String:[JSON]]]()
    
    var personTotal = 0
    let defaulSort = "position"
    ///选中的人员类型
    var selectedType = 0
    ///选中的筛选条件类型
    var selectedSort = "initials"
    var isFirstLoad = true
    
    static func presentPersonSelector(viewController :UIViewController , data : [JSON] , noticeName : String = "" , single : Bool = false){
        let vc = getViewToStoryboard("personSelectorView") as! PersonSelectorController
        var selectedPerson = [String:JSON]()
        if single{
            //如果是单选 则默认只接收传入的人员数组的第一个元素
            if data.count > 0 {
                selectedPerson[data[0]["personid"].stringValue] = data[0]
            }
        }else{
            for item in data{
                selectedPerson[item["personid"].stringValue] = item
            }
        }
        
        vc.selectedList = selectedPerson
        vc.notificationName = noticeName
        vc.singleSelect = single
        viewController.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        //tab的下划线及tab需要的一些设置
        lbl_markLine.clipsToBounds = true
        lbl_markLine.layer.cornerRadius = 1
        buttonGroup = [btn_all ,btn_stu ,btn_teacher ,btn_nurse]
        
        personCollection.delegate = self
        personCollection.dataSource = self
        personCollection.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        personCollection.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        let txt = view.viewWithTag(30002) as! UITextField
        txt.delegate = self
        
        personCollection.mj_header.beginRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveAdvanceSearch), name: PersonSelectorAdvanceSearchController.defaultNoticeName, object: nil)
        
    }
    
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_advanceSearch_inside(_ sender: UIButton) {
        myPresentView(self, viewName: "personSelectorAdvanceSearchView")
    }
    
    @IBAction func btn_sure_inside(_ sender: UIButton) {
        
        var data = [JSON]()
        for v in selectedList.values{
            data.append(v)
        }
        //print(data)
        var nName = PersonSelectorController.addPersonDefaultNotificationName
        if notificationName.count > 1{
            nName = Notification.Name(notificationName)
        }
        
        NotificationCenter.default.post(name: nName, object: nil, userInfo: ["data":data])
        
        dismiss(animated: true, completion: nil)
    }
    
    //全部  学员  医生  护士
    @IBAction func btn_side_inside(_ sender: UIButton) {
        hiddenKeyBoard()
        
        if sender.restorationIdentifier == "btn_all"{
            view.viewWithTag(30001)?.isHidden = false
            view.viewWithTag(30002)?.isHidden = false
            view.viewWithTag(40002)?.isHidden = true
        }else{
            view.viewWithTag(30001)?.isHidden = true
            view.viewWithTag(30002)?.isHidden = true
            view.viewWithTag(20003)?.isHidden = !(sender.restorationIdentifier == "btn_stu")
            //如果允许复原 才显示全选按钮
            if !singleSelect{
                view.viewWithTag(40002)?.isHidden = false
            }
            
        }
        
        switch sender.restorationIdentifier{
        case "btn_stu":
            changeSelectAllBtnStatus(status: isSelectedAll && isSelectedAllStu)
            break
        case "btn_teacher":
            changeSelectAllBtnStatus(status: isSelectedAll && isSelectedAllTeacer)
            break
        case "btn_nurse":
            changeSelectAllBtnStatus(status: isSelectedAll && isSelectedAllNurse)
            break
        default:
            break
        }
        
        
        if sender.tag - 10000 != selectedType{
            sectionIsSelected = [IndexPath : Bool]()
            selectedType = sender.tag - 10000
            selectedSort = defaulSort
            tabsTouchAnimation(sender: sender)
            btn_sortType_inside(view.viewWithTag(20002) as! UIButton)
        }
        
    }
    
    @IBAction func btn_sortType_inside(_ sender: UIButton) {
        selectedSort = sender.restorationIdentifier!
        
        var i = 0
        while (i < 3){
            let btn = view.viewWithTag(20001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
        
        jds = selectDataSource()
        
        personCollection.reloadData()
    }
    //全选按钮
    @IBAction func btn_selectAll_inside(_ sender: UIButton) {
        if isSelectedAll{
            //反选
            for key in jds.keys{
                for person in jds[key]!{
                    let id = person["personid"].stringValue
                    selectedList.removeValue(forKey: id)
                }
            }
            isSelectedAll = false
        }else{
            //全选
            for key in jds.keys{
                for person in jds[key]!{
                    let id = person["personid"].stringValue
                    selectedList[id] = person
                }
            }
            isSelectedAll = true
        }
        
        switch selectedType{
        case 2:
            isSelectedAllStu = isSelectedAll
            break
        case 3:
            isSelectedAllTeacer = isSelectedAll
            break
        case 4:
            isSelectedAllNurse = isSelectedAll
            break
        default:
            break
        }
        
        changeSelectAllBtnStatus(status: isSelectedAll)
        
        
        personCollection.reloadData()
    }
    
    @objc func receiveAdvanceSearch(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: PersonSelectorAdvanceSearchController.defaultNoticeName, object: nil)
        
        if notification.userInfo != nil{
            let data = (JSON)(notification.userInfo!["data"])
            if !data.isEmpty{
                resetAllStatus()
                getListData(data.dictionaryObject!)
            }
            
        }
    }
    
    ///修改全选按钮的状态
    func changeSelectAllBtnStatus(status : Bool){
        let sender = view.viewWithTag(40002) as! UIButton
        if status{
            //全选
            sender.setImage(UIImage(named: "选择-大"), for: .normal)
        }else{
            //反选
            sender.setImage(UIImage(named: "未选择-大"), for: .normal)
        }
    }
    
    func selectDataSource() -> [String : [JSON]]{
        
        //print("selectedType:\(selectedType)\nselectedSort:\(selectedSort)")
        personTotal = 0
        var result = [String : [JSON]]()
        switch selectedType {
        case 1:
            result =  allPersonDir
        case 2:
            result =  studentsDir[selectedSort]!
        case 3:
            result =  teacherDir[selectedSort]!
        case 4:
            result =  nurseDir[selectedSort]!
        default:
            break
        }
        
        for key in result.keys{
            personTotal += (result[key]?.count)!
        }
        let lbl = view.viewWithTag(40001) as! UILabel
        lbl.text = "共筛选出\(personTotal)人"
        return result
    }
    
    //下载数据
    func getListData(_ param : [String:Any] = [String:Any]() ){
        
        var submitParam = [String:Any]()
        if officeId == 0{
            officeId = UserDefaults.standard.integer(forKey: LoginInfo.officeId.rawValue)
        }
        if param.count == 0 {
            submitParam["officeid"] = officeId
        }else{
            submitParam["officeid"] = officeId
            submitParam.merge(param)
            
        }
        
        if submitParam["officeid"] as! Int == -1{
            submitParam.removeValue(forKey: "officeid")
        }
        
        print("查询参数=\(submitParam)")
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = SERVER_PORT + "/rest/app/searchPerson.do"
        myPostRequest(url,submitParam).responseString(completionHandler: {[weak self] resp in
            
            MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
            
            self?.personCollection.mj_header.endRefreshing()
            self?.personCollection.mj_footer.endRefreshing()

            switch resp.result{
            case .success(let responseJson):

                let json = JSON(parseJSON: responseJson)
                print(json)

                if json["code"].stringValue == "1"{
                    
                    self?.dataDecomposer(json: json["data"].arrayValue)
                    self?.btn_side_inside(self?.view.viewWithTag(10001) as! UIButton)
                    self?.personCollection.mj_footer.endRefreshingWithNoMoreData()
                }else{
                    myAlert(self!, message: "请求人员列表失败!")
                    print(json["msg"].stringValue)
                }
                
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
    
    ///分解数据下载的数据到各个分类
    func dataDecomposer(json : [JSON]){
        
        //全部
        allPersonDir = [String:[JSON]]()
        
        //学生
        var s_initialsList = [String:[JSON]]()
        var s_gradeList = [String:[JSON]]()
        var s_positionList = [String:[JSON]]()
        
        //老师
        var t_initialsList = [String:[JSON]]()
        var t_positionList = [String:[JSON]]()
        
        //护士
        var n_initialsList = [String:[JSON]]()
        var n_positionList = [String:[JSON]]()
        
        for person in json {
            
            let personType = person["persontype"].intValue
            
            //按首字母添加到"所有人"分类
            //首字母
            let firstpy = person["firstpy"].stringValue == "" ? findFirstLetterFromString(aString: person["personname"].stringValue) : person["firstpy"].stringValue
            if allPersonDir[firstpy] == nil{
                allPersonDir[firstpy] = [JSON]()
            }
            if person["ismystudent"].stringValue == "1"{
                if allPersonDir["我的学员"] == nil{
                    allPersonDir["我的学员"] = [JSON]()
                }
                allPersonDir["我的学员"]?.append(person)
            }else{
                allPersonDir[firstpy]?.append(person)
            }
            
            
            //先判断这个人的是不是学生
            if personType == 1{
                
                //首字母
                let key = person["firstpy"].stringValue
                if s_initialsList[key] == nil{
                    s_initialsList[key] = [JSON]()
                }
                s_initialsList[key]?.append(person)
                
                //年级
                let key2 = person["gradeyear"].stringValue
                if s_gradeList[key2] == nil{
                    s_gradeList[key2] = [JSON]()
                }
                s_gradeList[key2]?.append(person)
                
                //人员类型
                var key3 = person["studenttype"].stringValue
                switch key3 {
                    case "0":
                        key3 = "实习生"
                    case "1":
                        key3 = "见习生"
                    case "2":
                        key3 = "住院医师"
                    default:
                        key3 = "其他"
                        break
                }
                if s_positionList[key3] == nil{
                    s_positionList[key3] = [JSON]()
                }
                s_positionList[key3]?.append(person)
                

            }else if personType == 2{//判断这个人是不是老师
                //首字母
                let key = person["firstpy"].stringValue
                if t_initialsList[key] == nil{
                    t_initialsList[key] = [JSON]()
                }
                t_initialsList[key]?.append(person)
                
                //人员类型
                var key3 = person["isdirector"].stringValue
                if key3 == "1"{
                    if t_positionList["科主任"] == nil{
                        t_positionList["科主任"] = [JSON]()
                    }
                    t_positionList["科主任"]?.append(person)
                }
                
                
                key3 = person["issecretary"].stringValue
                if key3 == "1"{
                    if t_positionList["学术秘书"] == nil{
                        t_positionList["学术秘书"] = [JSON]()
                    }
                    t_positionList["学术秘书"]?.append(person)
                }
                
                key3 = person["isteacher"].stringValue
                if key3 == "1"{
                    if t_positionList["带教老师"] == nil{
                        t_positionList["带教老师"] = [JSON]()
                    }
                    t_positionList["带教老师"]?.append(person)
                }
                
            }else if personType == 3 {  //判断这个人是不是护士
                //首字母
                let key = person["firstpy"].stringValue
                if n_initialsList[key] == nil{
                    n_initialsList[key] = [JSON]()
                }
                n_initialsList[key]?.append(person)
                
                //人员类型
                let isHeadNurse = person["isheadnurse"].stringValue
                if isHeadNurse == "1"{
                    if n_positionList["护士长"] == nil{
                        n_positionList["护士长"] = [JSON]()
                    }
                    n_positionList["护士长"]?.append(person)
                }else{
                    if n_positionList["护士"] == nil{
                        n_positionList["护士"] = [JSON]()
                    }
                    n_positionList["护士"]?.append(person)
                }
                
            }else{
                //TODO
            }
            
        }

            allPersonDir = sort(original: allPersonDir)
            studentsDir["initials"] = sort(original: s_initialsList)
            studentsDir["position"] = sort(original: s_positionList, sortKey: "gradeyear")
            studentsDir["grade"] = sort(original: s_gradeList, sortKey: "studenttype")

            teacherDir["initials"] = sort(original: t_initialsList)
            teacherDir["position"] = sort(original: t_positionList)

            nurseDir["initials"] = sort(original: n_initialsList)
            nurseDir["position"] = sort(original: n_positionList)
        
    }
    
    ///给各个分组排序
    func sort( original : [String:[JSON]] , sortKey : String? = nil) -> [String:[JSON]]{
        var result = [String:[JSON]]()
        let keys = original.keys.sorted()
        
        for key in keys{
            
            result[key] = original[key]
            var sortedList = [JSON]()
            if sortKey != nil{
                sortedList = (original[key]?.sorted(by: { (j1, j2) -> Bool in
                    return j1[sortKey!].stringValue.compare(j2[sortKey!].stringValue) == .orderedDescending
                }))!
                result[key]  = sortedList
            }
            
        }
        return result
        
    }
    
    //获取拼音首字母（大写字母）
    func findFirstLetterFromString(aString: String) -> String {
        //转变成可变字符串
        let mutableString = NSMutableString.init(string: aString)
        
        //将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil,      kCFStringTransformToLatin, false)
        
        //去掉声调
        let pinyinString = mutableString.folding(options:          String.CompareOptions.diacriticInsensitive, locale:   NSLocale.current)
        
        //将拼音首字母换成大写
        let strPinYin = polyphoneStringHandle(nameString: aString,    pinyinString: pinyinString).uppercased()
        
        //截取大写首字母
        let firstString = strPinYin.substring(to:     strPinYin.index(strPinYin.startIndex, offsetBy: 1))
        
        //判断首字母是否为大写
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? firstString : "#"
    }
    
    func polyphoneStringHandle(nameString: String, pinyinString: String) -> String {
        if nameString.hasPrefix("长") {return "chang"}
        if nameString.hasPrefix("沈") {return "shen"}
        if nameString.hasPrefix("厦") {return "xia"}
        if nameString.hasPrefix("地") {return "di"}
        if nameString.hasPrefix("重") {return "chong"}
        return pinyinString
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
        
        UIView.setAnimationCurve(.easeOut)
        UIView.commitAnimations()
        
    }
    
    @objc func refresh() {
        resetAllStatus()
        getListData()
    }
    
    @objc func loadMore() {
        getListData()
    }
    
    ///重置当前页面所有状态
    func resetAllStatus(){
        //print("刷新数据....")
        ///排序后的key
        sortedKeys = [String]()
        
        //如果是界面第一次打开 则不清空已选择人员 防止把上一个界面传过来的已选给清除了
        if isFirstLoad{
            isFirstLoad = false
        }else{
            //选中的人员数据
            selectedList = [String:JSON]()
        }
        
        //已全选的section
        sectionIsSelected = [IndexPath:Bool]()
        
        //
        selectedType = 0
        ///选中的筛选条件类型
        selectedSort = "initials"
        
        jds.removeAll()
        
        //重置所有全选按钮的状态
        isSelectedAll = false
        isSelectedAllStu = false
        isSelectedAllTeacer = false
        isSelectedAllNurse = false
        
        (view.viewWithTag(40002) as! UIButton).setImage(UIImage(named: "未选择-大"), for: .normal)
    }
    
}


extension PersonSelectorController : UICollectionViewDelegate ,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        //对key进行排序
        if selectedType == 1{
            let key = "我的学员"
            sortedKeys = jds.keys.sorted()
            if jds.keys.contains(key){
                let array = jds.removeValue(forKey: key)
                sortedKeys.insert(key, at: 0)
                jds[key] = array
            }
            
        }else{
            sortedKeys = jds.keys.sorted()
        }
        //print("section:\(jds.count)")
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let key = sortedKeys[section]
        //print("items:\(jds[key]!.count + 1)")
        return jds[key]!.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let key = sortedKeys[indexPath.section]
        var cellName = "c1"
        if indexPath.item >= 1{
            cellName = "c2"
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
        if cellName == "c1"{
            let lbl = cell.viewWithTag(10001) as! UILabel
            lbl.text = key
            let btn = cell.viewWithTag(10002) as! UIButton
            //单选 则隐藏分组的全选按钮
            if singleSelect{
                btn.isHidden = true
            }
            btn.viewParam = [String:Any]()
            btn.viewParam!["key"] = key
            btn.viewParam!["index"] = indexPath
            btn.addTarget(self, action: #selector(chooseThisSection), for: .touchUpInside)
            if sectionIsSelected[indexPath] ?? false {
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
        }else{
            let data = jds[key]![indexPath.item - 1]
            let personId = data["personid"].stringValue
            
            var lbl = cell.viewWithTag(10001) as! UILabel
            lbl.text = data["personname"].stringValue
            
            lbl = cell.viewWithTag(10002) as! UILabel
            if selectedType == 2{
                if selectedSort == "position"{
                    lbl.text = "【\(data["officename"].stringValue) - \(data["gradeyear"].stringValue)】"
                }else if selectedSort == "grade"{
                    
                    var key3 = data["studenttype"].stringValue
                    switch key3 {
                    case "0":
                        key3 = "实习生"
                    case "1":
                        key3 = "见习生"
                    case "2":
                        key3 = "住院医师"
                    default:
                        key3 = "其他"
                        break
                    }
                    
                    lbl.text = "【\(data["majorname"].stringValue) - \(key3)】"
                }else{
                    lbl.text = "【\(data["majorname"].stringValue)】"
                }
            }else{
                lbl.text = "【\(data["officename"].stringValue)】"
            }
            
            let btn = cell.viewWithTag(10003) as! UIButton
            if selectedList.keys.contains(personId) {
                btn.setImage(UIImage(named: "选择-小"), for: .normal)
            }else{
                btn.setImage(UIImage(named: "未选择-小"), for: .normal)
            }

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.hiddenKeyBoard()
        
        if indexPath.item == 0 || sortedKeys.count == 0{
            return
        }
        
        //如果是单选 则每次选择前 清空所有已选对象
        if singleSelect{
            selectedList = [String:JSON]()
        }
        
        let key = sortedKeys[indexPath.section]
        
        let data = jds[key]![indexPath.item - 1]
        let personId = data["personid"].stringValue
        
        if selectedList.keys.contains(personId) {
            selectedList.removeValue(forKey: personId)
        }else{
            selectedList[personId] = data
        }
        //cellIsSelected[indexPath] = !(cellIsSelected[indexPath] ?? false)
        //print("选中了..需要刷新...")
        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.width, height: 40)
    }
    
    //某分组 全选
    @objc func chooseThisSection(sender : UIButton){
        
        let key = sender.viewParam!["key"] as! String
        let indexPath = sender.viewParam!["index"] as! IndexPath
        if sectionIsSelected[indexPath] ?? false{
            sectionIsSelected.removeValue(forKey: indexPath)
            for person in jds[key]!{
                selectedList.removeValue(forKey: person["personid"].stringValue)
            }
        }else{
            for person in jds[key]!{
                selectedList[person["personid"].stringValue] = person
            }
            sectionIsSelected[indexPath] = true
        }
        
        personCollection.reloadData()
        
    }
    
}

extension PersonSelectorController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        MBProgressHUD.showAdded(to: view, animated: true)
        var cds = [String : [JSON]]()
        let str = textField.text
        if str == nil || str == ""{
            cds = allPersonDir
        }else{
            for key in allPersonDir.keys{
                
                var arr = [JSON]()
                for person in allPersonDir[key]!{
                    
                    if person["personname"].stringValue.range(of: str!) != nil {
                        arr.append(person)
                    }
                }
                if arr.count > 0 {
                    cds[key] = arr
                }
                
            }
        }
        
        jds = cds
        let lbl = view.viewWithTag(40001) as! UILabel
        lbl.text = "共筛选出\(jds.count)人"
        personCollection.reloadData()
        MBProgressHUD.hideAllHUDs(for: view, animated: true)
        return true
    }
    
}
