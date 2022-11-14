package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

data class BleHRRaw(
    var mPpg: Int = 0, // PPG数据
) : BleReadable() {

    override fun decode() {
        super.decode()
        mPpg = readInt32(ByteOrder.LITTLE_ENDIAN)
    }

    companion object {
        const val ITEM_LENGTH = 4
    }
}
