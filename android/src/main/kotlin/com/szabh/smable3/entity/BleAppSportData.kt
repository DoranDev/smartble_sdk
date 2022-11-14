package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable
import java.nio.ByteOrder

// App端
data class BleAppSportData(
    var mStep: Int = 0,         //步数，与 BleActivity 中的 mStep 定义一致
    var mDistance: Int = 0,     //米，以米为单位，例如接收到的数据为56045，则代表 56045 米 约等于 56.045 Km
    var mCalorie: Int = 0,      //以千卡为单位
    var mDuration: Int = 0,     //运动持续时长，数据以秒为单位
    var mSpm: Int = 0,          //平均步频，步数/分钟的值
    var mAltitude: Int = 0,     //海拔高度，数据以米为单位
    var mAirPressure: Int = 0,  //气压，数据以 kPa 为单位
    var mPace: Int = 0,         //平均配速，接收到的数据以 秒/千米 为单位
    var mSpeed: Int = 0,        //平均速度，接收到的数据以 千米/小时 为单位
    var mMode: Int = 0,         //运动类型，与 BleActivity 中的 mMode 定义一致
    var mUndefined: Int = 0,    //占位用未定义，字节对齐预留
) : BleWritable() {

    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeInt32(mStep, ByteOrder.LITTLE_ENDIAN)
        writeInt32(mDistance, ByteOrder.LITTLE_ENDIAN)
        writeInt32(mCalorie, ByteOrder.LITTLE_ENDIAN)
        writeInt16(mDuration, ByteOrder.LITTLE_ENDIAN)
        writeInt16(mSpm, ByteOrder.LITTLE_ENDIAN)
        writeInt16(mAltitude, ByteOrder.LITTLE_ENDIAN)
        writeInt16(mAirPressure, ByteOrder.LITTLE_ENDIAN)
        writeInt32(mPace, ByteOrder.LITTLE_ENDIAN)
        writeInt32(mSpeed, ByteOrder.LITTLE_ENDIAN)
        writeInt8(mMode)
        writeInt24(mUndefined, ByteOrder.LITTLE_ENDIAN)
    }

    override fun toString(): String {
        return "BleAppSportData(mStep=$mStep, mDistance=$mDistance, mCalorie=$mCalorie, mDuration=$mDuration, mSpm=$mSpm, mAltitude=$mAltitude, mAirPressure=$mAirPressure, mPace=$mPace, mSpeed=$mSpeed, mMode=$mMode, mUndefined=$mUndefined)"
    }


    companion object {
        const val ITEM_LENGTH = 32
    }
}
