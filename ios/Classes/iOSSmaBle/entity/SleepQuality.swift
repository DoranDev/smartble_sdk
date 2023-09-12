//
// Created by Best Mafen on 2019/9/30.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation
/**
 * 睡眠质量数据
 * 部分设备不支持本地计算睡眠数据，
 * 需要通过App同步设备数据后，
 * 计算睡眠数据（可参考 BleSleep.analyseSleep 和 BleSleep.getSleepStatusDuration 方法），
 * 然后将这些数据回传给设备
 */
class BleSleepQuality: BleWritable {
    static let ITEM_LENGTH = 6

    override var mLengthToWrite: Int {
        BleSleepQuality.ITEM_LENGTH
    }


    var mLight: Int = 0 // 分钟数  浅睡
    var mDeep: Int = 0  // 分钟数  深睡
    var mTotal: Int = 0 // 分钟数  总睡眠时间

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }


    init(_ light: Int, _ deep: Int, _ total: Int) {
        super.init()
        mLight = light
        mDeep = deep
        mTotal = total
    }

    override func encode() {
        super.encode()
        writeInt16(mLight, .LITTLE_ENDIAN)
        writeInt16(mDeep, .LITTLE_ENDIAN)
        writeInt16(mTotal, .LITTLE_ENDIAN)
    }

    override func decode() {
        super.decode()

        mLight = Int(readUInt16(.LITTLE_ENDIAN))
        mDeep = Int(readUInt16(.LITTLE_ENDIAN))
        mTotal = Int(readUInt16(.LITTLE_ENDIAN))
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)

        mLight = try container.decode(Int.self, forKey: .mLight)
        mDeep = try container.decode(Int.self, forKey: .mDeep)
        mTotal = try container.decode(Int.self, forKey: .mTotal)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mLight, forKey: .mLight)
        try container.encode(mDeep, forKey: .mDeep)
        try container.encode(mTotal, forKey: .mTotal)
    }

    private enum CodingKeys: String, CodingKey {
        case mLight, mDeep, mTotal
    }

    override var description: String {
        "BleSleepQuality(mLight: \(mLight), mDeep: \(mDeep), mTotal: \(mTotal))"
    }
}
