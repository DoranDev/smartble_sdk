//
//  BleAerobicSettings.swift
//  SmartV3
//
//  Created by SMA on 2021/4/9.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class BleAerobicSettings: BleWritable {
    override var mLengthToWrite: Int {
        BleAerobicSettings.ITEM_LENGTH
    }
    
    static let ITEM_LENGTH = 9
    var mHour :Int = 0 // 0-23
    var mMin: Int = 0 //0-59
    var mHRMin :Int = 0 // hr min
    var mHRMax: Int = 0 //hr max
    var mHRMinTime :Int = 0 // 1-30
    var mHRMinVibration: Int = 0 //1-4
    var mHRMaxTime :Int = 0 // 1-30
    var mHRMaxVibration: Int = 0 //1-4
    var mHRIntermediate :Int = 0 // 1-30


    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func encode() {
        super.encode()
        writeInt8(mHour)
        writeInt8(mMin)
        writeInt8(mHRMin)
        writeInt8(mHRMax)
        writeInt8(mHRMinTime)
        writeInt8(mHRMinVibration)
        writeInt8(mHRMaxTime)
        writeInt8(mHRMaxVibration)
        writeInt8(mHRIntermediate)
    }

    override func decode() {
        super.decode()
        mHour = Int(readUInt8())
        mMin = Int(readUInt8())
        mHRMin = Int(readUInt8())
        mHRMax = Int(readUInt8())
        mHRMinTime = Int(readUInt8())
        mHRMinVibration = Int(readUInt8())
        mHRMaxTime = Int(readUInt8())
        mHRMaxVibration = Int(readUInt8())
        mHRIntermediate = Int(readUInt8())
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mMin = try container.decode(Int.self, forKey: .mHour)
        mMin = try container.decode(Int.self, forKey: .mMin)
        mHRMin = try container.decode(Int.self, forKey: .mHRMin)
        mHRMax = try container.decode(Int.self, forKey: .mHRMax)
        mHRMinTime = try container.decode(Int.self, forKey: .mHRMinTime)
        mHRMinVibration = try container.decode(Int.self, forKey: .mHRMinVibration)
        mHRMaxTime = try container.decode(Int.self, forKey: .mHRMaxTime)
        mHRMaxVibration = try container.decode(Int.self, forKey: .mHRMaxVibration)
        mHRIntermediate = try container.decode(Int.self, forKey: .mHRIntermediate)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mHour, forKey: .mHour)
        try container.encode(mMin, forKey: .mMin)
        try container.encode(mHRMin, forKey: .mHRMin)
        try container.encode(mHRMax, forKey: .mHRMax)
        try container.encode(mHRMinTime, forKey: .mHRMinTime)
        try container.encode(mHRMinVibration, forKey: .mHRMinVibration)
        try container.encode(mHRMaxTime, forKey: .mHRMaxTime)
        try container.encode(mHRMaxVibration, forKey: .mHRMaxVibration)
        try container.encode(mHRIntermediate, forKey: .mHRIntermediate)
        
    }

    private enum CodingKeys: String, CodingKey {
        case mHour, mMin, mHRMin, mHRMax, mHRMinTime, mHRMinVibration, mHRMaxTime, mHRMaxVibration, mHRIntermediate
    }

    override var description: String {
        "BleAerobicSettings(mHour: \(mHour), mMin: \(mMin), mHRMin: \(mHRMin), mHRMax: \(mHRMax), mHRMinTime: \(mHRMinTime), mHRMinVibration: \(mHRMinVibration), mHRMaxTime: \(mHRMaxTime), mHRMaxVibration: \(mHRMaxVibration), mHRIntermediate: \(mHRIntermediate))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mHour":mHour,
                                    "mMin":mMin,
                                    "mHRMin":mHRMin,
                                    "mHRMax":mHRMax,
                                    "mHRMinTime":mHRMinTime,
                                    "mHRMinVibration":mHRMinVibration,
                                    "mHRMaxTime":mHRMaxTime,
                                    "mHRMaxVibration":mHRMaxVibration,
                                    "mHRIntermediate":mHRIntermediate]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleAerobicSettings{

        let newModel = BleAerobicSettings()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mHour = dic["mHour"] as? Int ?? 0
        newModel.mMin = dic["mMin"] as? Int ?? 0
        newModel.mHRMin = dic["mHRMin"] as? Int ?? 0
        newModel.mHRMax = dic["mHRMax"] as? Int ?? 0
        newModel.mHRMinTime = dic["mHRMinTime"] as? Int ?? 0
        newModel.mHRMinVibration = dic["mHRMinVibration"] as? Int ?? 0
        newModel.mHRMaxTime = dic["mHRMaxTime"] as? Int ?? 0
        newModel.mHRMaxVibration = dic["mHRMaxVibration"] as? Int ?? 0
        newModel.mHRIntermediate = dic["mHRIntermediate"] as? Int ?? 0
        return newModel
    }
}
