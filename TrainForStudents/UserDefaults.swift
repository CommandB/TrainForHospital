
//
//  File.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/1/28.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import SwiftyJSON

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
            case sex
            case officeName
            case personcenterofficename
        }
    }
    
    // App配置
    struct AppConfig: UserDefaultsKeys {
        enum defaultKeys: String {
            ///投诉功能名称
            case complaintTitle
            ///延迟签到分钟数
            case lateCheckInMinutes
            ///延迟签出分钟数
            case lateCheckOutMinutes
            ///教学计划未提报通知日期
            case planNoticeDate
            ///教学计划未提报通知时间
            case planNoticeTime
            ///是否秘书
            case isSecretary
            ///是否学生
            case isStudent
            ///是否老师
            case isTeacher
            ///教学活动默认评价目录
            case teachingActivityDefaultEvaluationList
            ///通用评价目录编码
            case publicEvaluationList
            ///培训是否默认签到
            case trainingIsNeedCheckIn
            ///观摩室观看的考站的编码
            case watchClassroomId
            ///签到机扫码拍照
            case checkInMachineTakePhoto
            ///客户代码
            case clientCode
            ///扫码签到是否需要拍照
            case scanCheckInTakePhoto
            ///二维码失效时间
            case qrCodeInvalidTime
            ///发布培训通知延时分钟数
            case trainingDelayNoticeMinutes
            ///带教老师是否允许发科室公告
            case teacherAllowCreateDeptNotice
            /// web模块配置
            case webModule
            ///教学活动学员评价老师默认评价表
            case teachingActivityS2TEvaluationList
            ///教学活动老师评价学员默认评价表
            case teachingActivityT2SEvaluationList
            ///评价表清单
            case teachingActivityEvaluationList
            ///教学活动类型
            case teachingActivityType
            ///科室清单
            case officeList
            //是否开启Mini-CEX
            case isOpenMiniCex
            ///教室清单
            case classroomList
            ///专业基地清单
            case majorList
            ///职称清单
            case professionalList
            ///学历清单
            case highestdegreeList
            ///年级清单
            case gradeList
            ///届别清单
            case gradeYearList
            ///学员类型清单
            case studentTypeList
            ///人员分组清单
            case personGroupList
            ///使用新版本app
            case isUseNewApp
            //360评价是否使用
            case panoramicEvaluationAvailable
            //出科理论是否使用
            case subjectTheoryAvailable
            //出科技能是否使用
            case subjectSkillAvailable
            //标签清单
            case tagList
            //入科是否需要指定责任护士
            case selectNurseOfJoinOffice
            //浙二视频转发IPIP
            case zeyyVideoIP
            
            
            
            ///我自己添加的 不是初始化时候下载的
            ///出科考试试卷
            case subjectExamPaper
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
    
    static func json(forKey key: defaultKeys) -> JSON {
        let aKey = key.rawValue
        let str = UserDefaults.standard.string(forKey: aKey)
        if str == nil{
            return JSON()
        }
        var resultJson = JSON(str!)
        if resultJson.isEmpty{
            resultJson = JSON(parseJSON: str!)
        }
        
        return resultJson
    }
    
    static func any(forKey key: defaultKeys) -> Any? {
        let aKey = key.rawValue
        return UserDefaults.standard.object(forKey: aKey)
    }
}

