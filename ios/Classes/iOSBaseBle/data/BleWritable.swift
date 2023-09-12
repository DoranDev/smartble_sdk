//
// Created by Best Mafen on 2019/9/25.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 工具类，为方便从Object转换为Data。
 */
class BleWritable: BleReadable, BleBuffer {
    // Subclass should override.
    var mLengthToWrite: Int {
        0
    }

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK - BleBuffer
    func toData() -> Data {
        encode()
        return mData!
    }

    // Subclass should call super.encode().
    func encode() {
        restOffset()
        mData = Data(count: mLengthToWrite)
    }

    /**
     * 写入Int的低n位。
     */
    func writeIntN(_ value: Int, _ n: Int) {
        if n < 1 || n > 8 || outOfRange(n) {
            return
        }

        var mask = 2 << n
        mask >>= 1
        mask -= 1
        let valueToWrite = value & mask
        if mPosition[1] + n <= 8 {
            let shift = 8 - (mPosition[1] + n)
            mData![mPosition[0]] |= UInt8((valueToWrite << shift))
        } else {
            let shift = mPosition[1] + n - 8
            mData![mPosition[0]] |= UInt8((valueToWrite << shift))

            mask = 2 << shift
            mask >>= 1
            mask -= 1
            mask = valueToWrite & mask
            mask <<= 8 - shift
            mData![mPosition[0] + 1] |= UInt8(mask)
        }
        skip(n)
    }

    /**
     * 写入Bool，只写入1位，true写入1，否则写入0。
     */
    func writeBool(_ value: Bool) {
        writeIntN(value ? 1 : 0, 1)
    }

    /**
     * 写入Int的低8位。
     */
    func writeInt8(_ value: Int) {
        writeIntN(value, 8)
    }

    /**
     * 写入Int的低16位。
     */
    func writeInt16(_ value: Int, _ order: ByteOrder? = nil) {
        let high: Int
        let low: Int
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            high = (value >> 8) & 0xff
            low = value & 0xff
        } else {
            low = (value >> 8) & 0xff
            high = value & 0xff
        }
        writeInt8(high)
        writeInt8(low)
    }

    /**
     * 写入Int的低24位。
     */
    func writeInt24(_ value: Int, _ order: ByteOrder? = nil) {
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            writeInt16(value >> 8, ByteOrder.BIG_ENDIAN)
            writeInt8(value & 0xff)
        } else {
            writeInt16(value & 0xffff, ByteOrder.LITTLE_ENDIAN)
            writeInt8(value >> 16)
        }
    }

    /**
     * 写入Int的低32位。
     */
    func writeInt32(_ value: Int, _ order: ByteOrder? = nil) {
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            writeInt16(value >> 16, ByteOrder.BIG_ENDIAN)
            writeInt16(value & 0xffff, ByteOrder.BIG_ENDIAN)
        } else {
            writeInt16(value & 0xffff, ByteOrder.LITTLE_ENDIAN)
            writeInt16(value >> 16, ByteOrder.LITTLE_ENDIAN)
        }
    }

    /**
     * 写入Int，64位。
     */
    func writeInt(_ value: Int, _ order: ByteOrder? = nil) {
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            writeInt32(value >> 32, ByteOrder.BIG_ENDIAN)
            writeInt32(value & 0xffffffff, ByteOrder.BIG_ENDIAN)
        } else {
            writeInt32(value & 0xffffffff, ByteOrder.LITTLE_ENDIAN)
            writeInt32(value >> 32, ByteOrder.LITTLE_ENDIAN)
        }
    }

    /**
     * 写入Float，32位。
     */
    func writeFloat(_ value: Float, _ order: ByteOrder? = nil) {
        let intBits: UInt32 = value.bitPattern
        writeInt32(Int(intBits), order)
    }

    /**
     * 写入Double，64位。
     */
    func writeDouble(_ value: Double, _ order: ByteOrder? = nil) {
        let intBits: UInt64 = value.bitPattern
        writeInt(Int(bitPattern: UInt(intBits)), order)
    }

    /**
     * 写入Data。
     */
    func writeData(_ data: Data?, _ order: ByteOrder? = nil) {
        if data == nil {
            return
        }

        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            data?.forEach({
                writeInt8(Int($0))
            })
        } else {
            data?.reversed().forEach({
                writeInt8(Int($0))
            })
        }
    }

    /**
     * 写入字符串，编码后是多长，就写多长。
     *
     * @param text     待写入的字符串。
     * @param encoding 编码格式。
     */
    func writeString(_ text: String?, _ encoding: String.Encoding = .utf8) {
        if text == nil || text!.isEmpty {
            return
        }

        let data = text!.data(using: encoding)
        writeData(data, ByteOrder.BIG_ENDIAN)
    }

    /**
     * 写入字符串，如果没有超过限定长度，编码后是多长写入多长，否则只写入限定的长度。
     *
     * @param text     待写入的字符串。
     * @param limit    限定最大分配的字节数。
     * @param encoding 编码格式。
     */
    func writeStringWithLimit(_ text: String?, _ limit: Int, _ encoding: String.Encoding = .utf8) {
        if text == nil || text!.isEmpty {
            return
        }

        //skip(8 - mPositions[1]) // 写入的字符序列不允许跨字节，先跳到下个字节的开始位置
        let data = text!.data(using: encoding)
        let length = min(data!.count, limit)
        writeData(data![0..<length])
    }

    /**
     * 写入字符串，不管编码后多长，都只写入固定长度。
     * 如果没有达到固定长度，剩余的会写入0；
     * 如果超过的固定长度，超过的会被忽略；
     *
     * @param text     待写入的字符串。
     * @param fix      分配的固定长度。
     * @param encoding 编码格式。
     */
    func writeStringWithFix(_ text: String?, _ fix: Int, _ encoding: String.Encoding = .utf8) {
        if text == nil || text!.isEmpty {
            skip(fix * 8)
            return
        }

        let data = text!.data(using: encoding)
        let length = min(data!.count, fix)
        writeData(data![0..<length])
        if data!.count < fix {
            writeData(Data(repeating: 0, count: fix - data!.count))
        }
    }

    /**
     * 写入对象。
     */
    func writeObject(_ buf: BleBuffer?) {
        if buf == nil {
            return
        }

        writeData(buf!.toData())
    }

    /**
     * 写入数组。
     */
    func writeArray(_ array: [BleBuffer]?) {
        array?.forEach {
            writeObject($0)
        }
    }
}
