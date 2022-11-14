package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

data class BleGSensorRaw(
    var mX: Short = 0, // 屏幕宽度方向，暂时不用区分正负方向
    var mY: Short = 0, // 屏幕高度方向，暂时不用区分正负方向
    var mZ: Short = 0, // 垂直屏幕方向，往手腕佩戴方向为正
) : BleReadable() {

    override fun decode() {
        super.decode()
        mX = readInt16(ByteOrder.LITTLE_ENDIAN)
        mY = readInt16(ByteOrder.LITTLE_ENDIAN)
        mZ = readInt16(ByteOrder.LITTLE_ENDIAN)
    }

    companion object {
        const val ITEM_LENGTH = 6
    }
}
