package com.szabh.androidblesdk3.tools

import android.content.Context
import com.blankj.utilcode.util.FileIOUtils
import com.blankj.utilcode.util.LogUtils
import com.blankj.utilcode.util.ToastUtils
import com.jieli.bmp_convert.BmpConvert
import com.szabh.smable3.component.BleConnector
import java.io.File

fun doBle(context: Context, action: () -> Unit) {
    if (BleConnector.isAvailable()) {
        action()
    } else {
        toast(context, "BleConnector is not available!")
    }
}

fun toast(context: Context, text: String) {
    ToastUtils.showLong(text)
}

fun Boolean.toInt() = if (this) 1 else 0

val SIZE_4 = 4

/**
 * 使用杰里库转换png图片
 */
fun convertPng(
    pngFile: File,
    isAlpha: Boolean = true,
): ByteArray? {
    val outFilePath = pngFile.path + ".bin"
    val type = if (isAlpha) {
        BmpConvert.TYPE_BR_28_ALPHA_RAW
    } else {
        BmpConvert.TYPE_BR_28_RAW
    }
    LogUtils.d("convertPng type=$type, pngFile=$pngFile, outFilePath=$outFilePath")
    //目前是用杰里的库转换
    val ret = BmpConvert().bitmapConvertBlock(type, pngFile.path, outFilePath)
    if (ret <= 0) {
        LogUtils.d("convertPng error = $ret")
        return null
    }
    val outFileBytes = FileIOUtils.readFile2BytesByChannel(outFilePath)
    val bytesSize = (outFileBytes.size + SIZE_4 - 1) / SIZE_4 * SIZE_4
    val bytes = ByteArray(bytesSize)
    System.arraycopy(outFileBytes, 0, bytes, 0, outFileBytes.size)
    LogUtils.d("convertPng outFileBytes=${outFileBytes.size}, bytes=${bytes.size}")
    return bytes
}