//
//  BleDrinkWaterSettings.swift
//  SmartV3
//
//  Created by SMA on 2021/10/11.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class BleDrinkWaterSettings: BleWritable {
    static let ITEM_LENGTH = 6

    override var mLengthToWrite: Int {
        BleDrinkWaterSettings.ITEM_LENGTH
    }
    //////初始化值 10:00～21:00
    var mEnabled: Int = 0 //0->off 1->open
    var mRepeat: Int = 0 //Monday - Sunday (Arbitrary choice)
    var mStartHour: Int = 9
    var mStartMinute: Int = 0
    var mEndHour: Int = 21
    var mEndMinute: Int = 0
    var mInterval: Int = 60 // 分钟数

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func encode() {
        super.encode()
        writeIntN(mEnabled, 1)
        writeIntN(mRepeat, 7)
        writeInt8(mStartHour)
        writeInt8(mStartMinute)
        writeInt8(mEndHour)
        writeInt8(mEndMinute)
        writeInt8(mInterval)
    }

    override func decode() {
        super.decode()
        mEnabled = Int(readUIntN(1))
        mRepeat = Int(readUIntN(7))
        mStartHour = Int(readUInt8())
        mStartMinute = Int(readUInt8())
        mEndHour = Int(readUInt8())
        mEndMinute = Int(readUInt8())
        mInterval = Int(readUInt8())
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mEnabled = try container.decode(Int.self, forKey: .mEnabled)
        mRepeat = try container.decode(Int.self, forKey: .mRepeat)
        mStartHour = try container.decode(Int.self, forKey: .mStartHour)
        mStartMinute = try container.decode(Int.self, forKey: .mStartMinute)
        mEndHour = try container.decode(Int.self, forKey: .mEndHour)
        mEndMinute = try container.decode(Int.self, forKey: .mEndMinute)
        mInterval = try container.decode(Int.self, forKey: .mInterval)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mEnabled, forKey: .mEnabled)
        try container.encode(mRepeat, forKey: .mRepeat)
        try container.encode(mStartHour, forKey: .mStartHour)
        try container.encode(mStartMinute, forKey: .mStartMinute)
        try container.encode(mEndHour, forKey: .mEndHour)
        try container.encode(mEndMinute, forKey: .mEndMinute)
        try container.encode(mInterval, forKey: .mInterval)
    }

    private enum CodingKeys: String, CodingKey {
        case mEnabled, mRepeat, mStartHour, mStartMinute, mEndHour, mEndMinute, mInterval
    }

    override var description: String {
        "BleDrinkWaterSettings(mEnabled: \(mEnabled), mRepeat: \(mRepeat), mStartHour: \(mStartHour)"
            + ", mStartMinute: \(mStartMinute), mEndHour: \(mEndHour), mEndMinute: \(mEndMinute)"
            + ", mInterval: \(mInterval))"
    }
}
