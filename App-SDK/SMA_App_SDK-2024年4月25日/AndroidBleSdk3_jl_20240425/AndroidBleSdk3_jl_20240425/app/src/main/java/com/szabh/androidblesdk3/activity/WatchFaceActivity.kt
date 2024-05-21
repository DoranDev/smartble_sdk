package com.szabh.androidblesdk3.activity

import android.graphics.*
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.graphics.drawable.toBitmap
import androidx.core.view.isVisible
import com.blankj.utilcode.util.*
import com.jieli.bmp_convert.BmpConvert
import com.sifli.ezip.sifliEzipUtil
import com.szabh.androidblesdk3.R
import com.szabh.androidblesdk3.tools.toInt
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.BleCache
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.entity.BleDeviceInfo
import com.szabh.smable3.watchface.Element
import com.szabh.smable3.watchface.WatchFaceBuilder
import java.io.File
import java.nio.ByteBuffer

class WatchFaceActivity : AppCompatActivity() {

    //背景
    val customizeDialBg by lazy { findViewById<ImageView>(R.id.customizeDialBg) }
    //步数
    val controlViewStep by lazy { findViewById<RelativeLayout>(R.id.controlViewStep) }
    //心率
    val controlViewHr by lazy { findViewById<RelativeLayout>(R.id.controlViewHr) }
    //卡路理
    val controlViewCa by lazy { findViewById<RelativeLayout>(R.id.controlViewCa) }
    //距离
    val controlViewDis by lazy { findViewById<RelativeLayout>(R.id.controlViewDis) }
    //数字时间
    val timeDigitalView by lazy { findViewById<LinearLayout>(R.id.timeDigitalView) }
    //指针
    val timePointView by lazy { findViewById<ImageView>(R.id.timePointView) }
    //刻度
    val timeScaleView by lazy { findViewById<ImageView>(R.id.timeScaleView) }

    val cbDigital by lazy { findViewById<CheckBox>(R.id.cb_digital) }
    val btnSync by lazy { findViewById<Button>(R.id.btn_sync) }

    var isRound = true   //是否是圆屏
    var roundCornerRadius = 0f   //圆角矩形的圆角半径
    var screenWidth = 0    //设备屏幕实际尺寸-宽
    var screenHeight = 0   //设备屏幕实际尺寸-高
    var screenPreviewWidth = 0    //设备屏幕实际预览尺寸-宽
    var screenPreviewHeight = 0    //设备屏幕实际预览尺寸-高
    var screenReservedBoundary = 0  //部分设备实际分辨率和显示的的区域不一致，需要预留边界，避免出现偏差，例如T88_pro的设备
    var controlValueInterval = 0  //距离，步数等控件，图片和下方数字部分的距离间隔
    var controlValueRange = 9   //距离，步数等控件下方数字部分的内容
    var fileFormat = "png"   // 表盘元素的图片原始格式 一般为 png 格式，瑞昱的为 bmp 格式
    var imageFormat = WatchFaceBuilder.PNG_ARGB_8888   //图像编码，默认为 8888 ， 瑞昱的为 RGB565
    var X_CENTER = WatchFaceBuilder.GRAVITY_X_CENTER   //相对坐标标记，MTK和瑞昱的实现有差异
    var Y_CENTER = WatchFaceBuilder.GRAVITY_Y_CENTER   //相对坐标标记，MTK和瑞昱的实现有差异
    var borderSize = 0   //绘制图形时，添加圆环的宽度
    var ignoreBlack = 0 //是否忽略黑色，0-不忽略；1-忽略；4-杰里2D加速用

    //控件相关
    var stepValueCenterX = 0f
    var stepValueCenterY = 0f
    var caloriesValueCenterX = 0f
    var caloriesValueCenterY = 0f
    var distanceValueCenterX = 0f
    var distanceValueCenterY = 0f
    var heartRateValueCenterX = 0f
    var heartRateValueCenterY = 0f
    var valueColor = 0

    //数字时间
    var amLeftX = 0f
    var amTopY = 0f
    var digitalTimeHourLeftX = 0f
    var digitalTimeHourTopY = 0f
    var digitalTimeMinuteLeftX = 0f
    var digitalTimeMinuteRightX = 0f
    var digitalTimeMinuteTopY = 0f
    var digitalTimeSymbolLeftX = 0f
    var digitalTimeSymbolTopY = 0f
    var digitalDateMonthLeftX = 0f
    var digitalDateMonthTopY = 0f
    var digitalDateDayLeftX = 0f
    var digitalDateDayTopY = 0f
    var digitalDateSymbolLeftX = 0f
    var digitalDateSymbolTopY = 0f
    var digitalWeekLeftX = 0f
    var digitalWeekTopY = 0f
    var digitalValueColor = 0

    //pointer
    var pointerSelectNumber = 0

    //scale
    var scaleSelectNumber = 0

    private lateinit var DIAL_CUSTOMIZE_DIR: String

    //control
    private lateinit var CONTROL_DIR: String
    private lateinit var STEP_DIR: String
    private lateinit var CALORIES_DIR: String
    private lateinit var DISTANCE_DIR: String
    private lateinit var HEART_RATE_DIR: String

    //value
    private lateinit var VALUE_DIR: String

    //bg image array
    private lateinit var BG_IMAGE_ARRAY_DIR: String

    //time
    private lateinit var TIME_DIR: String

    //digital
    private lateinit var DIGITAL_DIR: String
    private lateinit var POINTER_DIR: String

    //digital_parameter
    val DIGITAL_AM_DIR = "am_pm"
    val DIGITAL_DATE_DIR = "date"
    val DIGITAL_HOUR_MINUTE_DIR = "hour_minute"
    val DIGITAL_WEEK_DIR = "week"

    //pointer_parameter
    val POINTER_HOUR = "pointer/hour"
    val POINTER_MINUTE = "pointer/minute"
    val POINTER_SECOND = "pointer/second"

    /**
     * 是否支持使用产商sdk转换png图片
     */
    val isSupportConvertPng
        get() = BleCache.mSupport2DAcceleration == BleDeviceInfo.SUPPORT_2D_ACCELERATION_1
                || BleCache.mPlatform == BleDeviceInfo.PLATFORM_SIFLI

    /**
     * 8565是带alpha通道的像素格式。
     * 是否将png转8565格式，等于true时，必须用png文件，目前只有部分设备才支持。
     * bin文件会变大。
     */
    var isTo8565 =
        BleCache.mPlatform == BleDeviceInfo.PLATFORM_JL && !isSupportConvertPng


    private val mBleHandleCallback by lazy {
        object : BleHandleCallback {
            override fun onSessionStateChange(status: Boolean) {
                btnSync.isEnabled = true
            }

            override fun onStreamProgress(status: Boolean, errorCode: Int, total: Int, completed: Int) {
                if (status) {
                    ToastUtils.showShort("onStreamProgress $status $errorCode $total $completed")
                    if (total == completed) {
                        btnSync.isEnabled = true
                    }
                } else {
                    btnSync.isEnabled = true
                }
            }

            override fun onCommandSendTimeout(bleKey: BleKey, bleKeyFlag: BleKeyFlag) {
                if (bleKey == BleKey.WATCH_FACE) {
                    btnSync.isEnabled = true
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BleConnector.addHandleCallback(mBleHandleCallback)
        ////////////////////////////////////////////////////
        //初始化参数
        val custom = intent.getIntExtra("custom", 1)
        if (custom == 2) {
            DIAL_CUSTOMIZE_DIR = "dial_customize_454"
            screenWidth = 454
            screenHeight = 454
            screenPreviewWidth = 280
            screenPreviewHeight = 280
            isRound = true
            setContentView(R.layout.activity_watch_face)
        } else if (custom == 3) {
            DIAL_CUSTOMIZE_DIR = "dial_customize_240"
            screenWidth = 240
            screenHeight = 286
            screenPreviewWidth = 150
            screenPreviewHeight = 174
            isRound = false
            setContentView(R.layout.activity_watch_face_2)
        } else {
            DIAL_CUSTOMIZE_DIR = "dial_customize_240"
            screenWidth = 240
            screenHeight = 240
            screenPreviewWidth = 150
            screenPreviewHeight = 150
            isRound = true
            setContentView(R.layout.activity_watch_face)
        }
        controlValueInterval = 1
        ignoreBlack =
            if (isSupportConvertPng
            ) 4 else 1
        controlValueRange = 10
        fileFormat = if (isSupportConvertPng || isTo8565
        ) "png" else "bmp"
        imageFormat = WatchFaceBuilder.BMP_565
        X_CENTER = WatchFaceBuilder.GRAVITY_X_CENTER_R
        Y_CENTER = WatchFaceBuilder.GRAVITY_Y_CENTER_R
        ////////////////////////////////////////////////////

        //初始资源路径
        CONTROL_DIR = "$DIAL_CUSTOMIZE_DIR/control"
        STEP_DIR = "$CONTROL_DIR/step"
        CALORIES_DIR = "$CONTROL_DIR/calories"
        DISTANCE_DIR = "$CONTROL_DIR/distance"
        HEART_RATE_DIR = "$CONTROL_DIR/heart_rate"

        //value
        VALUE_DIR = "$DIAL_CUSTOMIZE_DIR/value"

        BG_IMAGE_ARRAY_DIR = "$DIAL_CUSTOMIZE_DIR/bg"

        //time
        TIME_DIR = "$DIAL_CUSTOMIZE_DIR/time"

        //digital
        DIGITAL_DIR = "$TIME_DIR/digital"
        POINTER_DIR = "$TIME_DIR/pointer"

        cbDigital.setOnCheckedChangeListener { buttonView, isChecked ->
            if (isChecked) {
                timeDigitalView.visibility = View.VISIBLE
                timeScaleView.visibility = View.GONE
                timePointView.visibility = View.GONE
            } else {
                timeDigitalView.visibility = View.GONE
                timeScaleView.visibility = View.VISIBLE
                timePointView.visibility = View.VISIBLE
            }
        }
    }

    fun onSync(v: View) {
        btnSync.isEnabled = false

        val elements = ArrayList<Element>()

        if (isSupportConvertPng) {
            //获取预览
            val bgPreviewBytes = getPreview()
            val elementPreview = Element(
                type = WatchFaceBuilder.ELEMENT_PREVIEW,
                w = screenPreviewWidth, //预览的尺寸为
                h = screenPreviewHeight,
                gravity = 0,
                x = 0,
                y = 0,
                ignoreBlack = ignoreBlack,
                imageBuffers = arrayOf(bgPreviewBytes)
            )
            elements.add(elementPreview)

            //获取背景
            val bgBytes = getBg()
            val elementBg = Element(
                type = WatchFaceBuilder.ELEMENT_BACKGROUND,
                w = screenWidth, //背景的尺寸
                h = screenHeight + 1,
                gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
                x = 0,
                y = 0,
                ignoreBlack = ignoreBlack,
                imageBuffers = arrayOf(bgBytes)
            )
            elements.add(elementBg)

            //获取控件数值相关内容
            getControl2(elements)

            //获取时间相关内容
            if (timeDigitalView.isVisible) {
                getTimeDigital2(elements)
            }
            if (timePointView.isVisible) {
                if (BleCache.mPlatform == BleDeviceInfo.PLATFORM_JL) {
                    getPointer2(WatchFaceBuilder.ELEMENT_NEEDLE_HOUR, POINTER_HOUR, elements)
                    getPointer2(WatchFaceBuilder.ELEMENT_NEEDLE_MIN, POINTER_MINUTE, elements)
                    getPointer2(WatchFaceBuilder.ELEMENT_NEEDLE_SEC, POINTER_SECOND, elements)
                } else {
                    getPointer3(WatchFaceBuilder.ELEMENT_NEEDLE_HOUR, POINTER_HOUR, elements)
                    getPointer3(WatchFaceBuilder.ELEMENT_NEEDLE_MIN, POINTER_MINUTE, elements)
                    getPointer3(WatchFaceBuilder.ELEMENT_NEEDLE_SEC, POINTER_SECOND, elements)
                }
            }

            //背景组，目前只有部分设备支持
//            if (BleCache.mPlatform == BleDeviceInfo.PLATFORM_SIFLI) {
//                getBgImageArray2(elements)
//            }
        } else {
            //获取预览
            val bgPreviewBytes = getPreview()
            val elementPreview = Element(
                type = WatchFaceBuilder.ELEMENT_PREVIEW,
                w = screenPreviewWidth, //预览的尺寸为
                h = screenPreviewHeight,
                gravity = X_CENTER or Y_CENTER,
                x = screenWidth / 2,
                y = screenHeight / 2 + 2,
                imageBuffers = arrayOf(bgPreviewBytes)
            )
            elements.add(elementPreview)

            //获取背景
            val bgBytes = getBg()
            val elementBg = Element(
                type = WatchFaceBuilder.ELEMENT_BACKGROUND,
                w = screenWidth, //背景的尺寸
                h = screenHeight,
                gravity = X_CENTER or Y_CENTER,
                x = screenWidth / 2,
                y = screenHeight / 2,
                imageBuffers = arrayOf(bgBytes)
            )
            elements.add(elementBg)

            //获取控件数值相关内容
            getControl(elements)

            //获取时间相关内容
            if (timeDigitalView.isVisible) {
                getTimeDigital(elements)
            }
            if (timePointView.isVisible) {
                getPointer(WatchFaceBuilder.ELEMENT_NEEDLE_HOUR, POINTER_HOUR, elements)
                getPointer(WatchFaceBuilder.ELEMENT_NEEDLE_MIN, POINTER_MINUTE, elements)
                getPointer(WatchFaceBuilder.ELEMENT_NEEDLE_SEC, POINTER_SECOND, elements)
            }
        }

        for (element in elements) {
            LogUtils.d("customize dial length: ${element.imageBuffers.first().size} KB")
        }

        ToastUtils.showLong("图片生成")
        val bytes = WatchFaceBuilder.build(
            elements.toTypedArray(),
            imageFormat
        )
        FileIOUtils.writeFileFromBytesByStream(File(PathUtils.getExternalAppDataPath(), "dial.bin"), bytes)

//        val bytes = FileIOUtils.readFile2BytesByChannel(File(PathUtils.getExternalAppDataPath(), "watchface.bin"))
        LogUtils.d("customize dial bytes size  ${bytes.size}")
        BleConnector.sendStream(
            BleKey.WATCH_FACE,
            bytes
        )
    }


    private fun getPointer(type: Int, dir: String, elements: ArrayList<Element>) {
        val pointerHour = ArrayList<ByteArray>()
        val tmpBitmap =
            ImageUtils.getBitmap(resources.assets.open("$POINTER_DIR/${dir}/${pointerSelectNumber}.${fileFormat}"))
        val w = tmpBitmap.width
        val h = if (isTo8565) {
            (tmpBitmap.height * 0.6f).toInt() //固件的内存不足，这里按比例截取一下高度
        } else {
            tmpBitmap.height
        }
        val pointerHourValue =
            resources.assets.open("$POINTER_DIR/${dir}/${pointerSelectNumber}.${fileFormat}")
                .use { it.readBytes() }

        pointerHour.add(defaultConversion(fileFormat, pointerHourValue, w, isTo8565 = isTo8565, h = h))
        val elementAmPm = Element(
            type = type,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = screenWidth / 2 - 1,
            y = screenHeight / 2 - 1,
            bottomOffset = if (fileFormat == "png" && !isTo8565) 0 else h - tmpBitmap.height / 2,
            leftOffset = if (fileFormat == "png" && !isTo8565) 0 else w / 2,
            imageBuffers = pointerHour.toTypedArray()
        )
        elements.add(elementAmPm)
    }

    //指针不压缩
    private fun getPointer2(type: Int, dir: String, elements: ArrayList<Element>) {
        val pointerFileName = "$POINTER_DIR/${dir}/${pointerSelectNumber}.${fileFormat}"
        val pointerHour = ArrayList<ByteArray>()
        val tmpBitmap =
            ImageUtils.getBitmap(resources.assets.open(pointerFileName))
        val w = tmpBitmap.width
        val h = (tmpBitmap.height * 0.6f).toInt() //固件的内存不足，这里按比例截取一下高度

        pointerHour.add(
            defaultConversion(
                fileFormat,
                resources.assets.open(pointerFileName).use { it.readBytes() },
                w,
                isTo8565 = true,
                h = h
            )
        )
        val elementAmPm = Element(
            type = type,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = 1,
            x = screenWidth / 2,
            y = screenHeight / 2,
            bottomOffset = h - tmpBitmap.height / 2,
            leftOffset = w / 2,
            imageBuffers = pointerHour.toTypedArray()
        )
        elements.add(elementAmPm)
    }

    //指针不压缩
    private fun getPointer3(type: Int, dir: String, elements: ArrayList<Element>) {
        val pointerFileName = "$POINTER_DIR/${dir}/${pointerSelectNumber}.${fileFormat}"
        val pointerBytes = resources.assets.open(pointerFileName).use { it.readBytes() }
        val pointerFile = File(
            PathUtils.getExternalAppDataPath(),
            pointerFileName
        )
        FileIOUtils.writeFileFromBytesByStream(
            pointerFile, pointerBytes
        )
        val pointerHour = ArrayList<ByteArray>()
        val tmpBitmap =
            ImageUtils.getBitmap(pointerBytes, 0)
        val w = tmpBitmap.width
        val h = tmpBitmap.height

        convertPng(pointerFile, isRotate = true)?.let {
            pointerHour.add(it)
        }

        val elementAmPm = Element(
            type = type,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = screenWidth / 2,
            y = screenHeight / 2,
            bottomOffset = h - tmpBitmap.height / 2,
            leftOffset = w / 2,
            imageBuffers = pointerHour.toTypedArray()
        )
        elements.add(elementAmPm)
    }

    private fun getTimeDigital(elements: ArrayList<Element>) {
        //AM PM
        val amPmValue = ArrayList<ByteArray>()
        val tmpBitmap =
            ImageUtils.getBitmap(resources.assets.open("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_AM_DIR/am.${fileFormat}"))
        var w = tmpBitmap.width
        var h = tmpBitmap.height
        val amValue =
            resources.assets.open("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_AM_DIR/am.${fileFormat}")
                .use { it.readBytes() }
        val pmValue =
            resources.assets.open("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_AM_DIR/pm.${fileFormat}")
                .use { it.readBytes() }
        amPmValue.add(defaultConversion(fileFormat, amValue, w, isTo8565 = isTo8565, h = h))
        amPmValue.add(defaultConversion(fileFormat, pmValue, w, isTo8565 = isTo8565, h = h))
        val elementAmPm = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_AMPM,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = amLeftX.toInt(),
            y = amTopY.toInt(),
            imageBuffers = amPmValue.toTypedArray()
        )
        elements.add(elementAmPm)
        //数字时间
        val hourMinute =
            getNumberBuffers("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_HOUR_MINUTE_DIR/")
        w = hourMinute.first
        h = hourMinute.second
        var valueBuffers = hourMinute.third.toTypedArray()
        val elementHour = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_HOUR,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalTimeHourLeftX.toInt(),
            y = digitalTimeHourTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementHour)
        val elementMinute = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_MIN,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalTimeMinuteLeftX.toInt(),
            y = digitalTimeMinuteTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementMinute)
        //特殊元素需要手动传输，部分设备不能直接嵌入背景，那样部分设备可能回出现不一致的问题,例如MTK的设备，实际分辨率320x385,但是最终只用320x363
        if (screenReservedBoundary != 0) {
            getSymbol(
                "$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_HOUR_MINUTE_DIR",
                WatchFaceBuilder.ELEMENT_DIGITAL_DIV_HOUR,
                digitalTimeSymbolLeftX.toInt(),
                digitalTimeSymbolTopY.toInt(),
                elements
            )
        }
        //日期
        val date = getNumberBuffers("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_DATE_DIR/")
        w = date.first
        h = date.second
        valueBuffers = date.third.toTypedArray()
        val elementMonth = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_MONTH,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalDateMonthLeftX.toInt(),
            y = digitalDateMonthTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementMonth)
        val elementDay = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_DAY,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalDateDayLeftX.toInt(),
            y = digitalDateDayTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementDay)
        //特殊元素需要手动传输，不能直接嵌入背景，那样部分设备可能回出现不一致的问题
        if (screenReservedBoundary != 0) {
            getSymbol(
                "$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_DATE_DIR",
                WatchFaceBuilder.ELEMENT_DIGITAL_DIV_MONTH,
                digitalDateSymbolLeftX.toInt(),
                digitalDateSymbolTopY.toInt(),
                elements
            )
        }
        //week
        val week = getNumberBuffers("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_WEEK_DIR/", 6)
        w = week.first
        h = week.second
        valueBuffers = week.third.toTypedArray()
        val elementWeek = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_WEEKDAY,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalWeekLeftX.toInt(),
            y = digitalWeekTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementWeek)
    }

    private fun getTimeDigital2(elements: ArrayList<Element>) {
        //AM PM
        val amFileName = "$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_AM_DIR/am.${fileFormat}"
        val pmFileName = "$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_AM_DIR/pm.${fileFormat}"

        val amPmValue = ArrayList<ByteArray>()
        val tmpBitmap =
            ImageUtils.getBitmap(resources.assets.open(amFileName))
        var w = tmpBitmap.width
        var h = tmpBitmap.height
        val amValue =
            resources.assets.open(amFileName)
                .use { it.readBytes() }
        val pmValue =
            resources.assets.open(pmFileName)
                .use { it.readBytes() }

        val amFile = File(
            PathUtils.getExternalAppDataPath(),
            amFileName
        )
        FileIOUtils.writeFileFromBytesByStream(
            amFile, amValue
        )

        val pmFile = File(
            PathUtils.getExternalAppDataPath(),
            pmFileName
        )
        FileIOUtils.writeFileFromBytesByStream(
            pmFile, pmValue
        )

        convertPng(amFile)?.let {
            amPmValue.add(it)
        }

        convertPng(pmFile)?.let {
            amPmValue.add(it)
        }

        val elementAmPm = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_AMPM,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = amLeftX.toInt(),
            y = amTopY.toInt(),
            imageBuffers = amPmValue.toTypedArray()
        )
        elements.add(elementAmPm)


        //数字时间
        val hourMinute =
            getNumberBuffers2("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_HOUR_MINUTE_DIR/")
        w = hourMinute.first
        h = hourMinute.second
        var valueBuffers = hourMinute.third.toTypedArray()
        val elementHour = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_HOUR,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalTimeHourLeftX.toInt(),
            y = digitalTimeHourTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementHour)
        val elementMinute = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_MIN,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalTimeMinuteLeftX.toInt(),
            y = digitalTimeMinuteTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementMinute)
        //特殊元素需要手动传输，部分设备不能直接嵌入背景，那样部分设备可能回出现不一致的问题,例如MTK的设备，实际分辨率320x385,但是最终只用320x363
        if (screenReservedBoundary != 0) {
            getSymbol2(
                "$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_HOUR_MINUTE_DIR",
                WatchFaceBuilder.ELEMENT_DIGITAL_DIV_HOUR,
                digitalTimeSymbolLeftX.toInt(),
                digitalTimeSymbolTopY.toInt(),
                elements
            )
        }

        //日期
        val date = getNumberBuffers2("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_DATE_DIR/")
        w = date.first
        h = date.second
        valueBuffers = date.third.toTypedArray()
        val elementMonth = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_MONTH,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalDateMonthLeftX.toInt(),
            y = digitalDateMonthTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementMonth)
        val elementDay = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_DAY,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalDateDayLeftX.toInt(),
            y = digitalDateDayTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementDay)
        //特殊元素需要手动传输，不能直接嵌入背景，那样部分设备可能回出现不一致的问题
        if (screenReservedBoundary != 0) {
            getSymbol2(
                "$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_DATE_DIR",
                WatchFaceBuilder.ELEMENT_DIGITAL_DIV_MONTH,
                digitalDateSymbolLeftX.toInt(),
                digitalDateSymbolTopY.toInt(),
                elements
            )
        }

        //week
        val week = getNumberBuffers2("$DIGITAL_DIR/${digitalValueColor}/$DIGITAL_WEEK_DIR/", 6)
        w = week.first
        h = week.second
        valueBuffers = week.third.toTypedArray()
        val elementWeek = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_WEEKDAY,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = digitalWeekLeftX.toInt(),
            y = digitalWeekTopY.toInt(),
            imageBuffers = valueBuffers
        )
        elements.add(elementWeek)
    }

    private fun getSymbol(
        dir: String,
        type: Int,
        x: Int, y: Int,
        elements: ArrayList<Element>
    ) {
        val symbolValue = ArrayList<ByteArray>()
        val symbolBitmap =
            ImageUtils.getBitmap(resources.assets.open("${dir}/symbol.${fileFormat}"))
        val w = symbolBitmap.width
        val h = symbolBitmap.height
        symbolValue.add(
            defaultConversion(
                fileFormat,
                resources.assets.open("${dir}/symbol.${fileFormat}")
                    .use { it.readBytes() }, w, isTo8565 = isTo8565, h = h
            )
        )
        val valueBuffers = symbolValue.toTypedArray()
        val elementSymbol = Element(
            type = type,
            hasAlpha = isTo8565.toInt(),
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = x,
            y = y,
            imageBuffers = valueBuffers
        )
        elements.add(elementSymbol)
    }

    private fun getSymbol2(
        dir: String,
        type: Int,
        x: Int, y: Int,
        elements: ArrayList<Element>
    ) {
        val symbolFileName = "${dir}/symbol.${fileFormat}"
        val symbolValue = ArrayList<ByteArray>()
        val symbolBitmap =
            ImageUtils.getBitmap(resources.assets.open(symbolFileName))
        val w = symbolBitmap.width
        val h = symbolBitmap.height

        val symbolBytes = resources.assets.open(symbolFileName)
            .use { it.readBytes() }
        val symbolFile = File(
            PathUtils.getExternalAppDataPath(),
            symbolFileName
        )
        FileIOUtils.writeFileFromBytesByStream(
            symbolFile, symbolBytes
        )
        convertPng(symbolFile)?.let {
            symbolValue.add(it)
        }

        val valueBuffers = symbolValue.toTypedArray()
        val elementSymbol = Element(
            type = type,
            hasAlpha = 1,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = x,
            y = y,
            imageBuffers = valueBuffers
        )
        elements.add(elementSymbol)
    }

    private fun getControl(elements: ArrayList<Element>) {
        val triple = getNumberBuffers("$VALUE_DIR/${valueColor}/", controlValueRange)
        val w = triple.first
        val h = triple.second
        val valueBuffers = triple.third.toTypedArray()
        //获取步数数值
        if (controlViewStep.isVisible) {
            val elementStep = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_STEP,
                hasAlpha = isTo8565.toInt(),
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = stepValueCenterX.toInt(),
                y = stepValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            elements.add(elementStep)
        }
        //获取心率数值
        if (controlViewHr.isVisible) {
            val elementHr = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_HEART,
                hasAlpha = isTo8565.toInt(),
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = heartRateValueCenterX.toInt(),
                y = heartRateValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            elements.add(elementHr)
        }
        //获取卡路里数值
        if (controlViewCa.isVisible) {
            val elementCa = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_CALORIE,
                hasAlpha = isTo8565.toInt(),
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = caloriesValueCenterX.toInt(),
                y = caloriesValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            elements.add(elementCa)
        }
        //获取距离数值
        if (controlViewDis.isVisible) {
            val elementDis = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_DISTANCE,
                hasAlpha = isTo8565.toInt(),
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = distanceValueCenterX.toInt(),
                y = distanceValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            LogUtils.d("test distanceValueCenterX=$distanceValueCenterX  distanceValueCenterY=$distanceValueCenterY")
            elements.add(elementDis)
        }
    }

    private fun getControl2(elements: ArrayList<Element>) {
        val triple = getNumberBuffers2("$VALUE_DIR/${valueColor}/", controlValueRange)
        val w = triple.first
        val h = triple.second
        val valueBuffers = triple.third.toTypedArray()
        //获取步数数值
        if (controlViewStep.isVisible) {
            val elementStep = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_STEP,
                hasAlpha = 1,
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = stepValueCenterX.toInt(),
                y = stepValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            elements.add(elementStep)
        }
        //获取心率数值
        if (controlViewHr.isVisible) {
            val elementHr = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_HEART,
                hasAlpha = 1,
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = heartRateValueCenterX.toInt(),
                y = heartRateValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            elements.add(elementHr)
        }
        //获取卡路里数值
        if (controlViewCa.isVisible) {
            val elementCa = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_CALORIE,
                hasAlpha = 1,
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = caloriesValueCenterX.toInt(),
                y = caloriesValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            elements.add(elementCa)
        }
        //获取距离数值
        if (controlViewDis.isVisible) {
            val elementDis = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_DISTANCE,
                hasAlpha = 1,
                w = w,
                h = h,
                gravity = X_CENTER or Y_CENTER,
                ignoreBlack = ignoreBlack,
                x = distanceValueCenterX.toInt(),
                y = distanceValueCenterY.toInt(),
                imageBuffers = valueBuffers
            )
            LogUtils.d("test distanceValueCenterX=$distanceValueCenterX  distanceValueCenterY=$distanceValueCenterY")
            elements.add(elementDis)
        }
    }

    private fun getBgImageArray2(elements: ArrayList<Element>) {
        val triple = getBgImageBuffers("$BG_IMAGE_ARRAY_DIR/", 3)
        val w = triple.first
        val h = triple.second
        val valueBuffers = triple.third.toTypedArray()
        val element = Element(
            type = WatchFaceBuilder.ELEMENT_BG_IMAGE_ARRAY,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            x = 0,
            y = 0,
            ignoreBlack = ignoreBlack,
            imageBuffers = valueBuffers
        )
        elements.add(element)

    }

    private fun getNumberBuffers(
        dir: String,
        range: Int = 9
    ): Triple<Int, Int, ArrayList<ByteArray>> {
        var w = 0
        var h = 0
        val valueByte = ArrayList<ByteArray>()
        for (index in 0..range) {
            if (w == 0) {
                val tmpBitmap =
                    ImageUtils.getBitmap(resources.assets.open("$dir${index}.${fileFormat}"))
                w = tmpBitmap.width
                h = tmpBitmap.height
            }
            val value =
                resources.assets.open("$dir${index}.${fileFormat}")
                    .use { it.readBytes() }
            valueByte.add(defaultConversion(fileFormat, value, w,  isTo8565 = isTo8565, h = h))
        }
        return Triple(w, h, valueByte)
    }

    private fun getNumberBuffers2(
        dir: String,
        range: Int = 9
    ): Triple<Int, Int, ArrayList<ByteArray>> {
        var w = 0
        var h = 0
        val valueByte = ArrayList<ByteArray>()
        for (index in 0..range) {
            val fileName = "$dir${index}.${fileFormat}"
            if (w == 0) {
                val tmpBitmap =
                    ImageUtils.getBitmap(resources.assets.open(fileName))
                w = tmpBitmap.width
                h = tmpBitmap.height
            }

            val value =
                resources.assets.open(fileName)
                    .use { it.readBytes() }

            val pngFile = File(
                PathUtils.getExternalAppDataPath(),
                fileName
            )
            FileIOUtils.writeFileFromBytesByStream(
                pngFile, value
            )
            val bytes = convertPng(pngFile)
            if (bytes != null) {
                valueByte.add(bytes)
            }
        }
        return Triple(w, h, valueByte)
    }

    private fun getBgImageBuffers(
        dir: String,
        range: Int = 3
    ): Triple<Int, Int, ArrayList<ByteArray>> {
        var w = 0
        var h = 0
        val valueByte = ArrayList<ByteArray>()
        for (index in 0..range) {
            val fileName = "$dir${index}.${fileFormat}"
            if (w == 0) {
                val tmpBitmap =
                    ImageUtils.getBitmap(resources.assets.open(fileName))
                w = tmpBitmap.width
                h = tmpBitmap.height
            }

            val value =
                resources.assets.open(fileName)
                    .use { it.readBytes() }

            val pngFile = File(
                PathUtils.getExternalAppDataPath(),
                fileName
            )
            FileIOUtils.writeFileFromBytesByStream(
                pngFile, value
            )
            val bytes = convertPng(pngFile)
            if (bytes != null) {
                valueByte.add(bytes)
            }
        }
        return Triple(w, h, valueByte)
    }

    private fun getBg(): ByteArray {
        val finalBgBitMap = getBgBitmap(false)
        val pngFile = File(PathUtils.getExternalAppDataPath(),"dial_bg_file.png")
        ImageUtils.save(finalBgBitMap, pngFile, Bitmap.CompressFormat.PNG)
        if (isSupportConvertPng) {
            val bytes = convertPng(pngFile, false)
            if (bytes != null) {
                return bytes
            }
        }
        return bitmap2Bytes("bmp",finalBgBitMap)
    }


    private fun getPreview(): ByteArray {
        //尺寸需要严格对应,所以背景需要生成两次
        //获取背景bitmap--带数字,为生成预览做准备
        val finalBgBitMap = getBgBitmap(true)
        //根据此处表盘背景,生成背景对应的预览文件
        val previewScaleWidth = screenPreviewWidth.toFloat() / finalBgBitMap.width
        val previewScaleHeight = screenPreviewHeight.toFloat() / finalBgBitMap.height
        val previewScale = ImageUtils.scale(
            finalBgBitMap,
            previewScaleWidth,
            previewScaleHeight
        )
        val finalPreviewBitMap = if (isRound) {
            //裁圆,并且加黑边藏锯齿
            ImageUtils.toRound(previewScale, borderSize, resources.getColor(R.color.dark))
        } else {
            //裁圆,并且加黑边藏锯齿
            ImageUtils.toRoundCorner(
                previewScale,
                roundCornerRadius * previewScaleWidth,
                borderSize.toFloat(),
                resources.getColor(R.color.dark)
            )
        }

        val pngFile = File(PathUtils.getExternalAppDataPath(), "dial_bg_preview_file.png")
        ImageUtils.save(finalPreviewBitMap, pngFile, Bitmap.CompressFormat.PNG)
        if (isSupportConvertPng) {
            val bytes = convertPng(pngFile, false)
            if (bytes != null) {
                return bytes
            }
        }
        return bitmap2Bytes("bmp", finalPreviewBitMap)
    }

    private fun getBgBitmap(isCanvasValue: Boolean): Bitmap {
        val bgBitmap = if (isRound) {
            //圆
            ImageUtils.view2Bitmap(customizeDialBg)
        } else {
            //非圆
            customizeDialBg.drawable.toBitmap()
        }
        var scaleWidth = screenWidth.toFloat() / bgBitmap.width
        var scaleHeight = (screenHeight.toFloat() - screenReservedBoundary) / bgBitmap.height
        LogUtils.d("test getBgBitmap = ${bgBitmap.width}- ${bgBitmap.height} ; $scaleWidth - $scaleHeight ")
        val scale = ImageUtils.scale(
            bgBitmap,
            scaleWidth,
            scaleHeight
        )
        val bgBitMap = if (isRound) {
            //裁圆,并且加黑边藏锯齿
            ImageUtils.toRound(scale, borderSize, resources.getColor(R.color.dark))
        } else {
            //非圆
            ImageUtils.toRoundCorner(
                scale,
                roundCornerRadius,
                0f,
                resources.getColor(R.color.dark)
            )
        }
        //非圆,因为获取bitmap方式不一样,此处需要重新计算比列,为后续计算做准备
        if (!isRound) {
            scaleWidth = screenWidth.toFloat() / customizeDialBg.width
            scaleHeight = (screenHeight.toFloat() - screenReservedBoundary) / customizeDialBg.height
        }
        //获取控件的bitmap
        val canvas = Canvas(bgBitMap)
        val (stepX, stepY) = addControlBitmap(
            "$STEP_DIR/step_0.png",
            controlViewStep,
            "$VALUE_DIR/${valueColor}/",
            "18564",
            canvas,
            scaleWidth, scaleHeight,
            isCanvasValue
        )
        stepValueCenterX = stepX
        stepValueCenterY = stepY
        val (caloriesX, caloriesY) = addControlBitmap(
            "$CALORIES_DIR/calories_0.png",
            controlViewCa,
            "$VALUE_DIR/${valueColor}/",
            "50",
            canvas,
            scaleWidth, scaleHeight,
            isCanvasValue
        )
        caloriesValueCenterX = caloriesX
        caloriesValueCenterY = caloriesY
        val (distanceX, distanceY) = addControlBitmap(
            "$DISTANCE_DIR/distance_0.png",
            controlViewDis,
            "$VALUE_DIR/${valueColor}/",
            "6",
            canvas,
            scaleWidth, scaleHeight,
            isCanvasValue
        )
        distanceValueCenterX = distanceX
        distanceValueCenterY = distanceY
        val (heartRateX, heartRateY) = addControlBitmap(
            "$HEART_RATE_DIR/heart_rate_0.png",
            controlViewHr,
            "$VALUE_DIR/${valueColor}/",
            "90",
            canvas,
            scaleWidth, scaleHeight,
            isCanvasValue
        )
        heartRateValueCenterX = heartRateX
        heartRateValueCenterY = heartRateY
        //获取时间的bitmap
        if (timeDigitalView.isVisible) {
            //数字时间
            addDigitalTime(
                "$DIGITAL_DIR/${digitalValueColor}/",
                scaleWidth, scaleHeight,
                canvas,
                isCanvasValue
            )
        }
        if (timePointView.isVisible) {
            //指针
            getPointerBg(timePointView, isCanvasValue, canvas)
        }
        if (timeScaleView.isVisible) {
            //刻度如果有显示,则必然绘制
            getPointerBg(timeScaleView, true, canvas)
        }

        return getFinalBgBitmap(bgBitMap)
    }

    private fun bitmap2Bytes(fileFormat: String, finalBgBitMap: Bitmap): ByteArray {
        val allocate = ByteBuffer.allocate(finalBgBitMap.byteCount)
        finalBgBitMap.copyPixelsToBuffer(allocate)
        val array = allocate.array()
        return defaultConversion(fileFormat, array, finalBgBitMap.width, 16, 0, false)
    }

    private fun getFinalBgBitmap(bgBitMap: Bitmap): Bitmap {
        val finalBitmap = Bitmap.createBitmap(
            bgBitMap.width,
            bgBitMap.height + 1,
            Bitmap.Config.RGB_565
        )
        val canvas = Canvas(finalBitmap)
        val paint = Paint()
        paint.color = Color.BLACK
        canvas.drawBitmap(bgBitMap, 0f, 0f, paint)
        return finalBitmap
    }

    private fun getPointerBg(
        timeView: ImageView,
        isCanvasValue: Boolean,
        canvas: Canvas
    ) {
        val pointerBitmap = if (isRound) {
            //圆
            ImageUtils.view2Bitmap(timeView)
        } else {
            //非圆
            timeView.drawable.toBitmap()
        }
        val scaleWidth = screenWidth.toFloat() / pointerBitmap.width
        val scaleHeight = (screenHeight.toFloat() - screenReservedBoundary) / pointerBitmap.height
        val scale = ImageUtils.scale(
            pointerBitmap,
            scaleWidth,
            scaleHeight
        )
        val finalPointerBitMap = if (isRound) {
            ImageUtils.toRound(scale, 0, 0)
        } else {
            ImageUtils.toRoundCorner(scale, roundCornerRadius)
        }
        if (isCanvasValue) {
            canvas.drawBitmap(
                finalPointerBitMap,
                0f,
                0f,
                null
            )
        }
    }

    private fun addDigitalTime(
        digitalDir: String,
        scaleWidth: Float,
        scaleHeight: Float,
        canvas: Canvas,
        isCanvasValue: Boolean
    ) {
        val timeLeft = timeDigitalView.x * scaleWidth
        val timeTop = timeDigitalView.y * scaleHeight
        LogUtils.d("test timeLeft=$timeLeft,  timeTop=$timeTop, timeDigitalView.width=${timeDigitalView.width} ,scaleWidth =$scaleWidth")
        //获取AM原始资源.此处涉及到预览，所以强制使用PNG图片，避免透明色不显示
        val amBitmap =
            ImageUtils.getBitmap(resources.assets.open("$digitalDir$DIGITAL_AM_DIR/pm.png"))
        //绘制小时分钟的时间,这几个元素总宽度最长,根据这几个元素,可以确定时间元素整体的总宽度为120
        val tempValue = "08:30"
        val (hourMinuteBitmap, hourMinuteTop) = addDigitalTimeParam(
            digitalDir,
            DIGITAL_HOUR_MINUTE_DIR,
            tempValue,
            timeTop,
            amBitmap.height,
            canvas,
            timeLeft,
            isCanvasValue
        )
        //日期
        val tempDate = "07/08"
        val (_, dateAndWeekTop) = addDigitalTimeParam(
            digitalDir,
            DIGITAL_DATE_DIR,
            tempDate,
            hourMinuteTop,
            hourMinuteBitmap.height,
            canvas,
            timeLeft,
            isCanvasValue
        )
        //时间主体绘制完毕后,即可确认位置,然后就可以绘制其他的从属元素了
        //AM-PM
        if (isCanvasValue) {
            canvas.drawBitmap(
                amBitmap,
                digitalTimeMinuteRightX - amBitmap.width,
                timeTop,
                null
            )
        }
        amLeftX = digitalTimeMinuteRightX - amBitmap.width
        amTopY = timeTop
        //week 此处涉及到预览，所以强制使用PNG图片，避免透明色不显示
        val weekBitmap =
            ImageUtils.getBitmap(resources.assets.open("$digitalDir$DIGITAL_WEEK_DIR/4.png"))
        if (isCanvasValue) {
            canvas.drawBitmap(
                weekBitmap,
                digitalTimeMinuteRightX - weekBitmap.width,
                dateAndWeekTop,
                null
            )
        }
        digitalWeekLeftX = digitalTimeMinuteRightX - weekBitmap.width
        digitalWeekTopY = dateAndWeekTop
    }

    private fun addDigitalTimeParam(
        digitalDir: String,
        digitalSecondaryDir: String,
        tempValue: String,
        timeTop: Float,
        top: Int,
        canvas: Canvas,
        timeLeft: Float,
        isCanvasValue: Boolean
    ): Pair<Bitmap, Float> {
        //特殊符号处理-即使是瑞昱系列，也使用bng格式的特殊符号，因为特殊符号会被嵌入背景中，如果无法嵌入，需要单独做处理
        val symbolBitmap =
            ImageUtils.getBitmap(resources.assets.open("$digitalDir$digitalSecondaryDir/symbol.png"))
        //此处涉及到预览，所以强制使用PNG图片，避免透明色不显示
        val valueBitmap =
            ImageUtils.getBitmap(resources.assets.open("$digitalDir$digitalSecondaryDir/${tempValue[0]}.png"))
        val elementValueTop = timeTop + top + 6       //普通元素距离上方二外增加6像素间隔
        val symbolValueTop =
            elementValueTop + (valueBitmap.height - symbolBitmap.height) / 2       //特殊元素在普通元素的基础上，在增加差异高度一半的间隔
//        val valueWidth = valueBitmap.width * 4 + symbolBitmap.width
        if (digitalSecondaryDir.contains(DIGITAL_HOUR_MINUTE_DIR)) {
            digitalTimeHourLeftX = timeLeft
            digitalTimeHourTopY = elementValueTop
            digitalTimeSymbolLeftX = timeLeft + valueBitmap.width * 2
            digitalTimeSymbolTopY = symbolValueTop
            digitalTimeMinuteLeftX = timeLeft + valueBitmap.width * 2 + symbolBitmap.width
            digitalTimeMinuteTopY = elementValueTop
            digitalTimeMinuteRightX = digitalTimeMinuteLeftX + valueBitmap.width * 2 - 6
        } else if (digitalSecondaryDir.contains(DIGITAL_DATE_DIR)) {
            digitalDateMonthLeftX = timeLeft
            digitalDateMonthTopY = elementValueTop
            digitalDateSymbolLeftX = timeLeft + valueBitmap.width * 2
            digitalDateSymbolTopY = symbolValueTop
            digitalDateDayLeftX = timeLeft + valueBitmap.width * 2 + symbolBitmap.width
            digitalDateDayTopY = elementValueTop
        }

        if (screenReservedBoundary == 0) {
            //正常的图片，直接绘制特殊元素到背景，不用单独传输过去了，省得麻烦
            var valueParam = 0
            var valueSymWidth = 0
            for (index in tempValue.indices) {
                if (index == 2) {
                    canvas.drawBitmap(
                        symbolBitmap,
                        timeLeft + valueBitmap.width * valueParam,
                        symbolValueTop,
                        null
                    )
                    valueSymWidth = symbolBitmap.width
                } else {
                    if (isCanvasValue) {
                        val itemBitmap =
                            ImageUtils.getBitmap(resources.assets.open("$digitalDir$digitalSecondaryDir/${tempValue[index]}.png"))
                        canvas.drawBitmap(
                            itemBitmap,
                            timeLeft + valueBitmap.width * valueParam + valueSymWidth,
                            elementValueTop,
                            null
                        )
                    }
                    valueParam++
                }
            }
        } else {
            if (isCanvasValue) {
                var valueParam = 0
                var valueSymWidth = 0
                for (index in tempValue.indices) {
                    if (index == 2) {
                        canvas.drawBitmap(
                            symbolBitmap,
                            timeLeft + valueBitmap.width * valueParam,
                            symbolValueTop,
                            null
                        )
                        valueSymWidth = symbolBitmap.width
                    } else {
                        val itemBitmap =
                            ImageUtils.getBitmap(resources.assets.open("$digitalDir$digitalSecondaryDir/${tempValue[index]}.${fileFormat}"))
                        canvas.drawBitmap(
                            itemBitmap,
                            timeLeft + valueBitmap.width * valueParam + valueSymWidth,
                            elementValueTop,
                            null
                        )
                        valueParam++
                    }
                }
            }
        }
        return Pair(valueBitmap, elementValueTop)
    }

    private fun addControlBitmap(
        controlFileName: String,
        elementView: ViewGroup,
        controlValueFileDir: String,
        controlValue: String,
        canvas: Canvas,
        scaleWidth: Float,
        scaleHeight: Float,
        isCanvasValue: Boolean
    ): Pair<Float, Float> {
        if (elementView.isVisible) {
            LogUtils.d("test addControlBitmap $controlFileName , ${elementView.x} ${elementView.y} $scaleWidth $scaleHeight")
            val viewBitmap = ImageUtils.getBitmap(resources.assets.open(controlFileName))
            val viewLeft = elementView.x * scaleWidth
            val viewTop = elementView.y * scaleHeight
            //x.y 获取该view相对于父 view的的left,top坐标点
            canvas.drawBitmap(
                viewBitmap,
                viewLeft,
                viewTop,
                null
            )
            //计算底部横向中心点.为计算数值做准备
            val bottomCenterX = viewBitmap.width / 2 + viewLeft
            val bottomY =
                viewTop + viewBitmap.height + controlValueInterval   //图片和数字之间添加指定间隔，避免过于靠近

            val firstValue =
                ImageUtils.getBitmap(resources.assets.open("${controlValueFileDir}${controlValue[0]}.${fileFormat}"))
            val valueWidth = firstValue.width * controlValue.length + controlValue.length - 1
            val valueStartX = bottomCenterX - valueWidth / 2

            if (isCanvasValue) {
                for (index in controlValue.indices) {
                    //此处涉及到预览，所以强制使用PNG图片，避免透明色不显示
                    val value =
                        ImageUtils.getBitmap(resources.assets.open("${controlValueFileDir}${controlValue[index]}.png"))
                    canvas.drawBitmap(
                        value,
                        valueStartX + index + value.width * index,
                        bottomY,
                        null
                    )
                }
            }

            //计算数值显示区域的中心点,并返回
            val bottomCenterY = bottomY + firstValue.height / 2
            return Pair(bottomCenterX, bottomCenterY)
        }
        return Pair(0f, 0f)
    }

    val SIZE_4 = 4

    /**
     * 转换png图片
     */
    private fun convertPng(
        pngFile: File,
        isAlpha: Boolean = true,
        isRotate: Boolean = false //指针才需要旋转
    ): ByteArray? {
        val outFilePath = pngFile.path + ".bin"
        val outFileBytes:ByteArray
        if (BleCache.mPlatform == BleDeviceInfo.PLATFORM_JL) {
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
            outFileBytes = FileIOUtils.readFile2BytesByChannel(outFilePath)
        } else {
            //pngData：需要转换的png图像数据的指针。如果原素材不是png的图片，请调用通用的接口转换为png格式，然后
            //再调用该接口进行转换；
            //colorType：输出ezip的颜色格式类型，可取值rgb888、rgb565、rgb888a、rgb565a；
            //ezip_color_type：输出的“ezip的颜色格式类型”是否强制转换。
            //0：自适应颜色，如果原图带alpha，则输出带alpha。
            //1：强制颜色，输出严格按照colorType指定的颜色输出，如果原图不带alpha，colorType带alpha，将则输出时会填
            //充alpha为0xff；反之，如果原图带alpha，colorType带alpha，则输出时会去掉alpha。
            //ezip_bin_type：输出ezip的bin格式。 0，输出ezip格式0的bin文件；1，输出ezip格式2的bin文件。对于需要旋转的
            //图形使用格式0（binType = 0），否则使用格式1binType = 1；
            val pngData = FileIOUtils.readFile2BytesByChannel(pngFile)
            val colorType = if (isAlpha) {
                "rgb888a"
            } else {
                "rgb565"
            }
            outFileBytes = sifliEzipUtil.pngToEzip(pngData, colorType, 0, if (isRotate) 0 else 1, 0)

        }
        val bytesSize = (outFileBytes.size + SIZE_4 - 1) / SIZE_4 * SIZE_4
        val bytes = ByteArray(bytesSize)
        System.arraycopy(outFileBytes, 0, bytes, 0, outFileBytes.size)
        LogUtils.d("convertPng outFileBytes=${outFileBytes.size}, bytes=${bytes.size}")
        return bytes
    }

    fun argb8888To8565(argb: Int): Int {
        val b = argb and 255
        val g = argb shr 8 and 255
        val r = argb shr 16 and 255
        val a = argb shr 24 and 255
        return (a shl 16) + (r shr 3 shl 11) + (g shr 2 shl 5) + (b shr 3)
    }

    fun defaultConversion(
        fileFormat: String,
        data: ByteArray,
        w: Int,                      //图片宽度
        bitCount: Int = 16,          //位深度，可为8，16，24，32
        headerInfoSize: Int = 70,   //头部信息长度，默认70
        isReverseRows: Boolean = true,   //是否反转行数据，就是将第一行置换为最后一行
        isTo8565: Boolean = false, // 一般都是png文件转8565格式
        h: Int = 0                //图片高度
    ): ByteArray {
        if (fileFormat == "bmp") {

            //标准bmp文件可以从第十个字节读取到头长度，如果那些设备有问题可以先检查这里
            val headerInfoSize2 = if (headerInfoSize == 0) 0 else data[10]
            LogUtils.d("headerInfoSize $headerInfoSize2")

            val data1 = data.takeLast(data.size - headerInfoSize2)
            //分别获取每一行的数据
            //计算每行多少字节
            val rowSize: Int = (bitCount * w + 31) / 32 * 4
            val data2 = java.util.ArrayList<ByteArray>()
            //判断单、双数，单数要减去无用字节
            val offset = if (w % 2 == 0) 0 else 2
            for (index in 0 until (data1.size / rowSize)) {
                val tmpData = ByteArray(rowSize - offset)
                for (rowIndex in 0 until (rowSize - offset)) {
                    tmpData[rowIndex] = data1[index * rowSize + rowIndex]
                }
                data2.add(tmpData)
            }

            //将获得的行数据反转
            val data3 = if (isReverseRows) {
                data2.reversed()
            } else {
                data2
            }
            //将每行数据中，依据 16bit（此处定义，如果是不同的位深度，则需要跟随调整） 即 2 字节的内容从小端序修改为大端序
            val test3 = java.util.ArrayList<Byte>()
            for (index in data3.indices) {
                var j = 0
                while (j < data3[index].size) {
                    test3.add(data3[index][j + 1])
                    test3.add(data3[index][j])
                    j += 2
                }
            }
            //取得最终元素
            val finalData = ByteArray(test3.size)
            for (index in finalData.indices) {
                finalData[index] = test3[index]
            }
            return finalData
        } else {
            return if (isTo8565) {
                pngTo8565(data, w, h)
            } else {
                data
            }
        }

    }

    fun pngTo8565(bytes: ByteArray, w: Int, h:Int) :ByteArray {
        val tmpBitmap =
            ImageUtils.getBitmap(bytes, 0)
        val pixels = IntArray(tmpBitmap.height * tmpBitmap.width)
        tmpBitmap.getPixels(pixels, 0, tmpBitmap.width, 0, 0, tmpBitmap.width, tmpBitmap.height)

        val rowSize = (w * 3 + SIZE_4 - 1) / SIZE_4 * SIZE_4//4字节对齐
        val data = ByteArray(rowSize * h)
        for (y in 0 until h) {
            val rawBytes = ByteArray(rowSize)
            for (x in 0 until w) {
                val index = y * w + x
                val a565 = argb8888To8565(pixels[index])
                val offset = x * 3
                rawBytes[offset + 2] = (a565 and 255).toByte()//2
                rawBytes[offset + 1] = (a565 shr 8 and 255).toByte()//1.
                rawBytes[offset + 0] = (a565 shr 16 and 255).toByte()//0.alpha
            }
            System.arraycopy(rawBytes, 0, data, y * rowSize, rowSize)
        }
        LogUtils.d("pngTo8565 -> w=$w, h=$h, rowSize=$rowSize, data=${data.size}")
        return data
    }

    override fun onDestroy() {
        super.onDestroy()
        BleConnector.removeHandleCallback(mBleHandleCallback)
    }

    override fun onBackPressed() {
        if(btnSync.isEnabled) {
            super.onBackPressed()
        }
    }
}
