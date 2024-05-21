package com.szabh.androidblesdk3.activity

import android.app.ListActivity
import android.os.Bundle
import android.widget.ArrayAdapter
import com.szabh.androidblesdk3.tools.doBle
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.entity.BleNotification
import java.util.*

class NotificationActivity : ListActivity() {
    private val mContext by lazy { this }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupList()
    }

    private fun setupList() {
        val array = listOf(
            "INCOMING_CALL",
            "END_CALL",
            "MISSED_CALL",
            "SMS",
            "EMAIL",
            "SKYPE",
            "FACEBOOK_MESSENGER",
            "WHATS_APP",
            "LINE",
            "INSTAGRAM",
            "KAKAO_TALK",
            "GMAIL",
            "TWITTER",
            "LINKED_IN",
            "SINA_WEIBO",
            "QQ",
            "WE_CHAT",
            "OTHER_APP"
        )

        listView.apply {
            adapter = ArrayAdapter<String>(mContext, android.R.layout.simple_list_item_1, array)
            setOnItemClickListener { _, _, position, _ ->
                doBle(mContext) {
                    when (position) {
                        0 -> { // 来电incoming call
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_INCOMING_CALL,
                                mTime = Date().time,
                                mTitle = "Phone number",
                                mContent = "Incoming call"
                            ).let {
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, it)
                            }
                        }
                        1 -> { // 已接听answered
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_INCOMING_CALL
                            ).let {
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.DELETE, it)
                            }
                        }
                        2 -> { // 未接电话Missed call
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.PACKAGE_MISSED_CALL,
                                mTitle = "Phone number",
                                mContent = "Missed call"
                            ).let {
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, it)
                            }
                        }
                        3 -> { // 短信
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.PACKAGE_SMS,
                                mTitle = "Phone number",
                                mContent = "SMS body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        4 -> { // Email
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.ANDROID_EMAIL,
                                mTitle = "Email title",
                                mContent = "Email body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        5 -> { // Skype
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.SKYPE,
                                mTitle = "Skype title",
                                mContent = "Skype body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        6 -> { // Facebook Messenger
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.FACEBOOK_MESSENGER,
                                mTitle = "Facebook Messenger title",
                                mContent = "Facebook Messenger body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        7 -> { // Whats App
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.WHATS_APP,
                                mTitle = "Whats App title",
                                mContent = "Whats App body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        8 -> { // Line
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.LINE,
                                mTitle = "Line title",
                                mContent = "Line body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        9 -> { // Instagram
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.INSTAGRAM,
                                mTitle = "Instagram title",
                                mContent = "Instagram body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        10 -> { // Kakao Talk
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.KAKAO_TALK,
                                mTitle = "Kakao Talk title",
                                mContent = "Kakao Talk body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        11 -> { // GMail
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.GMAIL,
                                mTitle = "GMail title",
                                mContent = "GMail body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        12 -> { // Twitter
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.TWITTER,
                                mTitle = "Twitter title",
                                mContent = "Twitter body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        13 -> { // LinkedIn
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.LINKED_IN,
                                mTitle = "LinkedIn title",
                                mContent = "LinkedIn body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        14 -> { // Sina Weibo
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.SINA_WEIBO,
                                mTitle = "Sina Weibo title",
                                mContent = "Sina Weibo body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        15 -> { // QQ
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.QQ,
                                mTitle = "QQ title",
                                mContent = "QQ body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        16 -> { // WeChat
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.WE_CHAT,
                                mTitle = "WeChat title",
                                mContent = "WeChat body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        17 -> { // Other App
                            BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = "com.other.app",
                                mTitle = "Other App title",
                                mContent = "Other App body"
                            ).let { notification ->
                                BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                            }
                        }
                        else -> {
                        }
                    }
                }
            }
        }
    }
}