//
//  HUIScrollView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/21.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class HUIScrollView : UIScrollView{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
        //superview?.endEditing(true)
    }
}
