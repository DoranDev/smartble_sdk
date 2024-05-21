package com.szabh.androidblesdk3.activity

import android.Manifest
import android.bluetooth.BluetoothDevice
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.widget.ListView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.bestmafen.baseble.scanner.BleDevice
import com.bestmafen.baseble.scanner.BleScanCallback
import com.bestmafen.baseble.scanner.BleScanFilter
import com.bestmafen.baseble.scanner.ScannerFactory
import com.blankj.utilcode.constant.PermissionConstants
import com.blankj.utilcode.util.LogUtils
import com.blankj.utilcode.util.PermissionUtils
import com.szabh.androidblesdk3.R
import com.szabh.androidblesdk3.isJLOTA
import com.szabh.androidblesdk3.tools.require
import com.szabh.androidblesdk3.ui.DeviceAdapter
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.entity.BleDeviceInfo

class MainActivity : AppCompatActivity() {
    private val mListView by lazy {
        findViewById<ListView>(R.id.list_view)
    }
    private val mTvScan by lazy { findViewById<TextView>(R.id.tv_scan) }

    private val mAdapter = DeviceAdapter()

    private val mBleScanner by lazy {
        // ScannerFactory.newInstance(arrayOf(UUID.fromString(BleConnector.BLE_SERVICE)))
        ScannerFactory.newInstance()
            .setScanDuration(10)
            .setScanFilter(object : BleScanFilter {

                override fun match(device: BleDevice): Boolean {
                    //Filter the Bluetooth signal value, the larger the signal value, the stronger the signal, for example -66 > -88
                    return device.mRssi > -88
                }
            })
            .setBleScanCallback(object : BleScanCallback {

                override fun onBluetoothDisabled() {
                    mTvScan.setText(R.string.enable_bluetooth)
                }

                override fun onScan(scan: Boolean) {
                    if (scan) {
                        mAdapter.clear()
                        mTvScan.setText(R.string.scanning)
                    } else {
                        mTvScan.setText(R.string.scan)
                    }
                }

                override fun onDeviceFound(device: BleDevice) {
                    mAdapter.add(device)

                    LogUtils.d("${device.mName} isOTA -> ${isJLOTA(device)}")
                }
            })
    }

    private val mBleHandleCallback by lazy {
        object : BleHandleCallback {

            override fun onDeviceConnected(device: BluetoothDevice) {
            }

            override fun onIdentityCreate(status: Boolean, deviceInfo: BleDeviceInfo?) {
                if (status) {
                    BleConnector.connectClassic()
                    startActivity(Intent(this@MainActivity, CommandListActivity::class.java))
                    finish()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        BleConnector.addHandleCallback(mBleHandleCallback)
        mListView.apply {
            adapter = mAdapter
            setOnItemClickListener { _, _, position, _ ->
                mBleScanner.scan(false)
                //连接设备
                BleConnector.setBleDevice((mAdapter.getItem(position) as BleDevice)).connect(true)
            }
        }
        mTvScan.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PermissionUtils
                    .permission(
                        PermissionConstants.LOCATION,
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT
                    )
                    .require(
                        PermissionConstants.LOCATION,
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) { granted ->
                        if (granted) {
                            mBleScanner.scan(!mBleScanner.isScanning)
                        }
                    }
            } else {
                PermissionUtils
                    .permission(PermissionConstants.LOCATION)
                    .require(Manifest.permission.ACCESS_FINE_LOCATION) { granted ->
                        if (granted) {
                            mBleScanner.scan(!mBleScanner.isScanning)
                        }
                    }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        BleConnector.removeHandleCallback(mBleHandleCallback)
        mBleScanner.exit()
    }
}
