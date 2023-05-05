//
// Created by Best Mafen on 2019/9/19.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleMessenger: BaseBleMessenger {
    static let TIME_OUT = 4.0
    static let MAX_RETRY_TIMES = 3

    private var mBleMessages = [BleMessage]()

    private var mWritePackets = [WriteMessage]()
    private let mPacketsQueue = DispatchQueue(label: "PacketsQueue")
    private let mPacketsCondition = NSCondition()
    private let mPacketsSemaphore = BleSemaphore(1)

    private var mTaskTimer: Timer? = nil
    private var mTask: BleMessage? = nil
    private var mRetry = 0

    private var mPacketTimer: Timer? = nil
    private var mPacket: WriteMessage? = nil

    /**
     互斥锁,传输大文件时需要开线程边装包边发送,需要互斥锁
     */
    private let mLock = NSLock()

    var mMessengerDelegate: BleMessengerDelegate?

    override func setTargetConnector(_ bleConnector: BaseBleConnector) {
        super.setTargetConnector(bleConnector)
        mPacketsQueue.async() {
            while true {
                if self.mWritePackets.count > 0{
                    self.mPacketsSemaphore.acquire()
                    objc_sync_enter(self.mLock)
                    // 数组不为空在执行removeFirst, 否则闪退
                    if !self.mWritePackets.isEmpty {
                        self.mPacket = self.mWritePackets.removeFirst()
                    }
                    objc_sync_exit(self.mLock)
                    self.mPacketTimer?.fireDate = Date()
                }else{
                    self.mPacketsCondition.wait()
                }
            }
        }

        mPacketTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            if self.mBaseBleConnector.mPeripheral != nil && self.mPacket != nil {
                let cbCharacteristic = self.mBaseBleConnector.getCharacteristic(self.mPacket!.mService, self.mPacket!.mCharacteristic)
                if cbCharacteristic != nil {
                    #if DEBUG
                    bleLog("BleMessenger write packet \(String(describing: self.mBaseBleConnector.mPeripheral?.canSendWriteWithoutResponse)) -> \(self.mPacket!.description)")
                    #else
                    bleLog("BleMessenger write packet -> mService: \(self.mPacket!.mService), mCharacteristic: \(self.mPacket!.mCharacteristic), mDataCount: \(self.mPacket!.mData.count),mSupportNewTransportMode: \(BleCache.shared.mSupportNewTransportMode)")
                    #endif
                    if BleCache.shared.mSupportNewTransportMode == 1{
                        self.mBaseBleConnector.mPeripheral?.writeValue(self.mPacket!.mData, for: cbCharacteristic!,
                            type: .withoutResponse)
                    }else{
                        self.mBaseBleConnector.mPeripheral?.writeValue(self.mPacket!.mData, for: cbCharacteristic!,
                            type: .withResponse)
                    }
                }
            }
        })
        mPacketTimer?.fireDate = Date.distantFuture
    }

    override func enqueueMessage(_ message: BleMessage) {
        objc_sync_enter(mLock)
        mBleMessages.append(message)
        if mTaskTimer == nil {
            dequeueMessage()
        }
        objc_sync_exit(mLock)
    }

    override func dequeueMessage() {
        objc_sync_enter(mLock)
        if mTaskTimer != nil {
            mTaskTimer?.invalidate()
            mTaskTimer = nil
        }
        if mBleMessages.count > 0 {
            mRetry = 0
            mTask = mBleMessages.remove(at: 0) // Fatal error: UnsafeMutablePointer. deinitialize with negative count -> enLock fix
            #if DEBUG
            bleLog("BleMessenger dequeueMessage -> \(mTask?.description ?? ""))")
            #else
            bleLog("BleMessenger mBleMessages -> \(mBleMessages.count))")
            #endif
            mTaskTimer = Timer.scheduledTimer(withTimeInterval: BleMessenger.TIME_OUT, repeats: true, block: { _ in
                if self.mRetry == BleMessenger.MAX_RETRY_TIMES {
                    self.dequeueMessage()
                    return
                }
                if self.mRetry >= 1{
                    bleLog("超时补发 - \(self.mRetry)")
                }
                self.mRetry += 1
                if let readMessage = self.mTask as? ReadMessage {
                    if self.mBaseBleConnector.mPeripheral != nil {
                        let cbCharacteristic = self.mBaseBleConnector.getCharacteristic(readMessage.mService, readMessage.mCharacteristic)
                        if cbCharacteristic != nil {
                            self.mBaseBleConnector.mPeripheral?.readValue(for: cbCharacteristic!)
                        }
                    }
                } else if let writeMessage = self.mTask as? WriteMessage {
                    if self.mRetry > 1 {
                        self.mMessengerDelegate?.onRetry()
                    }
                    self.enqueueWritePackets(writeMessage)
                } else if let notifyMessage = self.mTask as? NotifyMessage {
                    if self.mBaseBleConnector.mPeripheral != nil {
                        let cbCharacteristic = self.mBaseBleConnector.getCharacteristic(notifyMessage.mService, notifyMessage.mCharacteristic)
                        if cbCharacteristic != nil {
                            self.mBaseBleConnector.mPeripheral?.setNotifyValue(notifyMessage.mEnabled, for: cbCharacteristic!)
                        }
                    }
                }
            })
            mTaskTimer?.fire()
        } else {
            bleLog("BleMessenger dequeueMessage -> No message right now")
        }
        objc_sync_exit(mLock)
    }

    func enqueueWritePackets(_ message: WriteMessage) {
        objc_sync_enter(mLock)
        let count: Int
        if message.mData.count % mPacketSize == 0 {
            count = message.mData.count / mPacketSize
        } else {
            count = message.mData.count / mPacketSize + 1
        }

        if count == 1 {
            mWritePackets.append(message)
        } else {
            for i in 0..<count {
                let data: Data
                if i == count - 1 {
                    data = message.mData.subdata(in: i * mPacketSize..<message.mData.count)
                } else {
                    data = message.mData.subdata(in: i * mPacketSize..<(i + 1) * mPacketSize)
                }
                mWritePackets.append(WriteMessage(message.mService, message.mCharacteristic, data))
            }
        }
        mPacketsCondition.signal()
        objc_sync_exit(mLock)
    }

    override func dequeueWritePacket() {
        mPacketTimer?.fireDate = Date.distantFuture
        if mPacketsSemaphore.mAvailablePermits < 1 {
            mPacketsSemaphore.release()
        }
    }

    func replyMessage(_ message: WriteMessage) {
        enqueueWritePackets(message)
    }

    override func reset() {
        if mTaskTimer != nil {
            mTaskTimer?.invalidate()
            mTaskTimer = nil
        }
        mPacketTimer?.fireDate = Date.distantFuture
        mBleMessages.removeAll()
        mWritePackets.removeAll()
        objc_sync_enter(mLock)
        mPacketsSemaphore.reset()
        objc_sync_exit(mLock)
    }
    
//    override func resetUploadFile() {
//        if mTaskTimer != nil {
//            mTaskTimer?.invalidate()
//            mTaskTimer = nil
//        }
//        mBleMessages.removeAll()
//    }
}
