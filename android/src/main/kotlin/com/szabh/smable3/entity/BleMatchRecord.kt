package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

/**
 * 比赛记录
 */
data class BleMatchRecord(
    var mStart: Int = 0,        //开始时间，数据以秒为单位
    var mType: Int = 0,         //比赛类型
    var mPeriodListSize: Int = 0,   //周期数据个数 x（1-9）
    var mLogListSize: Int = 0,      //事件数据个数 y（1-99）
    var mUndefined: Int = 0,        //占位用未定义，预留
    var mPeriod: BleMatchPeriod = BleMatchPeriod(),        //整个比赛的数据
    var mPeriodList: List<BleMatchPeriod> = mutableListOf(),   //周期的数据
    var mLogList: List<BleMatchLog> = mutableListOf()  //事件数据
) : BleReadable() {

    override fun decode() {
        super.decode()
        mStart = readInt32(ByteOrder.LITTLE_ENDIAN)
        mType = readUInt8().toInt()
        mPeriodListSize = readUInt8().toInt()
        mLogListSize = readUInt8().toInt()
        mUndefined = readUInt8().toInt()
        mPeriod = readObject(BleMatchPeriod.ITEM_LENGTH)
        mPeriodList = readList<BleMatchPeriod>(9, BleMatchPeriod.ITEM_LENGTH).take(mPeriodListSize)
        mLogList = readList<BleMatchLog>(99, BleMatchLog.ITEM_LENGTH).take(mLogListSize)
    }

    companion object {
        const val ITEM_LENGTH = 920

        //以下为比赛类型
        const val YOUTH = 0x00 //青年赛
        const val PROFILE1 = 0x01 //自定义比赛1
        const val PROFILE2 = 0x02 //自定义比赛2
        const val TRAINING = 0x03 //训练
    }
}
