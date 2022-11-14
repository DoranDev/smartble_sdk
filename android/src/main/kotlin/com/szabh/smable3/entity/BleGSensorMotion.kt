package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

data class BleGSensorMotion(
    var mMotion: Short = 0,
) : BleReadable() {

    override fun decode() {
        super.decode()
        mMotion = readInt16(ByteOrder.LITTLE_ENDIAN)
    }

    companion object {
        const val ITEM_LENGTH = 2
    }
}
