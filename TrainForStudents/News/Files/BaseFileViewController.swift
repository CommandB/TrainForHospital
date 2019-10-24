//
//  BaseFileViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/10.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
class BaseFileViewController: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var data:JSON?
    var dataArray:[JSON] = [JSON]()
    
    var titleView = BaseFileTitleView()//title
    
    var subListView = FileSubView()//子目录
    
    var headView = FileDownHeadView()
    
    var scrollView = UIScrollView()
    var taskType = 1000
    
    var firstVC = FIleWordViewController()
    var secondVC = FIleWordViewController()
    var thirdVC = FIleWordViewController()
    var fourthVC = FIleWordViewController()
    var fifthVC = FIleWordViewController()

    var pageIndex = 0
    
    var titleStr = ""
    
    var cataloghierarchy = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initProperty()
        addSubViews()
        getPageData(pageIndex: 0)
    }
    
    func initProperty() {
        let image = UIImage(named: "返回")!.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(cancelAction))
        if let title =  data?["leanchannelname"].stringValue {
            self.title = title;
        }
        self.dataArray.append(data ?? JSON())
    }
    
    func addSubViews() {
        let height:CGFloat = UIDevice.current.iPhoneX ? 88 : 64

        self.view.addSubview(titleView)

        self.titleView.mas_makeConstraints { (make) in
            make?.width.equalTo()(self.view)
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view)?.offset()(height)
            make?.height.mas_equalTo()(30)
        }
        titleView.data = self.dataArray
        
        titleView.buttonClickCallBack1 = { (button) in
//            if self.dataArray.count > 1 {
                self.dataArray.removeLast()
                self.getPageData(pageIndex: 1)
//            }
        }
        
        
        if let title =  data?["leanchannelname"].stringValue {
            titleView.titleLabel.text = title;
        }
        
        self.view.addSubview(subListView)
        self.subListView.mas_makeConstraints { (make) in
            make?.width.equalTo()(self.view)
            make?.centerX.offset()(0)
            make?.top.equalTo()(self.titleView.mas_bottom)
        }
        subListView.buttonClickCallBack = { (subViewData) in
//            self.data = subViewData
            
            self.dataArray.append(subViewData)
            self.getPageData(pageIndex: 1)
        }
        
        self.view.addSubview(headView)
        headView.mas_makeConstraints { (make) in
            make?.height.equalTo()(50)
            make?.top.equalTo()(subListView.mas_bottom)
            make?.left.right().equalTo()(self.view)
        }
        headView.buttonClickCallBack = { (tag) in
            self.changeViewWithTag(type: tag)
        }
        
        self.view.addSubview(scrollView)
        scrollView.mas_makeConstraints { (make) in
            make?.top.equalTo()(headView.mas_bottom)
            make?.left.right().offset()(0)
            make?.bottom.offset()(0)
        }
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH*5, height: 0)
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
//            UITableView.appearance().estimatedRowHeight = 0;
//            UITableView.appearance().estimatedSectionHeaderHeight = 0;
//            UITableView.appearance().estimatedSectionFooterHeight = 0;
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }

        firstVC.view.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height)
        secondVC.view.frame = CGRect.init(x: SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        thirdVC.view.frame = CGRect.init(x: SCREEN_WIDTH*2, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        fourthVC.view.frame = CGRect.init(x: SCREEN_WIDTH*3, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)
        fifthVC.view.frame = CGRect.init(x: SCREEN_WIDTH*4, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-height-50)

        self.addChildViewController(firstVC)
        self.addChildViewController(secondVC)
        self.addChildViewController(thirdVC)
        self.addChildViewController(fourthVC)
        self.addChildViewController(fifthVC)
        firstVC.fileType = "WORD"
        secondVC.fileType = "EXCEL"
        thirdVC.fileType = "PDF"
        fourthVC.fileType = "PPT"
        fifthVC.fileType = "视频"
        self.scrollView.addSubview(firstVC.view)
        self.scrollView.addSubview(secondVC.view)
        self.scrollView.addSubview(thirdVC.view)
        self.scrollView.addSubview(fourthVC.view)
        self.scrollView.addSubview(fifthVC.view)

        firstVC.data = data
        secondVC.data = data
        thirdVC.data = data
        fourthVC.data = data
        fifthVC.data = data
    
    }
    
    //获取子目录
    func getPageData(pageIndex:NSInteger){
        guard let jsonData = self.dataArray.last else { return }
        let url = SERVER_PORT+"rest/app/queryLearnSubdirectories.do"
        myPostRequest(url, ["leanchannelid":jsonData["leanchannelid"].stringValue],  method: .post).responseString(completionHandler: {resp in
            
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    
                    if json["cataloghierarchy"].array == nil || json["cataloghierarchy"].arrayValue.count == 0 {
                        self.dataArray.removeLast()
                        return
                    }
                    if pageIndex != 0 {
//                        let text = self.titleView.titleLabel.text
//                        self.titleView.titleLabel.text = text! + jsonData["leanchannelname"].stringValue + ">"
//                        self.titleView.data = self.dataArray
//                        self.titleView.lastButton.isHidden = (self.dataArray.count<= 1)
//                        let firstJSON = self.dataArray.first!
//                        self.dataArray.removeAll()
//                        self.dataArray.append(firstJSON)
//                        self.dataArray.append(jsonData)
                    }
                    
                    
                    self.titleView.data = self.dataArray
                 self.subListView.data = json["cataloghierarchy"].arrayValue
                    
                    self.firstVC.data = self.dataArray.last
                    self.secondVC.data = self.dataArray.last
                    self.thirdVC.data = self.dataArray.last
                    self.fourthVC.data = self.dataArray.last
                    self.fifthVC.data = self.dataArray.last

                }else{
                    myAlert(self, message: json["msg"].stringValue)
                    print(json)
                }
                break
            case .failure(let error):
                self.dataArray.removeLast()
                myAlert(self, message: "查询考题类目异常!")
                print(error)
                break
            }
            //            self.deptCollection.reloadData()
        })
        
    }

    
    
    func changeViewWithTag(type:NSInteger) {
        self.scrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(type-1000), y:self.scrollView.contentOffset.y)
        if type == self.taskType {
            return
        }
        self.taskType = type
        self.refreshOrderList()
    }
    
    func refreshOrderList() {
        switch taskType {
        case 1000:
            self.firstVC.tableView.mj_header.beginRefreshing();
            break
        case 1001:
            self.secondVC.tableView.mj_header.beginRefreshing();
            break
        case 1002:
            self.thirdVC.tableView.mj_header.beginRefreshing()
            break
        case 1003:
            self.fourthVC.tableView.mj_header.beginRefreshing()
            break
        case 1004:
            self.fifthVC.tableView.mj_header.beginRefreshing()
            break
        default:
            break
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = NSInteger(scrollView.contentOffset.x/SCREEN_WIDTH)
        self.headView.endScrollViewWithIndex(index:index)
        if 1000+index == self.taskType {
            return
        }
        self.taskType = 1000+index
        self.refreshOrderList()
    }
    
    @objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func publishAction() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cataloghierarchy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.imageView?.image = UIImage(named: "subFiles")
            cell.imageView?.contentMode = .scaleAspectFill
            cell.textLabel?.text = self.cataloghierarchy[indexPath.row]["leanchannelname"].stringValue
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    lazy var tableView: UITableView = {
        let height:CGFloat = UIDevice.current.iPhoneX ? 88 : 64
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: height, width: SCREEN_WIDTH, height: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


class BaseFileTitleView: UIView {
    
    typealias funcBlock1 = (_ button : UIButton) -> ()
    var buttonClickCallBack1 : funcBlock1?
    
    var data:[JSON] = [JSON]() {//属性后面加一对大括号称为属性监听器
        //属性即将进行改变时监听
        willSet{
        }
        //属性已经改变时进行监听
        didSet{
            setupButtonView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        setupButtonView()
        setupConstraints()
    }
    
    //布局子控件
    func setupButtonView() {
        if self.data.count == 0 {
            return;
        }
        self.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        
        self.addSubview(lastButton)
        lastButton.frame = CGRect(x: 10, y: 0, width: 60, height: 30)
        if self.data.count <= 1 {
            lastButton.frame = CGRect(x: 10, y: 0, width: 0, height: 30)
        }
        
        var origin_x:CGFloat = lastButton.frame.maxX
        var origin_y:CGFloat = 0
        let buttonHeight:CGFloat = 34
//        let buttonWidth:CGFloat = (SCREEN_WIDTH-80)/3
        for (index, dic) in data.enumerated() {
            let buttonWidth:CGFloat = self.textSize(text: dic["leanchannelname"].stringValue, font: UIFont.systemFont(ofSize: 13), maxSize: CGSize(width: 240, height: CGFloat(MAXFLOAT))).width+20
            let button = createButtonWithTitle(title: dic["leanchannelname"].stringValue, index: index)
            self.addSubview(button)
            button.frame = CGRect(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            if button.frame.maxX > SCREEN_WIDTH {
                //处理换行
                origin_x = 20;
                origin_y = origin_y + buttonHeight + 20;
                
                button.frame = CGRect(x: origin_x, y: origin_y, width: buttonWidth, height: buttonHeight)
            }
            origin_x = button.frame.maxX;
            button.tag = 1000+index;
        }
        
        self.addSubview(bottomline)
        bottomline.frame = CGRect(x: 0, y: 29, width: SCREEN_WIDTH, height: 1)
        
        self.mas_updateConstraints { (make) in
            make?.height.mas_equalTo()(origin_y + buttonHeight)
        }
        
        self.setNeedsUpdateConstraints()
    }
    
    func setupConstraints() {
//        self.mas_updateConstraints { (make) in
//            make?.height.mas_equalTo()(0)
//        }
        self.setNeedsUpdateConstraints()
    }
    
    func createButtonWithTitle(title:String, index:NSInteger) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title+">", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
//        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        //        btn.tag = tag
        //        if tag == 1000 {
        //            btn.setTitleColor(UIColor.defaultColor(), for: .normal)
        //            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        //        }
        return btn
    }
    
    
    @objc func didClicklastButton() {
        if let callBack = buttonClickCallBack1  {
            callBack(self.lastButton)
        }
        
    }
    
    
    func textSize(text : String , font : UIFont , maxSize : CGSize) -> CGSize{
        return text.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : font], context: nil).size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var lastButton: UIButton = {
        let lastButton = UIButton()
        lastButton.setTitleColor(UIColor.defaultColor(), for: .normal)
        lastButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        lastButton.titleLabel!.textAlignment = .left
        lastButton.setTitle("上一级", for: .normal)
//        lastButton.isHidden = true
        lastButton.addTarget(self, action: #selector(didClicklastButton), for: .touchUpInside)
        return lastButton
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "--";
        titleLabel.textColor = .lightGray
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textAlignment = .left
        return titleLabel
    }()
    
    lazy var bottomline:UILabel = {
        let bottomline = UILabel()
        bottomline.backgroundColor = RGBCOLOR(r: 240, 240, 240)
        return bottomline
    }()

}

