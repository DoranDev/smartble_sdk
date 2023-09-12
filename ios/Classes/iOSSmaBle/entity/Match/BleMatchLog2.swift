//
//  BleMatchLog2.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/14.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 比赛事件2
class BleMatchLog2: BleReadable {
    static let ITEM_LENGTH = 12
    
    /// 时间，数据以秒为单位，这个需要加上比赛开始时间才能得到完整的时间
    var mTime :Int = 0
    /// 事件发生的计数时间或者周期时间，数据以秒为单位
    var mPeriodTime :Int = 0
    /// 事件发生的周期序号
    var mPeriodNumber :Int = 0
    /// 当前事件类型, 参考: EventType 枚举, 使用方式举例: BleMatchLog2.EventType.KICK_OFF
    var mType :Int = 0
    /// 第几个进球或者第几次罚球
    var mCount : Int = 0
    /// 取消的事件类型（当前事件为取消事件时用到）
    var mCancelType :Int = 0
    // 一下三个属性为新协议
    /// 事件发生的所在球队（0主队1客队）0xFF表示无效，不显示
    var mTeam: Int = 0
    /// 时间发生的球员（球员ID，0到24）0xFF表示无效，不显示
    var mPlayer: Int = 0
    /// 事件的进球类型，犯规类型，或者替补球员ID 0xFF表示无效，不显示
    var mOtherType: Int = 0

    
    override func decode() {
        super.decode()
        mTime = Int(readUInt16(.LITTLE_ENDIAN))
        mPeriodTime = Int(readUInt16(.LITTLE_ENDIAN))
        mPeriodNumber = Int(readUInt8())
        mType = Int(readUInt8())
        mCount = Int(readUInt8())
        mCancelType = Int(readUInt8())
        mTeam = Int(readUInt8())
        mPlayer = Int(readUInt8())
        mOtherType = Int(readUInt8())
        _ = readUInt8()  //保留
    }
    
    override var description: String {
        "BleMatchLog2(mTime:\(mTime), mPeriodTime:\(mPeriodTime),mPeriodNumber:\(mPeriodNumber), mType:\(mType), " +
            "mCount:\(mCount), mCancelType:\(mCancelType), mTeam:\(mTeam), mPlayer:\(mPlayer), mOtherType:\(mOtherType))"
    }
    
}



extension BleMatchLog2 {
    
    /// 当前事件类型
    enum EventType: Int {
        /// 开球
        case KICK_OFF = 0x00
        /// 比赛开始
        case TIME_START = 0x01
        /// 比赛停止
        case TIME_STOP = 0x02
        /// 单周期结束
        case PERIOD_END = 0x03
        /// 单周期重置
        case PERIOD_RESET = 0x04
        /// 罚球
        case PENALTY = 0x05
        /// 主队进球
        case GOAL_HOME = 0x06
        /// 客队进球
        case GOAL_GUEST = 0x07
        /// 取消进球或者罚球
        case UNDO_LAST = 0x08
        /// 提前结束当前周期比赛
        case MERCY_END = 0x09
        /// 恶劣天气，暂停比赛
        case INCIDENT_BREAK = 0x0A
        /// 黄牌,只有自定义模式有
        case YELLOW_CARD = 0x0B
        /// 红牌,只有自定义模式有
        case RED_CARD = 0x0C
        /// 替补上场,只有自定义模式有
        case SUBSTITUTION = 0x0D
    }
}
