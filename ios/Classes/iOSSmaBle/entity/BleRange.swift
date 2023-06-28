//
//  BleRange.swift
//  blesdk3
//
//  Created by 叩鼎科技 on 2022/11/9.
//  Copyright © 2022 szabh. All rights reserved.
//

import UIKit

/// 酒精浓度检测设置
class BleRange: BleWritable {

    static let ITEM_LENGTH = 12
    
    override var mLengthToWrite: Int {
        BleSleepQuality.ITEM_LENGTH
    }
    
    var mStart: Int = 0
    var mEnd: Int = 0
    
    
    init(_ mStart: Int, _ mEnd: Int) {
        super.init()
        self.mStart = mStart
        self.mEnd = mEnd
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    
    override func encode() {
        super.encode()
        writeInt32(mStart, .LITTLE_ENDIAN)
        writeInt32(mEnd, .LITTLE_ENDIAN)
    }

    override func decode() {
        super.decode()

        self.mStart = Int(readUInt32(.LITTLE_ENDIAN))
        self.mEnd = Int(readUInt32(.LITTLE_ENDIAN))
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)

        mStart = try container.decode(Int.self, forKey: .mStart)
        mEnd = try container.decode(Int.self, forKey: .mStart)
    }
    
    
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mStart, forKey: .mStart)
        try container.encode(mEnd, forKey: .mEnd)
    }

    private enum CodingKeys: String, CodingKey {
        case mStart, mEnd
    }

    override var description: String {
        "BleRange(mStart:\(mStart), mEnd:\(mEnd))"
    }
}
