//
// Created by Best Mafen on 2019/9/27.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleUserProfile: BleWritable {
    static let ITEM_LENGTH = 11

    static let METRIC = 0
    static let IMPERIAL = 1

    static let FEMALE = 0
    static let MALE = 1

    override var mLengthToWrite: Int {
        BleUserProfile.ITEM_LENGTH
    }

    var mUnit = METRIC
    var mGender = FEMALE
    var mAge = 20
    var mHeight: Float = 0.0
    var mWeight: Float = 0.0

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ unit: Int, _ gender: Int, _ age: Int, _ height: Float, _ weight: Float) {
        super.init()
        mUnit = unit
        mGender = gender
        mAge = age
        mHeight = height
        mWeight = weight
    }

    override func encode() {
        super.encode()
        writeInt8(mUnit)
        writeInt8(mGender)
        writeInt8(mAge)
        writeFloat(mHeight, .LITTLE_ENDIAN)
        writeFloat(mWeight, .LITTLE_ENDIAN)
    }

    override func decode() {
        super.decode()
        mUnit = Int(readUInt8())
        mGender = Int(readUInt8())
        mAge = Int(readUInt8())
        mHeight = readFloat(.LITTLE_ENDIAN)
        mWeight = readFloat(.LITTLE_ENDIAN)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mUnit = try container.decode(Int.self, forKey: .mUnit)
        mGender = try container.decode(Int.self, forKey: .mGender)
        mAge = try container.decode(Int.self, forKey: .mAge)
        mHeight = try container.decode(Float.self, forKey: .mHeight)
        mWeight = try container.decode(Float.self, forKey: .mWeight)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mUnit, forKey: .mUnit)
        try container.encode(mGender, forKey: .mGender)
        try container.encode(mAge, forKey: .mAge)
        try container.encode(mHeight, forKey: .mHeight)
        try container.encode(mWeight, forKey: .mWeight)
    }

    private enum CodingKeys: String, CodingKey {
        case mUnit, mGender, mAge, mHeight, mWeight
    }

    override var description: String {
        "BleUserProfile(mUnit: \(mUnit), mGender: \(mGender), mAge: \(mAge), mHeight: \(mHeight)"
            + ", mWeight: \(mWeight))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mUnit":mUnit,
                                    "mGender":mGender,
                                    "mAge":mAge,
                                    "mHeight":mHeight,
                                    "mWeight":mWeight]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleUserProfile{

        let newModel = BleUserProfile()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mUnit = dic["mId"] as? Int ?? 0
        newModel.mGender = dic["mEnabled"] as? Int ?? 0
        newModel.mAge = dic["mRepeat"] as? Int ?? 0
        newModel.mHeight = dic["mYear"] as? Float ?? 0
        newModel.mWeight = dic["mMonth"] as? Float ?? 0
        return newModel
    }
}
