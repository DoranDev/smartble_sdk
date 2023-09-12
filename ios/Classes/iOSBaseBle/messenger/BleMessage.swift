//
// Created by Best Mafen on 2019/9/19.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 发送端的消息对象，代表了手机对蓝牙设备发起的一次操作。
 */
class BleMessage: CustomStringConvertible {

    var description: String {
        "BleMessage()"
    }
}

/**
 * 写操作，相当于执行n次CBPeripheral.writeValue()，如果消息长度超过了BaseBleMessenger.mPacketSize，
 * 会被拆分成多条消息。
 */
class WriteMessage: BleMessage {
    let mService: String
    let mCharacteristic: String
    let mData: Data

    init(_ service: String, _ characteristic: String, _ data: Data) {
        mService = service
        mCharacteristic = characteristic
        mData = data
    }

    override var description: String {
        "WriteMessage(mService: \(mService), mCharacteristic: \(mCharacteristic), mData: \(mData.mHexString))"
    }
}

/**
 * 读操作，相当于执行CBPeripheral.readValue()。
 */
class ReadMessage: BleMessage {
    let mService: String
    let mCharacteristic: String

    init(_ service: String, _ characteristic: String) {
        mService = service
        mCharacteristic = characteristic
    }

    override var description: String {
        "ReadMessage(mService: \(mService), mCharacteristic: \(mCharacteristic))"
    }
}

/**
 * 打开通知，相当于执行CBPeripheral.setNotifyValue()。
 */
class NotifyMessage: BleMessage {
    let mService: String
    let mCharacteristic: String
    let mEnabled: Bool

    init(_ service: String, _ characteristic: String, _ enabled: Bool) {
        mService = service
        mCharacteristic = characteristic
        mEnabled = enabled
    }

    override var description: String {
        "NotifyMessage(mService: \(mService), mCharacteristic: \(mCharacteristic), mEnabled: \(mEnabled))"
    }
}
