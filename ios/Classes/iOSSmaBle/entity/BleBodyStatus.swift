//
//  BleBodyData.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/12/27.
//  Copyright © 2022 CodingIOT. All rights reserved.
//

import UIKit

/// 身体数据
class BleBodyStatus: BleReadable {

    /// 距离当地2000/1/1 00:00:00 的秒数
    var mTime: Int = 0
    /// 评分
    var mValue: Int = 0
    
    static let ITEM_LENGTH = 6
    
    override func decode() {
        super.decode()
        
        mTime = Int(readInt32())
        mValue = Int(readInt8())
    }
    
    override var description: String {
        "BleBodyStatus(mTime:\(mTime), mValue:\(mValue))"
    }
}
