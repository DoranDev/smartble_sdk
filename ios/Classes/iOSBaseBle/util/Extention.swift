//
// Created by Best Mafen on 2019/9/21.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBManagerState {

    /**
     * 将一些关键的蓝牙状态常量转换为易阅读的文本
     */
    var mDescription: String {
        switch self {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        default:
            return ""
        }
    }
}

extension NSObject {
    var mIdentifier: String {
        String(obj: self)
    }
}

extension String {

    init(obj: AnyObject) {
        self.init(UInt(bitPattern: ObjectIdentifier(obj)))
    }
}


