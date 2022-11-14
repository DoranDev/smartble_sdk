package com.bestmafen.baseble.scanner

import android.bluetooth.BluetoothDevice
import com.bestmafen.baseble.data.mHexString

/**
 * [BluetoothDevice]的包装类，扫描返回的结果。
 *
 * A wrapper of [BluetoothDevice], presenting a result of scanning.
 */
data class BleDevice(
    /**
     * 扫描到的蓝牙设备。
     *
     * Remote device.
     */
    var mBluetoothDevice: BluetoothDevice,

    /**
     * 蓝牙设备报告的信号强度。
     *
     * Received signal strength.
     */
    var mRssi: Int,

    /**
     * 蓝牙设备广播的数据。
     *
     * The content of the advertisement record offered by the remote device.
     */
    var mScanRecord: ByteArray?,

    /**
     * 蓝牙设备名
     *
     * 之前用[BluetoothDevice.getName]直接获取蓝牙名，在搜索蓝牙设备时这个方法获取蓝牙名不为空，但后面多次调用的时候有可能出现空名的情况
     */
    var mName: String,

    /**
     *  设备类型，对应
     *  [BluetoothDevice.getType]
     */
    var mType: Int
) {

    override fun hashCode(): Int {
        return mBluetoothDevice.hashCode()
    }

    override fun equals(other: Any?): Boolean {
        if (other is BleDevice) return this.mBluetoothDevice == other.mBluetoothDevice

        return false
    }

    override fun toString(): String {
        return "BleDevice(type=${mType}, name=${mBluetoothDevice.name}, address=${mBluetoothDevice.address}, mRssi=$mRssi" +
            ", mScanRecord=${mScanRecord.mHexString})"
    }
}