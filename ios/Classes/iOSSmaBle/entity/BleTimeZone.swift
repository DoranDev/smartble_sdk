//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleTimeZone: BleWritable {
    static let ITEM_LENGTH = 1

    override var mLengthToWrite: Int {
        BleTimeZone.ITEM_LENGTH
    }

    var mOffset = 0 // 与零时区的间隔秒数

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
        let timeZone = TimeZone.current
        mOffset = timeZone.secondsFromGMT()
    }

    override func encode() {
        super.encode()
        writeInt8(mOffset / 60 / 15)
    }

    override func decode() {
        super.decode()
        mOffset = Int(readInt8()) * 60 * 15
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mOffset = try container.decode(Int.self, forKey: .mOffset)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mOffset, forKey: .mOffset)
    }

    private enum CodingKeys: String, CodingKey {
        case mOffset
    }

    override var description: String {
        "BleTimeZone(mOffset: \(mOffset))"
    }
}
