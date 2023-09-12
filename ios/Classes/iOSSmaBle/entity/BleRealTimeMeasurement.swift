//
//  BleRealTimeMeasurement.swift
//  SmartV3
//
//  Created by SMA-IOS on 2022/8/25.
//  Copyright © 2022 KingHuang. All rights reserved.
//

import Foundation

class BleRealTimeMeasurement: BleWritable {
    static let ITEM_LENGTH = 1
    override var mLengthToWrite: Int {
        BleRealTimeMeasurement.ITEM_LENGTH
    }
    
    var mHRSwitch: Int = 0 //心率 HR  0->off 1->open
    var mBOSwitch: Int = 0 //血氧 BloodOxygen
    var mBPSwitch: Int = 0 //血压 Blood Pressure
    
    override func encode() {
        super.encode()
        writeIntN(0,5)
        writeIntN(mBPSwitch,1)
        writeIntN(mBOSwitch,1)
        writeIntN(mHRSwitch,1)
    }
    
    override func decode() {
        super.decode()
        _ = readUIntN(5)
        mBPSwitch = Int(readUIntN(1))        
        mBOSwitch = Int(readUIntN(1))
        mHRSwitch = Int(readUIntN(1))
    }
    
    override var description: String {
        "BleRealTimeMeasurement(mHRSwitch: \(mHRSwitch), mBOSwitch: \(mBOSwitch), mBPSwitch: \(mBPSwitch))"
    }
}
