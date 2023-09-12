//
// Created by Best Mafen on 2019/9/30.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleTimeRange: BleWritable {
    static let ITEM_LENGTH = 5

    override var mLengthToWrite: Int {
        BleTimeRange.ITEM_LENGTH
    }

    var mEnabled: Int = 0 // 0 关闭, 1 开启
    var mStartHour: Int = 0
    var mStartMinute: Int = 0
    var mEndHour: Int = 0
    var mEndMinute: Int = 0

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ enabled: Int, _ startHour: Int, _ startMinute: Int, _ endHour: Int, _ endMinute: Int) {
        super.init()
        mEnabled = enabled
        mStartHour = startHour
        mStartMinute = startMinute
        mEndHour = endHour
        mEndMinute = endMinute
    }

    override func encode() {
        super.encode()
        writeInt8(mEnabled)
        writeInt8(mStartHour)
        writeInt8(mStartMinute)
        writeInt8(mEndHour)
        writeInt8(mEndMinute)
    }

    override func decode() {
        super.decode()
        mEnabled = Int(readUInt8())
        mStartHour = Int(readUInt8())
        mStartMinute = Int(readUInt8())
        mEndHour = Int(readUInt8())
        mEndMinute = Int(readUInt8())
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mEnabled = try container.decode(Int.self, forKey: .mEnabled)
        mStartHour = try container.decode(Int.self, forKey: .mStartHour)
        mStartMinute = try container.decode(Int.self, forKey: .mStartMinute)
        mEndHour = try container.decode(Int.self, forKey: .mEndHour)
        mEndMinute = try container.decode(Int.self, forKey: .mEndMinute)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mEnabled, forKey: .mEnabled)
        try container.encode(mStartHour, forKey: .mStartHour)
        try container.encode(mStartMinute, forKey: .mStartMinute)
        try container.encode(mEndHour, forKey: .mEndHour)
        try container.encode(mEndMinute, forKey: .mEndMinute)
    }

    private enum CodingKeys: String, CodingKey {
        case mEnabled, mStartHour, mStartMinute, mEndHour, mEndMinute
    }

    override var description: String {
        "BleTimeRange(mEnabled: \(mEnabled), mStartHour: \(mStartHour), mStartMinute: \(mStartMinute), mEndHour: \(mEndHour), mEndMinute: \(mEndMinute))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mEnabled":mEnabled,
                                    "mStartHour":mStartHour,
                                    "mStartMinute":mStartMinute,
                                    "mEndHour":mEndHour,
                                    "mEndMinute":mEndMinute]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleTimeRange{
        let newModel = BleTimeRange()
        newModel.mEnabled = dic["mEnabled"] as? Int ?? 0
        newModel.mStartHour = dic["mStartHour"] as? Int ?? 0
        newModel.mStartMinute = dic["mStartMinute"] as? Int ?? 0
        newModel.mEndHour = dic["mEndHour"] as? Int ?? 0
        newModel.mEndMinute = dic["mEndMinute"] as? Int ?? 0
        return newModel
    }
}
