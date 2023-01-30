package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

/**
 * The GSV data of the whole process of device positioning corresponds to the data displayed by the device
 */

data class BleLocationGsv(
    var satelliteNo: Int = 0, // 卫星编号
    var elevation: Int = 0, // 仰角
    var azimuth: Int = 0, // 方位角
    var snr: Int = 0, // 信噪比
) : BleReadable() {

    override fun decode() {
        super.decode()
        satelliteNo = readInt32(ByteOrder.LITTLE_ENDIAN)
        elevation = readInt32(ByteOrder.LITTLE_ENDIAN)
        azimuth = readInt32(ByteOrder.LITTLE_ENDIAN)
        snr = readInt32(ByteOrder.LITTLE_ENDIAN)
    }

    override fun toString(): String {
        return "BleLocationGsv(satelliteNo=$satelliteNo, elevation=$elevation, azimuth=$azimuth, snr=$snr)"
    }

    companion object {
        const val ITEM_LENGTH = 16
    }
}
