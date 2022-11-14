package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable

data class BleSettingWatchPassword(
    var mEnabled: Int = 0, //开关
    var mPassword: String = "" //固定四位数字,如‘123’
) : BleWritable() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeInt8(mEnabled)
        writeStringWithFix(mPassword, PWD_LENGTH)
    }

    override fun decode() {
        super.decode()
        mEnabled = readUInt8().toInt()
        mPassword = readString(PWD_LENGTH)
    }

    override fun toString(): String {
        return "BleSettingWatchPassword(mEnabled=$mEnabled, mPassword='$mPassword')"
    }

    companion object {
        const val ITEM_LENGTH = 5

        private const val PWD_LENGTH = 4
    }
}
