//
//  BleCoachingIds.swift
//  SmartV3
//
//  Created by SMA on 2020/3/4.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

class BleCoachingIds: BleReadable {
    var mCount = 0 // 表示当前设备有多少条运动模式
    var mIds = [Int]()

    required init(_ data: Data?, _ byteOrder: ByteOrder) {
        super.init(data, byteOrder)
    }

    override func decode() {
        super.decode()
        mIds.removeAll()
        mCount = Int(readInt8())
        for _ in 0..<mCount {
            mIds.append(Int(readInt8()))
        }
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mCount = try container.decode(Int.self, forKey: .mCount)
        mIds = try container.decode([Int].self, forKey: .mIds)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mCount, forKey: .mCount)
        try container.encode(mIds, forKey: .mIds)
    }

    private enum CodingKeys: String, CodingKey {
        case mCount, mIds
    }

    override var description: String {
        "BleCoachIds(mCount: \(mCount), mIds: \(mIds))"
    }
}
