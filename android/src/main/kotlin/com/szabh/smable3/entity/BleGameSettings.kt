package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable

data class BleGameSettings(
    var mEnabled: Int = 0,
    var mStartHour1: Int = 0,
    var mStartMinute1: Int = 0,
    var mEndHour1: Int = 0,
    var mEndMinute1: Int = 0,
    var mStartHour2: Int = 0,
    var mStartMinute2: Int = 0,
    var mEndHour2: Int = 0,
    var mEndMinute2: Int = 0,
) : BleWritable() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeInt8(mEnabled)
        writeInt8(mStartHour1)
        writeInt8(mStartMinute1)
        writeInt8(mEndHour1)
        writeInt8(mEndMinute1)
        writeInt8(mStartHour2)
        writeInt8(mStartMinute2)
        writeInt8(mEndHour2)
        writeInt8(mEndMinute2)
    }

    companion object {
        const val ITEM_LENGTH = 9
    }
}
