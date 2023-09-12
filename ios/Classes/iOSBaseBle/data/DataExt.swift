//
// Created by Best Mafen on 2019/9/27.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

extension Data {
    var mHexString: String {
        map({ String(format: "0x%02X", $0) }).joined(separator: ", ")
    }

    init(boolValue value: Bool) {
        self.init([value ? 1 : 0])
    }

    init(int8 value: Int) {
        let bytes = [UInt8(value & 0xff)]
        self.init(bytes)
    }

    init(int16 value: Int, _ order: ByteOrder) {
        var bytes: [UInt8] = [0, 0]
        if order == ByteOrder.BIG_ENDIAN {
            bytes[0] = UInt8((value >> 8) & 0xff)
            bytes[1] = UInt8(value & 0xff)
        } else {
            bytes[0] = UInt8(value & 0xff)
            bytes[1] = UInt8((value >> 8) & 0xff)
        }
        self.init(bytes)
    }

    init(int24 value: Int, _ order: ByteOrder) {
        var bytes: [UInt8] = [0, 0, 0]
        if order == ByteOrder.BIG_ENDIAN {
            bytes[0] = UInt8((value >> 16) & 0xff)
            bytes[1] = UInt8((value >> 8) & 0xff)
            bytes[2] = UInt8(value & 0xff)
        } else {
            bytes[0] = UInt8(value & 0xff)
            bytes[1] = UInt8((value >> 8) & 0xff)
            bytes[2] = UInt8((value >> 16) & 0xff)
        }
        self.init(bytes)
    }

    init(int32 value: Int, _ order: ByteOrder) {
        var bytes: [UInt8] = [0, 0, 0, 0]
        if order == ByteOrder.BIG_ENDIAN {
            bytes[0] = UInt8((value >> 24) & 0xff)
            bytes[1] = UInt8((value >> 16) & 0xff)
            bytes[2] = UInt8((value >> 8) & 0xff)
            bytes[3] = UInt8(value & 0xff)
        } else {
            bytes[0] = UInt8(value & 0xff)
            bytes[1] = UInt8((value >> 8) & 0xff)
            bytes[2] = UInt8((value >> 16) & 0xff)
            bytes[3] = UInt8((value >> 24) & 0xff)
        }
        self.init(bytes)
    }

    // 获取无符号整数
    // length = 1时，[0, 0xFF]
    // length = 2时，[0, 0xFFFF]
    // length = 3时，[0, 0xFFFFFF]
    // length = 4时，[0, 0xFFFFFFFF]
    func getUInt(_ start: Int, _ length: Int, _ byteOrder: ByteOrder = ByteOrder.BIG_ENDIAN) -> Int {
        if length < 1 || length > 4 {
            fatalError("length must be in 1...4")
        }

        if start + length > self.count {
            return 0
        }

        if byteOrder == ByteOrder.BIG_ENDIAN {
            switch length {
            case 1:
                return Int(self[start])
            case 2:
                return Int(self[start]) << 8 | Int(self[start + 1])
            case 3:
                return Int(self[start]) << 16 | Int(self[start + 1]) << 8 | Int(self[start + 2])
            case 4:
                return Int(self[start]) << 24 | Int(self[start + 1]) << 16 | Int(self[start + 2]) << 8 | Int(self[start + 3])
            default:
                return 0
            }
        } else {
            switch length {
            case 1:
                return Int(self[start])
            case 2:
                return Int(self[start + 1]) << 8 | Int(self[start])
            case 3:
                return Int(self[start + 2]) << 16 | Int(self[start + 1]) << 8 | Int(self[start])
            case 4:
                return Int(self[start + 3]) << 24 | Int(self[start + 2]) << 16 | Int(self[start + 1]) << 8 | Int(self[start])
            default:
                return 0
            }
        }
    }

    func splitWith0(beginAt: Int = 0) -> Array<Data> {
        var result = [Data]()
        var started = false
        var startIndex = 0
        for index in 0..<count {
            if index < beginAt {
                continue
            }

            let b = self[index]
            if b == 0 {
                if started {
                    result.append(Data(self[startIndex..<index]))
                    started = false
                }
            } else {
                if !started {
                    started = true
                    startIndex = index
                }
                if index == count - 1 {
                    if started {
                        result.append(Data(self[startIndex...index]))
                    }
                }
            }
        }
        return result
    }
}