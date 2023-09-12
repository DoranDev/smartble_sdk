//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleStream: NSObject {
    var mBleKey: BleKey = .NONE
    var mType: Int = 0
    var mData: Data = Data()

    init(_ bleKey: BleKey, _ type: Int, _ data: Data) {
        super.init()
        mBleKey = bleKey
        mType = type
        mData = data
    }

    func getPacket(_ index: Int, _ packetSize: Int) -> BleStreamPacket? {
        if index >= mData.count {
            return nil
        }

        if index + packetSize > mData.count {
            return BleStreamPacket(mType, mData.count, index, mData[index..<mData.count])
        } else {
            return BleStreamPacket(mType, mData.count, index, mData[index..<index + packetSize])
        }
    }
}

//当发送的内容长度超过固件接收buffer的长度时，需要拆分成多条指令发送
class BleStreamPacket: BleWritable {
    static let BUFFER_MAX_SIZE = 480

    override var mLengthToWrite: Int {
        1 + 4 + 4 + mPacket.count
    }

    var mType: Int = 0
    var mSize: Int = 0
    var mIndex: Int = 0
    var mPacket: Data!

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ type: Int, _ size: Int, _ index: Int, _ packet: Data) {
        super.init()
        mType = type
        mSize = size
        mIndex = index
        mPacket = packet
    }

    override func encode() {
        super.encode()
        writeInt8(mType)
        writeInt32(mSize)
        writeInt32(mIndex)
        writeData(mPacket)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override var description: String {
        "BleStreamPacket(mType: \(mType), mSize: \(mSize), mIndex: \(mIndex), mPacket: \(mPacket.mHexString)))"
    }
}
