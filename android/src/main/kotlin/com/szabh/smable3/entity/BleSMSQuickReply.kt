package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable

data class BleSMSQuickReply(
    var mId: Int = 0,
    var mPhone: String = ""
) : BleWritable() {
    override val mLengthToWrite: Int
        get() = 8 + BleNotification.PHONE_LENGTH

    override fun decode() {
        super.decode()
        mId = readUInt8().toInt()
        mPhone = readString(BleNotification.PHONE_LENGTH)
    }

    override fun toString(): String {
        return "BleSMSQuickReply(mId=$mId, mPhone='$mPhone', mLengthToWrite=$mLengthToWrite)"
    }
}
