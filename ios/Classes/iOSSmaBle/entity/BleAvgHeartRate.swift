//
//  BleAvgHeartRate.swift
//  blesdk3
//
//  Created by 叩鼎科技 on 2023/2/23.
//  Copyright © 2023 szabh. All rights reserved.
//

import UIKit

/// 平均心率
class BleAvgHeartRate: BleReadable {

    var mTime: Int = 0       //距离当地 2000/1/1 00:00:00 的秒值
    var mValue: Int = 0      //心率值
    
    
    static let ITEM_LENGTH = 8
    override func decode() {
        super.decode()
        
        mTime = Int(readInt32())
        mValue = Int(readInt32())
    }
}
