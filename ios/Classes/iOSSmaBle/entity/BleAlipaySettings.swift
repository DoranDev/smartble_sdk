//
//  BleAlipaySettings.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/3/15.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

class BleAlipaySettings: BleWritable {
    
    var mAlipayVersion: Int = 0  // 支付宝版本号
    var isActivate: Int = 0      // 是否需要激活操作? 0:否  1:是
    var mAddress: Data = Data()  // mac地址
    
    override var mLengthToWrite: Int {
        BleAlipaySettings.ITEM_LENGTH
    }
    static let ADDRESS_LENGTH = 6
    static let ITEM_LENGTH = BleAlipaySettings.ADDRESS_LENGTH + 4
    
    override func encode() {
        super.encode()
        
        writeInt8(mAlipayVersion)
        writeInt8(isActivate)
        writeData(Data(mAddress.reversed()))  // 这里需要字节反转
    }
    
    override func decode() {
        super.decode()
        
        mAlipayVersion = Int(readUInt8())
        mAlipayVersion = Int(readUInt8())
        mAddress = readData(BleAlipaySettings.ADDRESS_LENGTH)
    }
    
    
    override var description: String {
        return "BleAlipaySettings(mAlipayVersion=\(mAlipayVersion), isActivate=\(isActivate), mAddress=\(mAddress.mHexString))"
    }
}
