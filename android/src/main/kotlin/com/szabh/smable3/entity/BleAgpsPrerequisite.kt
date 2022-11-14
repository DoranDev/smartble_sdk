package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable
import java.nio.ByteOrder

data class BleAgpsPrerequisite(
    var mLongitude: Float = 0f,
    var mLatitude: Float = 0f,
    var mAltitude: Int = 0, // m
) : BleWritable() {

    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeFloat(mLongitude, ByteOrder.LITTLE_ENDIAN)
        writeFloat(mLatitude, ByteOrder.LITTLE_ENDIAN)
        writeInt16(mAltitude, ByteOrder.LITTLE_ENDIAN)
    }

    companion object {
        const val ITEM_LENGTH = 32
    }
}
