//
//  BleGameSettings.swift
//  SmartV3
//
//  Created by SMA-IOS on 2022/7/5.
//  Copyright © 2022 KingHuang. All rights reserved.
//

import Foundation

class BleGameSettings: BleWritable {
    static let ITEM_LENGTH = 9
    override var mLengthToWrite: Int {
        BleGameSettings.ITEM_LENGTH
    }
    var mEnabled : Int = 0
    var mStartHour1 : Int = 0
    var mStartMinute1 : Int = 0
    var mEndHour1 : Int = 0
    var mEndMinute1 : Int = 0
    var mStartHour2 : Int = 0
    var mStartMinute2 : Int = 0
    var mEndHour2 : Int = 0
    var mEndMinute2 : Int = 0
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mEnabled = try container.decode(Int.self, forKey: .mEnabled)
        mStartHour1 = try container.decode(Int.self, forKey: .mStartHour1)
        mStartMinute1 = try container.decode(Int.self, forKey: .mStartMinute1)
        mEndHour1 = try container.decode(Int.self, forKey: .mEndHour1)
        mEndMinute1 = try container.decode(Int.self, forKey: .mEndMinute1)
        mStartHour2 = try container.decode(Int.self, forKey: .mStartHour2)
        mStartMinute2 = try container.decode(Int.self, forKey: .mStartMinute2)
        mEndHour2 = try container.decode(Int.self, forKey: .mEndHour2)
        mEndMinute2 = try container.decode(Int.self, forKey: .mEndMinute2)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mEnabled, forKey: .mEnabled)
        try container.encode(mStartHour1, forKey: .mStartHour1)
        try container.encode(mStartMinute1, forKey: .mStartMinute1)
        try container.encode(mEndHour1, forKey: .mEndHour1)
        try container.encode(mEndMinute1, forKey: .mEndMinute1)
        try container.encode(mStartHour2, forKey: .mStartHour2)
        try container.encode(mStartMinute2, forKey: .mStartMinute2)
        try container.encode(mEndHour2, forKey: .mEndHour2)
        try container.encode(mEndMinute2, forKey: .mEndMinute2)
    }

    private enum CodingKeys: String, CodingKey {
        case mEnabled, mStartHour1, mStartMinute1, mEndHour1, mEndMinute1, mStartHour2, mStartMinute2, mEndHour2, mEndMinute2
    }
    
    override func encode() {
        super.encode()
        writeInt8(mEnabled)
        writeInt8(mStartHour1)
        writeInt8(mStartMinute1)
        writeInt8(mEndHour1)
        writeInt8(mEndMinute1)
        writeInt8(mStartHour2)
        writeInt8(mStartMinute2)
        writeInt8(mEndHour2)
        writeInt8(mEndMinute2)

    }
    
    override func decode() {
        super.decode()
        mEnabled = Int(readUInt8())
        mStartHour1 = Int(readUInt8())
        mStartMinute1 = Int(readUInt8())
        mEndHour1 = Int(readUInt8())
        mEndMinute1 = Int(readUInt8())
        mStartHour2 = Int(readUInt8())
        mStartMinute2 = Int(readUInt8())
        mEndHour2 = Int(readUInt8())
        mEndMinute2 = Int(readUInt8())
    }
    
    override var description: String {
        "BleGameSettings(mEnabled: \(mEnabled), mStartHour1: \(mStartHour1), mStartMinute1: \(mStartMinute1)"
        + ", mEndHour1: \(mEndHour1), mEndMinute1: \(mEndMinute1), mStartHour2: \(mStartHour2)"
        + ", mStartMinute2: \(mStartMinute2) ,mEndHour2: \(mEndHour2),mEndMinute2: \(mEndMinute2))"
    }
}
