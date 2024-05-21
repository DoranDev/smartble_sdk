package com.szabh.androidblesdk3

import android.app.Application
import android.text.format.DateFormat
import com.bestmafen.baseble.util.BleLog
import com.blankj.utilcode.util.FileUtils
import com.blankj.utilcode.util.PathUtils
import com.blankj.utilcode.util.ThreadUtils
import com.blankj.utilcode.util.Utils
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.entity.BleTime
import com.szabh.smable3.entity.BleTimeZone
import com.szabh.smable3.entity.Languages
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.ceil

class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        //It is recommended to save the log output by the sdk to a file, so that it can be easily analyzed if there is a problem
        BleLog.mInterceptor = { level, _, msg ->
            ThreadUtils.executeBySingle(object : ThreadUtils.SimpleTask<Void?>() {
                private val LOG_LINE_LENGTH = 140
                override fun doInBackground(): Void? {
                    val date = Date()
                    val fileName =
                        SimpleDateFormat("yyyyMMdd", Locale.getDefault()).format(date) + ".txt"
                    val time = SimpleDateFormat("HH:mm:ss.SSS", Locale.getDefault()).format(date)
                    val lines = ceil(msg.length.toDouble() / LOG_LINE_LENGTH).toInt()
                    repeat(lines) {
                        val content = if (it == lines - 1) {
                            msg.substring(it * LOG_LINE_LENGTH, msg.length)
                        } else {
                            msg.substring(it * LOG_LINE_LENGTH, (it + 1) * LOG_LINE_LENGTH)
                        }
                        File(
                            PathUtils.getExternalAppDataPath() + "/files/ble_logs",
                            fileName
                        ).also { file ->
                            FileUtils.createOrExistsFile(file)
                        }.appendText("$time $level $content\n")
                    }
                    return null
                }

                override fun onSuccess(result: Void?) {
                }
            })
            false
        }

        val connector = BleConnector.Builder(this)
            .supportLauncher(true) // 是否支持自动连接Ble蓝牙设备方法（如果绑定的话），如果不需要请传false
            .supportFilterEmpty(false) // 是否支持过滤空数据，如ACTIVITY、HEART_RATE、BLOOD_PRESSURE、SLEEP、WORKOUT、LOCATION、TEMPERATURE、BLOOD_OXYGEN、HRV，如果不需要支持传false。
            .build()

        //配置一个全局的回调
        connector.addHandleCallback(object : BleHandleCallback {

            override fun onSessionStateChange(status: Boolean) {
                //连接发生变化，连接成功需要将一些设置重新发送到设备，目前这几个是必须的，其他设置可以根据用户来定
                if (status) {
                    connector.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
                    connector.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
                    connector.sendInt8(BleKey.HOUR_SYSTEM, BleKeyFlag.UPDATE,
                        if (DateFormat.is24HourFormat(Utils.getApp())) 0 else 1)
                    connector.sendData(BleKey.POWER, BleKeyFlag.READ)
                    connector.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)
                    connector.sendInt8(BleKey.LANGUAGE, BleKeyFlag.UPDATE, Languages.languageToCode())
                    connector.sendData(BleKey.MUSIC_CONTROL, BleKeyFlag.READ)
                }
            }
        })
    }
}