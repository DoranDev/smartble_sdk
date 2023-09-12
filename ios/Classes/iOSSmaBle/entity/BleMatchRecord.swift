//
//  BleMatchRecord.swift
//  SmartV3
//
//  Created by SMA-IOS on 2021/11/19.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class BleMatchRecord :BleReadable{
    static let ITEM_LENGTH = 920
    
    var mStart :Int = 0
    var mType :Int = 0
    var mPeriodListSize :Int = 0
    var mLogListSize :Int = 0
    var mUndefined : Int = 0  // 保留数据, 1字节
    var mPeriod :BleMatchPeriod = BleMatchPeriod()
    var mPeriodArray : [BleMatchPeriod] = []
    var mLogArray :[BleMatchLog] = []
    
    override func decode() {
        super.decode()
        mStart = Int(readUInt32(.LITTLE_ENDIAN))
        mType = Int(readUInt8())
        mPeriodListSize = Int(readUInt8())
        mLogListSize = Int(readUInt8())
        mUndefined = Int(readUInt8())
        mPeriod = readObject(BleMatchPeriod.ITEM_LENGTH)
        mPeriodArray = readArray(9, BleMatchPeriod.ITEM_LENGTH)
        mLogArray = readArray(mLogListSize, BleMatchLog.ITEM_LENGTH)
    }
    
    override var description: String {
        "BleMatchRecord(mStart: \(mStart), mType: \(mType), mPeriodListSize: \(mPeriodListSize)," +
            " mLogListSize: \(mLogListSize), mUndefined: \(mUndefined), mPeriod: \(mPeriod), mPeriodList: \(mPeriodArray), mLogList: \(mLogArray))"
    }
}
