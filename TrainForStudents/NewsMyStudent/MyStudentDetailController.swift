//
//  MyStudentDetailController.swift
//  TrainForStudents
//
//  Created by  李莉 on 2019/10/23.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit

class MyStudentDetailController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var myTableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        creatUI()
    }
    func creatUI(){
        myTableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.plain)
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

}
