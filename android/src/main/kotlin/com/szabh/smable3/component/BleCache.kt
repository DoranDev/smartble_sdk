package com.szabh.smable3.component

import android.bluetooth.BluetoothAdapter
import android.util.SparseArray
import com.bestmafen.baseble.util.BleLog
import com.blankj.utilcode.util.SPUtils
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.szabh.smable3.BleCommand
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.entity.*
import id.kakzaki.smartble_sdk.BuildConfig

private const val SP_NAME = "sma_ble_sdk3"

object BleCache {
    private const val TAG = "BleCache"
    private const val MTK_OTA_META = "mtk_ota_meta"

    private val mSpUtils: SPUtils by lazy { SPUtils.getInstance(SP_NAME) }

    // 设备信息会包含其aGps文件类型，发送aGps时需要根据类型来检索下载链接
    private val mAGpsFileUrls = SparseArray<String>().apply {
        append(BleDeviceInfo.AGPS_EPO, "http://wepodownload.mediatek.com/EPO_GR_3_1.DAT")
        append(BleDeviceInfo.AGPS_UBLOX, "https://alp.u-blox.com/current_1d.alp")
        append(BleDeviceInfo.AGPS_AGNSS, "https://api.smawatch.cn/epo/ble_epo_offline.bin")
        append(
            BleDeviceInfo.AGPS_EPO2,
            if (BuildConfig.DEBUG) {//测试服务器
                "https://sma-test.oss-accelerate.aliyuncs.com/a-gps/file_info_3335_epo.DAT"
            } else {
                "https://sma-product.oss-accelerate.aliyuncs.com/a-gps/file_info_3335_epo.DAT"
            }
        )
        append(
            BleDeviceInfo.AGPS_LTO,
            if (BuildConfig.DEBUG) {//测试服务器
                "https://sma-test.oss-accelerate.aliyuncs.com/a-gps/file_info_7dv5_lto.brm"
            } else {
                "https://sma-product.oss-accelerate.aliyuncs.com/a-gps/file_info_7dv5_lto.brm"
            }
        )
    }

    // 必须在绑定设备之后调用，否则返回的信息没有任何意义
    var mDeviceInfo: BleDeviceInfo? = null

    val mDataKeys: List<Int>
        get() = mDeviceInfo?.mDataKeys ?: listOf()

    val mBleName: String
        get() = mDeviceInfo?.mBleName ?: ""

    val mBleAddress: String
        get() = mDeviceInfo?.mBleAddress ?: ""

    val mPlatform: String
        get() = mDeviceInfo?.mPlatform ?: ""

    val mPrototype: String
        get() = mDeviceInfo?.mPrototype ?: ""

    val mFirmwareFlag: String
        get() = mDeviceInfo?.mFirmwareFlag ?: ""

    val mAGpsType: Int
        get() = mDeviceInfo?.mAGpsType ?: BleDeviceInfo.AGPS_NONE

    val mIOBufferSize: Long
        get() {
            var size = mDeviceInfo?.mIOBufferSize
            if (size == null || size == 0L) {
                size = BleStreamPacket.BUFFER_MAX_SIZE
            }
            return size
        }

    val mWatchFaceType: Int
        get() = mDeviceInfo?.mWatchFaceType ?: BleDeviceInfo.WATCH_0

    val mHideDigitalPower: Int
        get() = mDeviceInfo?.mHideDigitalPower ?: BleDeviceInfo.DIGITAL_POWER_VISIBLE

    val mClassicAddress: String
        get() = mDeviceInfo?.mClassicAddress ?: ""

    val mAGpsFileUrl: String
        get() = mAGpsFileUrls[mAGpsType] ?: ""

    val mShowAntiLostSwitch: Int
        get() = mDeviceInfo?.mShowAntiLostSwitch ?: BleDeviceInfo.ANTI_LOST_HIDE

    val mSleepAlgorithmType: Int
        get() = mDeviceInfo?.mSleepAlgorithmType ?: BleDeviceInfo.SUPPORT_NEW_SLEEP_ALGORITHM_0

    val mSupportDateFormatSet: Int
        get() = mDeviceInfo?.mSupportDateFormatSet ?: BleDeviceInfo.SUPPORT_DATE_FORMAT_0

    val mSupportReadDeviceInfo: Int
        get() = mDeviceInfo?.mSupportReadDeviceInfo ?: BleDeviceInfo.SUPPORT_READ_DEVICE_INFO_0

    val mSupportTemperatureUnitSet: Int
        get() = mDeviceInfo?.mSupportTemperatureUnitSet ?: BleDeviceInfo.SUPPORT_TEMPERATURE_UNIT_0

    val mSupportDrinkWaterSet: Int
        get() = mDeviceInfo?.mSupportDrinkWaterSet ?: BleDeviceInfo.SUPPORT_DRINK_WATER_0

    val mSupportChangeClassicBluetoothState: Int
        get() = mDeviceInfo?.mSupportChangeClassicBluetoothState ?: BleDeviceInfo.SUPPORT_CHANGE_CLASSIC_BLUETOOTH_STATE_0

    val mSupportAppSport: Int
        get() = mDeviceInfo?.mSupportAppSport ?: BleDeviceInfo.SUPPORT_APP_SPORT_0

    val mSupportBloodOxyGenSet: Int
        get() = mDeviceInfo?.mSupportBloodOxyGenSet?: BleDeviceInfo.SUPPORT_BLOOD_OXYGEN_0

    val mSupportWashSet: Int
        get() = mDeviceInfo?.mSupportWashSet?: BleDeviceInfo.SUPPORT_WASH_0

    val mSupportRequestRealtimeWeather: Int
        get() = mDeviceInfo?.mSupportRequestRealtimeWeather?: BleDeviceInfo.SUPPORT_REQUEST_REALTIME_WEATHER_0

    val mSupportHID: Int
        get() = mDeviceInfo?.mSupportHID?: BleDeviceInfo.SUPPORT_HID_0

    val mSupportIBeaconSet: Int
        get() = mDeviceInfo?.mSupportIBeaconSet?: BleDeviceInfo.SUPPORT_IBEACON_SET_0

    val mSupportWatchFaceId: Int
        get() = mDeviceInfo?.mSupportWatchFaceId?: BleDeviceInfo.SUPPORT_WATCHFACE_ID_0

    val mSupportJLTransport: Int
        get() = mDeviceInfo?.mSupportJLTransport?: BleDeviceInfo.SUPPORT_JL_TRANSPORT_0

    val mSupportFindWatch: Int
        get() = mDeviceInfo?.mSupportFindWatch?: BleDeviceInfo.SUPPORT_FIND_WATCH_0

    val mSupportWorldClock: Int
        get() = mDeviceInfo?.mSupportWorldClock?: BleDeviceInfo.SUPPORT_WORLD_CLOCK_0

    val mSupportStock: Int
        get() = mDeviceInfo?.mSupportStock?: BleDeviceInfo.SUPPORT_STOCK_0

    val mSupportSMSQuickReply: Int
        get() = mDeviceInfo?.mSupportSMSQuickReply?: BleDeviceInfo.SUPPORT_SMS_QUICK_REPLY_0

    val mSupportNoDisturbSet: Int
        get() = mDeviceInfo?.mSupportNoDisturbSet?: BleDeviceInfo.SUPPORT_NO_DISTURB_0

    val mSupportSetWatchPassword: Int
        get() = mDeviceInfo?.mSupportSetWatchPassword?: BleDeviceInfo.SUPPORT_SET_WATCH_PASSWORD_0

    val mSupportRealTimeMeasurement: Int
        get() = mDeviceInfo?.mSupportRealTimeMeasurement?: BleDeviceInfo.SUPPORT_REALTIME_MEASUREMENT_0


    /**
     * 设备进入OTA之后的mac地址，[BleDeviceInfo.PLATFORM_NORDIC]的设备，进入OTA之后，设备地址会+1。
     */
    val mDfuAddress: String
        get() {
            val deviceInfo = mDeviceInfo
            if (deviceInfo == null || !BluetoothAdapter.checkBluetoothAddress(deviceInfo.mBleAddress))
                return ""

            if (deviceInfo.mPlatform == BleDeviceInfo.PLATFORM_JL || deviceInfo.mPlatform == BleDeviceInfo.PLATFORM_NORDIC || (deviceInfo.mPlatform == BleDeviceInfo.PLATFORM_GOODIX && deviceInfo.mPrototype == BleDeviceInfo.PROTOTYPE_R3Q)) {
                var addressHex = deviceInfo.mBleAddress.replace(":", "")
                val addressLong = addressHex.toLong(16) + 1
                addressHex = String.format("%012X", addressLong)
                return addressHex.chunked(2).joinToString(":")
            }

            return deviceInfo.mBleAddress
        }

    /**
     * 存入一个[Boolean]值。
     */
    fun putBoolean(bleKey: BleKey, value: Boolean, keyFlag: BleKeyFlag? = null) {
        BleLog.v("$TAG putBoolean ${getKey(bleKey, keyFlag)} -> $value")
        mSpUtils.put(getKey(bleKey, keyFlag), value)
    }

    /**
     * 取出一个[Boolean]值。
     */
    fun getBoolean(bleKey: BleKey, def: Boolean = false, keyFlag: BleKeyFlag? = null): Boolean {
        return mSpUtils.getBoolean(getKey(bleKey, keyFlag), def).also {
            BleLog.v("$TAG getBoolean ${getKey(bleKey, keyFlag)} -> $it")
        }
    }

    /**
     * 存入一个[Int]值。
     */
    fun putInt(bleKey: BleKey, value: Int, keyFlag: BleKeyFlag? = null) {
        BleLog.v("$TAG putInt ${getKey(bleKey, keyFlag)} -> $value")
        mSpUtils.put(getKey(bleKey, keyFlag), value)
    }

    /**
     * 取出一个[Int]值。
     */
    fun getInt(bleKey: BleKey, def: Int = 0, keyFlag: BleKeyFlag? = null): Int {
        return mSpUtils.getInt(getKey(bleKey, keyFlag), def).also {
            BleLog.v("$TAG getInt ${getKey(bleKey, keyFlag)} -> $it")
        }
    }

    /**
     * 存入一个[Long]值。
     */
    fun putLong(bleKey: BleKey, value: Long, keyFlag: BleKeyFlag? = null) {
        BleLog.v("$TAG putLong ${getKey(bleKey, keyFlag)} -> $value")
        mSpUtils.put(getKey(bleKey, keyFlag), value)
    }

    /**
     * 取出一个[Long]值。
     */
    fun getLong(bleKey: BleKey, def: Long = 0L, keyFlag: BleKeyFlag? = null): Long {
        return mSpUtils.getLong(getKey(bleKey, keyFlag), def).also {
            BleLog.v("$TAG getLong ${getKey(bleKey, keyFlag)} -> $it")
        }
    }

    /**
     * 存入一个[String]值。
     */
    fun putString(bleKey: BleKey, value: String, keyFlag: BleKeyFlag? = null) {
        BleLog.v("$TAG putString ${getKey(bleKey, keyFlag)} -> $value")
        mSpUtils.put(getKey(bleKey, keyFlag), value)
    }

    /**
     * 取出一个[String]值。
     */
    fun getString(bleKey: BleKey, def: String = "", keyFlag: BleKeyFlag? = null): String {
        return mSpUtils.getString(getKey(bleKey, keyFlag), def).also {
            BleLog.v("$TAG getString ${getKey(bleKey, keyFlag)} -> $it")
        }
    }

    /**
     * 存入一个对象。
     */
    fun <T> putObject(bleKey: BleKey, t: T?, keyFlag: BleKeyFlag? = null) {
        BleLog.v("$TAG putObject ${getKey(bleKey, keyFlag)} -> $t")
        if (t == null) {
            remove(bleKey)
        } else {
            mSpUtils.put(getKey(bleKey, keyFlag), Gson().toJson(t))
        }
    }

    /**
     * 取出一个对象，可能为null。
     */
    fun <T> getObject(bleKey: BleKey, clazz: Class<T>, keyFlag: BleKeyFlag? = null): T? {
        return Gson().fromJson(mSpUtils.getString(getKey(bleKey, keyFlag)), clazz).also {
            BleLog.v("$TAG getObject ${getKey(bleKey, keyFlag)} -> $it")
        }
    }

    /**
     * 取出一个对象，不为null。
     */
    fun <T> getObjectNotNull(bleKey: BleKey, clazz: Class<T>, def: T? = null, keyFlag: BleKeyFlag? = null): T {
        return getObject(bleKey, clazz) ?: (def ?: clazz.newInstance()).also {
            BleLog.v("$TAG getObjectNotNull ${getKey(bleKey, keyFlag)} -> $it")
        }
    }

    /**
     * 存入一个列表。
     */
    fun <T> putList(bleKey: BleKey, list: List<T>?, keyFlag: BleKeyFlag? = null) {
        BleLog.v("$TAG putList ${getKey(bleKey, keyFlag)} -> $list")
        if (list == null || list.isEmpty()) {
            remove(bleKey)
        } else {
            mSpUtils.put(getKey(bleKey, keyFlag), Gson().toJson(list))
        }
    }

    /**
     * 取出一个列表，不为null，但有可能为空。
     */
    fun <T> getList(bleKey: BleKey, clazz: Class<T>, keyFlag: BleKeyFlag? = null): MutableList<T> {
        return mutableListOf<T>().also { list ->
            if (mSpUtils.getString(getKey(bleKey, keyFlag)).isNotBlank()) {
                try {
                    JsonParser.parseString(mSpUtils.getString(getKey(bleKey, keyFlag))).asJsonArray?.forEach {
                        list.add(Gson().fromJson(it, clazz))
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }.also {
            BleLog.v("$TAG getList ${getKey(bleKey, keyFlag)} -> $it")
        }
    }

    /**
     * 保存MTK设备的固件信息。
     * mid=xx;mod=xx;oem=xx;pf=xx;p_id=xx;p_sec=xx;ver=xx;d_ty=xx;
     */
    fun putMtkOtaMeta(meta: String) {
        BleLog.v("$TAG putMtkOtaMeta  -> $meta")
        mSpUtils.put(MTK_OTA_META, meta)
    }

    /**
     * 获取MTK设备的固件信息。
     * mid=xx;mod=xx;oem=xx;pf=xx;p_id=xx;p_sec=xx;ver=xx;d_ty=xx;
     */
    fun getMtkOtaMeta(): String {
        return mSpUtils.getString(MTK_OTA_META).also {
            BleLog.v("$TAG getMtkOtaMeta -> $it")
        }
    }

    /**
     * 移除一个指令的缓存。
     */
    fun remove(bleKey: BleKey, keyFlag: BleKeyFlag? = null) {
        BleLog.v("$TAG remove ${getKey(bleKey, keyFlag)}")
        mSpUtils.remove(getKey(bleKey, keyFlag))
    }

    /**
     * 判定一个指令是否需要缓存，只在手机端发送时判定。设备回复和主动发送指令时，不依赖该方法的返回值，如果有需要，会直接缓存。
     */
    internal fun requireCache(bleKey: BleKey, bleKeyFlag: BleKeyFlag): Boolean {
        return when (bleKey.mBleCommand) {
            BleCommand.SET -> {
                bleKeyFlag == BleKeyFlag.CREATE || bleKeyFlag == BleKeyFlag.DELETE
                        || bleKeyFlag == BleKeyFlag.UPDATE || bleKeyFlag == BleKeyFlag.RESET
            }
            BleCommand.PUSH -> {
                (bleKey == BleKey.SCHEDULE && (bleKeyFlag == BleKeyFlag.CREATE || bleKeyFlag == BleKeyFlag.DELETE || bleKeyFlag == BleKeyFlag.UPDATE))
                        || (bleKey == BleKey.SMS_QUICK_REPLY_CONTENT && (bleKeyFlag == BleKeyFlag.CREATE || bleKeyFlag == BleKeyFlag.DELETE || bleKeyFlag == BleKeyFlag.UPDATE))
                        || (bleKey == BleKey.WEATHER_REALTIME && bleKeyFlag == BleKeyFlag.UPDATE)
                        || (bleKey == BleKey.WEATHER_FORECAST && bleKeyFlag == BleKeyFlag.UPDATE)
                        || (bleKey == BleKey.STOCK && (bleKeyFlag == BleKeyFlag.CREATE || bleKeyFlag == BleKeyFlag.DELETE || bleKeyFlag == BleKeyFlag.UPDATE))
                        || (bleKey == BleKey.WORLD_CLOCK && (bleKeyFlag == BleKeyFlag.CREATE || bleKeyFlag == BleKeyFlag.DELETE || bleKeyFlag == BleKeyFlag.UPDATE))
            }
            else -> false
        }
    }

    /**
     * 获取某些指令的[BleIdObject]列表
     */
    internal fun getIdObjects(bleKey: BleKey): MutableList<BleIdObject> {
        return when (bleKey) {
            BleKey.ALARM -> getList(bleKey, BleAlarm::class.java)
            BleKey.SCHEDULE -> getList(bleKey, BleSchedule::class.java)
            BleKey.COACHING -> getList(bleKey, BleCoaching::class.java)
            BleKey.WORLD_CLOCK -> getList(bleKey, BleWorldClock::class.java)
            BleKey.STOCK-> getList(bleKey, BleStock::class.java)
            BleKey.SMS_QUICK_REPLY_CONTENT-> getList(bleKey, BleSMSQuickReplyContent::class.java)
            else -> emptyList<BleIdObject>()
        }.toMutableList()
    }

    /**
     * 根据[BleKey]和[BleKeyFlag]生成一个用于缓存的key。
     */
    private fun getKey(bleKey: BleKey, keyFlag: BleKeyFlag?) =
        if (keyFlag == null) "$bleKey" else "${bleKey}_$keyFlag"

    /**
     * 清除所有缓存。
     */
    fun clear() {
        BleLog.v("$TAG clear")
        mSpUtils.clear()
    }
}