package com.jieli.watchtesttool.tool.config;

import android.content.Context;
import android.content.SharedPreferences;

import com.jieli.bluetooth_connect.constant.BluetoothConstant;
import com.jieli.watchtesttool.util.WatchConstant;

/**
 * @author zqjasonZhong
 * @email zhongzhuocheng@zh-jieli.com
 * @desc 功能配置辅助类
 * @since 2022/5/20
 */
public class ConfigHelper {
    private final SharedPreferences preferences;

    private static final String KEY_SPP_CONNECT_WAY = "key_spp_connect_way";
    private static final String KEY_USE_DEVICE_AUTH = "key_use_device_auth";
    private static final String KEY_BAN_AUTO_TEST = "key_ban_auto_test";
    private static final String KEY_TEST_FILE_TRANSFER = "key_test_file_transfer";
    private static final String KEY_TEST_FILE_BROWSE = "key_test_file_browse";
    private static final String KEY_TEST_SMALL_FILE_TRANSFER = "key_test_small_file_transfer";
    private static final String KEY_TEST_WATCH_OP = "key_test_watch_op";
    private static final String KEY_TEST_OTA = "key_test_ota";

    public ConfigHelper(Context context) {
        this.preferences = context.getSharedPreferences("watch_config_data", Context.MODE_PRIVATE);
    }

    public SharedPreferences getPreferences() {
        return preferences;
    }

    public boolean isSPPConnectWay(){
        return preferences.getBoolean(KEY_SPP_CONNECT_WAY, WatchConstant.DEFAULT_CONNECT_WAY == BluetoothConstant.PROTOCOL_TYPE_SPP);
    }

    public void setSppConnectWay(boolean isSppConnectWay){
        preferences.edit().putBoolean(KEY_SPP_CONNECT_WAY, isSppConnectWay).apply();
    }

    public boolean isUseDeviceAuth() {
        return preferences.getBoolean(KEY_USE_DEVICE_AUTH, WatchConstant.USE_DEVICE_AUTH);
    }

    public void setUseDeviceAuth(boolean isUseDeviceAuth) {
        preferences.edit().putBoolean(KEY_USE_DEVICE_AUTH, isUseDeviceAuth).apply();
    }

    public boolean isBanAutoTest() {
        return preferences.getBoolean(KEY_BAN_AUTO_TEST, WatchConstant.BAN_AUTO_TEST);
    }

    public void setBanAutoTest(boolean isBanAutoTest) {
        preferences.edit().putBoolean(KEY_BAN_AUTO_TEST, isBanAutoTest).apply();
    }

    public boolean isTestFileTransfer() {
        return preferences.getBoolean(KEY_TEST_FILE_TRANSFER, WatchConstant.TEST_FILE_TRANSFER);
    }

    public void setTestFileTransfer(boolean isTestFileTransfer) {
        preferences.edit().putBoolean(KEY_TEST_FILE_TRANSFER, isTestFileTransfer).apply();
    }

    public boolean isTestFileBrowse() {
        return preferences.getBoolean(KEY_TEST_FILE_BROWSE, WatchConstant.TEST_FILE_BROWSE);
    }

    public void setTestFileBrowse(boolean isTestFileBrowse) {
        preferences.edit().putBoolean(KEY_TEST_FILE_BROWSE, isTestFileBrowse).apply();
    }

    public boolean isTestSmallFileTransfer() {
        return preferences.getBoolean(KEY_TEST_SMALL_FILE_TRANSFER, WatchConstant.TEST_SMALL_FILE_TRANSFER);
    }

    public void setTestSmallFileTransfer(boolean isTestSmallFileTransfer) {
        preferences.edit().putBoolean(KEY_TEST_SMALL_FILE_TRANSFER, isTestSmallFileTransfer).apply();
    }

    public boolean isTestWatchOp() {
        return preferences.getBoolean(KEY_TEST_WATCH_OP, WatchConstant.TEST_WATCH_OP);
    }

    public void setTestWatchOp(boolean isTestWatchOp) {
        preferences.edit().putBoolean(KEY_TEST_WATCH_OP, isTestWatchOp).apply();
    }

    public boolean isTestOTA() {
        return preferences.getBoolean(KEY_TEST_OTA, WatchConstant.TEST_OTA_FUNC);
    }

    public void setTestOTA(boolean isTestOTA) {
        preferences.edit().putBoolean(KEY_TEST_OTA, isTestOTA).apply();
    }
}
