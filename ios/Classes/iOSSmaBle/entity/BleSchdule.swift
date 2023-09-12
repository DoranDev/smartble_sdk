//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 不支持[BleConnector.sendArray]，所以不能一次创建多个，也不能执行重置操作，
 * 也不支持读取操作。
 */
class BleSchedule: BleIdObject {
    static let TITLE_LENGTH = 32
    static let CONTENT_MAX_LENGTH = 250

    override var mLengthToWrite: Int {
        8 + BleSchedule.TITLE_LENGTH +
            min(mContent.data(using: .utf8)?.count ?? 0, BleSchedule.CONTENT_MAX_LENGTH)
    }

    var mYear: Int = 0
    var mMonth: Int = 0
    var mDay: Int = 0
    var mHour: Int = 0
    var mMinute: Int = 0
    var mAdvance: Int = 0 // 提前提醒分钟数, 0 ~ 0xffff
    var mTitle: String = ""
    var mContent: String = ""

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int,
         _ advance: Int, _ title: String, _ content: String) {
        super.init()
        mYear = year
        mMonth = month
        mDay = day
        mHour = hour
        mMinute = minute
        mAdvance = advance
        mTitle = title
        mContent = content
    }

    override func encode() {
        super.encode()
        writeInt8(mId)
        writeInt8(mYear - 2000)
        writeInt8(mMonth)
        writeInt8(mDay)
        writeInt8(mHour)
        writeInt8(mMinute)
        writeInt16(mAdvance)
        writeStringWithFix(mTitle, BleSchedule.TITLE_LENGTH)
        writeStringWithLimit(mContent, BleSchedule.CONTENT_MAX_LENGTH)
        writeInt8(0)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mId = try container.decode(Int.self, forKey: .mId)
        mYear = try container.decode(Int.self, forKey: .mYear)
        mMonth = try container.decode(Int.self, forKey: .mMonth)
        mDay = try container.decode(Int.self, forKey: .mDay)
        mHour = try container.decode(Int.self, forKey: .mHour)
        mMinute = try container.decode(Int.self, forKey: .mMinute)
        mAdvance = try container.decode(Int.self, forKey: .mAdvance)
        mTitle = try container.decode(String.self, forKey: .mTitle)
        mContent = try container.decode(String.self, forKey: .mContent)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mId, forKey: .mId)
        try container.encode(mYear, forKey: .mYear)
        try container.encode(mMonth, forKey: .mMonth)
        try container.encode(mDay, forKey: .mDay)
        try container.encode(mHour, forKey: .mHour)
        try container.encode(mMinute, forKey: .mMinute)
        try container.encode(mAdvance, forKey: .mAdvance)
        try container.encode(mTitle, forKey: .mTitle)
        try container.encode(mContent, forKey: .mContent)
    }

    private enum CodingKeys: String, CodingKey {
        case mId, mYear, mMonth, mDay, mHour, mMinute, mAdvance, mTitle, mContent
    }

    override var description: String {
        "BleSchedule(mScheduleId: \(mId), mYear: \(mYear), mMonth: \(mMonth), mDay: \(mDay)" +
            ", mHour: \(mHour), mMinute: \(mMinute), mAdvance: \(mAdvance), mTitle: \(mTitle)" +
            ", mContent: \(mContent))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = [ "mScheduleId":mId,
                                     "mYear":mYear,
                                     "mMonth":mMonth,
                                     "mDay":mDay,
                                     "mHour":mHour,
                                     "mMinute":mMinute,
                                     "mAdvance":mAdvance,
                                     "mTitle":mTitle,
                                     "mContent":mContent]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleSchedule{
        let newModel = BleSchedule()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mId = dic["mScheduleId"] as? Int ?? 0
        newModel.mYear = dic["mYear"] as? Int ?? 0
        newModel.mMonth = dic["mMonth"] as? Int ?? 0
        newModel.mDay = dic["mDay"] as? Int ?? 0
        newModel.mHour = dic["mHour"] as? Int ?? 0
        newModel.mMinute = dic["mMinute"] as? Int ?? 0
        newModel.mAdvance = dic["mAdvance"] as? Int ?? 0
        newModel.mTitle = dic["mTitle"] as? String ?? ""
        newModel.mContent = dic["mContent"] as? String ?? ""
        return newModel
    }
}
