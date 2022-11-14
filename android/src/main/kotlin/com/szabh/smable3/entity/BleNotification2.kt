package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable
import com.szabh.smable3.entity.BleNotification.Companion.CONTENT_MAX_LENGTH
import com.szabh.smable3.entity.BleNotification.Companion.PACKAGE_LENGTH
import com.szabh.smable3.entity.BleNotification.Companion.PHONE_LENGTH
import com.szabh.smable3.entity.BleNotification.Companion.TITLE_LENGTH
import kotlin.math.min

/**
 * 相比原始的消息推送协议，只是添加了Phone字段，专用于支持短信快捷回复的设备
 */
data class BleNotification2(
    var mCategory: Int = 0,
    var mTime: Long = 0L, // ms
    var mPackage: String = "",
    var mTitle: String = "",
    var mPhone: String = "",
    var mContent: String = ""
) : BleWritable() {
    override val mLengthToWrite: Int
        get() = 1 + 6 + PACKAGE_LENGTH + TITLE_LENGTH + PHONE_LENGTH + min(
            mContent.toByteArray().size,
            CONTENT_MAX_LENGTH
        )

    override fun encode() {
        super.encode()
        writeInt8(mCategory)
        writeObject(BleTime.ofLocal(mTime))
        writeStringWithFix(mPackage, PACKAGE_LENGTH)
        writeStringWithFix(mTitle, TITLE_LENGTH)
        writeStringWithFix(mPhone, PHONE_LENGTH)
        writeStringWithLimit(mContent, CONTENT_MAX_LENGTH, addEllipsis = true)
    }

    override fun toString(): String {
        return "BleNotification(mCategory=$mCategory, mTime=$mTime, mPackage='$mPackage'" +
                ", mTitle='$mTitle',mPhone='$mPhone', mContent='$mContent')"
    }
}