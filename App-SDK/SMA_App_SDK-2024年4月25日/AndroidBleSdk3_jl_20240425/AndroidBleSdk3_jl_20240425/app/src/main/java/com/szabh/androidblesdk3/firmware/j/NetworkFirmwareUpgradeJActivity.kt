package com.szabh.androidblesdk3.firmware.j

import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.bestmafen.baseble.util.BleLog
import com.blankj.utilcode.util.*
import com.jieli.bluetooth_connect.constant.BluetoothConstant
import com.jieli.jl_bt_ota.constant.StateCode
import com.jieli.jl_rcsp.impl.NetworkOpImpl
import com.jieli.jl_rcsp.interfaces.network.OnNetworkOTACallback
import com.jieli.jl_rcsp.model.network.OTAParam
import com.jieli.watchtesttool.tool.bluetooth.BluetoothEventListener
import com.jieli.watchtesttool.tool.bluetooth.BluetoothHelper
import com.jieli.watchtesttool.tool.watch.WatchManager
import com.szabh.androidblesdk3.R
import com.szabh.androidblesdk3.chooseFile
import com.szabh.smable3.component.BleCache
import com.szabh.smable3.component.BleConnector

/**
 * 杰里设备固件升级
 */
@SuppressLint("SetTextI18n")
class NetworkFirmwareUpgradeJActivity : AppCompatActivity() {
    private val textView by lazy { findViewById<TextView>(R.id.text_view) }
    private val btn by lazy { findViewById<Button>(R.id.btn) }

    private var mBluetoothHelper: BluetoothHelper? = null

    private val mBtEventListener = object : BluetoothEventListener() {
        override fun onAdapterStatus(bEnabled: Boolean) {
            LogUtils.d("bt onAdapterStatus $bEnabled")
        }
        override fun onConnection(device: BluetoothDevice, status: Int) {
            LogUtils.d("bt onConnection -> mJLUpgradeStatus = $device ,status = $status ,isOTA = ${mNetworkOp?.isNetworkOTA}")
            if (mNetworkOp?.isNetworkOTA == false) {
                if (status == BluetoothConstant.CONNECT_STATE_CONNECTED) {
                    chooseFile(this@NetworkFirmwareUpgradeJActivity, REQUEST_CODE_UPGRADE_J)
                } else if (status == StateCode.CONNECTION_DISCONNECT) {
                    LogUtils.d("bt onConnection -> device disconnected")
                    btn.isEnabled = false
                }
            }
        }
    }

    private var mNetworkOp: NetworkOpImpl? = null
    private var mWatchManager: WatchManager? = null

    private lateinit var binPath: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_firmware_upgrade)
        BleConnector.closeConnection(true)
        //建议加上log，升级遇到问题可以导出来让原厂分析
        JL_LogUtils.enableLog(this)
    }

    override fun onDestroy() {
        destroyOTA()
        BleConnector.launch()
        super.onDestroy()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_UPGRADE_J && resultCode == Activity.RESULT_OK) {
            val uri = data?.data ?: return

            val path = uri.path ?: ""
            val fileName = path.substring(path.lastIndexOf('/'))
            binPath = PathUtils.getExternalAppCachePath() + fileName
            BleLog.i(binPath)
            // 选取的文件不能直接通过uri拿到path, 所以先存到app外部cache目录
            FileIOUtils.writeFileFromIS(binPath, contentResolver.openInputStream(uri))
            startOTA(binPath)
        }
    }

    /**
     * 手动选择择
     */
    fun upgrade(view: View) {
        initOTA()
        connectDevice(BleCache.mBleAddress)
    }

    fun startOTA(filePath: String) {
        LogUtils.d("startOTA :: $filePath")
        mNetworkOp?.startNetworkOTA(mWatchManager!!.connectedDevice, OTAParam(filePath), object:
            OnNetworkOTACallback{
            override fun onStart() {
                LogUtils.d("onStartOTA")
                btn.isEnabled = false
            }

            override fun onProgress(p0: Int) {
                LogUtils.d("onProgress -> $p0")
                runOnUiThread {
                    textView.text = "$p0"
                }
            }

            override fun onCancel() {
                LogUtils.d("onCancel")
                btn.isEnabled = false
            }

            override fun onStop() {
                LogUtils.d("onStopOTA() upgrade ok")
                btn.isEnabled = true
            }

            override fun onError(p0: Int, p1: String?) {
                LogUtils.d("onError -> error = $p0, $p1")
                ToastUtils.showLong(p1)
                btn.isEnabled = true
            }

        })
    }

    private fun initOTA() {
        mBluetoothHelper = BluetoothHelper.getInstance(Utils.getApp())
        mBluetoothHelper?.addBluetoothEventListener(mBtEventListener)
        mWatchManager = WatchManager.getInstance(Utils.getApp())
        mNetworkOp = NetworkOpImpl.instance(mWatchManager)
    }

    private fun destroyOTA() {
        mWatchManager?.release()
        mWatchManager = null
        mNetworkOp?.destroy()
        mNetworkOp = null
        mBluetoothHelper?.removeBluetoothEventListener(mBtEventListener)
        mBluetoothHelper?.destroy()
        mBluetoothHelper = null
    }

    private fun connectDevice(address: String) {
        LogUtils.d("connectDevice: $address")
        mBluetoothHelper?.connectDevice(BluetoothAdapter.getDefaultAdapter()?.getRemoteDevice(address))
    }

    companion object {
        const val REQUEST_CODE_UPGRADE_J = 0x01
    }
}