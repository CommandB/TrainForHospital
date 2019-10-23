//
//  UIDevice.swift
//  TrainForStudents
//
//  Created by 陈海峰 on 2019/8/6.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import UIKit

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}
