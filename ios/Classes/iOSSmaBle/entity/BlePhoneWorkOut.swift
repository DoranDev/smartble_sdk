//
//  BlePhoneWorkOut.swift
//  SmartV3
//
//  Created by SMA-IOS on 2021/12/24.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation


class BlePhoneWorkOut: BleWritable {
    static let ITEM_LENGTH = 32
    
    var mStep = 0
    var mDistance = 0 // 1m
    var mCalories = 0 //1kcal
    var mDuration  = 0 // 运动持续时长，数据以秒为单位
    var mSmp = 0  //平均步频
    var mAltitude  = 0 // 海拔高度，数据以米为单位
    var mAirPressure = 0 // 气压，数据以 kPa 为单位
    var mAvgPace = 0 //s/km
    var mAvgSpeed = 0 //h/km
    var mModeSport = 0 //运动模式
    var mUndefined = 0 //占位符
    
    override var mLengthToWrite: Int {
        BlePhoneWorkOut.ITEM_LENGTH
    }
    
    init(_ step: Int, _ distance: Int, _ calories: Int, _ duration: Int, _ smp: Int, _ altiude: Int, _ airPressure: Int, _ avgPace: Int, _ avgSpeed: Int, _ modeType: Int) {
        super.init()
        mStep = step
        mDistance = distance
        mCalories = calories
        mDuration = duration
        mSmp = smp
        mAltitude = altiude
        mAirPressure = airPressure
        mAvgPace = avgPace
        mAvgSpeed = avgSpeed
        mModeSport = modeType
    }

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func encode() {
        super.encode()
        writeInt32(mStep,.LITTLE_ENDIAN)
        writeInt32(mDistance, .LITTLE_ENDIAN)
        writeInt32(mCalories, .LITTLE_ENDIAN)
        writeInt16(mDuration, .LITTLE_ENDIAN)
        writeInt16(mSmp, .LITTLE_ENDIAN)
        writeInt16(mAltitude, .LITTLE_ENDIAN)
        writeInt16(mAirPressure, .LITTLE_ENDIAN)
        writeInt32(mAvgPace, .LITTLE_ENDIAN)
        writeInt32(mAvgSpeed, .LITTLE_ENDIAN)
        writeInt8(mModeSport)
        writeInt24(mUndefined, .LITTLE_ENDIAN)

    }

    override func decode() {
        super.decode()
        mStep = Int(readUInt32())
        mDistance = Int(readUInt32())
        mCalories = Int(readUInt32())
        mDuration = Int(readUInt16())
        mSmp = Int(readUInt16())
        mAltitude = Int(readUInt16())
        mAirPressure = Int(readUInt16())
        mAvgPace = Int(readUInt32())
        mAvgSpeed = Int(readUInt32())
        mModeSport = Int(readUInt8())
        mUndefined = Int(readUInt24())
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mStep = try container.decode(Int.self, forKey: .wrokStep)
        mDistance = try container.decode(Int.self, forKey: .wrokDistance)
        mCalories = try container.decode(Int.self, forKey: .wrokCalories)
        mDuration = try container.decode(Int.self, forKey: .wrokDuration)
        mSmp = try container.decode(Int.self, forKey: .wrokSmp)
        mAltitude = try container.decode(Int.self, forKey: .wrokAltitude)
        mAirPressure = try container.decode(Int.self, forKey: .wrokAirPressure)
        mAvgPace = try container.decode(Int.self, forKey: .wrokAvgPace)
        mAvgSpeed = try container.decode(Int.self, forKey: .wrokAvgSpeed)
        mModeSport = try container.decode(Int.self, forKey: .wrokModeSport)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mStep, forKey: .wrokStep)
        try container.encode(mDistance, forKey: .wrokDistance)
        try container.encode(mCalories, forKey: .wrokCalories)
        try container.encode(mDuration, forKey: .wrokDuration)
        try container.encode(mSmp, forKey: .wrokSmp)
        try container.encode(mAltitude, forKey: .wrokAltitude)
        try container.encode(mAirPressure, forKey: .wrokAirPressure)
        try container.encode(mAvgPace, forKey: .wrokAvgPace)
        try container.encode(mAvgSpeed, forKey: .wrokAvgSpeed)
        try container.encode(mModeSport, forKey: .wrokModeSport)
    }

    private enum CodingKeys: String, CodingKey {
        case wrokStep, wrokDistance, wrokCalories, wrokDuration, wrokSmp, wrokAltitude, wrokAirPressure, wrokAvgPace, wrokAvgSpeed, wrokModeSport
    }

    override var description: String {
        "BlePhoneWorkOut(mStep: \(mStep) mDistance: \(mDistance), mCalories: \(mCalories), mDuration: \(mDuration), mSmp: \(mSmp), mAltitude: \(mAltitude), mAirPressure: \(mAirPressure), mAvgPace: \(mAvgPace), mAvgSpeed: \(mAvgSpeed), mModeSport: \(mModeSport)"
    }
    
}
