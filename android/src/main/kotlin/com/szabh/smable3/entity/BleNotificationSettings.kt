package com.szabh.smable3.entity

import com.bestmafen.baseble.data.BleWritable

/**
 * 通知设置
 */
class BleNotificationSettings : BleWritable() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    private val BIT_MASKS = mapOf(
        MIRROR_PHONE to 1,
        CALL to (1 shl 1),
        SMS to (1 shl 2),
        EMAIL to (1 shl 3),
        SKYPE to (1 shl 4),
        FACEBOOK_MESSENGER to (1 shl 5),
        WHATS_APP to (1 shl 6),
        LINE to (1 shl 7),
        INSTAGRAM to (1 shl 8),
        KAKAO_TALK to (1 shl 9),
        GMAIL to (1 shl 10),
        TWITTER to (1 shl 11),
        LINKED_IN to (1 shl 12),
        SINA_WEIBO to (1 shl 13),
        QQ to (1 shl 14),
        WE_CHAT to (1 shl 15),
        BAND to (1 shl 16),
        TELEGRAM to (1 shl 17),
        BETWEEN to (1 shl 18),
        NAVERCAFE to (1 shl 19),
        YOUTUBE to (1 shl 20),
        NETFLIX to (1 shl 21),
    )

    var mNotificationBits = 0

    init {
        //这个协议之前只针对ios的，安卓根据app的来电提醒设置处理CALL的开关状态即可，其他全部打开
        for (id in BIT_MASKS.keys) {
            if (id != CALL) {
                enable(id)
            }
        }
    }

    override fun encode() {
        super.encode()
        writeInt32(mNotificationBits)
    }

    override fun decode() {
        super.decode()
        mNotificationBits = readInt32()
    }

    fun isEnabled(id: String): Boolean {
        BIT_MASKS[id]?.let {
            return mNotificationBits and it > 0
        }
        return false
    }

    fun enable(id: String) {
        BIT_MASKS[id]?.let {
            mNotificationBits = mNotificationBits or it
        }
    }

    fun disable(id: String) {
        BIT_MASKS[id]?.let {
            mNotificationBits = mNotificationBits and it.inv()
        }
    }

    fun toggle(id: String) {
        BIT_MASKS[id]?.let {
            mNotificationBits = mNotificationBits xor it
        }
    }

    override fun toString(): String {
        return "BleNotificationSettings(mNotificationBits=${Integer.toBinaryString(mNotificationBits)})"
    }

    companion object {
        const val ITEM_LENGTH = 4

        const val MIRROR_PHONE = "mirror_phone"
        const val CALL = "tel"
        const val SMS = "sms"
        const val EMAIL = "mailto"
        const val SKYPE = "skype"
        const val FACEBOOK_MESSENGER = "fbauth2"
        const val WHATS_APP = "whatsapp"
        const val LINE = "line"
        const val INSTAGRAM = "instagram"
        const val KAKAO_TALK = "kakaolink"
        const val GMAIL = "googlegmail"
        const val TWITTER = "twitter"
        const val LINKED_IN = "linkedin"
        const val SINA_WEIBO = "sinaweibo"
        const val QQ = "mqq"
        const val WE_CHAT = "wechat"
        const val BAND = "bandapp"
        const val TELEGRAM = "telegram"
        const val BETWEEN = "between"
        const val NAVERCAFE = "navercafe"
        const val YOUTUBE = "youtube"
        const val NETFLIX = "nflx"
    }
}