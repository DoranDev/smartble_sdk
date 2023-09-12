//
//  BleBACResultSettings.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/2/10.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

/// 酒精含量测试结果提示设置
class BleBACResultSettings: BleWritable {

    var mLow: Int = 0       //含量低于预设范围
    var mHigh: Int = 0      //含量高于预设范围
    var mNormal: Int = 0    //含量在预设范围内
    var mDuration: Int = 0  //led持续时长, 以秒为单位
    var mVibrate: Int = 0   //震动提醒强度,1到100
    
    
    static let LEVE_RED = 0x00//红
    static let LEVE_GREEN = 0x01//绿
    static let LEVE_YELLOW = 0x02//黄
    
    private let ITEM_LENGTH = 8
    override var mLengthToWrite: Int {
        return ITEM_LENGTH
    }
    
    
    init(mLow: Int, mHigh: Int, mNormal: Int, mDuration: Int, mVibrate: Int) {
        super.init()
        
        self.mLow = mLow
        self.mHigh = mHigh
        self.mNormal = mNormal
        self.mDuration = mDuration
        self.mVibrate = mVibrate
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mLow = try container.decode(Int.self, forKey: .mLow)
        mHigh = try container.decode(Int.self, forKey: .mHigh)
        mNormal = try container.decode(Int.self, forKey: .mNormal)
        mDuration = try container.decode(Int.self, forKey: .mDuration)
        mVibrate = try container.decode(Int.self, forKey: .mVibrate)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mLow, forKey: .mLow)
        try container.encode(mHigh, forKey: .mHigh)
        try container.encode(mNormal, forKey: .mNormal)
        
        try container.encode(mDuration, forKey: .mDuration)
        try container.encode(mVibrate, forKey: .mVibrate)
    }
    
    private enum CodingKeys: String, CodingKey {
        case mLow, mHigh, mNormal, mDuration, mVibrate
    }
  
    override func encode() {
        super.encode()
        writeInt8(mLow)
        writeInt8(mHigh)
        writeInt8(mNormal)
        writeInt8(mDuration)
        writeInt8(mVibrate)
    }
}
