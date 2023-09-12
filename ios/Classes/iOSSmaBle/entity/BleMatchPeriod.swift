//
//  BleMatchPeriod.swift
//  SmartV3
//
//  Created by SMA-IOS on 2021/11/19.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class BleMatchPeriod :BleReadable{
    static let ITEM_LENGTH = 12
    
    var mDuration :Int = 0
    var mDistance :Int = 0
    var mStep :Int = 0
    var mCalorie :Int = 0
    var mSpeed : Int = 0
    var mAvgBpm :Int = 0
    var mMaxBpm :Int = 0
    
    override func decode() {
        super.decode()
        mDuration = Int(readUInt16(.LITTLE_ENDIAN))
        mDistance = Int(readUInt16(.LITTLE_ENDIAN))
        mStep = Int(readUInt16(.LITTLE_ENDIAN))
        mCalorie = Int(readUInt16(.LITTLE_ENDIAN))
        mSpeed = Int(readUInt16(.LITTLE_ENDIAN))
        mAvgBpm = Int(readUInt8())
        mMaxBpm = Int(readUInt8())
    }
    
    override var description: String {
        "BleMatchPeriod(mDuration: \(mDuration), mDistance: \(mDistance), mStep: \(mStep)," +
            " mCalorie: \(mCalorie), mSpeed: \(mSpeed), mAvgBpm: \(mAvgBpm), mMaxBpm: \(mMaxBpm))"
    }
}
