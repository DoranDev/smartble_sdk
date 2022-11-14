package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable

data class BleRealTimeMeasurement(
    var mHRSwitch: Int = 0, //心率开关
    var mBOSwitch: Int = 0, //血氧开关
    var mBPSwitch: Int = 0, //血压开关
) : BleWritable() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeIntN(0, 5)
        writeIntN(mBPSwitch, 1)
        writeIntN(mBOSwitch, 1)
        writeIntN(mHRSwitch, 1)
    }

    override fun decode() {
        super.decode()
        readIntN(5)
        mBPSwitch = readIntN(1).toInt()
        mBOSwitch = readIntN(1).toInt()
        mHRSwitch = readIntN(1).toInt()
    }

    override fun toString(): String {
        return "BleRealTimeMeasurement(mHRSwitch=$mHRSwitch, mBOSwitch=$mBOSwitch, mBPSwitch=$mBPSwitch)"
    }

    companion object {
        const val ITEM_LENGTH = 1
    }
}
