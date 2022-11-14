package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleReadable
import java.nio.ByteOrder

/**
 * 比赛事件
 */
data class BleMatchLog(
    var mTime: Int = 0,         //时间，数据以秒为单位，这个需要加上比赛开始时间才能得到完整的时间
    var mPeriodTime: Int = 0,   //事件发生的计数时间或者周期时间，数据以秒为单位
    var mPeriodNumber: Int = 0, //事件发生的周期序号
    var mType: Int = 0,         //当前事件类型
    var mCount: Int = 0,        //第几个进球或者第几次罚球
    var mCancelType: Int = 0,   //取消的事件类型（当前事件为取消事件时用到）
) : BleReadable() {

    override fun decode() {
        super.decode()
        mTime = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
        mPeriodTime = readUInt16(ByteOrder.LITTLE_ENDIAN).toInt()
        mPeriodNumber = readUInt8().toInt()
        mType = readUInt8().toInt()
        mCount = readUInt8().toInt()
        mCancelType = readUInt8().toInt()
    }

    companion object {
        const val ITEM_LENGTH = 8

        //以下为事件类型
        const val KICK_OFF = 0x00 //开球
        const val TIME_START = 0x01 //比赛开始
        const val TIME_STOP = 0x02 //比赛停止
        const val PERIOD_END = 0x03 //单周期结束
        const val PERIOD_RESET = 0x04 //单周期重置
        const val PENALTY = 0x05 //罚球
        const val GOAL_HOME = 0x06 //主队进球
        const val GOAL_GUEST= 0x07 //客队进球
        const val UNDO_LAST = 0x08 //取消进球或者罚球
        const val MERCY_END = 0x09 //提前结束当前周期比赛
    }
}
