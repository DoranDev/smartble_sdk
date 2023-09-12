//
//  BleMatchRecordTeam.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/14.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 比赛记录团队信息
class BleMatchRecordTeam: BleReadable {
    private let NAME_LENGTH = 25
    static let ITEM_LENGTH = 1908

    /// 2个球队名字(每个球队25个字节，utf8编码)
    var mTeamNames = [String]()
    
    /// 主队颜色 （按照上面的枚举赋值）[MatchColor]
    var mHomeTeamColor: Int = 0
    /// 客队颜色（按照上面的枚举赋值）[MatchColor]
    var mGuestTeamColor: Int = 0
    
    /// 4个裁判名字 (每个球队25个字节，utf8编码)
    var mRefereeRoles = [String]()
    
    /// 主队球员信息（player info data），每个球队最多25人
    var mHomePlayers = [BleMatchRecordPlayer]()
    /// 客队球员信息（player info data），每个球队最多25人
    var mGuestPlayers = [BleMatchRecordPlayer]()
    
    /// 8个进球类型，固定的有6个，两个可编辑的，utf8编码
    var mGoalTypes = [String]()
    /// 5个黄牌类型，固定的有3个，两个可编辑的，utf8编码
    var mYellowCardTypes = [String]()
    /// 5个红牌类型，固定的有3个，两个可编辑的，utf8编码
    var mRedCardTypes = [String]()
    
    
    override func decode() {
        super.decode()
        
        // 2个球队的名字
        var teamNames = [String]()
        for _ in 0..<2 {
            let name = readString(NAME_LENGTH)
            if !name.isEmpty {
                teamNames.append(name)
            }
        }
        self.mTeamNames = teamNames
        
        mHomeTeamColor = Int(readInt8())
        mGuestTeamColor = Int(readInt8())
        
        // 4个裁判名字
        var refereeRoles = [String]()
        for _ in 0..<4 {
            let name = readString(NAME_LENGTH)
            if !name.isEmpty {
                refereeRoles.append(name)
            }
        }
        self.mRefereeRoles = refereeRoles
        
        //主队球员信息
        let homePlayers: [BleMatchRecordPlayer] = readArray(25, BleMatchRecordPlayer.NAME_LENGTH)
        //客队球员信息
        let guestPlayers: [BleMatchRecordPlayer] = readArray(25, BleMatchRecordPlayer.NAME_LENGTH)
        
        //8个进球类型
        var goalTypes = [String]()
        for _ in 0..<8 {
            goalTypes.append(readString(NAME_LENGTH))
        }
        //5个黄牌类型
        var yellowCardTypes = [String]()
        for _ in 0..<5 {
            yellowCardTypes.append(readString(NAME_LENGTH))
        }
        //5个红牌类型
        var redCardTypes = [String]()
        for _ in 0..<5 {
            redCardTypes.append(readString(NAME_LENGTH))
        }
        
        
        //为了字节对齐才将数量放到后面
        mHomePlayers = Array(homePlayers.prefix(Int(readInt8())))
        mGuestPlayers = Array(guestPlayers.prefix(Int(readInt8())))
        mGoalTypes = Array(goalTypes.prefix(Int(readInt8())))
        mYellowCardTypes = Array(yellowCardTypes.prefix(Int(readInt8())))
        mRedCardTypes = Array(redCardTypes.prefix(Int(readInt8())))
    }
    
    
    
    override var description: String {
        
        "BleMatchRecordTeam(mTeamNames:\(mTeamNames), mHomeTeamColor:\(mHomeTeamColor), mGuestTeamColor:\(mGuestTeamColor), "
        + "mRefereeRoles:\(mRefereeRoles), mGuestPlayers:\(mGuestPlayers), mGoalTypes:\(mGoalTypes), mYellowCardTypes:\(mYellowCardTypes), "
        + "mRedCardTypes:\(mRedCardTypes)"
        + ")"
    }
    
}
