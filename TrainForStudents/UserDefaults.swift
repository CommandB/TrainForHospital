
//
//  File.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/1/28.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
extension UserDefaults{
    
    // 登录信息
//    struct LoginInfo: UserDefaultsKeys {
//        enum defaultKeys: String {
//            case loginId
//            case password
//            case server_port
//            case portal_port
//            case cloud_port
//            case hospital
//            case token
//        }
//    }
    
    // 考试信息
    struct Exam: UserDefaultsKeys {
        enum defaultKeys: String {
            case answerDic
        }
    }
    
    // 当前登录用户信息
    struct User: UserDefaultsKeys {
        enum defaultKeys: String {
            case personId
            case jobNum
            case personName
            case majorName
            case highestDegree
            case phoneNo
        }
    }
    
}

protocol UserDefaultsKeys {
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaultsKeys where defaultKeys.RawValue == String {
    static func set(value: String?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    static func set(value: Any?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    static func string(forKey key: defaultKeys) -> String? {
        let aKey = key.rawValue
        return UserDefaults.standard.string(forKey: aKey)
    }
    
    static func any(forKey key: defaultKeys) -> Any? {
        let aKey = key.rawValue
        return UserDefaults.standard.object(forKey: aKey)
    }
}

