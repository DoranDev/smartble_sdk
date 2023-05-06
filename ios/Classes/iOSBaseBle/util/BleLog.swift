//
// Created by Best Mafen on 2019/9/27.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

// 只有DEBUG为true时才会打印日志
var BASE_BLE_DEBUG = true

func bleLog(_ message: String) {
    #if DEBUG
    let dateFormat1 = DateFormatter()
    dateFormat1.dateFormat = "YYYY-MM-dd HH:mm:ss"
    print("\(Thread.current) - \(dateFormat1.string(from: Date()))-\(Date().milliStamp)  \(message)")
    #elseif !DEBUG
//    write log (.text) 没有请注释
    if UserDefaults.standard.bool(forKey: kRuntimeBleLog) {
        ABHBleLog.share.startWriteMessage(message)
    }
    #endif
}

extension Date {
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        let milli :String = "\(millisecond)"
        return String(milli.suffix(4)) as String
    }
}
