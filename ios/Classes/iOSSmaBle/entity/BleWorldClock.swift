//
//  BleWorldClock.swift
//  SmartV3
//
//  Created by SMA-IOS on 2022/7/14.
//  Copyright © 2022 KingHuang. All rights reserved.
//

import Foundation

class BleWorldClock: BleIdObject {
    static let BLE_CITY_NAME_MAX  = 62
    static let TITLE_LENGTH = 68

    override var mLengthToWrite: Int {
        BleWorldClock.TITLE_LENGTH
    }

    var mLocal : Int = 0
    var mTimeZoneOffset = 1 //偏差时间/15
    var mReversed : Int = 0 //占位符,不处理
    var mCityName = ""

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ local: Int = 0, _ timeZoneOffset: Int = 0, _ cityName: String = "") {
        super.init()
        mLocal = local
        mTimeZoneOffset = timeZoneOffset
        mCityName = cityName
    }

    override func encode() {
        super.encode()
        writeIntN(mLocal, 1)
        writeIntN(mId, 7)
        writeInt8(mTimeZoneOffset)
        writeInt16(mReversed)
        writeStringWithFix(mCityName, BleWorldClock.BLE_CITY_NAME_MAX,.utf16LittleEndian)
        writeInt16(0)//string 补0
    }

    override func decode() {
        super.decode()
        mLocal = Int(readUIntN(1))
        mId = Int(readUIntN(7))
        mTimeZoneOffset = Int(readInt8())
        mReversed = Int(readUInt16())
        mCityName = readString(BleWorldClock.BLE_CITY_NAME_MAX,.utf16LittleEndian)
    }

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mId = try container.decode(Int.self, forKey: .mId)
        mLocal = try container.decode(Int.self, forKey: .mLocal)
        mTimeZoneOffset = try container.decode(Int.self, forKey: .mTimeZoneOffset)
        mCityName = try container.decode(String.self, forKey: .mCityName)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mId, forKey: .mId)
        try container.encode(mLocal, forKey: .mLocal)
        try container.encode(mTimeZoneOffset, forKey: .mTimeZoneOffset)
        try container.encode(mCityName, forKey: .mCityName)
    }

    private enum CodingKeys: String, CodingKey {
        case mId, mLocal, mTimeZoneOffset, mCityName
    }

    override var description: String {
        "BleWorldClock(mId: \(mId), mLocal: \(mLocal), mTimeZoneOffset: \(mTimeZoneOffset), mCityName: \(mCityName))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mId":mId,
                                    "mLocal":mLocal,
                                    "mTimeZoneOffset":mTimeZoneOffset,
                                    "mCityName":mCityName,]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleWorldClock{

        let newModel = BleWorldClock()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mId = dic["mId"] as? Int ?? 0
        newModel.mLocal = dic["mLocal"] as? Int ?? 0
        newModel.mTimeZoneOffset = dic["mTimeZoneOffset"] as? Int ?? 0
        newModel.mCityName = dic["mCityName"] as? String ?? ""
        return newModel
    }
}
