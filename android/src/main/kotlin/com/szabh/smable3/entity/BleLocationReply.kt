package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable

// Some non-Gps devices will request mobile phone positioning during exercise.
// This class is the response to the command after the mobile phone is successfully positioned.
data class BleLocationReply(
    var mSpeed: Float = 0f, // KM/JAM
    var mTotalDistance: Float = 0f, // KM
    var mAltitude: Int = 0 // Meter
) : BleWritable() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeFloat(mSpeed)
        writeFloat(mTotalDistance)
        writeInt16(mAltitude)
    }

    companion object {
        const val ITEM_LENGTH = 16
    }
}
