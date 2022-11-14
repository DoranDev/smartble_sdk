package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable

// App运动模式开启或者变化，将会通知设备
data class BleAppSportState(
    var mMode: Int = 0, // 运动类型
    var mState: Int = 0, // 运动状态
) : BleWritable() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeInt8(mMode)
        writeInt8(mState)
    }

    override fun decode() {
        super.decode()
        mMode = readInt8().toInt()
        mState = readInt8().toInt()
    }

    companion object {
        const val ITEM_LENGTH = 2

        const val MODE_INDOOR = BleActivity.INDOOR
        const val MODE_OUTDOOR = BleActivity.OUTDOOR
        const val MODE_CYCLING = BleActivity.CYCLING
        const val MODE_CLIMBING = BleActivity.CLIMBING

        const val STATE_START = 1
        const val STATE_RESUME = 2
        const val STATE_PAUSE = 3
        const val STATE_END = 4
    }

}
