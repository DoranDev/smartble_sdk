package com.szabh.androidblesdk3.activity

import android.app.ListActivity
import android.os.Bundle
import android.widget.ArrayAdapter
import com.szabh.androidblesdk3.tools.doBle
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.entity.BleNotification
import com.szabh.smable3.entity.BleNotification2
import java.util.*

class Notification2Activity : ListActivity() {
    private val mContext by lazy { this }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupList()
    }

    private fun setupList() {
        val array = listOf(
            "INCOMING_CALL",
            "MISSED_CALL",
            "SMS",
        )

        listView.apply {
            adapter = ArrayAdapter<String>(mContext, android.R.layout.simple_list_item_1, array)
            setOnItemClickListener { _, _, position, _ ->
                doBle(mContext) {
                    when (position) {
                        0 -> { // 来电
                            BleNotification2(
                                mCategory = BleNotification.CATEGORY_INCOMING_CALL,
                                mTime = Date().time,
                                mTitle = "Phone number",
                                mPhone = "18682108748",
                                mContent = "Incoming call"
                            ).let {
                                BleConnector.sendObject(BleKey.NOTIFICATION2, BleKeyFlag.UPDATE, it)
                            }
                        }
                        1 -> { // 未接来电
                            BleNotification2(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.PACKAGE_MISSED_CALL,
                                mTitle = "Phone number",
                                mPhone = "18682108748",
                                mContent = "Missed call"
                            ).let {
                                BleConnector.sendObject(BleKey.NOTIFICATION2, BleKeyFlag.UPDATE, it)
                            }
                        }
                        2 -> { // 短信
                            BleNotification2(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.PACKAGE_SMS,
                                mTitle = "Phone number",
                                mPhone = "18682108748",
                                mContent = "SMS body"
                            ).let { notification ->
                                BleConnector.sendObject(
                                    BleKey.NOTIFICATION2,
                                    BleKeyFlag.UPDATE,
                                    notification
                                )
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