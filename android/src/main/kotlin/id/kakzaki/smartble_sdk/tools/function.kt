package id.kakzaki.smartble_sdk.tools

import android.content.Context
import com.blankj.utilcode.util.ToastUtils
import com.szabh.smable3.component.BleConnector

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
