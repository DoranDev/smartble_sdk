//
// Created by Best Mafen on 2019/9/21.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleParser: BleParserDelegate {
    private var mData: Data = Data(count: 0)
    private var mReceived = -1
    private let mLock = NSLock()

    func onReceive(_ data: Data) -> Data? {
        objc_sync_enter(mLock)
        if data.count < 1 {
            return nil
        }
        /**
         固件消息  0xAB 0x30 0x00 0x00 0x00 0x00 0x03 0x01
         导致 mData[mReceived..<mReceived + data.count] = data 越界
         */
        if mReceived == -1 {
            if data[0] != 0xAB {
                //杰里平台需要此判断,第一包不是AB则抛弃不做处理
                bleLog("onReceive != 0xAB data = \(data.mHexString)")
                return nil
            }
            let contentLength = data.getUInt(MessageFactory.LENGTH_BEFORE_LENGTH, MessageFactory.LENGTH_PAYLOAD_LENGTH)
            mData = Data(count: MessageFactory.LENGTH_BEFORE_CMD + contentLength)
            mReceived = 0
        }
        
        bleLog("flag = 004, BleParser onReceive -> total=\(mData.count), received=\(mReceived), data:\(data.count)")
        if mReceived < mData.count {
            mData[mReceived..<mReceived + data.count] = data
            mReceived += data.count
            bleLog("flag = 005, BleParser onReceive -> total=\(mData.count), received=\(mReceived)")

            if mReceived >= mData.count {
                mReceived = -1
                return mData
            }
        }
        objc_sync_exit(mLock)
        return nil
    }

    func reset() {
        mData = Data(count: 0)
        mReceived = -1
    }
}
