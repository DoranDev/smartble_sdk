package com.szabh.androidblesdk3.activity

import android.app.ListActivity
import android.content.Intent
import android.os.Bundle
import android.widget.ArrayAdapter
import com.szabh.androidblesdk3.R
import com.szabh.androidblesdk3.tools.toast
import com.szabh.smable3.BleCommand
import com.szabh.smable3.BleKey
import com.szabh.smable3.component.BleCache
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.component.WorkoutState
import com.szabh.smable3.entity.BleAlarm
import com.szabh.smable3.entity.BleNoDisturbSettings

class CommandListActivity : ListActivity() {
    private val mContext by lazy { this }

    private val mBleHandleCallback by lazy {
        object : BleHandleCallback {

            override fun onSessionStateChange(status: Boolean) {
                toast(mContext, "onSessionStateChange $status")
            }

            override fun onNoDisturbUpdate(noDisturbSettings: BleNoDisturbSettings) {
                toast(mContext, "onNoDisturbUpdate $noDisturbSettings")
            }

            override fun onAlarmUpdate(alarm: BleAlarm) {
                toast(mContext, "onAlarmUpdate $alarm")
            }

            override fun onAlarmDelete(id: Int) {
                toast(mContext, "onAlarmDelete $id")
            }

            override fun onAlarmAdd(alarm: BleAlarm) {
                toast(mContext, "onAlarmAdd $alarm")
            }

            override fun onFindPhone(start: Boolean) {
                toast(mContext, "onFindPhone ${if (start) "started" else "stopped"}")
            }

            override fun onRequestLocation(workoutState: Int) {
                toast(mContext, "onRequestLocation ${WorkoutState.getState(workoutState)}")
            }

            override fun onDeviceRequestAGpsFile(url: String) {
                toast(mContext, "onDeviceRequestAGpsFile $url")
                // 以下是示例代码，sdk中的文件会过期，只是用于演示
                when (BleCache.mAGpsType) {
                    1 -> BleConnector.sendStream(BleKey.AGPS_FILE, assets.open("type1_epo_gr_3_1.dat"))
                    2 -> BleConnector.sendStream(BleKey.AGPS_FILE, assets.open("type2_current_1d.alp"))
                    6 -> BleConnector.sendStream(BleKey.AGPS_FILE, assets.open("type6_ble_epo_offline.bin"))
                }
                // 实际工程要从url下载aGps文件，然后发送该aGps文件
                // val file = download(url)
                // BleConnector.sendStream(BleKey.AGPS_FILE, file)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BleConnector.addHandleCallback(mBleHandleCallback)
        setupCommandList()
    }

    override fun onDestroy() {
        BleConnector.removeHandleCallback(mBleHandleCallback)
        super.onDestroy()
    }

    // 显示Command列表
    private fun setupCommandList() {
        val bleCommands = BleCommand.values()
        listView.apply {
            adapter = ArrayAdapter(mContext, android.R.layout.simple_list_item_1, bleCommands)
            setOnItemClickListener { _, _, position, _ ->
                val bleCommand = bleCommands[position]
                if (bleCommand == BleCommand.NONE) {
                    val intent = Intent(mContext, OtherFunctionActivity::class.java)
                    startActivity(intent)
                } else {
                    val intent = Intent(mContext, KeyListActivity::class.java)
                    intent.putExtra("BleCommand", bleCommand)
                    startActivity(intent)
                }
            }
        }
    }
}