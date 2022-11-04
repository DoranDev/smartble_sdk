package id.kakzaki.smartble_sdk

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.*
import android.provider.ContactsContract
import android.telecom.TelecomManager
import android.text.format.DateFormat
import android.util.Log
import android.view.KeyEvent
import androidx.annotation.NonNull
import com.bestmafen.baseble.scanner.BleDevice
import com.bestmafen.baseble.scanner.BleScanCallback
import com.bestmafen.baseble.scanner.BleScanFilter
import com.bestmafen.baseble.scanner.ScannerFactory
import com.blankj.utilcode.constant.PermissionConstants
import com.blankj.utilcode.util.*
import com.blankj.utilcode.util.ActivityUtils.startActivity
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.*
import com.szabh.smable3.entity.*
import id.kakzaki.smartble_sdk.activity.MusicControlActivity
import id.kakzaki.smartble_sdk.tools.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.*
import kotlin.random.Random


/** SmartbleSdkPlugin */
class SmartbleSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private val mContext: Context?=null
  private val mActivity: Activity?=null
  private val ID_ALL = 0xff
  private lateinit var mBleKey: BleKey
  private var mType = 0
  data class Contact(var name: String, var phone: String)
  private var mCameraEntered = false
  private var mLocationTimes = 1
  private var mClassicBluetoothState = 2
  private var sportState = BleAppSportState.STATE_START

  private lateinit var channel : MethodChannel
  private var scanChannel : EventChannel?=null
  private lateinit var scanSink: EventSink

  private var mResult: Result? = null
  private val mDevices = mutableListOf<Any>()
  private val mBleScanner by lazy {
    // ScannerFactory.newInstance(arrayOf(UUID.fromString(BleConnector.BLE_SERVICE)))
    ScannerFactory.newInstance()
      .setScanDuration(10)
      .setScanFilter(object : BleScanFilter {

        override fun match(device: BleDevice): Boolean {
          //过滤蓝牙信号值，信号值越大，说明信号越强，例如 -66 > -88
          return device.mRssi > -88
        }
      })
      .setBleScanCallback(object : BleScanCallback {

        override fun onBluetoothDisabled() {
          print("onBluetoothDisabled")
        }

        override fun onScan(scan: Boolean) {
          if (scan) {
            mDevices.clear()
          }
          print("onScan $scan")
        }

        override fun onDeviceFound(device: BleDevice) {
          val item: MutableMap<String, Any> = HashMap()
          item["deviceName"] = device.mBluetoothDevice.name
          item["deviceMacAddress"] = device.mBluetoothDevice.address
          if (!(mDevices.contains(item))) {
            mDevices.add(item)
          }
//         Handler(Looper.getMainLooper()).post {
            scanSink.success(mDevices)
//          }
          if (BuildConfig.DEBUG) {
            Log.d("mDevices Found ","$mDevices")
          }
        }
      })
  }

  private val mBleHandleCallback by lazy {
    object : BleHandleCallback {

      override fun onDeviceConnected(device: BluetoothDevice) {
        if (BuildConfig.DEBUG) {
          Log.d("onDeviceConnected","$device")
        }
      }

      override fun onIdentityCreate(status: Boolean, deviceInfo: BleDeviceInfo?) {
        if (status) {
          BleConnector.connectClassic()
        }
        if (BuildConfig.DEBUG) {
          Log.d("onIdentityCre","$status")
        }
      }

      override fun onCommandReply(bleKey: BleKey, bleKeyFlag: BleKeyFlag, status: Boolean) {
        print( "onCommandReply $bleKey $bleKeyFlag -> $status")
      }

      override fun onOTA(status: Boolean) {
        print( "onOTA $status")
        if (!status) return

        if (mContext != null) {
          //FirmwareHelper.gotoOtaReally(mContext)
        }
      }

      override fun onReadMtkOtaMeta() {
        if (mContext != null) {
          //FirmwareHelper.gotoOtaReally(mContext)
        }
      }

      override fun onReadPower(power: Int) {
        print( "onReadPower $power")
      }

      override fun onReadFirmwareVersion(version: String) {
        print( "onReadFirmwareVersion $version")
      }

      override fun onReadBleAddress(address: String) {
        print( "onReadBleAddress $address")
      }

      override fun onReadSedentariness(sedentarinessSettings: BleSedentarinessSettings) {
        print( "onReadSedentariness $sedentarinessSettings")
      }

      override fun onReadNoDisturb(noDisturbSettings: BleNoDisturbSettings) {
        print( "onReadNoDisturb $noDisturbSettings")
      }

      override fun onReadAlarm(alarms: List<BleAlarm>) {
        print( "onReadAlarm $alarms")
      }

      override fun onReadCoachingIds(bleCoachingIds: BleCoachingIds) {
        print( "onReadCoachingIds $bleCoachingIds")
      }

      override fun onReadUiPackVersion(version: String) {
        print( "onReadUiPackVersion $version")
      }

      override fun onReadLanguagePackVersion(version: BleLanguagePackVersion) {
        print( "onReadLanguagePackVersion $version")
      }


      override fun onIdentityDeleteByDevice(isDevice: Boolean) {
        print( "onIdentityDeleteByDevice $isDevice")
        BleConnector.unbind()
        unbindCompleted()
      }

      override fun onCameraStateChange(cameraState: Int) {
        print( "onCameraStateChange ${CameraState.getState(cameraState)}")
        if (cameraState == CameraState.ENTER) {
          mCameraEntered = true
        } else if (cameraState == CameraState.EXIT) {
          mCameraEntered = false
        }
      }

      override fun onCameraResponse(status: Boolean, cameraState: Int) {
        print( "onCameraResponse $status ${CameraState.getState(cameraState)}")
        if (status) {
          if (cameraState == CameraState.ENTER) {
            mCameraEntered = true
          } else if (cameraState == CameraState.EXIT) {
            mCameraEntered = false
          }
        }
      }

      override fun onSyncData(syncState: Int, bleKey: BleKey) {
        print( "onSyncData syncState=$syncState, bleKey=$bleKey")
      }

      override fun onReadActivity(activities: List<BleActivity>) {
        print( "$activities")
      }

      override fun onReadHeartRate(heartRates: List<BleHeartRate>) {
        print( "$heartRates")
      }

      override fun onUpdateHeartRate(heartRate: BleHeartRate) {
        print( "$heartRate")
      }

      override fun onReadBloodPressure(bloodPressures: List<BleBloodPressure>) {
        // print( "$bloodPressures")
      }

      override fun onReadSleep(sleeps: List<BleSleep>) {
        // print( "$sleeps")
      }

      override fun onReadLocation(locations: List<BleLocation>) {
        // print( "$locations")
      }

      override fun onReadTemperature(temperatures: List<BleTemperature>) {
        // print( "$temperatures")
      }

      override fun onReadWorkout2(workouts: List<BleWorkout2>) {
        print( "$workouts")
      }

      override fun onStreamProgress(
        status: Boolean,
        errorCode: Int,
        total: Int,
        completed: Int
      ) {
        print( "onStreamProgress $status $errorCode $total $completed")
      }

      @SuppressLint("MissingPermission")
      override fun onIncomingCallStatus(status: Int) {
        if (status == 0) {
          //接听电话
          try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              val manager =
                mContext!!.getSystemService(Context.TELECOM_SERVICE) as TelecomManager?
              manager?.acceptRingingCall()
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
              //其中  NotificationListenerService 需要在 Manifest 中定义为服务后才可以使用，例如
              /**
              <service
              android:name=".ble.MyNotificationListenerService"
              android:label="@string/app_name"
              android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE">
              <intent-filter>
              <action android:name="android.service.notification.NotificationListenerService" />
              </intent-filter>
              </service>
               */

//                            val mediaSessionManager =
//                                getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
//                            val mediaControllerList = mediaSessionManager.getActiveSessions(
//                                ComponentName(this, NotificationListenerService::class.java)
//                            )
//                            for (m in mediaControllerList) {
//                                if ("com.android.server.telecom" == m.packageName) {
//                                    m.dispatchMediaButtonEvent(
//                                        KeyEvent(
//                                            KeyEvent.ACTION_DOWN,
//                                            KeyEvent.KEYCODE_HEADSETHOOK
//                                        )
//                                    )
//                                    m.dispatchMediaButtonEvent(
//                                        KeyEvent(
//                                            KeyEvent.ACTION_UP,
//                                            KeyEvent.KEYCODE_HEADSETHOOK
//                                        )
//                                    )
//                                    break
//                                }
//                            }
            } else {
              val audioManager =
                mContext!!.getSystemService(Context.AUDIO_SERVICE) as AudioManager?
              val eventDown =
                KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_HEADSETHOOK)
              val eventUp = KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_HEADSETHOOK)
              audioManager?.dispatchMediaKeyEvent(eventDown)
              audioManager?.dispatchMediaKeyEvent(eventUp)
              Runtime.getRuntime()
                .exec("input keyevent " + Integer.toString(KeyEvent.KEYCODE_HEADSETHOOK))
            }
          } catch (e: Exception) {
            e.printStackTrace()
          }
        } else {
          //拒接
          if (Build.VERSION.SDK_INT < 28) {
            try {
              val telephonyClass =
                Class.forName("com.android.internal.telephony.ITelephony")
              val telephonyStubClass = telephonyClass.classes[0]
              val serviceManagerClass = Class.forName("android.os.ServiceManager")
              val serviceManagerNativeClass =
                Class.forName("android.os.ServiceManagerNative")
              val getService =
                serviceManagerClass.getMethod("getService", String::class.java)
              val tempInterfaceMethod =
                serviceManagerNativeClass.getMethod(
                  "asInterface",
                  IBinder::class.java
                )
              val tmpBinder = Binder()
              tmpBinder.attachInterface(null, "fake")
              val serviceManagerObject = tempInterfaceMethod.invoke(null, tmpBinder)
              val retbinder =
                getService.invoke(serviceManagerObject, "phone") as IBinder
              val serviceMethod =
                telephonyStubClass.getMethod("asInterface", IBinder::class.java)
              val telephonyObject = serviceMethod.invoke(null, retbinder)
              val telephonyEndCall = telephonyClass.getMethod("endCall")
              telephonyEndCall.invoke(telephonyObject)
            } catch (e: Exception) {
              LogUtils.d("hang up error " + e.message)
            }
          } else {
            PermissionUtils
              .permission(PermissionConstants.PHONE)
              .request2 {
                if (it == PermissionStatus.GRANTED) {
                  LogUtils.d("hang up OK")
                  val manager =
                    mContext!!.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                  manager.endCall()
                }
              }
          }
        }

      }

      override fun onUpdateAppSportState(appSportState: BleAppSportState) {
        print( "$appSportState")
      }

      override fun onClassicBluetoothStateChange(state: Int) {
        print( ClassicBluetoothState.getState(state))
        mClassicBluetoothState = state
      }

      override fun onDeviceFileUpdate(deviceFile: BleDeviceFile) {
        LogUtils.d("onDeviceFileUpdate $deviceFile")
        print( "$deviceFile")
      }

      override fun onReadDeviceFile(deviceFile: BleDeviceFile) {
        if (deviceFile.mFileSize != 0) {
          BleConnector.sendData(BleKey.DEVICE_FILE, BleKeyFlag.READ_CONTINUE)
        }
        LogUtils.d("onReadDeviceFile $deviceFile")
        print( "$deviceFile")
        FileIOUtils.writeFileFromBytesByStream(
          File(PathUtils.getExternalAppDataPath() + "/voice/${deviceFile.mTime}.wav"),
          deviceFile.mFileContent,
          true
        )

      }

      override fun onReadTemperatureUnit(value: Int) {
        print( "onReadTemperatureUnit $value")
      }

      override fun onReadDateFormat(value: Int) {
        print( "onReadDateFormat $value")
      }

      override fun onReadWatchFaceSwitch(value: Int) {
        print( "onReadWatchFaceSwitch $value")
      }

      override fun onUpdateWatchFaceSwitch(status: Boolean) {
        print( "onUpdateWatchFaceSwitch $status")
      }

      override fun onAppSportDataResponse(status: Boolean) {
        print( "$status")
      }

      override fun onReadWatchFaceId(watchFaceId: BleWatchFaceId) {
        print( "onReadWatchFaceId ${watchFaceId.mIdList}")
      }

      override fun onWatchFaceIdUpdate(status: Boolean) {
        //chooseFile(mContext, BleKey.WATCH_FACE.mKey)
      }

      override fun onHIDState(state: Int) {
        print( "$state")
        if(state == HIDState.DISCONNECTED){
          BleConnector.connectHID()
        }
      }

      override fun onHIDValueChange(value: Int) {
        print( "$value")
      }

      override fun onDeviceSMSQuickReply(smsQuickReply: BleSMSQuickReply) {
        print( smsQuickReply.toString())
      }

      override fun onReadDeviceInfo(deviceInfo: BleDeviceInfo) {
        print( deviceInfo.toString())
      }

    }
  }


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "smartble_sdk")
    channel.setMethodCallHandler(this)
    scanChannel = EventChannel(flutterPluginBinding.binaryMessenger, "smartble_sdk/scan")
    scanChannel!!.setStreamHandler(scanResultsHandler)
    val connector = BleConnector.Builder(flutterPluginBinding.applicationContext)
      .supportRealtekDfu(false) // Whether to support Realtek device Dfu, pass false if no support is required.
      .supportMtkOta(false) // Whether to support MTK device Ota, pass false if no support is required.
      .supportLauncher(true) // Whether to support automatic connection to Ble Bluetooth device method (if bound), if not, please pass false
      .supportFilterEmpty(true) // Whether to support filtering empty data, such as ACTIVITY, HEART_RATE, BLOOD_PRESSURE, SLEEP, WORKOUT, LOCATION, TEMPERATURE, BLOOD_OXYGEN, HRV, if you do not need to support false.
      .build()

    connector.addHandleCallback(object : BleHandleCallback {
      override fun onSessionStateChange(status: Boolean) {
        if (status) {
          connector.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
          connector.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
          connector.sendInt8(
            BleKey.HOUR_SYSTEM, BleKeyFlag.UPDATE,
            if (DateFormat.is24HourFormat(Utils.getApp())) 0 else 1)
          connector.sendData(BleKey.POWER, BleKeyFlag.READ)
          connector.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)
          connector.sendInt8(BleKey.LANGUAGE, BleKeyFlag.UPDATE, Languages.languageToCode())
          connector.sendData(BleKey.MUSIC_CONTROL, BleKeyFlag.READ)
        }
      }
    })
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    this.mResult = result
    when (call.method) {
      "scan" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
          PermissionUtils
            .permission(
              PermissionConstants.LOCATION,
              Manifest.permission.BLUETOOTH_SCAN,
              Manifest.permission.BLUETOOTH_CONNECT,
              Manifest.permission.BLUETOOTH_ADVERTISE
            )
            .require(
              PermissionConstants.LOCATION,
              Manifest.permission.BLUETOOTH_SCAN,
              Manifest.permission.BLUETOOTH_CONNECT,
              Manifest.permission.BLUETOOTH_ADVERTISE,
            ) { granted ->
              if (granted) {
                mBleScanner.scan(!mBleScanner.isScanning)
              }
            }
        } else {
          PermissionUtils
            .permission(PermissionConstants.LOCATION)
            .require(Manifest.permission.ACCESS_FINE_LOCATION) { granted ->
              if (granted) {
                mBleScanner.scan(!mBleScanner.isScanning)
              }
            }
        }
      }
      "connect" -> {
        mBleScanner.scan(false)
          val bname: String? = call.argument<String>("bname")
          val bmac : String? = call.argument<String>("bmac")
          if (bmac != null) {
            BleConnector.setAddress(bmac).connect(true)
          }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  // 显示该BleKey对应的Flag列表
  private fun setupKeyFlagList(bleKey: BleKey) {
    val bleKeyFlags = bleKey.getBleKeyFlags()
    //Todo : isi dulu perintahnya
    handleCommand(mBleKey, bleKeyFlags[0])

    when (bleKey) {
      BleKey.WATCH_FACE -> {
//                findViewById<TextView>(R.id.tv_custom1).apply {
//                    visibility = View.VISIBLE
//                    text = "custom 240*240"
//                    setOnClickListener {
//                        startActivity(
//                            Intent(
//                                this@KeyFlagListActivity,
//                                WatchFaceActivity::class.java
//                            ).putExtra("custom", 1)
//                        )
//                    }
//                }
//
//                findViewById<TextView>(R.id.tv_custom2).apply {
//                    visibility = View.VISIBLE
//                    text = "custom 454*454"
//                    setOnClickListener {
//                        startActivity(
//                            Intent(
//                                this@KeyFlagListActivity,
//                                WatchFaceActivity::class.java
//                            ).putExtra("custom", 2)
//                        )
//                    }
//                }
      }
      else -> {}
    }

  }

  // 发送相应的指令
  private fun handleCommand(bleKey: BleKey, bleKeyFlag: BleKeyFlag) {
    if (bleKey == BleKey.IDENTITY) {
      if (bleKeyFlag == BleKeyFlag.DELETE) { // 解除绑定
        // 发送解除绑定指令, 有些设备回复后会触发BleHandleCallback.onIdentityDelete()
        BleConnector.sendData(bleKey, bleKeyFlag)
        // 等待一会再解绑
        Handler().postDelayed({
          BleConnector.unbind()
          unbindCompleted()
        }, 2000)
        return
      }
    }

    if (mContext != null) {
      doBle(mContext) {
        when (bleKey) {
          // BleCommand.UPDATE
//          BleKey.OTA -> FirmwareHelper.gotoOta(mContext)
          BleKey.XMODEM -> BleConnector.sendData(bleKey, bleKeyFlag)

          // BleCommand.SET
          BleKey.TIME -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置时间, 设置时间之前必须先设置时区
              BleConnector.sendObject(bleKey, bleKeyFlag, BleTime.local())
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.TIME_ZONE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置时区
              BleConnector.sendObject(bleKey, bleKeyFlag, BleTimeZone())
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.POWER -> BleConnector.sendData(bleKey, bleKeyFlag) // 读取电量
          BleKey.FIRMWARE_VERSION -> BleConnector.sendData(bleKey, bleKeyFlag) // 读取固件版本
          BleKey.BLE_ADDRESS -> BleConnector.sendData(bleKey, bleKeyFlag) // 读取BLE蓝牙地址
          BleKey.USER_PROFILE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置用户信息
              val bleUserProfile = BleUserProfile(
                mUnit = BleUserProfile.METRIC,
                mGender = BleUserProfile.FEMALE,
                mAge = 20,
                mHeight = 170f,
                mWeight = 60f
              )
              BleConnector.sendObject(bleKey, bleKeyFlag, bleUserProfile)
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.STEP_GOAL -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置目标步数
              BleConnector.sendInt32(bleKey, bleKeyFlag, 10)
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.BACK_LIGHT -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置背光时长
              BleConnector.sendInt8(bleKey, bleKeyFlag, 6) // 0 is off, or 5 ~ 20
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.SEDENTARINESS -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置久坐
              val bleSedentariness = BleSedentarinessSettings(
                mEnabled = 1,
                // Monday ~ Saturday
                mRepeat = BleRepeat.MONDAY or BleRepeat.TUESDAY or BleRepeat.WEDNESDAY or BleRepeat.THURSDAY or BleRepeat.FRIDAY or BleRepeat.SATURDAY,
                mStartHour = 1,
                mEndHour = 22,
                mInterval = 60
              )
              BleConnector.sendObject(bleKey, bleKeyFlag, bleSedentariness)
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.NO_DISTURB_RANGE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置勿扰
              val noDisturb = BleNoDisturbSettings().apply {
                mBleTimeRange1 = BleTimeRange(1, 2, 0, 18, 0)
              }
              BleConnector.sendObject(bleKey, bleKeyFlag, noDisturb)
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
//                BleKey.NO_DISTURB_GLOBAL -> BleConnector.sendBoolean(bleKey, bleKeyFlag, true) // on
          BleKey.VIBRATION -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置震动次数
              BleConnector.sendInt8(bleKey, bleKeyFlag, 3) // 0~10, 0 is off
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.GESTURE_WAKE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置抬手亮
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleGestureWake(BleTimeRange(1, 8, 0, 22, 0))
              )
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
//                BleKey.HR_ASSIST_SLEEP -> BleConnector.sendBoolean(bleKey, bleKeyFlag, true) // on
          // 设置小时制
          BleKey.HOUR_SYSTEM ->
            // 切换, 0: 24-hourly; 1: 12-hourly
            BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)
          // 设置设备语言
          BleKey.LANGUAGE -> BleConnector.sendInt8(
            bleKey,
            bleKeyFlag,
            Languages.languageToCode()
          )
          BleKey.ALARM -> {
            // 创建一个1分钟后的闹钟
            if (bleKeyFlag == BleKeyFlag.CREATE) {
              val calendar = Calendar.getInstance().apply { add(Calendar.MINUTE, 1) }
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleAlarm(
                  mEnabled = 1,
                  mRepeat = BleRepeat.EVERYDAY,
                  mYear = calendar.get(Calendar.YEAR),
                  mMonth = calendar.get(Calendar.MONTH) + 1,
                  mDay = calendar.get(Calendar.DAY_OF_MONTH),
                  mHour = calendar.get(Calendar.HOUR_OF_DAY),
                  mMinute = calendar.get(Calendar.MINUTE),
                  mTag = "tag"
                )
              )
            } else if (bleKeyFlag == BleKeyFlag.DELETE) {
              // 如果缓存中有闹钟的话，删除第一个
              val alarms = BleCache.getList(BleKey.ALARM, BleAlarm::class.java)
              if (alarms.isNotEmpty()) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, alarms[0].mId)
              }
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 如果缓存中有闹钟的话，切换第一个闹钟的开启状态
              val alarms = BleCache.getList(BleKey.ALARM, BleAlarm::class.java)
              if (alarms.isNotEmpty()) {
                alarms[0].let { alarm ->
                  alarm.mEnabled = if (alarm.mEnabled == 0) 1 else 0
                  BleConnector.sendObject(bleKey, bleKeyFlag, alarm)
                }
              }
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              // 读取设备上所有的闹钟
              BleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
            } else if (bleKeyFlag == BleKeyFlag.RESET) {
              // 重置设备上的闹钟
              val calendar = Calendar.getInstance()
              BleConnector.sendList(bleKey, bleKeyFlag, List(8) {
                BleAlarm(
                  mEnabled = it.rem(2),
                  mRepeat = it,
                  mYear = calendar.get(Calendar.YEAR),
                  mMonth = calendar.get(Calendar.MONTH) + 1,
                  mDay = calendar.get(Calendar.DAY_OF_MONTH),
                  mHour = calendar.get(Calendar.HOUR_OF_DAY),
                  mMinute = it,
                  mTag = "$it"
                )
              })
            }
          }
          BleKey.COACHING -> {
            if (bleKeyFlag == BleKeyFlag.CREATE) {
              BleConnector.sendObject(
                bleKey, bleKeyFlag, BleCoaching(
                  "My title", // title
                  "My description", // description
                  3, // repeat
                  listOf(
                    BleCoachingSegment(
                      CompletionCondition.DURATION.condition, // completion condition
                      "My name", // name
                      0, // activity
                      Stage.WARM_UP.stage, // stage
                      10, // completion value
                      0 // hr zone
                    )
                  )
                )
              )
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 如果缓存中有Coaching的话，修改第一个Coaching的标题
              val coachings = BleCache.getList(BleKey.COACHING, BleCoaching::class.java)
              if (coachings.isNotEmpty()) { // update the first coaching
                coachings[0].let { coaching ->
                  coaching.mTitle += "nice"
                  BleConnector.sendObject(bleKey, bleKeyFlag, coaching)
                }
              }
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              // 读取所有Coaching
              BleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
            }
          }
          // 设置是否开启消息推送
          BleKey.NOTIFICATION_REMINDER ->
            BleConnector.sendBoolean(
              bleKey,
              bleKeyFlag,
              !BleCache.getBoolean(bleKey, false)
            ) // 切换
          // 设置防丢提醒
          BleKey.ANTI_LOST ->
            BleConnector.sendBoolean(
              bleKey,
              bleKeyFlag,
              !BleCache.getBoolean(bleKey, false)
            ) // 切换
          // 设置心率自动检测
          BleKey.HR_MONITORING -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              val hrMonitoring = BleHrMonitoringSettings(
                mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
                mInterval = 1 // an hour
              )
              BleConnector.sendObject(bleKey, bleKeyFlag, hrMonitoring)
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          // 读取UI包版本
          BleKey.UI_PACK_VERSION -> BleConnector.sendData(bleKey, bleKeyFlag)
          // 读取语言包版本
          BleKey.LANGUAGE_PACK_VERSION -> BleConnector.sendData(bleKey, bleKeyFlag)
          // 发送睡眠质量
          BleKey.SLEEP_QUALITY -> BleConnector.sendObject(
            bleKey, bleKeyFlag,
            BleSleepQuality(mLight = 202, mDeep = 201, mTotal = 481)
          )
          // 设置女性健康提醒
          BleKey.GIRL_CARE -> BleConnector.sendObject(
            bleKey, bleKeyFlag,
            BleGirlCareSettings(
              mEnabled = 1,
              mReminderHour = 9,
              mReminderMinute = 0,
              mMenstruationReminderAdvance = 2,
              mOvulationReminderAdvance = 2,
              mLatestYear = 2020,
              mLatestMonth = 1,
              mLatestDay = 1,
              mMenstruationDuration = 7,
              mMenstruationPeriod = 30
            )
          )
          // 设置温度检测
          BleKey.TEMPERATURE_DETECTING -> BleConnector.sendObject(
            bleKey, bleKeyFlag,
            BleTemperatureDetecting(
              mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
              mInterval = 60 // an hour
            )
          )
          // 设置有氧运动
          BleKey.AEROBIC_EXERCISE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleAerobicExerciseSettings(
                  mExerciseHour = 1,
                  mExerciseMinute = 30,
                  mHrMin = 50,
                  mHrMax = 150,
                  mLowHrMinMinute = 10,
                  mLowHrMinVibration = 2,
                  mHighHrMaxMinute = 20,
                  mHighHrMaxVibration = 2,
                  mLowOrHighHrDuration = 30,
                )
              )
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          // 温度单位设置
          BleKey.TEMPERATURE_UNIT ->
            // 切换, 0: 摄氏度; 1: 华氏度
            BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)

          // 日期格式设置
          BleKey.DATE_FORMAT ->
            // 切换, 0: 年月日; 1: 日月年; 2: 月日年;
            BleConnector.sendInt8(bleKey, bleKeyFlag, (BleCache.getInt(bleKey, 0) + 1) % 3)
          BleKey.RAW_SLEEP ->
            BleConnector.sendData(bleKey, bleKeyFlag)

          //默认表盘切换设置
          BleKey.WATCH_FACE_SWITCH ->
            // value, 0-4;
            BleConnector.sendInt8(bleKey, bleKeyFlag, (BleCache.getInt(bleKey, 0) + 1) % 5)

          // 表盘id
          BleKey.WATCHFACE_ID -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              mType = 1//表盘在设备上的位置
              BleConnector.sendInt32(bleKey, bleKeyFlag, 100)//只有>=100或者无效
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }

          //IBEACON_SET
          BleKey.IBEACON_SET -> {
            //安卓绑定成功后，强制让设备关闭这个功能，省电
            BleConnector.sendInt8(bleKey, bleKeyFlag, 0)
          }

          //二维码的进制转换设置
          BleKey.MAC_QRCODE -> {
            //0x01:十进制 0x02:十六进制
            BleConnector.sendInt8(bleKey, bleKeyFlag, 0x01)
          }

          BleKey.SET_WATCH_PASSWORD -> {
            BleConnector.sendObject(
              bleKey,
              bleKeyFlag,
              BleSettingWatchPassword(mEnabled = 1, mPassword = "1234")
            )
          }

          BleKey.REALTIME_MEASUREMENT -> {
            BleConnector.sendObject(
              bleKey,
              bleKeyFlag,
              BleRealTimeMeasurement(mHRSwitch = 0, mBOSwitch = 1, mBPSwitch = 0)
            )
          }

          //BleCommand.CONNECT
          BleKey.IDENTITY ->
            if (bleKeyFlag == BleKeyFlag.CREATE) {
              // 绑定设备, 外部无需手动调用, 框架内部会自动发送该指令
              BleConnector.sendInt32(bleKey, bleKeyFlag, Random.nextInt())
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }

          // BleCommand.PUSH
          BleKey.MUSIC_CONTROL -> startActivity(
            Intent(
              mContext,
              MusicControlActivity::class.java
            )
          )
          BleKey.SCHEDULE -> {
            if (bleKeyFlag == BleKeyFlag.CREATE) {
              // 创建一个1分钟后的日程
              val calendar = Calendar.getInstance().apply { add(Calendar.MINUTE, 1) }
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleSchedule(
                  mYear = calendar.get(Calendar.YEAR),
                  mMonth = calendar.get(Calendar.MONTH) + 1,
                  mDay = calendar.get(Calendar.DAY_OF_MONTH),
                  mHour = calendar.get(Calendar.HOUR_OF_DAY),
                  mMinute = calendar.get(Calendar.MINUTE),
                  mAdvance = 0,
                  mTitle = "Title8",
                  mContent = "Content9"
                )
              )
            } else if (bleKeyFlag == BleKeyFlag.DELETE) {
              // 如果缓存中有日程的话，删除第一个
              val schedules = BleCache.getList(BleKey.SCHEDULE, BleSchedule::class.java)
              if (schedules.isNotEmpty()) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, schedules[0].mId)
              }
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 如果缓存中有日程的话，修改第一个日程的时间
              val schedules = BleCache.getList(BleKey.SCHEDULE, BleSchedule::class.java)
              if (schedules.isNotEmpty()) {
                schedules[0].let { schedule ->
                  schedule.mHour = Random.nextInt(23)
                  BleConnector.sendObject(bleKey, bleKeyFlag, schedule)
                }
              }
            }
          }
          // 发送实时天气
          BleKey.WEATHER_REALTIME -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              BleConnector.sendObject(
                BleKey.WEATHER_REALTIME, bleKeyFlag, BleWeatherRealtime(
                  mTime = (Date().time / 1000L).toInt(),
                  mWeather = BleWeather(
                    mCurrentTemperature = 1,
                    mMaxTemperature = 1,
                    mMinTemperature = 1,
                    mWeatherCode = BleWeather.RAINY,
                    mWindSpeed = 1,
                    mHumidity = 1,
                    mVisibility = 1,
                    mUltraVioletIntensity = 1,
                    mPrecipitation = 1
                  )
                )
              )
            }
          }
          // 发送天气预备
          BleKey.WEATHER_FORECAST -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              BleConnector.sendObject(
                BleKey.WEATHER_FORECAST, bleKeyFlag, BleWeatherForecast(
                  mTime = (Date().time / 1000L).toInt(),
                  mWeather1 = BleWeather(
                    mCurrentTemperature = 2,
                    mMaxTemperature = 2,
                    mMinTemperature = 3,
                    mWeatherCode = BleWeather.CLOUDY,
                    mWindSpeed = 2,
                    mHumidity = 2,
                    mVisibility = 2,
                    mUltraVioletIntensity = 2,
                    mPrecipitation = 2
                  ),
                  mWeather2 = BleWeather(
                    mCurrentTemperature = 3,
                    mMaxTemperature = 3,
                    mMinTemperature = 3,
                    mWeatherCode = BleWeather.OVERCAST,
                    mWindSpeed = 3,
                    mHumidity = 3,
                    mVisibility = 3,
                    mUltraVioletIntensity = 3,
                    mPrecipitation = 3
                  ),
                  mWeather3 = BleWeather(
                    mCurrentTemperature = 4,
                    mMaxTemperature = 4,
                    mMinTemperature = 4,
                    mWeatherCode = BleWeather.RAINY,
                    mWindSpeed = 4,
                    mHumidity = 4,
                    mVisibility = 4,
                    mUltraVioletIntensity = 4,
                    mPrecipitation = 4
                  )
                )
              )
            }
          }
          // HID
          BleKey.HID -> {
            BleConnector.sendData(bleKey, bleKeyFlag)
          }
          //世界时钟
          BleKey.WORLD_CLOCK -> {
            // 创建一个时钟
            if (bleKeyFlag == BleKeyFlag.CREATE) {
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleWorldClock(
                  isLocal = 0,
                  mTimeZoneOffset = TimeZone.getDefault().rawOffset / 1000 / 60 / 15,
                  mCityName = "本地时间"
                )
              )
            } else if (bleKeyFlag == BleKeyFlag.DELETE) {
              // 如果缓存中有时钟的话，删除第一个
              val clocks = BleCache.getList(BleKey.WORLD_CLOCK, BleWorldClock::class.java)
              if (clocks.isNotEmpty()) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, clocks[0].mId)
              }
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
              val clocks = BleCache.getList(BleKey.WORLD_CLOCK, BleWorldClock::class.java)
              if (clocks.isNotEmpty()) {
                clocks[0].let { clock ->
                  clock.isLocal = if (clock.isLocal == 0) 1 else 0
                  BleConnector.sendObject(bleKey, bleKeyFlag, clock)
                }
              }
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              // 读取设备上所有的时钟
              BleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
            }
          }
          //股票
          BleKey.STOCK -> {
            // 创建一个股票
            if (bleKeyFlag == BleKeyFlag.CREATE) {
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleStock(
                  mStockCode = "AAPL",
                  mSharePrice = 148.470f,
                  mNetChangePoint = 2.980f,
                  mNetChangePercent = 2.05f,
                  mMarketCapitalization = 2.40f
                )
              )
            } else if (bleKeyFlag == BleKeyFlag.DELETE) {
              // 如果缓存中有股票的话，删除第一个
              val stocks = BleCache.getList(BleKey.STOCK, BleStock::class.java)
              if (stocks.isNotEmpty()) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, stocks[0].mId)
              }
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
              val stocks = BleCache.getList(BleKey.STOCK, BleStock::class.java)
              if (stocks.isNotEmpty()) {
                stocks[0].let { stock ->
                  stock.mSharePrice = stock.mSharePrice + 1
                  BleConnector.sendObject(bleKey, bleKeyFlag, stock)
                }
              }
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              // 读取设备上所有的股票
              BleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
            }
          }
          //短信快捷回复
          BleKey.SMS_QUICK_REPLY_CONTENT -> {
            if (bleKeyFlag == BleKeyFlag.CREATE) {
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleSMSQuickReplyContent(
                  mContent = "我正在会议中，${Random.nextInt(10)}请稍后再联系我"
                )
              )
            } else if (bleKeyFlag == BleKeyFlag.DELETE) {
              // 如果缓存中有内容的话，删除第一个
              val smsQuickReply = BleCache.getList(
                BleKey.SMS_QUICK_REPLY_CONTENT,
                BleSMSQuickReplyContent::class.java
              )
              if (smsQuickReply.isNotEmpty()) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, smsQuickReply[0].mId)
              }
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 如果缓存中有内容的话，修改第一个
              val smsQuickReply = BleCache.getList(
                BleKey.SMS_QUICK_REPLY_CONTENT,
                BleSMSQuickReplyContent::class.java
              )
              if (smsQuickReply.isNotEmpty()) {
                smsQuickReply[0].let { smsQuickReply ->
                  smsQuickReply.mContent = "我正在会议中，${Random.nextInt(10)}请稍后再联系我"
                  BleConnector.sendObject(bleKey, bleKeyFlag, smsQuickReply)
                }
              }
            }
          }
          // BleCommand.DATA
          BleKey.DATA_ALL, BleKey.ACTIVITY, BleKey.HEART_RATE, BleKey.BLOOD_PRESSURE, BleKey.SLEEP,
          BleKey.WORKOUT, BleKey.LOCATION, BleKey.TEMPERATURE, BleKey.BLOOD_OXYGEN, BleKey.HRV, BleKey.LOG, BleKey.WORKOUT2 ->
            // 读取数据
            BleConnector.sendData(bleKey, bleKeyFlag)

          BleKey.APP_SPORT_DATA -> {
            // App 主导的运动，发送运动过程中App计算的数据给设备
            val reply = BleAppSportData(
              mDuration = 132,
              mAltitude = -30,
              mAirPressure = 1000,
              mSpm = 300,
              mMode = BleAppSportState.MODE_INDOOR,
              mStep = 898,
              mDistance = 700,
              mCalorie = 300,
              mSpeed = 6000,
              mPace = 900,
            )
            BleConnector.sendObject(bleKey, bleKeyFlag, reply)
            print("$reply")
            LogUtils.d(reply)
          }

          // BleCommand.CONTROL
          BleKey.CAMERA -> {
            if (mCameraEntered) {
              // 退出相机
              BleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.EXIT)
            } else {
              // 进入相机
              BleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.ENTER)
            }
          }
          BleKey.REQUEST_LOCATION -> {
            // 回复位置信息
            val reply = BleLocationReply(
              mSpeed = 1.11f * mLocationTimes,
              mTotalDistance = 1.11f * mLocationTimes,
              mAltitude = 111 * mLocationTimes
            )
            BleConnector.sendObject(bleKey, bleKeyFlag, reply)
            print("$reply")
            mLocationTimes++
            if (mLocationTimes > 10) mLocationTimes = 1
          }
          BleKey.APP_SPORT_STATE -> {
            // App 主导的运动，发送运动状态变化
            when (sportState) {
              BleAppSportState.STATE_START -> sportState = BleAppSportState.STATE_PAUSE
              BleAppSportState.STATE_PAUSE -> sportState = BleAppSportState.STATE_END
              else -> sportState = BleAppSportState.STATE_START
            }
            val reply = BleAppSportState(
              mMode = BleAppSportState.MODE_INDOOR,
              mState = sportState,
            )
            BleConnector.sendObject(bleKey, bleKeyFlag, reply)
            print("$reply")
            LogUtils.d(reply)
          }
          BleKey.CLASSIC_BLUETOOTH_STATE -> {
            // 3.0 开关
            if (mClassicBluetoothState == ClassicBluetoothState.CLOSE_SUCCESSFULLY) {
              mClassicBluetoothState = ClassicBluetoothState.OPEN
              BleConnector.sendInt8(bleKey, bleKeyFlag, mClassicBluetoothState)
            } else if (mClassicBluetoothState == ClassicBluetoothState.OPEN_SUCCESSFULLY) {
              mClassicBluetoothState = ClassicBluetoothState.CLOSE
              BleConnector.sendInt8(bleKey, bleKeyFlag, mClassicBluetoothState)
            } else {
              //3.0状态正在切换中，请稍等
              print("3.0 status is switching, please wait")
            }
          }

          // BleCommand.IO
          BleKey.WATCH_FACE, BleKey.AGPS_FILE, BleKey.FONT_FILE, BleKey.UI_FILE, BleKey.LANGUAGE_FILE, BleKey.BRAND_INFO_FILE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 发送文件
              if (mActivity != null) {
                chooseFile(mActivity, bleKey.mKey)
              }
            }/* else if (bleKeyFlag == BleKeyFlag.DELETE) {
                        // 删除设备上的文件
                        BleConnector.sendInt8(bleKey, bleKeyFlag, 1)
                    }*/
          }
          BleKey.CONTACT -> {
            PermissionUtils
              .permission(PermissionConstants.CONTACTS)
              .require(Manifest.permission.READ_CONTACTS) { granted ->
                if (granted) {
                  val bytes = getContactBytes()
                  if (bytes.isNotEmpty()) {
                    BleConnector.sendStream(BleKey.CONTACT, bytes)
                  } else {
                    LogUtils.d("contact is empty")
                  }
                }
              }
          }

          BleKey.DEVICE_FILE -> {
            if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }

          else -> {
            print("$bleKey")
          }
        }
      }
    }
  }

  @SuppressLint("Range")
  private fun getContactBytes(): ByteArray {
    val cursor = mContext!!.contentResolver.query(
      ContactsContract.Contacts.CONTENT_URI,
      null,
      null,
      null,
      "${ContactsContract.Contacts.DISPLAY_NAME} COLLATE LOCALIZED ASC"
    )
    val contact = ArrayList<Contact>()
    if (cursor != null && cursor.moveToFirst()) {
      do {
        val idColumn: Int =
          cursor.getColumnIndex(ContactsContract.Contacts._ID)
        val displayNameColumn: Int =
          cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)
        // 获得联系人的ID号
        val contactId: String = cursor.getString(idColumn)
        // 获得联系人姓名
        val disPlayName: String =
          cursor.getString(displayNameColumn)
        val phones =
          mContext.contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            null,
            ContactsContract.CommonDataKinds.Phone.CONTACT_ID
                    + " = " + contactId, null, null
          )
        if (phones != null && phones.moveToFirst()) {
          //电话号码如果有多个,则只取第一个,
          var phone: String =
            phones.getString(
              phones.getColumnIndex(
                ContactsContract.CommonDataKinds.Phone.NUMBER
              )
            )
          phone = phone.replace("-", "")
          phone = phone.replace(" ", "")
//          contact.add(KeyFlagListActivity.Contact(disPlayName, phone))
          phones.close()
        }
      } while (cursor.moveToNext())
      cursor.close()
    }
    LogUtils.d(contact.toString())
    //固件拟定:姓名 24和电话号码 16个字节,所以此处依据数据大小,创建array
    val bytes = ByteArray(contact.size * 40)
    for (index in contact.indices) {
      val nameBytes = contact[index].name.toByteArray()
      for (valueIndex in nameBytes.indices) {
        if (valueIndex < 24) {
          bytes[index * 40 + valueIndex] = nameBytes[valueIndex]
        }
      }
      val phoneBytes = contact[index].phone.toByteArray()
      for (valueIndex in phoneBytes.indices) {
        if (valueIndex < 16) {
          bytes[index * 40 + 24 + valueIndex] = phoneBytes[valueIndex]
        }
      }
    }
  //  LogUtils.d(bytes.mHexString)
    return bytes
  }

  private fun unbindCompleted() {

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    BleConnector.removeHandleCallback(mBleHandleCallback)
    mBleScanner.exit()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }


  private val scanResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        scanSink = eventSink
      }
    }

    override fun onCancel(o: Any?) {

    }
  }

}
