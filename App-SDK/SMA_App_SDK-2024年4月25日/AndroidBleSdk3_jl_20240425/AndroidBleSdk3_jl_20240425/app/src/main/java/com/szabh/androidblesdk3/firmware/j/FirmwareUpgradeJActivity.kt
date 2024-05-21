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
import com.jieli.jl_bt_ota.constant.StateCode
import com.jieli.jl_bt_ota.interfaces.BtEventCallback
import com.jieli.jl_bt_ota.interfaces.IUpgradeCallback
import com.jieli.jl_bt_ota.model.base.BaseError
import com.jieli.watchtesttool.tool.bluetooth.BluetoothEventListener
import com.jieli.watchtesttool.tool.bluetooth.BluetoothHelper
import com.jieli.watchtesttool.tool.upgrade.OTAManager
import com.szabh.androidblesdk3.R
import com.szabh.androidblesdk3.chooseFile
import com.szabh.androidblesdk3.firmware.OTAStatus
import com.szabh.smable3.component.BleCache
import com.szabh.smable3.component.BleConnector

/**
 * 杰里设备固件升级
 */
@SuppressLint("SetTextI18n")
class FirmwareUpgradeJActivity : AppCompatActivity() {
    private var isUseDfuAddress = false
    private val textView by lazy { findViewById<TextView>(R.id.text_view) }
    private val btn by lazy { findViewById<Button>(R.id.btn) }

    private var mOTAStatus = OTAStatus.NONE

    private var mBluetoothHelper: BluetoothHelper? = null

    private val mBtEventListener = object : BluetoothEventListener() {
        override fun onAdapterStatus(bEnabled: Boolean) {
            LogUtils.d("bt onAdapterStatus $bEnabled")
        }
        override fun onConnection(device: BluetoothDevice, status: Int) {
            LogUtils.d("bt onConnection $device $status")
        }
    }

    private val mOTAEventCallback: BtEventCallback = object : BtEventCallback() {
        override fun onConnection(device: BluetoothDevice, status: Int) {
            LogUtils.d("ota onConnection -> mJLUpgradeStatus = $mOTAStatus, $device ,status = $status ,isOTA = ${mOTAManager!!.isOTA}")
            //ota过程中可能会断连重连
            if (!mOTAManager!!.isOTA) {//非ota状态
                if (status == StateCode.CONNECTION_OK) {
                    //避免升级完成后这里还执行一次
                    if(canOTA(mOTAStatus)) {
//                        startOTA(binPath)
                        chooseFile(this@FirmwareUpgradeJActivity, REQUEST_CODE_UPGRADE_J)
                    }
                } else if (status == StateCode.CONNECTION_DISCONNECT) {
                    LogUtils.d("ota onConnection -> device disconnected")
                    if(mOTAStatus == OTAStatus.UPGRADE_PREPARE) {
                        updateUpgradeStatus(OTAStatus.UPGRADE_PREPARE_FAILED)
                    }
                }
            }
        }
    }

    private var mOTAManager: OTAManager? = null

    private lateinit var binPath:String

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

    var upgradeCount = 0

    /**
     * 手动选择择
     */
    fun upgrade(view: View) {
        //这里循环升级的代码，压力测试
//        upgradeCount++
//        binPath = if (upgradeCount % 2 == 0) {
//            "/storage/emulated/0/Android/data/com.szabh.androidblesdk3/cache/AM06_SEAL_V005.ufw"
//        } else {
//            "/storage/emulated/0/Android/data/com.szabh.androidblesdk3/cache/AM06_SEAL_V007.ufw"
//        }
//        LogUtils.d("start upgrade $upgradeCount $binPath")

        updateUpgradeStatus(OTAStatus.NONE)
        //升级失败重置一下ota,不然容易出现重试失败
        destroyOTA()
        initOTA()
        if(isUseDfuAddress) {//如果设备长时间卡在ota界面就用dfu地址
            LogUtils.d("upgrade -> use dfuAddress")
            connectDevice(BleCache.mDfuAddress)
        } else {
            LogUtils.d("upgrade -> use bleAddress")
            connectDevice(BleCache.mBleAddress)
        }
        updateUpgradeStatus(OTAStatus.UPGRADE_PREPARE)
    }

    fun startOTA(filePath: String) {
        LogUtils.d("startOTA :: $filePath")
        mOTAManager?.bluetoothOption?.firmwareFilePath = filePath
        mOTAManager?.startOTA(object : IUpgradeCallback {
            override fun onError(p0: BaseError?) {
                LogUtils.d("onError -> status = $mOTAStatus, error = $p0")
                ToastUtils.showLong(p0?.message)
                updateUpgradeStatus(OTAStatus.UPGRADE_FAILED)
            }

            /**
             * 需要回连的回调
             *
             * <p>注意: 1.仅连接BLE通讯通道
             * 2.用于单备份OTA</p>
             *
             * @param addr 回连设备的MAC地址
             * @param isNewReconnectWay 是否使用新回连方式
             */
            override fun onNeedReconnect(addr: String, isNewReconnectWay: Boolean) {
                LogUtils.d("onNeedReconnect : $addr, $isNewReconnectWay")
                isUseDfuAddress = true
            }

            override fun onStopOTA() {
                LogUtils.d("onStopOTA() upgrade ok")
                isUseDfuAddress = false
                updateUpgradeStatus(OTAStatus.UPGRADE_STOP)
                btn.isEnabled = true

                //循环升级
//                Handler().postDelayed({
//                    upgrade(textView)
//                },5000)
            }

            override fun onProgress(type: Int, progress: Float) {
                LogUtils.d("onProgress -> $type $progress")
                if (type == 0) {//type 0:校验文件 1:正在升级
                    mOTAStatus = OTAStatus.UPGRADE_CHECKING
                } else {
                    mOTAStatus = OTAStatus.UPGRADEING
                }
                runOnUiThread {
                    textView.text = "$type ${Math.round(progress)}"
                }
            }

            override fun onStartOTA() {
                LogUtils.d("onStartOTA")
                updateUpgradeStatus(OTAStatus.UPGRADE_START)
            }

            override fun onCancelOTA() {
                LogUtils.d("onCancelOTA")
                updateUpgradeStatus(OTAStatus.UPGRADE_FAILED)
            }
        })
    }

    private fun updateUpgradeStatus(status: OTAStatus) {
        LogUtils.d("updateUpgradeStatus status = $status")
        mOTAStatus = status
        btn.isEnabled = isOTAError(status)
    }

    private fun canOTA(status: OTAStatus): Boolean {
        return !isOTAError(status) && status != OTAStatus.UPGRADE_STOP
    }

    private fun isOTAError(status: OTAStatus): Boolean {
        return when(status){
            OTAStatus.UPGRADE_SCANNING_TIMEOUT, OTAStatus.UPGRADE_FAILED, OTAStatus.UPGRADE_PREPARE_FAILED -> true
            else -> false
        }
    }

    private fun initOTA() {
        mBluetoothHelper = BluetoothHelper.getInstance(Utils.getApp())
        mBluetoothHelper?.addBluetoothEventListener(mBtEventListener)
        mOTAManager = OTAManager(this)
        mOTAManager?.registerBluetoothCallback(mOTAEventCallback)
    }

    private fun destroyOTA(){
        mOTAManager?.unregisterBluetoothCallback(mOTAEventCallback)
        mOTAManager?.release()
        mOTAManager = null
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