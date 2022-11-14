package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

/**
 * 比赛周期
 */
data class BleMatchPeriod(
    var mDuration: Int = 0,     //持续时长，数据以秒为单位
    var mDistance: Int = 0,     //10米，以10米为单位，例如接收到的数据为5421，则代表 54210 米 约等于 54.21 Km
    var mStep: Int = 0,         //步数
    var mCalorie: Int = 0,      //卡，以卡为单位
    var mSpeed: Int = 0,        //平均速度，接收到的数据以 千米/小时 为单位
    var mAvgBpm: Int = 0,       //平均心率
    var mMaxBpm: Int = 0        //最大心率
) : BleReadable() {

    override fun decode() {
        super.decode()
        mDuration = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
        mDistance = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
        mStep = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
        mCalorie = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
        mSpeed = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
        mAvgBpm = readUInt8().toInt()
        mMaxBpm = readUInt8().toInt()
    }

    companion object {
        const val ITEM_LENGTH = 12
    }
}
