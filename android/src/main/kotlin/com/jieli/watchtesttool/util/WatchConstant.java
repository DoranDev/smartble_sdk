package com.jieli.watchtesttool.util;

import com.jieli.bluetooth_connect.constant.BluetoothConstant;

/**
 * @author zqjasonZhong
 * @email zhongzhuocheng@zh-jieli.com
 * @desc  手表常量定义
 * @since 2021/4/20
 */
public class WatchConstant {

    public final static int REQUEST_CODE_PERMISSIONS = 2333;
    public final static int REQUEST_CODE_CHECK_GPS = 2334;

    /*功能配置区*/
    //默认连接方式
    public final static int DEFAULT_CONNECT_WAY = BluetoothConstant.PROTOCOL_TYPE_BLE;
    //是否使用设备认证
    public final static boolean USE_DEVICE_AUTH = true;
    //是否禁止自动测试功能
    public final static boolean BAN_AUTO_TEST = true;
    //测试大文件传输功能
    public final static boolean TEST_FILE_TRANSFER = true;
    //测试文件浏览
    public final static boolean TEST_FILE_BROWSE = false;
    //测试表盘操作功能
    public final static boolean TEST_WATCH_OP = true;
    //测试OTA相关功能
    public final static boolean TEST_OTA_FUNC = true;
    //测试小文件传输功能
    public final static boolean TEST_SMALL_FILE_TRANSFER = false;


    public final static String DIR_WATCH = "watch";        //表盘测试文件夹
    public final static String DIR_WATCH_BG = "watch_bg";  //表盘自定义背景测试文件夹
    public final static String DIR_MUSIC = "music";        //音乐文件测试文件夹
    public final static String DIR_CONTACTS = "contacts";  //联系人测试文件夹
    public final static String DIR_UPDATE = "upgrade";     //升级文件

    public final static String DIR_BR23 = "BR23";
    public final static String DIR_BR28 = "BR28";

    public final static String KEY_FORCED_UPDATE_FLAG = "forced_update_flag";  //强制更新资源标志
}
