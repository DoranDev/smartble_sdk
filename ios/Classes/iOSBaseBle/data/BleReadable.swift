//
// Created by Best Mafen on 2019/9/25.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 工具类，为方便从Data转换为Object。
 */
class BleReadable: BleData, Codable {

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    // Subclass should call super.decode().
    func decode() {
        restOffset()
    }

    /**
     * 读取n位，解析成UInt8。
     * @return 范围为0~0xff。
     */
    func readUIntN(_ n: Int) -> UInt8 {
        if n < 1 || n > 8 || outOfRange(n) {
            return 0
        }

        var value: Int
        if mPosition[1] + n <= 8 { // 没有跨字节
            value = Int(mData![mPosition[0]]) >> (8 - mPosition[1] - n)
            var mask = 2 << n
            mask >>= 1
            mask -= 1
            value &= mask
        } else { // 已经跨字节
            var mask = 2 << (8 - mPosition[1])
            mask >>= 1
            mask -= 1
            value = Int(mData![mPosition[0]]) & mask
            value <<= (mPosition[1] + n - 8)

            var value2 = Int(mData![mPosition[0] + 1]) & 0xff
            value2 >>= (16 - mPosition[1] - n)

            value |= value2
        }
        skip(n)
        return UInt8(value)
    }

    /**
     * 读取1位，解析成Bool。
     * @return 如果该位为1，返回true，否则返回false。
     */
    func readBool() -> Bool {
        readUIntN(1) == 1
    }

    /**
     * 读取8位，解析成UInt8。
     * @return 范围为0~0xff。
     */
    func readUInt8() -> UInt8 {
        readUIntN(8)
    }

    /**
     * 读取8位，解析成Int8。
     * @return 范围为-0x80~0x7f。
     */
    func readInt8() -> Int8 {
        Int8(bitPattern: readUInt8())
    }

    /**
     * 读取16位，解析成UInt16。
     * @return 范围为0~0xffff。
     */
    func readUInt16(_ order: ByteOrder? = nil) -> UInt16 {
        let high: UInt8
        let low: UInt8
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            high = readUInt8()
            low = readUInt8()
        } else {
            low = readUInt8()
            high = readUInt8()
        }
        return UInt16(high) << 8 | UInt16(low)
    }

    /**
     * 读取16位，解析成Int16
     * @return 范围为-0x8000~0x7fff。
     */
    func readInt16(_ order: ByteOrder? = nil) -> Int16 {
        Int16(bitPattern: readUInt16(order))
    }

    /**
      * 读取24位，解析成UInt32。
      * @return 范围为0~0xffffff。
      */
    func readUInt24(_ order: ByteOrder? = nil) -> UInt32 {
        let high: UInt8
        let low: UInt16
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            high = readUInt8()
            low = readUInt16(ByteOrder.BIG_ENDIAN)
        } else {
            low = readUInt16(ByteOrder.LITTLE_ENDIAN)
            high = readUInt8()
        }
        return UInt32(high) << 16 | UInt32(low)
    }

    /**
      * 读取32位，解析成UInt32。
      * @return 范围为0~0xffffffff。
      */
    func readUInt32(_ order: ByteOrder? = nil) -> UInt32 {
        let high: UInt16
        let low: UInt16
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            high = readUInt16(ByteOrder.BIG_ENDIAN)
            low = readUInt16(ByteOrder.BIG_ENDIAN)
        } else {
            low = readUInt16(ByteOrder.LITTLE_ENDIAN)
            high = readUInt16(ByteOrder.LITTLE_ENDIAN)
        }
        return UInt32(high) << 16 | UInt32(low)
    }

    /**
     * 读取32位，解析成Int32。
     * @return 范围为-0x80000000~0x7fffffff。
     */
    func readInt32(_ order: ByteOrder? = nil) -> Int32 {
        Int32(bitPattern: readUInt32(order))
    }

    /**
      * 读取64位，解析成UInt64。
      * @return 范围为0~0xffffffffffffffff。
      */
    func readUInt64(_ order: ByteOrder? = nil) -> UInt64 {
        let high: UInt32
        let low: UInt32
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            high = readUInt32(ByteOrder.BIG_ENDIAN)
            low = readUInt32(ByteOrder.BIG_ENDIAN)
        } else {
            low = readUInt32(ByteOrder.LITTLE_ENDIAN)
            high = readUInt32(ByteOrder.LITTLE_ENDIAN)
        }
        return UInt64(high) << 32 | UInt64(low)
    }

    /**
     * 读取64位，解析成Int。
     * @return 范围为-0x8000000000000000~0x7fffffffffffffff。
     */
    func readInt(_ order: ByteOrder? = nil) -> Int {
        let high: Int32
        let low: Int32
        if order ?? mByteOrder == ByteOrder.BIG_ENDIAN {
            high = readInt32(ByteOrder.BIG_ENDIAN)
            low = readInt32(ByteOrder.BIG_ENDIAN)
        } else {
            low = readInt32(ByteOrder.LITTLE_ENDIAN)
            high = readInt32(ByteOrder.LITTLE_ENDIAN)
        }
        return Int(high) << 32 | Int(low)
    }

    /**
     * 读取32位，解析成Float。
     */
    func readFloat(_ order: ByteOrder? = nil) -> Float {
        let intBits: UInt32 = readUInt32(order)
        return Float.init(bitPattern: intBits)
    }

    /**
     * 读取64位，解析成Double。
     */
    func readDouble(_ order: ByteOrder? = nil) -> Double {
        let intBits: UInt64 = readUInt64(order)
        return Double.init(bitPattern: intBits)
    }

    /**
     * 读取n个字节。
     */
    func readData(_ length: Int) -> Data {
        var result = Data(count: length)
        for i in 0..<length {
            result[i] = readUInt8()
        }
        return result
    }

    /**
     * 读取n个字节，根据编码解析成字符串，如果最后一个字节为'\0'，会被忽略。
     */
    func readString(_ length: Int, _ encoding: String.Encoding = .utf8) -> String {
        let data = readData(length)
        if encoding == .utf8 || encoding == .ascii{
            if let endIndex = data.firstIndex(of: 0) {
                return String(data: Data(data[0..<endIndex]), encoding: encoding) ?? ""
            } else {
                return String(data: data, encoding: encoding) ?? ""
            }
        }else if encoding == .utf16 || encoding == .utf16LittleEndian || encoding == .utf16BigEndian{
            var endIndex = -1
            for index in 0..<length/2{
                if data[index*2] == 0 && data[index*2+1] == 0{
                    endIndex = index * 2
                    break
                }
            }
            if endIndex == -1{
                return String(data: data, encoding: encoding) ?? ""
            }else{
                return String(data: Data(data[0..<endIndex]), encoding: encoding) ?? ""
            }
        }else{
            return String(data: data, encoding: encoding) ?? ""
        }
    }

    /**
     * 读取n个字节，解析成对象。
     */
    func readObject<T: BleReadable>(_ itemLength: Int) -> T {
        let t = T.init()
        t.mData = readData(itemLength)
        t.decode()
        return t
    }

    /**
     * 读取count*itemLength个字节，解析成数组。
     */
    func readArray<T: BleReadable>(_ count: Int, _ itemLength: Int) -> [T] {
        var list = [T]()
        for _ in 0..<count {
            list.append(readObject(itemLength))
        }
        return list
    }

    /**
     * 一直读取，直到遇到指定的数字。
     * 该方法不适用于跨字节的情况，返回的ByteArray不包含末尾的util，但是mPositions会移动到util的下个字节。
     */
    func readDataUtil(_ util: UInt8) -> Data {
        if let data = mData {
            for index in mPosition[0]..<data.count {
                if data[index] == util {
                    let data = readData(index - mPosition[0])
                    skip(8)
                    return data
                }
            }
        }

        return Data(count: 0)
    }

    /**
     * 一直读取，直到遇到指定的数字，然后将读取的数据根据编码转换成String并返回。
     * 该方法不适用于跨字节的情况，返回的ByteArray不包含末尾的util，但是mPositions会移动到util的下个字节。
     */
    func readStringUtil(_ util: UInt8, _ encoding: String.Encoding = .utf8) -> String {
        let data = readDataUtil(util)
        if data.isEmpty {
            return ""
        } else {
            return String(data: data, encoding: encoding) ?? ""
        }
    }

    /**
     * 工厂方法，将Data转换为BleReadable子类的实例。
     * @param from include。
     * @param to exclude。
     */
    static func ofObject<T: BleReadable>(_ data: Data, _ from: Int = 0, _ to: Int? = nil) -> T {
        let t = T.init()
        let end = to ?? data.count
        t.mData = Data(data[from..<end])
        t.decode()
        return t
    }

    /**
     * 工厂方法，将Data转换为BleReadable子类的数组。
     * @param from include。
     * @param to exclude。
     */
    static func ofArray<T: BleReadable>(_ data: Data, _ itemLength: Int, _ from: Int = 0, _ to: Int? = nil) -> [T] {
        var array = [T]()
        let end = to ?? data.count
        let count = (end - from) / itemLength
        if count > 0 {
            for i in 0..<count {
                let itemData = Data(data[from + itemLength * i..<from + itemLength * (i + 1)])
                array.append(ofObject(itemData))
            }
        }
        return array
    }

    required init(from decoder: Decoder) throws {

    }

    func encode(to encoder: Encoder) throws {
    }
}
