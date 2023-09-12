//
//  BleMatchTrainingSettings.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/15.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 间歇训练设置
class BleMatchTrainingSettings: BleWritable {

    /// 周期数量 (1-99)
    var mPeriods: Int = 1
    /// 训练时间 00:00 - 99:59, 秒
    var mTrainingTime: Int = 0
    /// 休息时间 00:00 - 99:59 秒
    var mRestingTime: Int = 0
    /// 结束休息时间 00:00 - 99:59 秒
    var mFinshRestingTime: Int = 0
    /// 震动等级（0-5）0=关
    var mVibration: Int = 0
    /// 0：屏幕常亮 1：抬手亮屏
    var mScreen: Int = 0

    override var mLengthToWrite: Int {
        return 1 + 9
    }
    
    init() {
        super.init()
    }
    init(mPeriods: Int, mTrainingTime: Int, mRestingTime: Int, mFinshRestingTime: Int, mVibration: Int, mScreen: Int) {
        super.init()
        
        self.mPeriods = mPeriods
        self.mTrainingTime = mTrainingTime
        self.mRestingTime = mRestingTime
        self.mFinshRestingTime = mFinshRestingTime
        self.mVibration = mVibration
        self.mScreen = mScreen
    }
    
    
    override func encode() {
        super.encode()
        
        writeInt8(MatchSetType.INTERVAL_TRAINING.rawValue)
        writeInt8(mPeriods)
        writeInt16(mTrainingTime)
        writeInt16(mRestingTime)
        writeInt16(mFinshRestingTime)
        writeInt8(mVibration)
        writeInt8(mScreen)
    }
    
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        fatalError("init(_:_:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    
    override var description: String {
        
        "BleMatchTrainingSettings(mPeriods:\(mPeriods), mTrainingTime:\(mTrainingTime), mRestingTime:\(mRestingTime), mFinshRestingTime:\(mFinshRestingTime), mVibration:\(mVibration), mScreen:\(mScreen))"
    }
    
}
