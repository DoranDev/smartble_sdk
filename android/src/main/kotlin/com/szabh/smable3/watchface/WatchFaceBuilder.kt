package com.szabh.smable3.watchface

/**
 * 用于生成自定义表盘。
 */
object WatchFaceBuilder {
    const val PNG_ARGB_8888 = 0x01
    const val BMP_565 = 0x02

    //适用于MTK，不合规的做法，因出货设备较多，暂时无法纠正
    const val GRAVITY_X_LEFT = 1
    const val GRAVITY_X_RIGHT = 1 shl 1
    const val GRAVITY_X_CENTER = 1 shl 2
    const val GRAVITY_Y_TOP = 1 shl 3
    const val GRAVITY_Y_BOTTOM = 1 shl 4
    const val GRAVITY_Y_CENTER = 1 shl 5

    //以下适用于瑞昱
    const val GRAVITY_X_CENTER_R = 1 shl 1
    const val GRAVITY_X_RIGHT_R = 1 shl 2
    const val GRAVITY_Y_CENTER_R = 1 shl 4
    const val GRAVITY_Y_BOTTOM_R = 1 shl 5

    const val ELEMENT_PREVIEW = 0x01
    const val ELEMENT_BACKGROUND = 0x02     //The background cannot be moved, and the default is full screen, setting coordinates is meaningless
    const val ELEMENT_NEEDLE_HOUR = 0x03
    const val ELEMENT_NEEDLE_MIN = 0x04
    const val ELEMENT_NEEDLE_SEC = 0x05
    const val ELEMENT_DIGITAL_YEAR = 0x06
    const val ELEMENT_DIGITAL_MONTH = 0x07
    const val ELEMENT_DIGITAL_DAY = 0x08
    const val ELEMENT_DIGITAL_HOUR = 0x09
    const val ELEMENT_DIGITAL_MIN = 0x0A
    const val ELEMENT_DIGITAL_SEC = 0x0B
    const val ELEMENT_DIGITAL_AMPM = 0x0C
    const val ELEMENT_DIGITAL_WEEKDAY = 0x0D
    const val ELEMENT_DIGITAL_STEP = 0x0E
    const val ELEMENT_DIGITAL_HEART = 0x0F
    const val ELEMENT_DIGITAL_CALORIE = 0x10
    const val ELEMENT_DIGITAL_DISTANCE = 0x11
    const val ELEMENT_DIGITAL_BAT = 0x12
    const val ELEMENT_DIGITAL_BT = 0x13
    const val ELEMENT_DIGITAL_DIV_HOUR = 0x14
    const val ELEMENT_DIGITAL_DIV_MONTH = 0x15

    init {
        System.loadLibrary("smawatchface")
        initLib()
    }

    external fun build(elements: Array<Element>, imageFormat: Int): ByteArray

    external fun initLib()
}
