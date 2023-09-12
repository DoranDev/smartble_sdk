//
//  BleSleepMonitoringSettings.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/12/6.
//  Copyright © 2022 CodingIOT. All rights reserved.
//

import UIKit

class BleSleepMonitoringSettings: BleWritable {

    var mEnabled: Int = 0
    var mStartHour: Int = 0
    var mStartMinute: Int = 0
    var mEndHour: Int = 0
    var mEndMinute: Int = 0
    
    private let ITEM_LENGTH = 5
    override var mLengthToWrite: Int {
        return ITEM_LENGTH
    }
    
    override func encode() {
        super.encode()
        writeInt8(mEnabled)
        writeInt8(mStartHour)
        writeInt8(mStartMinute)
        writeInt8(mEndHour)
        writeInt8(mEndMinute)
    }

    override func decode() {
        super.decode()
        mEnabled = Int(readUInt8())
        mStartHour = Int(readUInt8())
        mStartMinute = Int(readUInt8())
        mEndHour = Int(readUInt8())
        mEndMinute = Int(readUInt8())
    }
    
    override var description: String {
        return "BleSleepMonitoringSettings(mEnabled=\(mEnabled), mStartHour=\(mStartHour), mStartMinute=\(mStartMinute), mEndHour=\(mEndHour), mEndMinute:\(mEndMinute))"
    }
}
