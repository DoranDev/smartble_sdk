package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

/**
 * The UTC time in the device positioning raw data
 */
data class BleLocationUTC(
    var mHour: Int = 0,
    var mMinute: Int = 0,
    var mSecond: Int = 0,
    var mMilli: Int = 0,
) : BleReadable() {

    override fun decode() {
        super.decode()
        mHour = readUInt8().toInt()
        mMinute = readUInt8().toInt()
        mSecond = readUInt8().toInt()
        skip(8)
        mMilli = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
    }

    companion object {
        const val ITEM_LENGTH = 8
    }
}
