//
//  BleMatchRecord2.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/14.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 比赛记录2
class BleMatchRecord2: BleReadable {
    static let ITEM_LENGTH = 3244 + 12
    
    /// 开始时间，数据以秒为单位/
    var mStart: Int = 0
    /// 比赛类型, 参考MatchType 枚举值
    var mType: Int = 0
    /// 周期数据个数 x（1-9）
    var mPeriodListSize: Int = 0
    /// 事件数据个数 y（1-99） 如果是秒表数据，则是秒表的总圈数
    var mLogListSize: Int = 0
    /// 是否是秒表的数据
    var mIsStopWatchData: Int = 0
    /// 整个比赛的周期数据
    var mPeriod: BleMatchPeriod2 = BleMatchPeriod2()
    /// 周期的数据
    var mPeriodList = [BleMatchPeriod2]()
    /// 事件数据数组 （log data） 如果是秒表数据取前面99*4 byte，没4 byte记录一圈的时间
    var mLogList = [BleMatchLog2]()
    /// 是秒表数据时用到,毫秒
    var mStopWatchList = [Int]()
    /// 团队信息
    var mTeamInfo: BleMatchRecordTeam = BleMatchRecordTeam()
    /// 天气信息
    var mWeather: BleWeather = BleWeather()
    
    
    override func decode() {
        super.decode()
        mStart = Int(readUInt32(.LITTLE_ENDIAN))
        mType = Int(readUInt8())
        mPeriodListSize = Int(readUInt8())
        mLogListSize = Int(readUInt8())
        mIsStopWatchData = Int(readUInt8())
        mPeriod = readObject(BleMatchPeriod2.ITEM_LENGTH)
        
        mPeriodList = readArray(9, BleMatchPeriod2.ITEM_LENGTH)
        mPeriodList = Array(mPeriodList.prefix(mPeriodListSize))
        
        if mIsStopWatchData == 1 {
         
            var list = [Int]()
            for _ in 0..<(99 * 3) {
                list.append(Int(readInt32(.LITTLE_ENDIAN)))
            }
            mStopWatchList = Array(list.prefix(mLogListSize))
        } else {
            mLogList = readArray(99, BleMatchLog2.ITEM_LENGTH)
            mLogList = Array(mLogList.prefix(mLogListSize))
        }
        
        mTeamInfo = readObject(BleMatchRecordTeam.ITEM_LENGTH)
        mWeather = readObject(BleWeather.ITEM_LENGTH)
    }
    
    override var description: String {
        "BleMatchRecord2(mStart:\(mStart), mType:\(mType), mPeriodListSize:\(mPeriodListSize), mLogListSize:\(mLogListSize), "
        + "mIsStopWatchData:\(mIsStopWatchData), mPeriod:\(mPeriod), mPeriodList:\(mPeriodList), mLogList:\(mLogList)"
        + "mStopWatchList:\(mStopWatchList), mTeamInfo:\(mTeamInfo), mWeather:\(mWeather)"
        + ")"
    }

}

extension BleMatchRecord2 {
    
    /// 比赛类型
    enum MatchType: Int {
        /// 青年赛，有周期数据，总数据和事件数据
        case YOUTH = 0x00
        /// 经典比赛，有周期数据，总数据和事件数据
        case CLASSIC = 0x01
        /// 自定义比赛，有周期数据，总数据和事件数据
        case PROFILE = 0x02
        /// 训练，只有一个总的数据，没有事件数据和周期数据
        case TRAINING = 0x03
    }
}
