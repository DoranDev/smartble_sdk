package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

data class BleWatchFaceId(
    var mIdList: MutableList<Int> = mutableListOf()
) : BleReadable() {

    override fun decode() {
        super.decode()
        mBytes?.let {
            val size = it.size / 4
            if (size != 0) {
                for (i in 0 until size) {
                    mIdList.add(readInt32())
                }
            }
        }
    }

    companion object {
        const val WATCHFACE_ID_INVALID = 0xFFFFFFFF //无效的表盘id
    }
}
