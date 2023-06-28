//
// Created by Best Mafen on 2019/9/27.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/// 只有DEBUG为true时才会打印日志
var BASE_BLE_DEBUG = true
//let kRuntimeBleLog = "kRuntimeBleLog"

func bleLog(_ message: String) {


    let dateFormat1 = DateFormatter()
    dateFormat1.dateFormat = "YYYY-MM-dd HH:mm:ss"
    
    
    if BASE_BLE_DEBUG {
        print("\(Thread.current) - \(dateFormat1.string(from: Date()))-\(getMilliStampLog(Date()))  \(message)")
        //if UserDefaults.standard.bool(forKey: kRuntimeBleLog) {
        //ABHBleLog.share.startWriteMessage(message)
        //}
    }
}

// 这个就是为了解输出日志的时间而使用的方法, 其他地方不用, 直接写到这里即可, 将之前外部的那个Date扩展删除,
// 不要对外界Date扩展产生冲突
private func getMilliStampLog(_ date: Date) ->String {

    let timeInterval: TimeInterval = date.timeIntervalSince1970
    let millisecond = CLongLong(round(timeInterval*1000))
    let milli :String = "\(millisecond)"
    return String(milli.suffix(4)) as String
}
