//
// Created by Best Mafen on 2019/10/6.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 工具类，为方便Data和Object之间的转换。
 */
class BleData: NSObject {
    var mData: Data?
    var mByteOrder: ByteOrder

    /**
     * 将要读取/写入的位置, 表示当前位置还未读取/写入
     * [0]: 第几个字节, 范围为 [0, mData.count - 1]
     * [1]: 当前字节的第几位，范围为 [0, 7]
     * 初始位置为 [0, 0], 表示将要读第一个字节的第一位
     * 当位置为 [mData.count - 1, 8] 时, 表示已经读/写完毕
     * xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx
     * xxxxxxxx x^xxxxxx xxxxxxxx xxxxxxxx -> [0]=1, [1]=1
     */
    var mPosition = [0, 0]

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        mData = data
        mByteOrder = byteOrder
    }

    // 已读/写的位数
    func bitsOffset() -> Int {
        return mPosition[0] * 8 + mPosition[1]
    }

    // 剩余未读/写的位数
    func bitsLeft() -> Int {
        guard let data = mData else {
            return 0
        }

        return data.count * 8 - bitsOffset()
    }

    /**
     * 判断如果偏移指定位数, 是否会越界, 该方法不会造成实际偏移。
     */
    func outOfRange(_ bits: Int) -> Bool {
        guard let data = mData else {
            return true
        }

        let offset = bitsOffset() + bits
        return offset < 0 || offset > data.count * 8
    }

    /**
     * 修改当前位置偏移。
     * @param offset 偏移的位数: 大于0时, 向后偏移; 小于0时, 向前偏移。
     */
    func skip(_ offset: Int) {
        var newOffset = bitsOffset() + offset
        if newOffset < 0 {
            newOffset = 0
        }
        mPosition[0] = newOffset / 8
        mPosition[1] = newOffset % 8
    }

    /**
     * 重置读/写的位置, 标记到开始位置, 即第0个字节第0位。
     */
    func restOffset() {
        mPosition[0] = 0
        mPosition[1] = 0
    }
}
