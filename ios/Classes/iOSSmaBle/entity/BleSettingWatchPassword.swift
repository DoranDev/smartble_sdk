//
//  BleSettingWatchPassword.swift
//  SmartV3
//
//  Created by SMA-IOS on 2022/8/25.
//  Copyright © 2022 KingHuang. All rights reserved.
//

import Foundation

class BleSettingWatchPassword: BleWritable {
    static let ITEM_LENGTH = 5
    static let PASSWORD_LENGTH = 4
    override var mLengthToWrite: Int {
        BleSettingWatchPassword.ITEM_LENGTH
    }
    var mEnabled: Int = 0 //0->off 1->open
    var mPassword: String = "1234"
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mEnabled = try container.decode(Int.self, forKey: .mEnabled)
        mPassword = try container.decode(String.self, forKey: .mPassword)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mEnabled, forKey: .mEnabled)
        try container.encode(mPassword, forKey: .mPassword)
    }
    
    private enum CodingKeys: String, CodingKey {
        case mEnabled, mPassword
    }
    
    override func encode() {
        super.encode()
        writeInt8(mEnabled)
        writeStringWithFix(mPassword,BleSettingWatchPassword.PASSWORD_LENGTH)
    }
    
    override func decode() {
        super.decode()
        mEnabled = Int(readUInt8())
        mPassword = readString(BleSettingWatchPassword.PASSWORD_LENGTH)

    }
    
    override var description: String {
        "BleSettingWatchPassword(mEnabled: \(mEnabled), mPassword: \(mPassword)"
    }
}
