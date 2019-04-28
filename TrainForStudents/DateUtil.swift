//
//  DateUtil.swift
//  SRM
//
//  Created by 黄玮晟 on 16/7/14.
//  Copyright © 2016年 黄玮晟. All rights reserved.
//

import Foundation
import SwiftDate

class DateUtil{

    static let dayToSecond = 86400
    static let hourToSecond = 3600
    static let minuteToSecond = 60
    //默认日期格式化参数
    ///yyyy-MM
    static let monthOfYearPattern = "yyyy-MM"
    ///yyyy-MM-dd
    static let datePattern = "yyyy-MM-dd"
    ///yyyy-MM-dd HH:mm:ss
    static let dateTimePattern="yyyy-MM-dd HH:mm:ss"
    ///yyyy-MM-dd HH:mm:ss.s
    static let dateTimeSecondPattern="yyyy-MM-dd HH:mm:ss.s"
    
    ///自定义pattern
    static func formatString(_ dateStr:String,pattern:String) ->Date{
//        let regin = DateInRegion()
//        regin.formatters.dateFormatter().locale = Locale.current
//        let r = Region.GMT()
        
//        return dateStr.date(format: DateFormat.custom(pattern) , fromRegion: r)!.absoluteDate
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter.date(from: dateStr)!
    }
    
    ///格式化符合yyyy-MM-dd格式的字符串
    static func stringToDate(_ dateStr:String) -> Date{
        return formatString(dateStr, pattern: datePattern)
    }
    
    ///格式化符合yyyy-MM-dd HH:mm:ss格式的字符串
    static func stringToDateTime(_ dateTimeStr:String) -> Date{
        return formatString(dateTimeStr, pattern: dateTimePattern)
    }
    
    static func formatDate(_ date:Date,pattern:String) -> String {
        return date.string(format: DateFormat.custom(pattern))
    }
    
    ///格式化日期 精确到分钟
    static func stringToDateToMinute(_ dateStr : String) -> String{
        return DateUtil.formatDate(DateUtil.stringToDateTime(dateStr), pattern: "yyyy-MM-dd HH:mm")
    }
    
    static func dateToString(_ date:Date) -> String {
        return formatDate(date, pattern: datePattern)
    }
    
    static func dateTimeToString(_ date:Date) -> String{
        return formatDate(date, pattern: dateTimePattern)
    }
    
    static func dateMonthOfYearToString(_ date:Date) -> String{
        return formatDate(date, pattern: monthOfYearPattern)
    }
    
    ///获取字符串格式的当前日期
    static func getCurrentDate() -> String{
        return dateToString(Date())
    }
    
    ///获取字符串格式的当前日期时间
    static func getCurrentDateTime() -> String{
        return dateTimeToString(Date())
    }

    ///计算两个日前相隔的"日,时,分"
    static func intervalDate(_ from:String ,to:String , pattern:String ) ->(day:Int,hour:Int,minute:Int) {

        //返回值
        var result=(day:0,hour:0,minute:0);
        //把参数赋值给成员变量
        
        var fromDate = formatString(from, pattern: pattern)
        let toDate = formatString(to, pattern: pattern)
        //初始化calendar
        let calendar=Calendar(identifier:Calendar.Identifier.gregorian)

        //计算相隔天数
        let intervalDay=(calendar as NSCalendar?)?.components(NSCalendar.Unit.day, from: fromDate, to: toDate, options: NSCalendar.Options(rawValue:0))
        //把天数增加 以便计算小时
        fromDate=fromDate+(intervalDay?.day?.day)!


        //计算除天数外的小时数数
        let intervalHour=(calendar as NSCalendar?)?.components(NSCalendar.Unit.hour, from: fromDate, to: toDate, options: NSCalendar.Options(rawValue:0))
        //把分钟数增加 以便计算分钟数
        fromDate=fromDate+(intervalHour?.hour?.hour)!


        //计算出天数外的分钟数
        let intervalMinute=(calendar as NSCalendar?)?.components(NSCalendar.Unit.minute, from: fromDate, to: toDate, options: NSCalendar.Options(rawValue:0))

        result=(day:(intervalDay?.day)!,hour:(intervalHour?.hour)!,minute:(intervalMinute?.minute)!);

        return result

    }
    
    
    ///获取某月份中所有的天数
    static func getAlldayOfMonth(_ date : Date) -> [Date]{
        var dayOfMonth = [Date]()
        let startDate = date.startOf(component: .month)
        let startDay = date.startOf(component: .month).day
        let endDay = date.endOf(component: .month).day
        
        for i in startDay...endDay{
            dayOfMonth.append(startDate.addingTimeInterval(TimeInterval(60 * 60 * 24 * (i - 1))))
        }
        
        return dayOfMonth
    }
    
    static func getWeek(_ date : Date) -> String {
        switch date.weekday {
        case 1:
            return "星期天"
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        case 7:
            return "星期六"
        default:
            return "未知"
        }
    }

}
