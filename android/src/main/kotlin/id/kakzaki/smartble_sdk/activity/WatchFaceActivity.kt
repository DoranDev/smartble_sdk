package id.kakzaki.smartble_sdk.activity

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.graphics.drawable.toBitmap
import com.blankj.utilcode.util.*
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.watchface.Element
import com.szabh.smable3.watchface.WatchFaceBuilder
import java.io.File
import java.nio.ByteBuffer

class WatchFaceActivity : AppCompatActivity() {

    //背景
//    var customizeDialBg = false
    //步数
    private var controlViewStep = false

    //心率
    private var controlViewHr = false

    //卡路理
    private var controlViewCa = false

    //距离
    private var controlViewDis = false
    //数字时间
    private var timeDigitalView=false
    private var timeDigitalViewX=0
    private var timeDigitalViewY=0
    private  var timeDigitalViewWidth=0
    //指针
    private var timePointView = false
    //刻度
    private var timeScaleView = false

    private  var btnSync = false

    private var bgBitmapx: Bitmap? = null
    private  var customizeDialBg: Bitmap? = null

    private  var isRound = false //whether it is a round screen
    private  var roundCornerRadius = 0f //The corner radius of the rounded rectangle
    private var screenReservedBoundary = 0 //The actual resolution of some devices is inconsistent with the displayed area, and the boundary needs to be reserved to avoid deviations, such as T88_pro devices
    private var controlValueInterval = 0 //Controls such as distance and steps, the distance interval between the picture and the number part below
    private var controlValueRange = 9 //The content of the digital part below the control such as distance and steps
    private var fileFormat = "png" // The original format of the image of the dial element is generally in png format, and Realtek's is in bmp format
    private var imageFormat = WatchFaceBuilder.PNG_ARGB_8888 //Image encoding, the default is 8888, Realtek is RGB565
    private var X_CENTER = WatchFaceBuilder.GRAVITY_X_CENTER //Relative coordinate mark, MTK and Realtek have different implementations
    private var Y_CENTER = WatchFaceBuilder.GRAVITY_Y_CENTER //Relative coordinate mark, MTK and Realtek have different implementations
    private var borderSize = 0 //When drawing graphics, add the width of the ring
    private var ignoreBlack = 0 //Whether to ignore black, 0-do not ignore; 1-ignore


    //控件相关
    private var stepValueCenterX = 0f
    private var stepValueCenterY = 0f
    private var caloriesValueCenterX = 0f
    private var caloriesValueCenterY = 0f
    private var distanceValueCenterX = 0f
    private var distanceValueCenterY = 0f
    private var heartRateValueCenterX = 0f
    private var heartRateValueCenterY = 0f
    var valueColor = 0

    //数字时间
    private var amLeftX = 0f
    private var amTopY = 0f
    private var digitalTimeHourLeftX = 0f
    private var digitalTimeHourTopY = 0f
    private var digitalTimeMinuteLeftX = 0f
    private var digitalTimeMinuteRightX = 0f
    private var digitalTimeMinuteTopY = 0f
    private var digitalTimeSymbolLeftX = 0f
    private var digitalTimeSymbolTopY = 0f
    private var digitalDateMonthLeftX = 0f
    private var digitalDateMonthTopY = 0f
    private var digitalDateDayLeftX = 0f
    private var digitalDateDayTopY = 0f
    private var digitalDateSymbolLeftX = 0f
    private var digitalDateSymbolTopY = 0f
    private var digitalWeekLeftX = 0f
    private var digitalWeekTopY = 0f
    private var digitalValueColor = 0

    //pointer
    private var pointerSelectNumber = 0

    //digital_parameter
    private val DIGITAL_AM_DIR = "am_pm"
    private val DIGITAL_DATE_DIR = "date"
    private val DIGITAL_HOUR_MINUTE_DIR = "hour_minute"
    private val DIGITAL_WEEK_DIR = "week"

    //pointer_parameter
    private val POINTER_HOUR = "pointer/hour"
    private val POINTER_MINUTE = "pointer/minute"
    private  val POINTER_SECOND = "pointer/second"

    private val mBleHandleCallback by lazy {
        object : BleHandleCallback {
            override fun onSessionStateChange(status: Boolean) {

            }

            override fun onStreamProgress(status: Boolean, errorCode: Int, total: Int, completed: Int) {
                    ToastUtils.showShort("onStreamProgress $status $errorCode $total $completed")
            }

            override fun onCommandSendTimeout(bleKey: BleKey, bleKeyFlag: BleKeyFlag) {

            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BleConnector.addHandleCallback(mBleHandleCallback)

//        controlValueInterval = 1
//        ignoreBlack = 1
//        controlValueRange = 10
//        isRound = true
//        fileFormat = "bmp"
//        imageFormat = WatchFaceBuilder.BMP_565
//        X_CENTER = WatchFaceBuilder.GRAVITY_X_CENTER_R
//        Y_CENTER = WatchFaceBuilder.GRAVITY_Y_CENTER_R

    }

    fun onSync( ) {
        btnSync = false
        val custom=1
        val screenWidth:Int
        val screenHeight :Int
        val screenPreviewWidth :Int
        val screenPreviewHeight :Int
        if (custom == 2) {
            screenWidth = 454
            screenHeight = 454
            screenPreviewWidth = 280
            screenPreviewHeight = 280
        } else {
            screenWidth = 240
            screenHeight = 240
            screenPreviewWidth = 150
            screenPreviewHeight = 150
        }
        val elements = ArrayList<Element>()
        // get preview
        val bgPreviewBytes = getPreview(custom)
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

        // get the background
        val bgBytes = getBg(custom)
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

        // Get the relevant content of the control value
        getControl(elements,custom)

        // Get time related content
        if (timeDigitalView) {
            getTimeDigital(elements,custom)
        }
        if (timePointView) {
            getPointer(WatchFaceBuilder.ELEMENT_NEEDLE_HOUR, POINTER_HOUR, elements,custom)
            getPointer(WatchFaceBuilder.ELEMENT_NEEDLE_MIN, POINTER_MINUTE, elements,custom)
            getPointer(WatchFaceBuilder.ELEMENT_NEEDLE_SEC, POINTER_SECOND, elements,custom)
        }

        for (element in elements) {
            LogUtils.d("customize dial length: ${element.imageBuffers.first().size * 10 / 1024 / 10.0} KB")
        }

        val bytes = WatchFaceBuilder.build(
            elements.toTypedArray(),
            imageFormat
        )
        LogUtils.d("customize dial bytes size  ${bytes.size}")
        BleConnector.sendStream(
            BleKey.WATCH_FACE,
            bytes
        )
    }


    private fun getPointer(type: Int, dir: String, elements: ArrayList<Element>,custom:Int) {
        val customDir: String
        val screenWidth:Int
        val screenHeight :Int
        if (custom == 2) {
            customDir = "dial_customize_454"
            screenWidth = 454
            screenHeight = 454
        } else {
            customDir = "dial_customize_240"
            screenWidth = 240
            screenHeight = 240
        }

        //time
        val TIME_DIR = "$customDir/time"

        val POINTER_DIR = "$TIME_DIR/pointer"
        val pointerHour = ArrayList<ByteArray>()
        val tmpBitmap =
            ImageUtils.getBitmap(resources.assets.open("$POINTER_DIR/${dir}/${pointerSelectNumber}.${fileFormat}"))
        val w = tmpBitmap.width
        val h = tmpBitmap.height
        val pointerHourValue =
            resources.assets.open("$POINTER_DIR/${dir}/${pointerSelectNumber}.${fileFormat}")
                .use { it.readBytes() }

        pointerHour.add(defaultConversion(fileFormat, pointerHourValue, w))
        val elementAmPm = Element(
            type = type,
            w = w,
            h = h,
            gravity = WatchFaceBuilder.GRAVITY_X_LEFT or WatchFaceBuilder.GRAVITY_Y_TOP,
            ignoreBlack = ignoreBlack,
            x = screenWidth / 2 - 1,
            y = screenHeight / 2 - 1,
            bottomOffset = if (fileFormat == "png") 0 else h / 2,
            leftOffset = if (fileFormat == "png") 0 else w / 2,
            imageBuffers = pointerHour.toTypedArray()
        )
        elements.add(elementAmPm)
    }

    companion object {
        fun getTimeDigitalCom(context: Context,elements: ArrayList<Element>,custom:Int) : ArrayList<Element>{
            val activity = context as WatchFaceActivity
            activity.getTimeDigital(elements, custom)
            return elements
        }

        fun getPointerCom(context: Context,type: Int, dir: String,elements: ArrayList<Element>,custom:Int): ArrayList<Element> {
            val activity = context as WatchFaceActivity
            activity.getPointer(type,dir,elements, custom)
            return elements
        }

        fun bitmap2Bytes(context: Context, bgBitMap: Bitmap) : ByteArray {
            val activity = context as WatchFaceActivity
            return activity.bitmap2Bytes(bgBitMap)

        }

    }

    private fun getTimeDigital(elements: ArrayList<Element>,custom:Int) {
        //AM PM
        val amPmValue = ArrayList<ByteArray>()

        val customDir: String = if (custom == 2) {
            "dial_customize_454"
        } else {
            "dial_customize_240"
        }

        //time
        val TIME_DIR = "$customDir/time"

        //digital
        val DIGITAL_DIR = "$TIME_DIR/digital"
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
        amPmValue.add(defaultConversion(fileFormat, amValue, w))
        amPmValue.add(defaultConversion(fileFormat, pmValue, w))
        val elementAmPm = Element(
            type = WatchFaceBuilder.ELEMENT_DIGITAL_AMPM,
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
                    .use { it.readBytes() }, w
            )
        )
        val valueBuffers = symbolValue.toTypedArray()
        val elementSymbol = Element(
            type = type,
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

    private fun getControl(elements: ArrayList<Element>,custom:Int) {
        val customDir: String = if (custom == 2) {
            "dial_customize_454"
        } else {
            "dial_customize_240"
        }
        //value
        val VALUE_DIR = "$customDir/value"
        val triple = getNumberBuffers("$VALUE_DIR/${valueColor}/", controlValueRange)
        val w = triple.first
        val h = triple.second
        val valueBuffers = triple.third.toTypedArray()
        //获取步数数值
        if (controlViewStep) {
            val elementStep = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_STEP,
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
        if (controlViewHr) {
            val elementHr = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_HEART,
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
        if (controlViewCa) {
            val elementCa = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_CALORIE,
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
        if (controlViewDis) {
            val elementDis = Element(
                type = WatchFaceBuilder.ELEMENT_DIGITAL_DISTANCE,
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
            valueByte.add(defaultConversion(fileFormat, value, w))
        }
        return Triple(w, h, valueByte)
    }

    private fun getBg(custom:Int): ByteArray {
        val finalBgBitMap = getBgBitmap(false, custom)
        ImageUtils.save(finalBgBitMap, File(PathUtils.getExternalAppDataPath(),"dial_bg_file.png"), Bitmap.CompressFormat.PNG)
        return bitmap2Bytes(finalBgBitMap)
    }


    private fun getPreview(custom:Int): ByteArray {
        // The size needs to be strictly corresponding, so the background needs to be generated twice
        // Get the background bitmap--with numbers, in preparation for generating a preview
        // Ukuran harus benar-benar sesuai, jadi latar belakang perlu dibuat dua kali
        // Dapatkan bitmap latar belakang--dengan angka, sebagai persiapan untuk membuat pratinjau
        val finalBgBitMap = getBgBitmap(true,custom)
        //根据此处表盘背景,生成背景对应的预览文件
        val screenPreviewWidth :Int
        val screenPreviewHeight :Int
        if (custom == 2) {
            screenPreviewWidth = 280
            screenPreviewHeight = 280
        } else {
            screenPreviewWidth = 150
            screenPreviewHeight = 150
        }
        val previewScaleWidth = screenPreviewWidth.toFloat() / finalBgBitMap.width
        val previewScaleHeight = screenPreviewHeight.toFloat() / finalBgBitMap.height
        val previewScale = ImageUtils.scale(
            finalBgBitMap,
            previewScaleWidth,
            previewScaleHeight
        )
        val finalPreviewBitMap = if (isRound) {
            //裁圆,并且加黑边藏锯齿
            ImageUtils.toRound(previewScale, borderSize, Color.parseColor("#FF0000"))
        } else {
            //裁圆,并且加黑边藏锯齿
            ImageUtils.toRoundCorner(
                previewScale,
                roundCornerRadius * previewScaleWidth,
                borderSize.toFloat(),
                Color.parseColor("#FF0000")
            )
        }

        ImageUtils.save(finalPreviewBitMap, File(PathUtils.getExternalAppDataPath(), "dial_bg_preview_file.png"), Bitmap.CompressFormat.PNG)
        return bitmap2Bytes(finalPreviewBitMap)
    }

    private fun getBgBitmap(isCanvasValue: Boolean,custom:Int): Bitmap {
        val customDir: String
        val screenWidth:Int
        val screenHeight :Int
        if (custom == 2) {
            customDir = "dial_customize_454"
            screenWidth = 454
            screenHeight = 454
        } else {
            customDir = "dial_customize_240"
            screenWidth = 240
            screenHeight = 240
        }

        //初始资源路径
        val CONTROL_DIR = "$customDir/control"
        val STEP_DIR = "$CONTROL_DIR/step"
        val CALORIES_DIR = "$CONTROL_DIR/calories"
        val DISTANCE_DIR = "$CONTROL_DIR/distance"
        val HEART_RATE_DIR = "$CONTROL_DIR/heart_rate"

        //time
        val TIME_DIR = "$customDir/time"
        val DIGITAL_DIR = "$TIME_DIR/digital"

        //value
        val VALUE_DIR = "$customDir/value"

        val bgBitmap = if (isRound) {
            //圆
            bgBitmapx!!
        } else {
            //非圆
            bgBitmapx!!
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
            ImageUtils.toRound(scale, borderSize, Color.parseColor("#000000"))
        } else {
            //非圆
            ImageUtils.toRoundCorner(
                scale,
                roundCornerRadius,
                0f,
                Color.parseColor("#000000")
            )
        }
        //非圆,因为获取bitmap方式不一样,此处需要重新计算比列,为后续计算做准备
        if (!isRound) {
            if(customizeDialBg!=null){
                scaleWidth = screenWidth.toFloat() / customizeDialBg!!.width
                scaleHeight = (screenHeight.toFloat() - screenReservedBoundary) / customizeDialBg!!.height
            }
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
        if (timeDigitalView) {
            //数字时间
            addDigitalTime(
                "$DIGITAL_DIR/${digitalValueColor}/",
                scaleWidth, scaleHeight,
                canvas,
                isCanvasValue
            )
        }
        if (timePointView) {
            //指针
         //   getPointerBg(timePointView, isCanvasValue, canvas)
        }
        if (timeScaleView) {
            //刻度如果有显示,则必然绘制
           // getPointerBg(timeScaleView, true, canvas)
        }

        return getFinalBgBitmap(bgBitMap)
    }

    private fun bitmap2Bytes(finalBgBitMap: Bitmap): ByteArray {
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
        canvas: Canvas,
        custom:Int
    ) {
        val screenWidth:Int
        val screenHeight :Int

        if (custom == 2) {
            screenWidth = 454
            screenHeight = 454
        } else {
            screenWidth = 240
            screenHeight = 240
        }
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
        val timeLeft = timeDigitalViewX * scaleWidth
        val timeTop = timeDigitalViewY * scaleHeight
        LogUtils.d("test timeLeft=$timeLeft,  timeTop=$timeTop, timeDigitalView.width=${timeDigitalViewWidth} ,scaleWidth =$scaleWidth")
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
        elementView: Boolean,
        controlValueFileDir: String,
        controlValue: String,
        canvas: Canvas,
        scaleWidth: Float,
        scaleHeight: Float,
        isCanvasValue: Boolean
    ): Pair<Float, Float> {
        if (elementView) {
            LogUtils.d("test addControlBitmap $controlFileName , $scaleWidth $scaleHeight")
            val viewBitmap = ImageUtils.getBitmap(resources.assets.open(controlFileName))
            val viewLeft = 0 * scaleWidth
            val viewTop = 0 * scaleHeight
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

    private fun defaultConversion(
        fileFormat: String,
        data: ByteArray,
        w: Int,                      //图片宽度
        bitCount: Int = 16,          //位深度，可为8，16，24，32
        headerInfoSize: Int = 70,   //头部信息长度，默认70
        isReverseRows: Boolean = true   //是否反转行数据，就是将第一行置换为最后一行
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
            //非bmp的目前不需要转换，直接用
            return data
        }

    }
    override fun onDestroy() {
        super.onDestroy()
        BleConnector.removeHandleCallback(mBleHandleCallback)
    }

}
