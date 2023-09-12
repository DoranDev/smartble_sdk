//
//  BleMatchPlayerSettings.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/15.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 比赛球员设置
class BleMatchPlayerSettings: BleWritable {

    /// 比赛设置类型主队和客队
    var mMatchSetType = MatchSetType.HOME_TEAM_PLAYER_LIST.rawValue
    /// 球员列表（最多25）
    var mPlayerList = [BleMatchPlayer]()
    
    override var mLengthToWrite: Int {
        return 2 + mPlayerList.count * BleMatchPlayer.ITEM_LENGTH
    }
 
    init() {
        super.init()
    }
    init(mMatchSetType: MatchSetType, mPlayerList: [BleMatchPlayer]) {
        super.init()
        self.mMatchSetType = mMatchSetType.rawValue
        self.mPlayerList = mPlayerList
    }
    
    override func encode() {
        super.encode()
        writeInt8(mMatchSetType)
        writeInt8(mPlayerList.count)//球员数量
        for it in mPlayerList {
            writeObject(it)
        }
    }
    
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mMatchSetType = try container.decode(Int.self, forKey: .mMatchSetType)
        mPlayerList = try container.decode([BleMatchPlayer].self, forKey: .mPlayerList)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mMatchSetType, forKey: .mMatchSetType)
        try container.encode(mPlayerList, forKey: .mPlayerList)
    }

    private enum CodingKeys: String, CodingKey {
        case mMatchSetType, mPlayerList
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    override var description: String {
        "BleMatchPlayerSettings(mMatchSetType:\(mMatchSetType), mPlayerList:\(mPlayerList))"
    }
}
