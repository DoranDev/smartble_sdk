//
//  BleMatchYouthSettings.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/15.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 青年赛设置
class BleMatchYouthSettings: BleWritable {
    static let NAME_LENGTH = 25

    /// 周期数量 (1-9)
    var mPeriods: Int = 0
    /// 周期训练时间（9个）00:00 - 99:59, 秒
    var mPeriodTime = [Int]()
    /// 周期结束休息时间（8个，最后一个周期结束不需要休息时间） 00:00 - 99:59 秒
    var mBreakTime = [Int]()
    /// 震动等级（0-5）0=关
    var mVibration: Int = 0
    /// 开启/暂停的按键类型 0，单击 1，长按 2，双击 [MatchButtomType]
    var mButtonType: Int = 0
    /// 主队颜色 （按照上面的枚举赋值）[MatchColor]
    var mHomeTeamColor: Int = 0
    /// 客队颜色（按照上面的枚举赋值）[MatchColor]
    var mGuestTeamColor: Int = 0
    /// 惩罚时间, 犯规时间 00:00 - 99:59 秒
    var mPenaltyTime: Int = 0
    /// GPS开关 0，关闭 1，开启
    var mGps: Int = 0
    /// 0：屏幕常亮 1：抬手亮屏
    var mScreen: Int = 0
    /// 显示模式 0，正常 1，高可见性 2，白天 [MatchMainView]
    var mMatchView: Int = 0
    /// 2个球队名字（每个球队25个字节，utf8编码）
    var mTeamNames = [String]()
    /// 4个裁判名字（每个球队25个字节，utf8编码）
    var mRefereeRole = [String]()
    /// 是否显示事件时间, 0:关闭, 1:开启
    var mEventTime: Int = 0
    
    
    
    override var mLengthToWrite: Int {
        return 1 + 10 + 2 * 9 + 2 * 8 + 2 * BleMatchYouthSettings.NAME_LENGTH + 4 * BleMatchYouthSettings.NAME_LENGTH + 1
    }
    
    override func encode() {
        super.encode()
        
        writeInt8(MatchSetType.YOUTH_MATCH.rawValue)
        writeInt8(mPeriods)
        //周期训练时间 不足补0
        for i in 0..<9 {
            if i < mPeriodTime.count {
                writeInt16(mPeriodTime[i])
            } else {
                writeInt16(0)
            }
        }
        //周期结束休息时间不足补0
        for i in 0..<8 {
            if i < mBreakTime.count {
                writeInt16(mBreakTime[i])
            } else {
                writeInt16(0)
            }
        }
        writeInt8(mVibration)
        writeInt8(mButtonType)
        writeInt8(mHomeTeamColor)
        writeInt8(mGuestTeamColor)
        writeInt16(mPenaltyTime)
        writeInt8(mGps)
        writeInt8(mScreen)
        writeInt8(mMatchView)
        //2个球队名字
        for i in 0..<2 {
            if i < mTeamNames.count {
                writeStringWithFix(mTeamNames[i], 25)
            } else {
                writeStringWithFix("", 25)
            }
        }
        //4个裁判名字
        for i in 0..<4 {
            if i < mRefereeRole.count {
                writeStringWithFix(mRefereeRole[i], 25)
            } else {
                writeStringWithFix("", 25)
            }
        }
        
        writeInt8(mEventTime)
    }
    
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mPeriods = try container.decode(Int.self, forKey: .mPeriods)
        mPeriodTime = try container.decode([Int].self, forKey: .mPeriodTime)
        mBreakTime = try container.decode([Int].self, forKey: .mBreakTime)
        mVibration = try container.decode(Int.self, forKey: .mVibration)
        mButtonType = try container.decode(Int.self, forKey: .mButtonType)
        mHomeTeamColor = try container.decode(Int.self, forKey: .mHomeTeamColor)
        mGuestTeamColor = try container.decode(Int.self, forKey: .mGuestTeamColor)
        mPenaltyTime = try container.decode(Int.self, forKey: .mPenaltyTime)
        mGps = try container.decode(Int.self, forKey: .mGps)
        mScreen = try container.decode(Int.self, forKey: .mScreen)
        mMatchView = try container.decode(Int.self, forKey: .mMatchView)
        mTeamNames = try container.decode([String].self, forKey: .mTeamNames)
        mRefereeRole = try container.decode([String].self, forKey: .mRefereeRole)
        mEventTime = try container.decode(Int.self, forKey: .mEventTime)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mPeriods, forKey: .mPeriods)
        try container.encode(mPeriodTime, forKey: .mPeriodTime)
        try container.encode(mBreakTime, forKey: .mBreakTime)
        try container.encode(mVibration, forKey: .mVibration)
        try container.encode(mButtonType, forKey: .mButtonType)
        try container.encode(mHomeTeamColor, forKey: .mHomeTeamColor)
        try container.encode(mGuestTeamColor, forKey: .mGuestTeamColor)
        try container.encode(mPenaltyTime, forKey: .mPenaltyTime)
        try container.encode(mGps, forKey: .mGps)
        try container.encode(mScreen, forKey: .mScreen)
        try container.encode(mMatchView, forKey: .mMatchView)
        try container.encode(mTeamNames, forKey: .mTeamNames)
        try container.encode(mRefereeRole, forKey: .mRefereeRole)
        try container.encode(mEventTime, forKey: .mEventTime)
    }

    private enum CodingKeys: String, CodingKey {
        case mPeriods, mPeriodTime, mBreakTime, mVibration, mButtonType, mHomeTeamColor
        case mGuestTeamColor, mPenaltyTime, mGps, mScreen, mMatchView, mTeamNames, mRefereeRole
        case mEventTime
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    override var description: String {
        "BleMatchYouthSettings(mPeriods:\(mPeriods), mPeriodTime:\(mPeriodTime), mBreakTime:\(mBreakTime), mVibration:\(mVibration), " +
        "mButtonType:\(mButtonType), mHomeTeamColor:\(mHomeTeamColor), mGuestTeamColor:\(mGuestTeamColor), mPenaltyTime:\(mPenaltyTime), " +
        "mGps:\(mGps), mScreen:\(mScreen), mMatchView:\(mMatchView), mTeamNames:\(mTeamNames), mRefereeRole:\(mRefereeRole), " +
        "mEventTime:\(mEventTime)" + ")"
    }
}
