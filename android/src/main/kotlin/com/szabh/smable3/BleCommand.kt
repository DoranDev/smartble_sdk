package com.szabh.smable3

import com.szabh.smable3.component.BleCache

/**
 * BLE协议中的command
 */
enum class BleCommand(val mBleCommand: Int) {
    UPDATE(0x01), SET(0x02), CONNECT(0x03), PUSH(0x04), DATA(0x05), CONTROL(0x06), IO(0x07), NONE(0xff);

    /**
     * 获取该command对应的所有key
     */
    fun getBleKeys(): List<BleKey> {
        return BleKey.values().filter { bleKey ->
            bleKey.mKey ushr 8 == mBleCommand
        }
    }

    // 不要对toString()做任何修改
    override fun toString(): String {
        return String.format("0x%02X_", mBleCommand) + name
    }
}

/**
 * BLE协议中的key, key的定义包括了其对应的command，使用时直接使用key就行了。
 * 增加key时，需要关注[BleCache.requireCache]、[BleCache.getIdObjects]、[BleKey.isIdObjectKey]
 * 是否需要相应修改
 */
enum class BleKey(val mKey: Int) {
    // UPDATE
    OTA(0x0101),
    XMODEM(0x0102),

    // SET
    TIME(0x0201), TIME_ZONE(0x0202), POWER(0x0203), FIRMWARE_VERSION(0x0204),
    BLE_ADDRESS(0x0205), USER_PROFILE(0x0206), STEP_GOAL(0x0207), BACK_LIGHT(0x0208),
    SEDENTARINESS(0x0209), NO_DISTURB_RANGE(0x020A), VIBRATION(0x020B),
    GESTURE_WAKE(0x020C), HR_ASSIST_SLEEP(0x020D), HOUR_SYSTEM(0x020E), LANGUAGE(0x020F),
    ALARM(0x0210), COACHING(0x0212),
    FIND_PHONE(0x0213), NOTIFICATION_REMINDER(0x0214), ANTI_LOST(0x0215), HR_MONITORING(0x0216),
    UI_PACK_VERSION(0x0217), LANGUAGE_PACK_VERSION(0x0218), SLEEP_QUALITY(0x0219), GIRL_CARE(0x021A),
    TEMPERATURE_DETECTING(0x021B), AEROBIC_EXERCISE(0x021C), TEMPERATURE_UNIT(0x021D), DATE_FORMAT(0x021E),
    WATCH_FACE_SWITCH(0x021F), AGPS_PREREQUISITE(0x0220), DRINK_WATER(0x0221), SHUTDOWN(0x0222),
    APP_SPORT_DATA(0x0223), REAL_TIME_HEART_RATE(0x0224), BLOOD_OXYGEN_SET(0x0225), WASH_SET(0x0226),

    // KeyFlag为UPDATE时：设备支持外置多表盘，但是因为IO协议的限制，无法携带表盘id信息，所以在发送表盘文件之前需要先发送该指令提前告知
    //                    将要发送表盘的id
    // KeyFlag为READ时：设备支持外置多表盘，读取设备上已存在表盘id列表
    WATCHFACE_ID(0x0227),
    IBEACON_SET(0x0228),
    MAC_QRCODE(0x0229), //二维码的进制转换设置
    REAL_TIME_TEMPERATURE(0x0230),
    REAL_TIME_BLOOD_PRESSURE(0x0231),

    TEMPERATURE_VALUE(0x0232),//体温标定
    GAME_SET(0x0233),//家长控制, 游戏时间设置
    FIND_WATCH(0x0234),//找手机
    SET_WATCH_PASSWORD(0x0235),//设置手表密码
    REALTIME_MEASUREMENT(0x0236),//实时测量

    LOCATION_GSV(0x02F7), // 设备定位GSV数据
    HR_RAW(0x02F8),
    REALTIME_LOG(0x02F9),
    GSENSOR_OUTPUT(0x02FA), // G-Sensor原始数据，1开启，0关闭
    GSENSOR_RAW(0x02FB), // G-Sensor原始数据，2^9为1g
    MOTION_DETECT(0x02FC), // G-Sensor动作检测数据，n组√(x1 - x0)² + (y1 - y0)² + (z1 - z0)²，带符号16位整数
    LOCATION_GGA(0x02FD), // 设备定位GGA数据
    RAW_SLEEP(0x02FE), // 洪涛写的睡眠算法的原始数据
    NO_DISTURB_GLOBAL(0x02FF),

    // CONNECT
    IDENTITY(0x0301), // 身份，代表绑定的意思
    SESSION(0x0302), // 会话，代表登陆的意思

    // PUSH
    NOTIFICATION(0x0401),
    MUSIC_CONTROL(0x0402),
    SCHEDULE(0x0403),
    WEATHER_REALTIME(0x0404),
    WEATHER_FORECAST(0x0405),
    HID(0x0406),
    WORLD_CLOCK(0x0407),
    STOCK(0x0408),
    SMS_QUICK_REPLY_CONTENT(0x0409),
    NOTIFICATION2(0x040A),  //带有Phone字段的推送协议，应用于支持短信快捷回复的设备

    // DATA
    DATA_ALL(0x05ff), // 实际协议中并没有该指令，该指令只是用来同步所有数据
    ACTIVITY_REALTIME(0x0501),
    ACTIVITY(0x0502), HEART_RATE(0x0503), BLOOD_PRESSURE(0x0504), SLEEP(0x0505),
    WORKOUT(0x0506), LOCATION(0x0507), TEMPERATURE(0x0508), BLOOD_OXYGEN(0x0509), HRV(0x050A),
    LOG(0x050B), SLEEP_RAW_DATA(0x050C), PRESSURE(0x050D), WORKOUT2(0x050E),
    MATCH_RECORD(0x050F),

    // CONTROL
    CAMERA(0x0601),
    REQUEST_LOCATION(0x0602),
    INCOMING_CALL(0x0603),
    APP_SPORT_STATE(0x0604),
    CLASSIC_BLUETOOTH_STATE(0x0605),
    DEVICE_SMS_QUICK_REPLY(0x0607),

    // IO
    WATCH_FACE(0x0701),
    AGPS_FILE(0x0702),
    FONT_FILE(0x0703),
    CONTACT(0x0704),
    UI_FILE(0x0705),
    DEVICE_FILE(0x0706),
    LANGUAGE_FILE(0x0707),
    BRAND_INFO_FILE(0x0708),

    NONE(0xffff);

    val mBleCommand: BleCommand
        get() {
            val bleCommand = BleCommand.values().find { it.mBleCommand == mKey.ushr(8) }
            return bleCommand ?: BleCommand.NONE
        }

    val mCommandRawValue: Byte
        get() = mKey.shr(8).toByte()

    val mKeyRawValue: Byte
        get() = mKey.toByte()

    fun getBleKeyFlags(): List<BleKeyFlag> {
        return when (this) {
            // UPDATE
            OTA, XMODEM ->
                listOf(BleKeyFlag.UPDATE)
            // SET
            POWER, FIRMWARE_VERSION, BLE_ADDRESS, UI_PACK_VERSION, LANGUAGE_PACK_VERSION, DEVICE_FILE, RAW_SLEEP ->
                listOf(BleKeyFlag.READ)
            TIME, NOTIFICATION_REMINDER, SLEEP_QUALITY, GIRL_CARE, TEMPERATURE_DETECTING, SHUTDOWN, APP_SPORT_DATA, REAL_TIME_HEART_RATE,
            IBEACON_SET, MAC_QRCODE, REAL_TIME_TEMPERATURE, REAL_TIME_BLOOD_PRESSURE, SET_WATCH_PASSWORD, REALTIME_MEASUREMENT ->
                listOf(BleKeyFlag.UPDATE)
            TIME_ZONE, USER_PROFILE, STEP_GOAL, BACK_LIGHT, SEDENTARINESS,
            NO_DISTURB_RANGE, NO_DISTURB_GLOBAL, VIBRATION, GESTURE_WAKE, HR_ASSIST_SLEEP,
            HOUR_SYSTEM, LANGUAGE, ANTI_LOST, HR_MONITORING, AEROBIC_EXERCISE, TEMPERATURE_UNIT, DATE_FORMAT, WATCH_FACE_SWITCH, DRINK_WATER,
            WATCHFACE_ID ->
                listOf(BleKeyFlag.UPDATE, BleKeyFlag.READ)
            ALARM ->
                listOf(BleKeyFlag.CREATE, BleKeyFlag.DELETE, BleKeyFlag.UPDATE, BleKeyFlag.READ, BleKeyFlag.RESET)
            COACHING ->
                listOf(BleKeyFlag.CREATE, BleKeyFlag.UPDATE, BleKeyFlag.READ)
            // CONNECT
            IDENTITY ->
                listOf(BleKeyFlag.CREATE, BleKeyFlag.READ, BleKeyFlag.DELETE, BleKeyFlag.UPDATE)
            // PUSH
            NOTIFICATION, WEATHER_REALTIME, WEATHER_FORECAST, NOTIFICATION2 ->
                listOf(BleKeyFlag.UPDATE)
            SCHEDULE, SMS_QUICK_REPLY_CONTENT ->
                listOf(BleKeyFlag.CREATE, BleKeyFlag.DELETE, BleKeyFlag.UPDATE)
            HID ->
                listOf(BleKeyFlag.READ)
            WORLD_CLOCK, STOCK ->
                listOf(BleKeyFlag.CREATE, BleKeyFlag.DELETE, BleKeyFlag.UPDATE, BleKeyFlag.READ)
            // DATA
            DATA_ALL, ACTIVITY_REALTIME ->
                listOf(BleKeyFlag.READ)
            ACTIVITY, HEART_RATE, BLOOD_PRESSURE, SLEEP, WORKOUT, LOCATION, TEMPERATURE, BLOOD_OXYGEN, HRV, LOG, SLEEP_RAW_DATA, PRESSURE, WORKOUT2 ->
                listOf(BleKeyFlag.READ, BleKeyFlag.DELETE)
            // CONTROL
            CAMERA ->
                listOf(BleKeyFlag.UPDATE)
            REQUEST_LOCATION, DEVICE_SMS_QUICK_REPLY ->
                listOf(BleKeyFlag.CREATE)
            INCOMING_CALL, APP_SPORT_STATE, CLASSIC_BLUETOOTH_STATE ->
                listOf(BleKeyFlag.UPDATE)

            // IO
            WATCH_FACE, AGPS_FILE, FONT_FILE, CONTACT, UI_FILE, LANGUAGE_FILE, BRAND_INFO_FILE ->
                listOf(/*BleKeyFlag.DELETE, */BleKeyFlag.UPDATE)
            else -> listOf()
        }
    }

    internal fun isIdObjectKey(): Boolean {
        return this == ALARM || this == SCHEDULE || this == COACHING || this == WORLD_CLOCK || this == STOCK || this == SMS_QUICK_REPLY_CONTENT
    }

    // 不要对toString()做任何修改
    override fun toString(): String {
        return String.format("0x%04X_", mKey) + name
    }

    companion object {

        fun of(key: Int): BleKey {
            val bleKey = values().find { it.mKey == key }
            return bleKey ?: NONE
        }
    }
}

enum class BleKeyFlag(val mBleKeyFlag: Int) {
    UPDATE(0x00), READ(0x10), READ_CONTINUE(0x11), CREATE(0x20), DELETE(0x30),

    // BleIdObject专属，相当于Delete All和Create的组合，用于绑定时重置BleIdObject列表
    // 只能用BleConnector.sendList重置，sendObject无效
    RESET(0x40),
    NONE(0xff);

    // 不要对toString()做任何修改
    override fun toString(): String {
        return String.format("0x%02X_", mBleKeyFlag) + name
    }

    companion object {

        fun of(flag: Int): BleKeyFlag {
            val bleKey = values().find { it.mBleKeyFlag == flag }
            return bleKey ?: NONE
        }
    }
}
