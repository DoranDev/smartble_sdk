//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleAlarm: BleIdObject {
    static let ITEM_LENGTH = 28

    private static let TAG_LENGTH = 21

    override var mLengthToWrite: Int {
        BleAlarm.ITEM_LENGTH
    }

    var mEnabled = 1
    var mRepeat = 0
    var mYear = 2000
    var mMonth = 1
    var mDay = 1
    var mHour = 0
    var mMinute = 0
    var mTag = ""

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ enabled: Int = 1, _ repeat: Int = 0, _ year: Int = 2000, _ month: Int = 1, _ day: Int = 1,
         _ hour: Int = 0, _ minute: Int = 0, _ tag: String = "") {
        super.init()
        mEnabled = enabled
        mRepeat = `repeat`
        mYear = year
        mMonth = month
        mDay = day
        mHour = hour
        mMinute = minute
        mTag = tag
    }

    override func encode() {
        super.encode()
        writeInt8(mId)
        writeIntN(mEnabled, 1)
        writeIntN(mRepeat, 7)
        writeInt8(mYear - 2000)
        writeInt8(mMonth)
        writeInt8(mDay)
        writeInt8(mHour)
        writeInt8(mMinute)
        writeStringWithFix(mTag, BleAlarm.TAG_LENGTH)
    }

    override func decode() {
        super.decode()
        mId = Int(readUInt8())
        mEnabled = Int(readUIntN(1))
        mRepeat = Int(readUIntN(7))
        mYear = Int(readUInt8()) + 2000
        mMonth = Int(readUInt8())
        mDay = Int(readUInt8())
        mHour = Int(readUInt8())
        mMinute = Int(readUInt8())
        mTag = readString(BleAlarm.TAG_LENGTH)
    }

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mId = try container.decode(Int.self, forKey: .mId)
        mEnabled = try container.decode(Int.self, forKey: .mEnabled)
        mRepeat = try container.decode(Int.self, forKey: .mRepeat)
        mYear = try container.decode(Int.self, forKey: .mYear)
        mMonth = try container.decode(Int.self, forKey: .mMonth)
        mDay = try container.decode(Int.self, forKey: .mDay)
        mHour = try container.decode(Int.self, forKey: .mHour)
        mMinute = try container.decode(Int.self, forKey: .mMinute)
        mTag = try container.decode(String.self, forKey: .mTag)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mId, forKey: .mId)
        try container.encode(mEnabled, forKey: .mEnabled)
        try container.encode(mRepeat, forKey: .mRepeat)
        try container.encode(mYear, forKey: .mYear)
        try container.encode(mMonth, forKey: .mMonth)
        try container.encode(mDay, forKey: .mDay)
        try container.encode(mHour, forKey: .mHour)
        try container.encode(mMinute, forKey: .mMinute)
        try container.encode(mTag, forKey: .mTag)
    }

    private enum CodingKeys: String, CodingKey {
        case mId, mEnabled, mRepeat, mYear, mMonth, mDay, mHour, mMinute, mTag
    }

    override var description: String {
        "BleAlarm(mId: \(mId), mEnabled: \(mEnabled), mRepeat: \(mRepeat), mYear: \(mYear)" +
            ", mMonth: \(mMonth), mDay: \(mDay), mHour: \(mHour), mMinute: \(mMinute), mTag: \(mTag))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mId":mId,
                                    "mEnabled":mEnabled,
                                    "mRepeat":mRepeat,
                                    "mYear":mYear,
                                    "mMonth":mMonth,
                                    "mDay":mDay,
                                    "mHour":mHour,
                                    "mMinute":mMinute,
                                    "mTag":mTag]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleAlarm{

        let newModel = BleAlarm()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mId = dic["mId"] as? Int ?? 0
        newModel.mEnabled = dic["mEnabled"] as? Int ?? 0
        newModel.mRepeat = dic["mRepeat"] as? Int ?? 0
        newModel.mYear = dic["mYear"] as? Int ?? 0
        newModel.mMonth = dic["mMonth"] as? Int ?? 0
        newModel.mDay = dic["mDay"] as? Int ?? 0
        newModel.mHour = dic["mHour"] as? Int ?? 0
        newModel.mMinute = dic["mMinute"] as? Int ?? 0
        newModel.mTag = dic["mTag"] as? String ?? ""
        return newModel
    }
}
