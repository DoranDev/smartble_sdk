package com.szabh.smable3.entity

import kotlin.math.min

data class BleSMSQuickReplyContent(
    var mContent: String = ""
) : BleIdObject() {
    override val mLengthToWrite: Int
        get() = 8 + min(mContent.toByteArray().size, CONTENT_MAX_LENGTH)

    override fun encode() {
        super.encode()
        writeInt8(mId)
        writeStringWithLimit(mContent, CONTENT_MAX_LENGTH)
        writeInt8(0)
    }

    override fun toString(): String {
        return "BleSMSQuickReplyContent(mId='$mId',mContent='$mContent', mLengthToWrite=$mLengthToWrite)"
    }


    companion object {
        const val CONTENT_MAX_LENGTH = 60
    }
}
