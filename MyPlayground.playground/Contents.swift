//: A UIKit based Playground for presenting user interface
  
import UIKit
import SwiftyJSON
import SwiftDate

//计算出本月所有日期
func getAlldayOfMonth(_ date : Date) -> [Date]{
    var dayOfMonth = [Date]()
    let currentDate = Date()
    let startDate = currentDate.startOf(component: .month)
    let startDay = currentDate.startOf(component: .month).day
    let endDay = currentDate.endOf(component: .month).day
    
    for i in startDay...endDay{
        print(i)
        dayOfMonth.append(startDate.addingTimeInterval(TimeInterval(60 * 60 * 24 * i)))
    }
    
    return dayOfMonth
}
let pattern = "yyyy-MM-dd HH:mm:ss"
let date = Date()
//print(getAlldayOfMonth(Date()))
let dateStr = date.startOf(component: .month).string(format: DateFormat.custom(pattern))
dateStr.date(format: DateFormat.custom(pattern))?.absoluteDate


let startDate = date.startOf(component: .month)
let startDate2 = date.string(format: DateFormat.custom("yyyy-MM")).date(format: DateFormat.custom("yyyy-MM"))?.absoluteDate
startDate.day
startDate2?.day

