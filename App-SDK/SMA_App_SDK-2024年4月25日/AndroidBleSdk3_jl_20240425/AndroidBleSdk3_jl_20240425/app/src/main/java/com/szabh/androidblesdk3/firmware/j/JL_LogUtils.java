package com.szabh.androidblesdk3.firmware.j;


import android.content.Context;

import com.jieli.jl_bt_ota.util.JL_Log;

/**
 * 主要是用在杰里ota的log保存
 */
public class JL_LogUtils {

    private static boolean isEnable = false;

    public static void enableLog(Context context) {
        if (!isEnable) {
            isEnable = true;
            //开启杰里OTA的log
            JL_Log.setLog(true);
            JL_Log.setIsSaveLogFile(context, true);

            //开启杰里连接的打印库
            com.jieli.bluetooth_connect.util.JL_Log.setLog(true);
            com.jieli.bluetooth_connect.util.JL_Log.setLogOutput(new com.jieli.bluetooth_connect.util.JL_Log.ILogOutput() {
                @Override
                public void output(String logcat) {
                    JL_Log.addLogOutput(logcat);
                }
            });
        }
    }

    public static void disableLog(Context context) {
        isEnable = false;
        //关闭杰里OTA的log
        JL_Log.setLog(false);
        JL_Log.setIsSaveLogFile(context, false);

        //关闭杰里连接的打印库
        com.jieli.bluetooth_connect.util.JL_Log.setLog(false);
        com.jieli.bluetooth_connect.util.JL_Log.setLogOutput(null);
    }
}
