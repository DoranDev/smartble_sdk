package com.szabh.androidblesdk3

import android.Manifest
import android.app.Activity
import android.app.ListActivity
import android.content.Context
import android.content.Intent
import com.bestmafen.baseble.scanner.BleDevice
import com.blankj.utilcode.constant.PermissionConstants
import com.blankj.utilcode.util.FileUtils
import com.blankj.utilcode.util.PathUtils
import com.blankj.utilcode.util.PermissionUtils
import com.szabh.androidblesdk3.tools.require
import com.szabh.smable3.BleKey
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.DATA_EPOCH
import java.io.File
import java.util.*
import kotlin.concurrent.thread

val SDK_FILE_ROOT: String = PathUtils.getExternalAppFilesPath()
const val REQUEST_CODE_G_FIRMWARE = 1
const val REQUEST_CODE_N_FIRMWARE = 2

fun copyAssert(context: Context, callback: (() -> Unit)? = null) {
    FileUtils.createOrExistsDir(SDK_FILE_ROOT)
    PermissionUtils
        .permission(PermissionConstants.STORAGE)
        .require(Manifest.permission.WRITE_EXTERNAL_STORAGE) { granted ->
            if (granted) {
                context.assets.list("")?.filter {
                    it.endsWith(".alp") || it.endsWith(".bin") || it.endsWith(".dat") || it.endsWith(".zip")|| it.endsWith(".png")
                }?.let { assertFiles ->
                    for (assertFile in assertFiles) {
                        val copyToFile = File(SDK_FILE_ROOT, assertFile)
                        if (!copyToFile.exists()) {
                            copyToFile.writeBytes(context.assets.open(assertFile).readBytes())
                        }
                    }
                }
            }
            callback?.invoke()
        }
}

fun chooseFile(activity: Activity, requestCode: Int) {
    val chooseFile = Intent(Intent.ACTION_GET_CONTENT).apply {
        addCategory(Intent.CATEGORY_OPENABLE)
        type = "*/*"
    }
    activity.startActivityForResult(Intent.createChooser(chooseFile, "Choose a file"), requestCode)
}

fun dispatchChooseFileActivityResult(context: Context, requestCode: Int, resultCode: Int, data: Intent?, type: Int = 0) {
    if (resultCode == ListActivity.RESULT_OK) {
        val uri = data?.data ?: return

        context.contentResolver.openInputStream(uri)?.let {
            BleConnector.sendStream(BleKey.of(requestCode), it, type)
        }
    }
}

/**
 * 将ble类里面的time转成实际的毫秒时间
 */
fun toTimeMillis(time: Int): Long {
    val offset = TimeZone.getDefault().getOffset(System.currentTimeMillis()).toLong()
    return (time + DATA_EPOCH) * 1000L - offset
}

/**
 * 杰里设备是否ota模式
 */
fun isJLOTA(device: BleDevice): Boolean {
    val bytes = device.mScanRecord ?: ByteArray(20)
    if (bytes.size > 20) {
        return String(bytes.copyOfRange(4,9).reversed().toByteArray()) == "JLOTA"
    }
    return false
}