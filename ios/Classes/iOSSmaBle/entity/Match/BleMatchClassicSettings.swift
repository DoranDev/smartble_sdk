//
//  BleMatchClassicSettings.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/14.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 比赛设置类型
enum MatchSetType: Int {
    /// 青年赛
    case YOUTH_MATCH = 0
    /// 传统比赛
    case CLASSIC_MATCH = 1
    /// 职业比赛
    case PRO_MATCH = 2
    /// 间歇训练
    case INTERVAL_TRAINING = 3
    /// 主队球员
    case HOME_TEAM_PLAYER_LIST = 4
    /// 客队球员
    case GUEST_TEAM_PLAYER_LIST = 5
}

/// 比赛设置颜色
enum MatchColor: Int {

    case RED = 0

    case BLUE = 1

    case GREEN = 2

    case YELLOW = 3

    case ORANGE = 4

    case PURPLE = 5

    case PINK = 6

    case BROWN = 7

    case GREY = 8

    case BLACK = 9

    case WHITE = 10

    case MAX = 11
    
    /// 由颜色枚举原始值, 返回UIColor
    static func rawToUIColor(_ num: Int) -> UIColor? {
        
        return MatchColor(rawValue: num)?.tranToUIColor()
    }
    
    /// 根据当前的 MatchColor值, 返回对应的UIColor
    func tranToUIColor() -> UIColor {
        
        
        var selectColor = UIColor.red
        
        switch self {
        case .BLUE:
            selectColor = UIColor.blue
        case .GREEN:
            selectColor = UIColor.green
        case .YELLOW:
            selectColor = UIColor.yellow
        case .ORANGE:
            selectColor = UIColor.orange
            
        case .PURPLE:
            selectColor = UIColor.purple
        case .PINK: // 粉色
            selectColor = UIColor(red: 255.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        case .BROWN:
            selectColor = UIColor.brown
        case .BLACK:
            selectColor = UIColor.black
        case .WHITE:
            selectColor = UIColor.white
        default:
            break
        }
        
        return selectColor
    }
}

/// 比赛设置按键类型
enum MatchButtomType: Int {
    /// 单击
    case SHORT_PRESS = 0
    /// 长按
    case LONG_PRESS = 1
    /// 双击
    case DOUBLE_PRESS = 2
}

/// 比赛设置显示模式
enum MatchMainView: Int {
    /// 正常
    case ORIGINAL = 0
    /// 高可见性
    case HIGH_VISIBILITY = 1
    /// 白天
    case DAYLIGHT = 2
}


class BleMatchClassicSettings: BleWritable {
    private let NAME_LENGTH = 25
    
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
    /// GPS开关 0，关闭 1，开启
    var mGps: Int = 0
    /// 0：屏幕常亮 1：抬手亮屏
    var mScreen: Int = 0
    /// 显示模式 0，正常 1，高可见性 2，白天 [MatchMainView]/
    var mMatchView: Int = 0
    /// 2个球队名字（每个球队25个字节，utf8编码）
    var mTeamNames = [String]()
    /// 4个裁判名字（每个球队25个字节，utf8编码）
    var mRefereeRole = [String]()
    
    override var mLengthToWrite: Int {
        1 + 7 + 2 * 9 + 2 * 8 + 2 * NAME_LENGTH + 4 * NAME_LENGTH
    }
    
    
    override func encode() {
        super.encode()
        
        writeInt8(MatchSetType.CLASSIC_MATCH.rawValue)
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
    }
    
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mPeriods = try container.decode(Int.self, forKey: .mPeriods)
        mPeriodTime = try container.decode([Int].self, forKey: .mPeriodTime)
        mBreakTime = try container.decode([Int].self, forKey: .mBreakTime)
        mVibration = try container.decode(Int.self, forKey: .mVibration)
        mButtonType = try container.decode(Int.self, forKey: .mButtonType)
        mGps = try container.decode(Int.self, forKey: .mGps)
        mScreen = try container.decode(Int.self, forKey: .mScreen)
        mMatchView = try container.decode(Int.self, forKey: .mMatchView)
        mTeamNames = try container.decode([String].self, forKey: .mTeamNames)
        mRefereeRole = try container.decode([String].self, forKey: .mRefereeRole)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mPeriods, forKey: .mPeriods)
        try container.encode(mPeriodTime, forKey: .mPeriodTime)
        try container.encode(mBreakTime, forKey: .mBreakTime)
        try container.encode(mVibration, forKey: .mVibration)
        try container.encode(mButtonType, forKey: .mButtonType)
        try container.encode(mGps, forKey: .mGps)
        try container.encode(mScreen, forKey: .mScreen)
        try container.encode(mMatchView, forKey: .mMatchView)
        try container.encode(mTeamNames, forKey: .mTeamNames)
        try container.encode(mRefereeRole, forKey: .mRefereeRole)
    }

    private enum CodingKeys: String, CodingKey {
        case mPeriods, mPeriodTime, mBreakTime, mVibration, mButtonType, mGps, mScreen
        case mMatchView, mTeamNames, mRefereeRole
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    override var description: String {
        "BleMatchClassicSettings(mPeriods:\(mPeriods), mPeriodTime:\(mPeriodTime), mBreakTime:\(mBreakTime), mVibration:\(mVibration), "
        + "mButtonType:\(mButtonType), mGps:\(mGps), mScreen:\(mScreen), mMatchView:\(mMatchView), mTeamNames:\(mTeamNames), mRefereeRole:\(mRefereeRole))"
    }

}
