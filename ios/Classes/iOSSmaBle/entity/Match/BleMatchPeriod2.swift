//
//  BleMatchPeriod2.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/14.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 比赛周期2
class BleMatchPeriod2: BleReadable {
    static let ITEM_LENGTH = 14
    
    /// 持续时长，数据以秒为单位
    var mDuration: Int = 0
    /// 10米，以10米为单位，例如接收到的数据为5421，则代表 54210 米 约等于 54.21 Km
    var mDistance: Int = 0
    /// 步数
    var mStep: Int = 0
    /// 卡，以卡为单位
    var mCalorie: Int = 0
    /// 平均速度, 接收到的数据以 （0.1km/h） 为单位, 数据需要除以10显示
    var mSpeed: Int = 0
    /// 平均心率
    var mAvgBpm: Int = 0
    /// 最大心率
    var mMaxBpm: Int = 0
    /// 最大速度, 接收到的数据以 （0.1km/h） 为单位, 数据需要除以10显示
    var mMaxSpeed: Int = 0
    
    
    override func decode() {
        super.decode()
        mDuration = Int(readUInt16(.LITTLE_ENDIAN))
        mDistance = Int(readUInt16(.LITTLE_ENDIAN))
        mStep = Int(readUInt16(.LITTLE_ENDIAN))
        mCalorie = Int(readUInt16(.LITTLE_ENDIAN))
        mSpeed = Int(readUInt16(.LITTLE_ENDIAN))
        mAvgBpm = Int(readUInt8())
        mMaxBpm = Int(readUInt8())
        mMaxSpeed = Int(readUInt16(.LITTLE_ENDIAN))
    }
    
    override var description: String {
        "BleMatchPeriod2(mDuration: \(mDuration), mDistance: \(mDistance), mStep: \(mStep)," +
            " mCalorie: \(mCalorie), mSpeed: \(mSpeed), mAvgBpm: \(mAvgBpm), mMaxBpm: \(mMaxBpm), mMaxSpeed:\(mMaxSpeed))"
    }
    
}
