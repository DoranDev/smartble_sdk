package id.kakzaki.smartble_sdk.activity

import android.app.ListActivity
import android.content.Intent
import android.os.Bundle
import android.widget.ArrayAdapter
import id.kakzaki.smartble_sdk.MyNotificationListenerService
import com.szabh.smable3.BleCommand
import com.szabh.smable3.BleKey
import com.szabh.smable3.component.BleCache

class KeyListActivity : ListActivity() {
    private val mContext by lazy { this }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val bleCommand = intent.getSerializableExtra("BleCommand") as BleCommand
        setupKeyList(bleCommand)
    }

    // 显示该Command对应的Key列表
    private fun setupKeyList(bleCommand: BleCommand) {
        var bleKeys = bleCommand.getBleKeys()
        // 过滤设备不支持的数据
        if (bleCommand == BleCommand.DATA) {
            val dataKeys = BleCache.mDataKeys
            bleKeys = bleKeys.filter {
                dataKeys.contains(it.mKey)
            }
        }
        listView.apply {
            adapter = ArrayAdapter<BleKey>(mContext, android.R.layout.simple_list_item_1, bleKeys)
            setOnItemClickListener { _, _, position, _ ->
                when {
                    bleKeys[position] == BleKey.NOTIFICATION -> {
                        val intent = Intent(mContext, NotificationActivity::class.java)
                        startActivity(intent)
                    }
                    bleKeys[position] == BleKey.NOTIFICATION2 -> {
                        val intent = Intent(mContext, Notification2Activity::class.java)
                        startActivity(intent)
                    }
                    bleKeys[position] == BleKey.MUSIC_CONTROL -> {
                        if (MyNotificationListenerService.isEnabled(mContext)) {
                            val intent = Intent(mContext, MusicControlActivity::class.java)
                            startActivity(intent)
                            MyNotificationListenerService.checkAndReEnable(mContext)
                        } else {
                            MyNotificationListenerService.toEnable(mContext)
                        }
                    }
                    else -> {
//                        val intent = Intent(mContext, KeyFlagListActivity::class.java)
//                        intent.putExtra("BleKey", bleKeys[position])
//                        startActivity(intent)
                    }
                }
            }
        }
    }
}