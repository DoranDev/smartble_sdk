//
//  ABHRealTimeHR.swift
//  SmartV3
//
//  Created by SMA-IOS on 2021/12/24.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class ABHRealTimeHR: BleReadable {
    static let ITEM_LENGTH = 6
    var mTime: Int = 0
    var mHR = 0
    
    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mHR = Int(readInt8())
        
    }
    override var description: String {
        "ABHRealTimeHR(mTime: \(mTime), mHR: \(mHR))"
    }
}
