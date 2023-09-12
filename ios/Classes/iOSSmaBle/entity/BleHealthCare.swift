//
//  BleHealthCare.swift
//  SmartV3
//
//  Created by SMA on 2020/5/20.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

/**设置生理健康*/

class BleHealthCare: BleWritable {

    static let ITEM_LENGTH = 10
    static let defaultDate = Date()

    var mEnabled = 1//默认开
    var mReminderHour = 20 // 提醒小时
    var mReminderMinute = 0
    var mMenstruationReminderAdvance = 1 // 生理期提醒提前天数
    var mOvulationReminderAdvance = 3 // 排卵期提醒提前天数
    var mLatestYear = 0 // 上次生理期日期
    var mLatestMonth = 0
    var mLatestDay = 0
    
    var mMenstruationDuration = 5 // 生理期持续时间，天
    var mMenstruationPeriod = 28 // 生理期周期，天

    override var mLengthToWrite: Int {
        BleHealthCare.ITEM_LENGTH
    }

    init(_ reminderH: Int, _ reminderM: Int, _ menstruation: Int, _ ovulation: Int, _ LastMensY: Int, _ LastMensM: Int, _ LastMensD: Int, _ cycle: Int, _ mSwitch: Int, _ period: Int) {
        super.init()
        mEnabled = mSwitch
        mReminderHour = reminderH
        mReminderMinute = reminderM
        mMenstruationReminderAdvance = menstruation
        mOvulationReminderAdvance = ovulation
        mLatestYear = LastMensY
        mLatestMonth = LastMensM
        mLatestDay = LastMensD
        mMenstruationPeriod = cycle
        mMenstruationDuration = period

    }

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func encode() {
        super.encode()
        writeInt8(mEnabled)
        writeInt8(mReminderHour)
        writeInt8(mReminderMinute)
        writeInt8(mMenstruationReminderAdvance)
        writeInt8(mOvulationReminderAdvance)
        writeInt8(mLatestYear - 2000)
        writeInt8(mLatestMonth)
        writeInt8(mLatestDay)
        writeInt8(mMenstruationDuration)
        writeInt8(mMenstruationPeriod)

    }

    override func decode() {
        super.decode()
        mEnabled = Int(readUInt8())
        mReminderHour = Int(readUInt8())
        mReminderMinute = Int(readUInt8())
        mMenstruationReminderAdvance = Int(readUInt8())
        mOvulationReminderAdvance = Int(readUInt8())
        mLatestYear = Int(readUInt8()) + 2000
        mLatestMonth = Int(readUInt8())
        mLatestDay = Int(readUInt8())
        mMenstruationDuration = Int(readUInt8())
        mMenstruationPeriod = Int(readUInt8())

    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mEnabled = try container.decode(Int.self, forKey: .mEnabled)
        mReminderHour = try container.decode(Int.self, forKey: .mReminderHour)
        mReminderMinute = try container.decode(Int.self, forKey: .mReminderMinute)
        mMenstruationReminderAdvance = try container.decode(Int.self, forKey: .mMenstruationReminderAdvance)
        mOvulationReminderAdvance = try container.decode(Int.self, forKey: .mOvulationReminderAdvance)
        mLatestYear = try container.decode(Int.self, forKey: .mLatestYear)
        mLatestMonth = try container.decode(Int.self, forKey: .mLatestMonth)
        mLatestDay = try container.decode(Int.self, forKey: .mLatestDay)
        mMenstruationDuration = try container.decode(Int.self, forKey: .mMenstruationDuration)
        mMenstruationPeriod = try container.decode(Int.self, forKey: .mMenstruationPeriod)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mEnabled, forKey: .mEnabled)
        try container.encode(mReminderHour, forKey: .mReminderHour)
        try container.encode(mReminderMinute, forKey: .mReminderMinute)
        try container.encode(mMenstruationReminderAdvance, forKey: .mMenstruationReminderAdvance)
        try container.encode(mOvulationReminderAdvance, forKey: .mOvulationReminderAdvance)
        try container.encode(mLatestYear, forKey: .mLatestYear)
        try container.encode(mLatestMonth, forKey: .mLatestMonth)
        try container.encode(mLatestDay, forKey: .mLatestDay)
        try container.encode(mMenstruationDuration, forKey: .mMenstruationDuration)
        try container.encode(mMenstruationPeriod, forKey: .mMenstruationPeriod)
    }

    private enum CodingKeys: String, CodingKey {
        case mEnabled, mReminderHour, mReminderMinute, mMenstruationReminderAdvance, mOvulationReminderAdvance, mLatestYear, mLatestMonth, mLatestDay, mMenstruationDuration, mMenstruationPeriod
    }
    
    override var description: String {
        "BleHealthCare(mReminderHour: \(mReminderHour),mReminderMinute:\(mReminderMinute), mMenstruationReminderAdvance: \(mMenstruationReminderAdvance), mOvulationReminderAdvance: \(mOvulationReminderAdvance), mLatestYear: \(mLatestYear),mLatestMonth:\(mLatestMonth),mLatestDay:\(mLatestDay), mMenstruationPeriod: \(mMenstruationPeriod), mEnabled: \(mEnabled),mMenstruationDuration:\(mMenstruationDuration))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mReminderHour":mReminderHour,
                                    "mReminderMinute":mReminderMinute,
                                    "mMenstruationReminderAdvance":mMenstruationReminderAdvance,
                                    "mOvulationReminderAdvance":mOvulationReminderAdvance,
                                    "mLatestYear":mLatestYear,
                                    "mLatestMonth":mLatestMonth,
                                    "mLatestDay":mLatestDay,
                                    "mMenstruationPeriod":mMenstruationPeriod,
                                    "mMenstruationDuration":mMenstruationDuration,
                                    "mEnabled":mEnabled]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleHealthCare{
        let newModel = BleHealthCare()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mReminderHour = dic["mReminderHour"] as? Int ?? 0
        newModel.mReminderMinute = dic["mReminderMinute"] as? Int ?? 0
        newModel.mMenstruationReminderAdvance = dic["mMenstruationReminderAdvance"] as? Int ?? 0
        newModel.mOvulationReminderAdvance = dic["mOvulationReminderAdvance"] as? Int ?? 0
        newModel.mLatestYear = dic["mLatestYear"] as? Int ?? 0
        newModel.mLatestMonth = dic["mLatestMonth"] as? Int ?? 0
        newModel.mLatestDay = dic["mLatestDay"] as? Int ?? 0
        newModel.mMenstruationDuration = dic["mMenstruationDuration"] as? Int ?? 0
        newModel.mMenstruationPeriod = dic["mMenstruationPeriod"] as? Int ?? 0
        newModel.mEnabled = dic["mEnabled"] as? Int ?? 0
        return newModel
    }
}
