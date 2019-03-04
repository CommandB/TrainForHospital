//
//  HSimplePickerViewImpl.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/3.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AudioToolbox

typealias didSelectorClorsure = (_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void
class HSimplePickerViewImpl :UIViewController, UIPickerViewDelegate , UIPickerViewDataSource{
    
    var clorsureImpl : didSelectorClorsure?
    var dataSource = [JSON]()
    var titleKey = ""
    
    func getDefaultPickerView( picker :UIPickerView? = nil) -> UIPickerView{
        var p = UIPickerView()
        if picker != nil{
            p = picker!
        }
        p.delegate = self
        p.dataSource = self
        return p
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row][titleKey].stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //1519
        //1520
        //1521
//        AudioServicesPlayAlertSound(1520)
        if clorsureImpl != nil{
            clorsureImpl!(dataSource,pickerView,row,component)
        }
        
    }
    
}
