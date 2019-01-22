//
//  Dictionary.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2019/1/22.
//  Copyright © 2019 黄玮晟. All rights reserved.
//

import Foundation


extension Dictionary {
    mutating func merge<S:Sequence>(_ sequence: S) where S.Iterator.Element == (key: Key, value: Value) {
        sequence.forEach {
            self[$0] = $1
        }
    }
}
