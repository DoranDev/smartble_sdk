//
//  BleCoaching.swift
//  SmartV3
//
//  Created by SMA on 2020/3/4.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

/**
 * 不支持[BleConnector.sendArray]，所以不能一次创建多个，也不能执行重置操作。
 * 也不支持[BleConnector.sendInt8]，删除时只需要删除本地缓存。
 * 读取时只支持[ID_ALL]，不支持读取单个，而且设备并不是返回该类的列表，而是[BleCoachingIds]对象，里面包含了设备上已存在的实例的id列表。
 */
class BleCoaching: BleIdObject {
    static let LENGTH_TITLE = 15 // 包括结束的0，所以有效只有14字节
    static let LENGTH_FIXED = LENGTH_TITLE + 4
    static let MAX_LENGTH_DESCRIPTION = 128

    var mTitle = ""
    // description字符串的字节数
    private var mDescriptionLength: Int {
        min(mDescription.data(using: .utf8)?.count ?? 0, BleCoaching.MAX_LENGTH_DESCRIPTION)
    }
    var mDescription = ""
    var mRepeat = 0 // 重复次数1~255
    private var mSegmentsCount: Int {
        mSegments.count
    }
    var mSegments = [BleCoachingSegment]()

    override var mLengthToWrite: Int {
        BleCoaching.LENGTH_FIXED + mDescriptionLength + mSegments.map({ $0.mLengthToWrite }).reduce(0, { $0 + $1 })
    }

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ title: String, _ description: String, _ `repeat`: Int, _ segments: [BleCoachingSegment]) {
        super.init()
        mTitle = title
        mDescription = description
        mRepeat = `repeat`
        mSegments = segments
    }

    override func encode() {
        super.encode()
        writeInt8(mId)
        writeStringWithFix(mTitle, 15)
        writeInt8(mDescriptionLength)
        writeStringWithFix(mDescription, mDescriptionLength)
        writeInt8(mRepeat)
        writeInt8(mSegmentsCount)
        writeArray(mSegments)
    }

    override func decode() {
        super.decode()
        mId = Int(readInt8())
        mTitle = readString(15)
        skip(8)
        mDescription = readString(mDescriptionLength)
        mRepeat = Int(readInt8())
        skip(8)
        mSegments = readArray(0, mSegments.count)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mId = try container.decode(Int.self, forKey: .mId)
        mTitle = try container.decode(String.self, forKey: .mTitle)
        mDescription = try container.decode(String.self, forKey: .mDescription)
        mRepeat = try container.decode(Int.self, forKey: .mRepeat)
        mSegments = try container.decode([BleCoachingSegment].self, forKey: .mSegments)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mId, forKey: .mId)
        try container.encode(mTitle, forKey: .mTitle)
        try container.encode(mDescription, forKey: .mDescription)
        try container.encode(mRepeat, forKey: .mRepeat)
        try container.encode(mSegments, forKey: .mSegments)
    }

    private enum CodingKeys: String, CodingKey {
        case mId, mTitle, mDescription, mRepeat, mSegments
    }

    override var description: String {
        "BleCoaching(mId: \(mId), mTitle: \(mTitle), mDescriptionLength: \(mDescriptionLength)"
            + ", mDescription: \(mDescription), mRepeat: \(mRepeat), mSegmentsCount: \(mSegmentsCount)"
            + ", mSegments:\(mSegments)"
    }
}
