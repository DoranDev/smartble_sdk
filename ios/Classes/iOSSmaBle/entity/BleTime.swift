//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleTime: BleWritable {
    static let ITEM_LENGTH = 6

    override var mLengthToWrite: Int {
        BleTime.ITEM_LENGTH
    }

    var mYear = 2000
    var mMonth = 1
    var mDay = 1
    var mHour = 1
    var mMinute = 1
    var mSecond = 1

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int) {
        super.init()
        mYear = year
        mMonth = month
        mDay = day
        mHour = hour
        mMinute = minute
        mSecond = second
    }

    private convenience init(_ date: Date, _ calendar: Calendar) {
        self.init(
            calendar.component(.year, from: date),
            calendar.component(.month, from: date),
            calendar.component(.day, from: date),
            calendar.component(.hour, from: date),
            calendar.component(.minute, from: date),
            calendar.component(.second, from: date)
        )
    }

    override func encode() {
        super.encode()
        writeInt8(mYear - 2000)
        writeInt8(mMonth)
        writeInt8(mDay)
        writeInt8(mHour)
        writeInt8(mMinute)
        writeInt8(mSecond)
    }

    override func decode() {
        super.decode()
        mYear = Int(readUInt8()) + 2000
        mMonth = Int(readUInt8())
        mDay = Int(readUInt8())
        mHour = Int(readUInt8())
        mMinute = Int(readUInt8())
        mSecond = Int(readUInt8())
    }

    // 将本地时间转为时间戳
    func timeIntervalSince1970ByLocal() -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = mYear
        dateComponents.month = mMonth
        dateComponents.day = mDay
        dateComponents.hour = mHour
        dateComponents.minute = mMinute
        dateComponents.second = mSecond
        return Int(Calendar.current.date(from: dateComponents)?.timeIntervalSince1970 ?? 0)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mYear = try container.decode(Int.self, forKey: .mYear)
        mMonth = try container.decode(Int.self, forKey: .mMonth)
        mDay = try container.decode(Int.self, forKey: .mDay)
        mHour = try container.decode(Int.self, forKey: .mHour)
        mMinute = try container.decode(Int.self, forKey: .mMinute)
        mSecond = try container.decode(Int.self, forKey: .mSecond)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mYear, forKey: .mYear)
        try container.encode(mMonth, forKey: .mMonth)
        try container.encode(mDay, forKey: .mDay)
        try container.encode(mHour, forKey: .mHour)
        try container.encode(mMinute, forKey: .mMinute)
        try container.encode(mSecond, forKey: .mSecond)
    }

    private enum CodingKeys: String, CodingKey {
        case mYear, mMonth, mDay, mHour, mMinute, mSecond
    }

    override var description: String {
        "BleTime(mYear: \(mYear), mMonth: \(mMonth), mDay: \(mDay), mHour: \(mHour), mMinute: \(mMinute), mSecond: \(mSecond))"
    }

    static var utcTimeZone: TimeZone {
        TimeZone.init(secondsFromGMT: 0)!
    }

    static func utc() -> BleTime {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = utcTimeZone
        let nowTime = Date.init()
        let componentsSet = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
        let componentss = calendar.dateComponents(componentsSet, from: nowTime)
        return BleTime(calendar.date(from: componentss)!, calendar)
    }

    static func local() -> BleTime {
        let calendar = Calendar.init(identifier: .gregorian)//Specify Gregorian
        let nowTime = Date.init()
        let componentsSet = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
        let componentss = calendar.dateComponents(componentsSet, from: nowTime)
        return BleTime(calendar.date(from: componentss)!, calendar)
    }

    static func ofLocal(_ timeIntervalSince1970: Int) -> BleTime {
        let date = Date(timeIntervalSince1970: TimeInterval(timeIntervalSince1970))
        let calendar = Calendar.init(identifier: .gregorian)
        return BleTime(date, calendar)
    }
}
