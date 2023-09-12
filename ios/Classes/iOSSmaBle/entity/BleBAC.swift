//
//  BleBAC.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/2/10.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 酒精浓度
class BleBAC: BleReadable {
    
    var mTime: Int = 0  // 距离当地2000/1/1 00:00:00的秒数
    var mValue: Int = 0 // 酒精含量

    static let ITEM_LENGTH = 12
    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mValue = Int(readInt32())
    }
    
    override var description: String {
        return "BleBAC(mTime=\(mTime), mValue=\(mValue)')"
    }
}
