package id.kakzaki.smartble_sdk.tools

import android.content.Context
import android.util.Log
import com.blankj.utilcode.util.ToastUtils
import com.szabh.smable3.component.BleConnector

fun doBle(context: Context, action: () -> Unit) {
    if (BleConnector.isAvailable()) {
        action()
    } else {
        Log.d("doBLE","BleConnector is not available!")
    }
}
