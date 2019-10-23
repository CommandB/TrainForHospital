//
//  NewsBaseViewController.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/25.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit

class NewsBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "返回")!.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(cancelAction))
    }
    
    @objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
