package id.kakzaki.smartble_sdk

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.Intent
import android.os.*
import android.text.format.DateFormat
import android.util.Log
import androidx.multidex.BuildConfig
import com.bestmafen.baseble.scanner.BleDevice
import com.bestmafen.baseble.scanner.BleScanCallback
import com.bestmafen.baseble.scanner.BleScanFilter
import com.bestmafen.baseble.scanner.ScannerFactory
import com.blankj.utilcode.constant.PermissionConstants
import com.blankj.utilcode.util.*
import com.blankj.utilcode.util.ActivityUtils.startActivity
import com.google.gson.Gson
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.*
import com.szabh.smable3.entity.*
import com.szabh.smable3.entity.BleAlarm
import com.szabh.smable3.watchface.Element
import com.szabh.smable3.watchface.WatchFaceBuilder
import id.kakzaki.smartble_sdk.activity.MusicControlActivity
import id.kakzaki.smartble_sdk.activity.WatchFaceActivity
import id.kakzaki.smartble_sdk.tools.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.InputStream
import java.net.URL
import java.util.*
import kotlin.random.Random


/** SmartbleSdkPlugin */
class  SmartbleSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var mContext: Context?=null
  private var mActivity: Activity?=null
  private var pluginBinding: FlutterPluginBinding? = null
  private var activityBinding: ActivityPluginBinding? = null

  private val ID_ALL = 0xff
  private lateinit var mBleKey: BleKey
  private lateinit var mBleKeyFlag: BleKeyFlag
  private var mType = 0
  data class Contact(var name: String, var phone: String)
  private var mLocationTimes = 1
  private var mClassicBluetoothState = 2
  private var sportState = BleAppSportState.STATE_START

  private lateinit var channel : MethodChannel

  private var scanChannel : EventChannel?=null
  private lateinit var scanSink: EventSink
  private var onDeviceConnectedChannel : EventChannel?=null
  private var onDeviceConnectedSink: EventSink?=null
  private var onIdentityCreateChannel : EventChannel?=null
  private var onIdentityCreateSink: EventSink?=null
  private var onCommandReplyChannel : EventChannel?=null
  private var onCommandReplySink: EventSink?=null
  private var onOTAChannel : EventChannel?=null
  private var onOTASink: EventSink?=null
  private var onReadPowerChannel : EventChannel?=null
  private var onReadPowerSink: EventSink?=null
  private var onReadFirmwareVersionChannel : EventChannel?=null
  private var onReadFirmwareVersionSink: EventSink?=null
  private var onReadBleAddressChannel : EventChannel?=null
  private var onReadBleAddressSink: EventSink?=null
  private var onReadSedentarinessChannel : EventChannel?=null
  private var onReadSedentarinessSink: EventSink?=null
  private var onReadNoDisturbChannel : EventChannel?=null
  private var onReadNoDisturbSink: EventSink?=null
  private var onReadAlarmChannel : EventChannel?=null
  private var onReadAlarmSink: EventSink?=null
  private var onReadCoachingIdsChannel : EventChannel?=null
  private var onReadCoachingIdsSink: EventSink?=null
  private var onReadUiPackVersionChannel : EventChannel?=null
  private var onReadUiPackVersionSink: EventSink?=null
  private var onReadLanguagePackVersionChannel : EventChannel?=null
  private var onReadLanguagePackVersionSink: EventSink?=null
  private var onIdentityDeleteByDeviceChannel : EventChannel?=null
  private var onIdentityDeleteByDeviceSink: EventSink?=null
  private var onCameraStateChangeChannel : EventChannel?=null
  private var onCameraStateChangeSink: EventSink?=null
  private var onCameraResponseChannel : EventChannel?=null
  private var onCameraResponseSink: EventSink?=null
  private var onSyncDataChannel : EventChannel?=null
  private var onSyncDataSink: EventSink?=null
  private var onReadActivityChannel : EventChannel?=null
  private var onReadActivitySink: EventSink?=null
  private var onReadHeartRateChannel : EventChannel?=null
  private var onReadHeartRateSink: EventSink?=null
  private var onUpdateHeartRateChannel : EventChannel?=null
  private var onUpdateHeartRateSink: EventSink?=null
  private var onReadBloodPressureChannel : EventChannel?=null
  private var onReadBloodPressureSink: EventSink?=null
  private var onReadSleepChannel : EventChannel?=null
  private var onReadSleepSink: EventSink?=null
  private var onReadLocationChannel : EventChannel?=null
  private var onReadLocationSink: EventSink?=null
  private var onReadTemperatureChannel : EventChannel?=null
  private var onReadTemperatureSink: EventSink?=null
  private var onReadWorkout2Channel : EventChannel?=null
  private var onReadWorkout2Sink: EventSink?=null
  private var onStreamProgressChannel : EventChannel?=null
  private var onStreamProgressSink: EventSink?=null
  private var onUpdateAppSportStateChannel : EventChannel?=null
  private var onUpdateAppSportStateSink: EventSink?=null
  private var onClassicBluetoothStateChangeChannel : EventChannel?=null
  private var onClassicBluetoothStateChangeSink: EventSink?=null
  private var onDeviceFileUpdateChannel : EventChannel?=null
  private var onDeviceFileUpdateSink: EventSink?=null
  private var onReadDeviceFileChannel : EventChannel?=null
  private var onReadDeviceFileSink: EventSink?=null
  private var onReadTemperatureUnitChannel : EventChannel?=null
  private var onReadTemperatureUnitSink: EventSink?=null
  private var onReadDateFormatChannel : EventChannel?=null
  private var onReadDateFormatSink: EventSink?=null
  private var onReadWatchFaceSwitchChannel : EventChannel?=null
  private var onReadWatchFaceSwitchSink: EventSink?=null
  private var onUpdateWatchFaceSwitchChannel : EventChannel?=null
  private var onUpdateWatchFaceSwitchSink: EventSink?=null
  private var onAppSportDataResponseChannel : EventChannel?=null
  private var onAppSportDataResponseSink: EventSink?=null
  private var onReadWatchFaceIdChannel : EventChannel?=null
  private var onReadWatchFaceIdSink: EventSink?=null
  private var onWatchFaceIdUpdateChannel : EventChannel?=null
  private var onWatchFaceIdUpdateSink: EventSink?=null
  private var onHIDStateChannel : EventChannel?=null
  private var onHIDStateSink: EventSink?=null
  private var onHIDValueChangeChannel : EventChannel?=null
  private var onHIDValueChangeSink: EventSink?=null
  private var onDeviceSMSQuickReplyChannel : EventChannel?=null
  private var onDeviceSMSQuickReplySink: EventSink?=null
  private var onReadDeviceInfoChannel : EventChannel?=null
  private var onReadDeviceInfoSink: EventSink?=null
  private var onSessionStateChangeChannel : EventChannel?=null
  private var onSessionStateChangeSink: EventSink?=null
  private var onNoDisturbUpdateChannel : EventChannel?=null
  private var onNoDisturbUpdateSink: EventSink?=null
  private var onAlarmUpdateChannel : EventChannel?=null
  private var onAlarmUpdateSink: EventSink?=null
  private var onAlarmDeleteChannel : EventChannel?=null
  private var onAlarmDeleteSink: EventSink?=null
  private var onAlarmAddChannel : EventChannel?=null
  private var onAlarmAddSink: EventSink?=null
  private var onFindPhoneChannel : EventChannel?=null
  private var onFindPhoneSink: EventSink?=null
  private var onRequestLocationChannel : EventChannel?=null
  private var onRequestLocationSink: EventSink?=null
  private var onDeviceRequestAGpsFileChannel : EventChannel?=null
  private var onDeviceRequestAGpsFileSink: EventSink?=null
  private var onReadBloodOxygenChannel : EventChannel?=null
  private var onReadBloodOxygenSink: EventSink?=null
  private var onReadWorkoutChannel : EventChannel?=null
  private var onReadWorkoutSink: EventSink?=null
  private var onReadBleHrvChannel : EventChannel?=null
  private var onReadBleHrvSink: EventSink?=null
  private var onReadPressureChannel : EventChannel?=null
  private var onReadPressureSink: EventSink?=null
  private var onDeviceConnectingChannel : EventChannel?=null
  private var onDeviceConnectingSink: EventSink?=null
  private var onIncomingCallStatusChannel : EventChannel?=null
  private var onIncomingCallStatusSink: EventSink?=null

  private var mResult: Result? = null
  private val mDevices = mutableListOf<Any>()
  private val mBleScanner by lazy {
    // ScannerFactory.newInstance(arrayOf(UUID.fromString(BleConnector.BLE_SERVICE)))
    ScannerFactory.newInstance()
      .setScanDuration(30)
      .setScanFilter(object : BleScanFilter {

        override fun match(device: BleDevice): Boolean {
          //Filter the Bluetooth signal value, the larger the signal value, the stronger the signal, for example -66 > -88
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
        val item: MutableMap<String, Any> = HashMap()
        if(device!=null){
          item["deviceName"] = device.name
          item["deviceMacAddress"] = device.address
          if(onDeviceConnectedSink!=null){
            onDeviceConnectedSink!!.success(item)
          }
        }
      }

      override fun onIdentityCreate(status: Boolean, deviceInfo: BleDeviceInfo?) {
        if (status) {
          BleConnector.connectClassic()
        }
        if (BuildConfig.DEBUG) {
          Log.d("onIdentityCre","$status")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        item["deviceInfo"] = gson.toJson(deviceInfo)
        if(onIdentityCreateSink!=null)
          onIdentityCreateSink!!.success(item)
      }

      override fun onCommandReply(bleKey: BleKey, bleKeyFlag: BleKeyFlag, status: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onCommandReply","$bleKey $bleKeyFlag -> $status")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        item["bleKey"] = gson.toJson(bleKey)
        item["bleKeyFlag"] = gson.toJson(bleKeyFlag)
        if(onCommandReplySink!=null)
          onCommandReplySink!!.success(item)
      }

      override fun onOTA(status: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onOTA","$status")
        }
        if (!status) return

        if (mContext != null) {
          //FirmwareHelper.gotoOtaReally(mContext)
        }
      }

      override fun onReadMtkOtaMeta() {
        if (mContext != null) {
         // FirmwareHelper.gotoOtaReally(mContext)
        }
      }

      override fun onReadPower(power: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadPower","$power")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["power"] = power
        if(onReadPowerSink!=null)
          onReadPowerSink!!.success(item)
      }

      override fun onReadFirmwareVersion(version: String) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadFirmware", version)
        }
        val item: MutableMap<String, Any> = HashMap()
        item["version"] = version
        if(onReadFirmwareVersionSink!=null)
          onReadFirmwareVersionSink!!.success(item)
      }

      override fun onReadBleAddress(address: String) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadBleAddress", address)
        }
        val item: MutableMap<String, Any> = HashMap()
        item["address"] = address
        if(onReadBleAddressSink!=null)
          onReadBleAddressSink!!.success(item)
      }

      override fun onReadSedentariness(sedentarinessSettings: BleSedentarinessSettings) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadSedentariness","$sedentarinessSettings")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["sedentarinessSettings"] = gson.toJson(sedentarinessSettings)
        if(onReadSedentarinessSink!=null)
          onReadSedentarinessSink!!.success(item)
      }

      override fun onReadNoDisturb(noDisturbSettings: BleNoDisturbSettings) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadNoDisturb","$noDisturbSettings")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["noDisturbSettings"] = gson.toJson(noDisturbSettings)
        if(onReadNoDisturbSink!=null)
          onReadNoDisturbSink!!.success(item)
      }

      override fun onReadAlarm(alarms: List<BleAlarm>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadAlarm","$alarms")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["alarms"] = gson.toJson(alarms)
        if(onReadAlarmSink!=null)
          onReadAlarmSink!!.success(item)
      }

      override fun onReadCoachingIds(bleCoachingIds: BleCoachingIds) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadCoachingIds","$bleCoachingIds")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["onReadCoachingIds"] = gson.toJson(bleCoachingIds)
        if(onReadCoachingIdsSink!=null)
          onReadCoachingIdsSink!!.success(item)
      }

      override fun onReadUiPackVersion(version: String) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadUiPackVersion","$version")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["version"] = version
        if(onReadUiPackVersionSink!=null)
          onReadUiPackVersionSink!!.success(item)
      }

      override fun onReadLanguagePackVersion(version: BleLanguagePackVersion) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadLanguagePackVersi","$version")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["version"] = version
        if(onReadLanguagePackVersionSink!=null)
          onReadLanguagePackVersionSink!!.success(item)
      }


      override fun onIdentityDeleteByDevice(isDevice: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onIdentityDeleteByDevic","$isDevice")
        }
        BleConnector.unbind()
        unbindCompleted()
        val item: MutableMap<String, Any> = HashMap()
        item["isDevice"] = isDevice
        if(onIdentityDeleteByDeviceSink!=null)
          onIdentityDeleteByDeviceSink!!.success(item)
      }

      override fun onCameraStateChange(cameraState: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onCameraStateChange","${CameraState.getState(cameraState)}")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["cameraState"] = cameraState
        item["cameraStateName"] = "${CameraState.getState(cameraState)}"
        if(onCameraStateChangeSink!=null)
          onCameraStateChangeSink!!.success(item)
      }

      override fun onCameraResponse(status: Boolean, cameraState: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onCameraResponse","$status ${CameraState.getState(cameraState)}")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        item["cameraState"] = cameraState
        item["cameraStateName"] = "${CameraState.getState(cameraState)}"
        if(onCameraResponseSink!=null)
          onCameraResponseSink!!.success(item)
      }

      override fun onSyncData(syncState: Int, bleKey: BleKey) {
        if (BuildConfig.DEBUG) {
          Log.d("onSyncData","syncState=$syncState, bleKey=$bleKey")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["syncState"] = syncState
        item["bleKey"] = gson.toJson(bleKey)
        if(onSyncDataSink!=null)
          onSyncDataSink!!.success(item)
      }
      val gson = Gson()
      override fun onReadActivity(activities: List<BleActivity>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadActivity","$activities")
        }
//        var activitiesDecode: MutableList<Any> = ArrayList()
//        for(e in activities){
//          activitiesDecode.add(e.decode())
//        }
        val item: MutableMap<String, Any> = HashMap()

        item["activities"] = gson.toJson(activities)
        if(onReadActivitySink!=null)
          onReadActivitySink!!.success(item)
      }

      override fun onReadHeartRate(heartRates: List<BleHeartRate>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadHeartRate","$heartRates")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["heartRates"] = gson.toJson(heartRates)
        if(onReadHeartRateSink!=null)
          onReadHeartRateSink!!.success(item)
      }

      override fun onUpdateHeartRate(heartRate: BleHeartRate) {
        if (BuildConfig.DEBUG) {
          Log.d("onUpdateHeartRate","$heartRate")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["heartRate"] = gson.toJson(heartRate)
        if(onUpdateHeartRateSink!=null)
          onUpdateHeartRateSink!!.success(item)
      }

      override fun onReadBloodPressure(bloodPressures: List<BleBloodPressure>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadBloodPressure","$bloodPressures")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["bloodPressures"] = gson.toJson(bloodPressures)
        if(onReadBloodPressureSink!=null)
          onReadBloodPressureSink!!.success(item)
        // print( "$bloodPressures")
      }

      override fun onReadSleep(sleeps: List<BleSleep>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadSleep","$sleeps")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["sleeps"] = gson.toJson(sleeps)
        if(onReadSleepSink!=null)
          onReadSleepSink!!.success(item)
      }

      override fun onReadLocation(locations: List<BleLocation>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadLocation","$locations")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["locations"] = gson.toJson(locations)
        if(onReadLocationSink!=null)
          onReadLocationSink!!.success(item)
      }

      override fun onReadTemperature(temperatures: List<BleTemperature>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadTemperature","$temperatures")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["temperatures"] = gson.toJson(temperatures)
        if(onReadTemperatureSink!=null)
          onReadTemperatureSink!!.success(item)
      }

      override fun onReadWorkout2(workouts: List<BleWorkout2>) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadWorkout2","$workouts")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["workouts"] = gson.toJson(workouts)
        if(onReadWorkout2Sink!=null)
          onReadWorkout2Sink!!.success(item)
      }

      override fun onStreamProgress(
        status: Boolean,
        errorCode: Int,
        total: Int,
        completed: Int
      ) {
        if (BuildConfig.DEBUG) {
          Log.d("onStreamProgress","$status $errorCode $total $completed")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        item["errorCode"] = errorCode
        item["total"] = total
        item["completed"] = completed
        if(onStreamProgressSink!=null)
          onStreamProgressSink!!.success(item)
      }


      override fun onIncomingCallStatus(status: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onIncomingCallStatus","$status ${if (status == 0) "Answer" else "Reject"}")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        item["message"] = if (status == 0) "Answer" else "Reject"
        if(onIncomingCallStatusSink!=null){
          onIncomingCallStatusSink!!.success(item)
        }
      }

      override fun onUpdateAppSportState(appSportState: BleAppSportState) {
        if (BuildConfig.DEBUG) {
          Log.d("onUpdateAppSportState","$appSportState")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["appSportState"] = gson.toJson(appSportState)
        if(onUpdateAppSportStateSink!=null)
          onUpdateAppSportStateSink!!.success(item)
      }

      override fun onClassicBluetoothStateChange(state: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onClassicBluetoot","$state")
        }
        print( ClassicBluetoothState.getState(state))
        mClassicBluetoothState = state
        val item: MutableMap<String, Any> = HashMap()
        item["state"] = state
        if(onClassicBluetoothStateChangeSink!=null)
          onClassicBluetoothStateChangeSink!!.success(item)
      }

      override fun onDeviceFileUpdate(deviceFile: BleDeviceFile) {
        if (BuildConfig.DEBUG) {
          Log.d("onDeviceFileUpdate","$deviceFile")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["deviceFile"] = gson.toJson(deviceFile)
        if(onDeviceFileUpdateSink!=null)
          onDeviceFileUpdateSink!!.success(item)
      }

      override fun onReadDeviceFile(deviceFile: BleDeviceFile) {
        if (deviceFile.mFileSize != 0) {
          BleConnector.sendData(BleKey.DEVICE_FILE, BleKeyFlag.READ_CONTINUE)
        }
        if (BuildConfig.DEBUG) {
          Log.d("onReadDeviceFile","$deviceFile")
        }
        FileIOUtils.writeFileFromBytesByStream(
          File(PathUtils.getExternalAppDataPath() + "/voice/${deviceFile.mTime}.wav"),
          deviceFile.mFileContent,
          true
        )
        val item: MutableMap<String, Any> = HashMap()
        item["deviceFile"] = gson.toJson(deviceFile)
        if(onReadDeviceFileSink!=null)
          onReadDeviceFileSink!!.success(item)
      }

      override fun onReadTemperatureUnit(value: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadTemperatureUnit","$value")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["value"] = value
        if(onReadTemperatureUnitSink!=null)
          onReadTemperatureUnitSink!!.success(item)
      }

      override fun onReadDateFormat(value: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadDateFormat","$value")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["value"] = value
        if(onReadDateFormatSink!=null)
          onReadDateFormatSink!!.success(item)
      }

      override fun onReadWatchFaceSwitch(value: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadWatchFaceSwitch","$value")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["value"] = value
        if(onReadWatchFaceSwitchSink!=null)
          onReadWatchFaceSwitchSink!!.success(item)
      }

      override fun onUpdateWatchFaceSwitch(status: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onUpdateWatchFaceSwitch","$status")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        if(onUpdateWatchFaceSwitchSink!=null)
          onUpdateWatchFaceSwitchSink!!.success(item)
      }

      override fun onAppSportDataResponse(status: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onAppSportDataResponse","$status")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        if(onAppSportDataResponseSink!=null)
          onAppSportDataResponseSink!!.success(item)
      }

      override fun onReadWatchFaceId(watchFaceId: BleWatchFaceId) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadWatchFaceId","${watchFaceId.mIdList}")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["watchFaceId"] = gson.toJson(watchFaceId)
        if(onReadWatchFaceIdSink!=null)
          onReadWatchFaceIdSink!!.success(item)
      }

      override fun onWatchFaceIdUpdate(status: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onWatchFaceIdUpdate","$status")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        if(onWatchFaceIdUpdateSink!=null)
          onWatchFaceIdUpdateSink!!.success(item)
        //chooseFile(mContext, BleKey.WATCH_FACE.mKey)
      }

      override fun onHIDState(state: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onHIDState","$state")
        }
        if(state == HIDState.DISCONNECTED){
          BleConnector.connectHID()
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = state
        if(onHIDStateSink!=null)
          onHIDStateSink!!.success(item)
      }

      override fun onHIDValueChange(value: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onHIDValueChange","$value")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["value"] = value
        if(onHIDValueChangeSink!=null)
          onHIDValueChangeSink!!.success(item)
      }

      override fun onDeviceSMSQuickReply(smsQuickReply: BleSMSQuickReply) {
        if (BuildConfig.DEBUG) {
          Log.d("onDeviceSMSQuickReply", smsQuickReply.toString())
        }
        val item: MutableMap<String, Any> = HashMap()
        item["smsQuickReply"] = gson.toJson(smsQuickReply)
        if(onDeviceSMSQuickReplySink!=null)
          onDeviceSMSQuickReplySink!!.success(item)
      }

      override fun onReadDeviceInfo(deviceInfo: BleDeviceInfo) {
        if (BuildConfig.DEBUG) {
          Log.d("onReadDeviceInfo","$deviceInfo")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["deviceInfo"] = gson.toJson(deviceInfo)
        if(onReadDeviceInfoSink!=null)
          onReadDeviceInfoSink!!.success(item)
      }

      override fun onSessionStateChange(status: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onSessionStateChange","$status")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        if(onSessionStateChangeSink!=null)
          onSessionStateChangeSink!!.success(item)
      }

      override fun onNoDisturbUpdate(noDisturbSettings: BleNoDisturbSettings) {
        if (BuildConfig.DEBUG) {
          Log.d("onNoDisturbUpdate","$noDisturbSettings")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["noDisturbSettings"] = gson.toJson(noDisturbSettings)
        if(onNoDisturbUpdateSink!=null)
          onNoDisturbUpdateSink!!.success(item)
      }

      override fun onAlarmUpdate(alarm: BleAlarm) {
        if (BuildConfig.DEBUG) {
          Log.d("onAlarmUpdate","$alarm")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["alarm"] = gson.toJson(alarm)
        if(onAlarmUpdateSink!=null)
          onAlarmUpdateSink!!.success(item)
      }

      override fun onAlarmDelete(id: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onAlarmDelete","$id")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["id"] = id
        if(onAlarmDeleteSink!=null)
          onAlarmDeleteSink!!.success(item)
      }

      override fun onAlarmAdd(alarm: BleAlarm) {
        if (BuildConfig.DEBUG) {
          Log.d("onAlarmAdd","$alarm")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["alarm"] = gson.toJson(alarm)
        if(onAlarmAddSink!=null)
          onAlarmAddSink!!.success(item)
      }

      override fun onFindPhone(start: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onFindPhone","onFindPhone ${if (start) "started" else "stopped"}")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["start"] = start
        if(onFindPhoneSink!=null)
          onFindPhoneSink!!.success(item)
      }

      override fun onRequestLocation(workoutState: Int) {
        if (BuildConfig.DEBUG) {
          Log.d("onRequestLocation","${WorkoutState.getState(workoutState)}")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["workoutState"] = workoutState
        if(onRequestLocationSink!=null)
          onRequestLocationSink!!.success(item)
      }

      override fun onDeviceRequestAGpsFile(url: String) {
        if (BuildConfig.DEBUG) {
          Log.d("onDeviceRequestAGpsFile", url)
        }
        val item: MutableMap<String, Any> = HashMap()
        item["url"] = url
        if(onDeviceRequestAGpsFileSink!=null)
          onDeviceRequestAGpsFileSink!!.success(item)
        // 以下是示例代码，sdk中的文件会过期，只是用于演示
//        when (BleCache.mAGpsType) {
//          1 -> BleConnector.sendStream(BleKey.AGPS_FILE, assets.open("type1_epo_gr_3_1.dat"))
//          2 -> BleConnector.sendStream(BleKey.AGPS_FILE, assets.open("type2_current_1d.alp"))
//          6 -> BleConnector.sendStream(BleKey.AGPS_FILE, assets.open("type6_ble_epo_offline.bin"))
//        }
        // 实际工程要从url下载aGps文件，然后发送该aGps文件
        // val file = download(url)
        // BleConnector.sendStream(BleKey.AGPS_FILE, file)
      }


      override fun onReadBloodOxygen(bloodOxygen: List<BleBloodOxygen>){
        if (BuildConfig.DEBUG) {
          Log.d("onReadBloodOxygen","$bloodOxygen")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["bloodOxygen"] = gson.toJson(bloodOxygen)
        if(onReadBloodOxygenSink!=null)
          onReadBloodOxygenSink!!.success(item)
      }

      override fun onReadWorkout(workouts: List<BleWorkout>){
        if (BuildConfig.DEBUG) {
          Log.d("onReadWorkout","$workouts")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["workouts"] = gson.toJson(workouts)
        if(onReadWorkoutSink!=null)
          onReadWorkoutSink!!.success(item)
      }

      override fun onReadBleHrv(hrv: List<BleHrv>){
        if (BuildConfig.DEBUG) {
          Log.d("onReadBleHrv","$hrv")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["hrv"] = gson.toJson(hrv)
        if(onReadBleHrvSink!=null)
          onReadBleHrvSink!!.success(item)
      }

      override fun onReadPressure(pressures: List<BlePressure>){
        if (BuildConfig.DEBUG) {
          Log.d("onReadPressure","$pressures")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["pressures"] = gson.toJson(pressures)
        if(onReadPressureSink!=null)
          onReadPressureSink!!.success(item)
      }


      override fun onDeviceConnecting(status: Boolean) {
        if (BuildConfig.DEBUG) {
          Log.d("onDeviceConnecting","$status")
        }
        val item: MutableMap<String, Any> = HashMap()
        item["status"] = status
        if(onDeviceConnectingSink!=null){
          onDeviceConnectingSink!!.success(item)
        }
      }

    }
  }


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
    pluginBinding=flutterPluginBinding
    mContext=flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "smartble_sdk")
    channel.setMethodCallHandler(this)
    scanChannel = EventChannel(flutterPluginBinding.binaryMessenger, "smartble_sdk/scan")
    scanChannel!!.setStreamHandler(scanResultsHandler)
    onDeviceConnectedChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onDeviceConnected")
    onDeviceConnectedChannel!!.setStreamHandler(onDeviceConnectedResultsHandler)
    onIdentityCreateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onIdentityCreate")
    onIdentityCreateChannel!!.setStreamHandler(onIdentityCreateResultsHandler)
    onCommandReplyChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onCommandReply")
    onCommandReplyChannel!!.setStreamHandler(onCommandReplyResultsHandler)
    onOTAChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onOTA")
    onOTAChannel!!.setStreamHandler(onOTAResultsHandler)
    onReadPowerChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadPower")
    onReadPowerChannel!!.setStreamHandler(onReadPowerResultsHandler)
    onReadFirmwareVersionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadFirmwareVersion")
    onReadFirmwareVersionChannel!!.setStreamHandler(onReadFirmwareVersionResultsHandler)
    onReadBleAddressChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadBleAddress")
    onReadBleAddressChannel!!.setStreamHandler(onReadBleAddressResultsHandler)
    onReadSedentarinessChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadSedentariness")
    onReadSedentarinessChannel!!.setStreamHandler(onReadSedentarinessResultsHandler)
    onReadNoDisturbChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadNoDisturb")
    onReadNoDisturbChannel!!.setStreamHandler(onReadNoDisturbResultsHandler)
    onReadAlarmChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadAlarm")
    onReadAlarmChannel!!.setStreamHandler(onReadAlarmResultsHandler)
    onReadCoachingIdsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadCoachingIds")
    onReadCoachingIdsChannel!!.setStreamHandler(onReadCoachingIdsResultsHandler)
    onReadUiPackVersionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadUiPackVersion")
    onReadUiPackVersionChannel!!.setStreamHandler(onReadUiPackVersionResultsHandler)
    onReadLanguagePackVersionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadLanguagePackVersion")
    onReadLanguagePackVersionChannel!!.setStreamHandler(onReadLanguagePackVersionResultsHandler)
    onIdentityDeleteByDeviceChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onIdentityDeleteByDevice")
    onIdentityDeleteByDeviceChannel!!.setStreamHandler(onIdentityDeleteByDeviceResultsHandler)
    onCameraStateChangeChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onCameraStateChange")
    onCameraStateChangeChannel!!.setStreamHandler(onCameraStateChangeResultsHandler)
    onCameraResponseChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onCameraResponse")
    onCameraResponseChannel!!.setStreamHandler(onCameraResponseResultsHandler)
    onSyncDataChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onSyncData")
    onSyncDataChannel!!.setStreamHandler(onSyncDataResultsHandler)
    onReadActivityChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadActivity")
    onReadActivityChannel!!.setStreamHandler(onReadActivityResultsHandler)
    onReadHeartRateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadHeartRate")
    onReadHeartRateChannel!!.setStreamHandler(onReadHeartRateResultsHandler)
    onUpdateHeartRateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onUpdateHeartRate")
    onUpdateHeartRateChannel!!.setStreamHandler(onUpdateHeartRateResultsHandler)
    onReadBloodPressureChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadBloodPressure")
    onReadBloodPressureChannel!!.setStreamHandler(onReadBloodPressureResultsHandler)
    onReadSleepChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadSleep")
    onReadSleepChannel!!.setStreamHandler(onReadSleepResultsHandler)
    onReadLocationChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadLocation")
    onReadLocationChannel!!.setStreamHandler(onReadLocationResultsHandler)
    onReadTemperatureChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadTemperature")
    onReadTemperatureChannel!!.setStreamHandler(onReadTemperatureResultsHandler)
    onReadWorkout2Channel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadWorkout2")
    onReadWorkout2Channel!!.setStreamHandler(onReadWorkout2ResultsHandler)
    onStreamProgressChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onStreamProgress")
    onStreamProgressChannel!!.setStreamHandler(onStreamProgressResultsHandler)
    onUpdateAppSportStateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onUpdateAppSportState")
    onUpdateAppSportStateChannel!!.setStreamHandler(onUpdateAppSportStateResultsHandler)
    onClassicBluetoothStateChangeChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onClassicBluetoothStateChange")
    onClassicBluetoothStateChangeChannel!!.setStreamHandler(onClassicBluetoothStateChangeResultsHandler)
    onDeviceFileUpdateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onDeviceFileUpdate")
    onDeviceFileUpdateChannel!!.setStreamHandler(onDeviceFileUpdateResultsHandler)
    onReadDeviceFileChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadDeviceFile")
    onReadDeviceFileChannel!!.setStreamHandler(onReadDeviceFileResultsHandler)
    onReadTemperatureUnitChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadTemperatureUnit")
    onReadTemperatureUnitChannel!!.setStreamHandler(onReadTemperatureUnitResultsHandler)
    onReadDateFormatChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadDateFormat")
    onReadDateFormatChannel!!.setStreamHandler(onReadDateFormatResultsHandler)
    onReadWatchFaceSwitchChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadWatchFaceSwitch")
    onReadWatchFaceSwitchChannel!!.setStreamHandler(onReadWatchFaceSwitchResultsHandler)
    onUpdateWatchFaceSwitchChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onUpdateWatchFaceSwitch")
    onUpdateWatchFaceSwitchChannel!!.setStreamHandler(onUpdateWatchFaceSwitchResultsHandler)
    onAppSportDataResponseChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onAppSportDataResponse")
    onAppSportDataResponseChannel!!.setStreamHandler(onAppSportDataResponseResultsHandler)
    onReadWatchFaceIdChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadWatchFaceId")
    onReadWatchFaceIdChannel!!.setStreamHandler(onReadWatchFaceIdResultsHandler)
    onWatchFaceIdUpdateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onWatchFaceIdUpdate")
    onWatchFaceIdUpdateChannel!!.setStreamHandler(onWatchFaceIdUpdateResultsHandler)
    onHIDStateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onHIDState")
    onHIDStateChannel!!.setStreamHandler(onHIDStateResultsHandler)
    onHIDValueChangeChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onHIDValueChange")
    onHIDValueChangeChannel!!.setStreamHandler(onHIDValueChangeResultsHandler)
    onDeviceSMSQuickReplyChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onDeviceSMSQuickReply")
    onDeviceSMSQuickReplyChannel!!.setStreamHandler(onDeviceSMSQuickReplyResultsHandler)
    onReadDeviceInfoChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadDeviceInfo")
    onReadDeviceInfoChannel!!.setStreamHandler(onReadDeviceInfoResultsHandler)
    onSessionStateChangeChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onSessionStateChange")
    onSessionStateChangeChannel!!.setStreamHandler(onSessionStateChangeResultsHandler)
    onNoDisturbUpdateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onNoDisturbUpdate")
    onNoDisturbUpdateChannel!!.setStreamHandler(onNoDisturbUpdateResultsHandler)
    onAlarmUpdateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onAlarmUpdate")
    onAlarmUpdateChannel!!.setStreamHandler(onAlarmUpdateResultsHandler)
    onAlarmDeleteChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onAlarmDelete")
    onAlarmDeleteChannel!!.setStreamHandler(onAlarmDeleteResultsHandler)
    onAlarmAddChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onAlarmAdd")
    onAlarmAddChannel!!.setStreamHandler(onAlarmAddResultsHandler)
    onFindPhoneChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onFindPhone")
    onFindPhoneChannel!!.setStreamHandler(onFindPhoneResultsHandler)
    onRequestLocationChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onRequestLocation")
    onRequestLocationChannel!!.setStreamHandler(onRequestLocationResultsHandler)
    onDeviceRequestAGpsFileChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onDeviceRequestAGpsFile")
    onDeviceRequestAGpsFileChannel!!.setStreamHandler(onDeviceRequestAGpsFileResultsHandler)
    onReadBloodOxygenChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadBloodOxygen")
    onReadBloodOxygenChannel!!.setStreamHandler(onReadBloodOxygenResultsHandler)
    onReadWorkoutChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadWorkout")
    onReadWorkoutChannel!!.setStreamHandler(onReadWorkoutResultsHandler)
    onReadBleHrvChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadBleHrv")
    onReadBleHrvChannel!!.setStreamHandler(onReadBleHrvResultsHandler)
    onReadPressureChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onReadPressure")
    onReadPressureChannel!!.setStreamHandler(onReadPressureResultsHandler)
    onDeviceConnectingChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onDeviceConnecting")
    onDeviceConnectingChannel!!.setStreamHandler(onDeviceConnectingResultsHandler)
    onIncomingCallStatusChannel = EventChannel(flutterPluginBinding.binaryMessenger, "onIncomingCallStatus")
    onIncomingCallStatusChannel!!.setStreamHandler(onIncomingCallStatusResultsHandler)
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
//          connector.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)
//          connector.sendInt8(BleKey.LANGUAGE, BleKeyFlag.UPDATE, Languages.languageToCode())
//          connector.sendData(BleKey.MUSIC_CONTROL, BleKeyFlag.READ)
        }
      }
    })
    BleConnector.addHandleCallback(mBleHandleCallback)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
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
                val isScan : Boolean? = call.argument<Boolean>("isScan")
                if (isScan != null) {
                  mBleScanner.scan(isScan)
                }
              }
            }
        } else {
          PermissionUtils
            .permission(PermissionConstants.LOCATION)
            .require(Manifest.permission.ACCESS_FINE_LOCATION) { granted ->
              if (granted) {
                val isScan : Boolean? = call.argument<Boolean>("isScan")
                if (isScan != null) {
                  mBleScanner.scan(isScan)
                }
              }
            }
        }
      }
      "setAddress" -> {
        mBleScanner.scan(false)
          val bmac : String? = call.argument<String>("bmac")
          if (bmac != null) {
            BleConnector.setAddress(bmac)
          }
      }
      "connect" -> {
        BleConnector.connect(true)
      }
      "isConnecting" -> {
        result.success(BleConnector.isConnecting)
      }
      "isNeedBind" -> {
        result.success(BleConnector.isNeedBind)
      }
      "connectHID" -> {
        BleConnector.connectHID();
      }
      "connectClassic" -> {
        BleConnector.connectClassic();
      }
      "closeConnection" -> {
        BleConnector.closeConnection(stopReconnecting = true);
      }
      "unbind" -> {
        BleConnector.unbind();
      }
      "analyzeSleep" -> {
        val listSleep : List<Map<String, Int>>? = call.argument<List<Map<String, Int>>>("listSleep")
        if (listSleep != null) {
          val listNew = ArrayList<BleSleep>()
          for (item in listSleep) {
            val bleS=BleSleep(mTime =  item["mTime"]!!, mMode =item["mMode"]!! , mSoft = item["mSoft"]!!, mStrong =item["mStrong"]!! )
            listNew.add(bleS)
          }
          val res = BleSleep.getSleepStatusDuration(sleeps = BleSleep.analyseSleep(listNew), origin = listNew)
          result.success(res);
        }
      }
      "customDials" -> {
        var imageFormat = WatchFaceBuilder.PNG_ARGB_8888
        var DIAL_CUSTOMIZE_DIR = "dial_customize_454"
        var screenWidth = 0 //The actual size of the device screen - width
        var screenHeight = 0 //The actual size of the device screen - height
        var screenPreviewWidth = 0 //The actual preview size of the device screen - width
        var screenPreviewHeight = 0 //The actual preview size of the device screen - height
        var X_CENTER = WatchFaceBuilder.GRAVITY_X_CENTER //Relative coordinate mark, MTK and Realtek have different implementations
        var Y_CENTER = WatchFaceBuilder.GRAVITY_Y_CENTER //Relative coordinate mark, MTK and Realtek have different implementations

        val elements = ArrayList<Element>()
        val bgPreviewBytes : ByteArray? = call.argument<ByteArray?>("bgPreviewBytes")
        val custom : Int? = call.argument<Int>("custom")
        val isDigital : Boolean? = call.argument<Boolean>("isDigital")

        if (custom == 2) {
          DIAL_CUSTOMIZE_DIR = "dial_customize_454"
          screenWidth = 454
          screenHeight = 454
          screenPreviewWidth = 280
          screenPreviewHeight = 280
        } else {
          DIAL_CUSTOMIZE_DIR = "dial_customize_240"
          screenWidth = 240
          screenHeight = 240
          screenPreviewWidth = 150
          screenPreviewHeight = 150
        }

        // get the background preview
        val elementPreview = Element(
          type = WatchFaceBuilder.ELEMENT_PREVIEW,
          w = screenPreviewWidth, //预览的尺寸为
          h = screenPreviewHeight,
          gravity = X_CENTER or Y_CENTER,
          x = screenWidth / 2,
          y = screenHeight / 2 + 2,
          imageBuffers = arrayOf(bgPreviewBytes!!)
        )
        elements.add(elementPreview)

        // get the backgroundsize
        val bgBytes : ByteArray? = call.argument<ByteArray?>("bgBytes")
        val elementBg = Element(
          type = WatchFaceBuilder.ELEMENT_BACKGROUND,
          w = screenWidth, //背景的尺寸
          h = screenHeight,
          gravity = X_CENTER or Y_CENTER,
          x = screenWidth / 2,
          y = screenHeight / 2,
          imageBuffers = arrayOf(bgBytes!!)
        )
        elements.add(elementBg)

//        // Get time related content
//        if (isDigital==true) {
//          WatchFaceActivity.getTimeDigitalCom(mContext!!,elements,custom!!)
//        }else{
//          val POINTER_HOUR = "pointer/hour"
//          val POINTER_MINUTE = "pointer/minute"
//          val POINTER_SECOND = "pointer/second"
//          WatchFaceActivity.getPointerCom(mContext!!,WatchFaceBuilder.ELEMENT_NEEDLE_HOUR, POINTER_HOUR, elements,custom!!)
//          WatchFaceActivity.getPointerCom(mContext!!,WatchFaceBuilder.ELEMENT_NEEDLE_MIN, POINTER_MINUTE, elements,custom!!)
//          WatchFaceActivity.getPointerCom(mContext!!,WatchFaceBuilder.ELEMENT_NEEDLE_SEC, POINTER_SECOND, elements,custom!!)
//        }

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
      else -> {
        when (call.method) {
          "OTA" -> {
           mBleKey=BleKey.OTA
          }
          "XMODEM" -> {
            mBleKey=BleKey.XMODEM
          }
          "TIME" -> {
            mBleKey=BleKey.TIME
          }
          "TIME_ZONE" -> {
            mBleKey=BleKey.TIME_ZONE
          }
          "POWER" -> {
            mBleKey=BleKey.POWER
          }
          "FIRMWARE_VERSION" -> {
            mBleKey=BleKey.FIRMWARE_VERSION
          }
          "BLE_ADDRESS" -> {
            mBleKey=BleKey.BLE_ADDRESS
          }
          "USER_PROFILE" -> {
            mBleKey=BleKey.USER_PROFILE
          }
          "STEP_GOAL" -> {
            mBleKey=BleKey.STEP_GOAL
          }
          "BACK_LIGHT" -> {
            mBleKey=BleKey.BACK_LIGHT
          }
          "SEDENTARINESS" -> {
            mBleKey=BleKey.SEDENTARINESS
          }
          "NO_DISTURB_RANGE" -> {
            mBleKey=BleKey.NO_DISTURB_RANGE
          }
          "VIBRATION" -> {
            mBleKey=BleKey.VIBRATION
          }
          "GESTURE_WAKE" -> {
            mBleKey=BleKey.GESTURE_WAKE
          }
          "HR_ASSIST_SLEEP" -> {
            mBleKey=BleKey.HR_ASSIST_SLEEP
          }
          "HOUR_SYSTEM" -> {
            mBleKey=BleKey.HOUR_SYSTEM
          }
          "LANGUAGE" -> {
            mBleKey=BleKey.LANGUAGE
          }
          "ALARM" -> {
            mBleKey=BleKey.ALARM
          }
          "COACHING" -> {
            mBleKey=BleKey.COACHING
          }
          "FIND_PHONE" -> {
            mBleKey=BleKey.FIND_PHONE
          }
          "NOTIFICATION_REMINDER" -> {
            mBleKey=BleKey.NOTIFICATION_REMINDER
          }
          "ANTI_LOST" -> {
            mBleKey=BleKey.ANTI_LOST
          }
          "HR_MONITORING" -> {
            mBleKey=BleKey.HR_MONITORING
          }
          "UI_PACK_VERSION" -> {
            mBleKey=BleKey.UI_PACK_VERSION
          }
          "LANGUAGE_PACK_VERSION" -> {
            mBleKey=BleKey.LANGUAGE_PACK_VERSION
          }
          "SLEEP_QUALITY" -> {
            mBleKey=BleKey.SLEEP_QUALITY
          }
          "GIRL_CARE" -> {
            mBleKey=BleKey.GIRL_CARE
          }
          "TEMPERATURE_DETECTING" -> {
            mBleKey=BleKey.TEMPERATURE_DETECTING
          }
          "AEROBIC_EXERCISE" -> {
            mBleKey=BleKey.AEROBIC_EXERCISE
          }
          "TEMPERATURE_UNIT" -> {
            mBleKey=BleKey.TEMPERATURE_UNIT
          }
          "DATE_FORMAT" -> {
            mBleKey=BleKey.DATE_FORMAT
          }
          "WATCH_FACE_SWITCH" -> {
            mBleKey=BleKey.WATCH_FACE_SWITCH
          }
          "AGPS_PREREQUISITE" -> {
            mBleKey=BleKey.AGPS_PREREQUISITE
          }
          "DRINK_WATER" -> {
            mBleKey=BleKey.DRINK_WATER
          }
          "SHUTDOWN" -> {
            mBleKey=BleKey.SHUTDOWN
          }
          "APP_SPORT_DATA" -> {
            mBleKey=BleKey.APP_SPORT_DATA
          }
          "REAL_TIME_HEART_RATE" -> {
            mBleKey=BleKey.REAL_TIME_HEART_RATE
          }
          "BLOOD_OXYGEN_SET" -> {
            mBleKey=BleKey.BLOOD_OXYGEN_SET
          }
          "WASH_SET" -> {
            mBleKey=BleKey.WASH_SET
          }
          "WATCHFACE_ID" -> {
            mBleKey=BleKey.WATCHFACE_ID
          }
          "IBEACON_SET" -> {
            mBleKey=BleKey.IBEACON_SET
          }
          "MAC_QRCODE" -> {
            mBleKey=BleKey.MAC_QRCODE
          }
          "REAL_TIME_TEMPERATURE" -> {
            mBleKey=BleKey.REAL_TIME_TEMPERATURE
          }
          "REAL_TIME_BLOOD_PRESSURE" -> {
            mBleKey=BleKey.REAL_TIME_BLOOD_PRESSURE
          }
          "TEMPERATURE_VALUE" -> {
            mBleKey=BleKey.TEMPERATURE_VALUE
          }
          "GAME_SET" -> {
            mBleKey=BleKey.GAME_SET
          }
          "FIND_WATCH" -> {
            mBleKey=BleKey.FIND_WATCH
          }
          "SET_WATCH_PASSWORD" -> {
            mBleKey=BleKey.SET_WATCH_PASSWORD
          }
          "REALTIME_MEASUREMENT" -> {
            mBleKey=BleKey.REALTIME_MEASUREMENT
          }
          "LOCATION_GSV" -> {
            mBleKey=BleKey.LOCATION_GSV
          }
          "HR_RAW" -> {
            mBleKey=BleKey.HR_RAW
          }
          "REALTIME_LOG" -> {
            mBleKey=BleKey.REALTIME_LOG
          }
          "GSENSOR_OUTPUT" -> {
            mBleKey=BleKey.GSENSOR_OUTPUT
          }
          "GSENSOR_RAW" -> {
            mBleKey=BleKey.GSENSOR_RAW
          }
          "MOTION_DETECT" -> {
            mBleKey=BleKey.MOTION_DETECT
          }
          "LOCATION_GGA" -> {
            mBleKey=BleKey.LOCATION_GGA
          }
          "RAW_SLEEP" -> {
            mBleKey=BleKey.RAW_SLEEP
          }
          "NO_DISTURB_GLOBAL" -> {
            mBleKey=BleKey.NO_DISTURB_GLOBAL
          }
          "IDENTITY" -> {
            mBleKey=BleKey.IDENTITY
          }
          "SESSION" -> {
            mBleKey=BleKey.SESSION
          }
          "NOTIFICATION" -> {
            mBleKey=BleKey.NOTIFICATION
          }
          "MUSIC_CONTROL" -> {
            mBleKey=BleKey.MUSIC_CONTROL
          }
          "SCHEDULE" -> {
            mBleKey=BleKey.SCHEDULE
          }
          "WEATHER_REALTIME" -> {
            mBleKey=BleKey.WEATHER_REALTIME
          }
          "WEATHER_FORECAST" -> {
            mBleKey=BleKey.WEATHER_FORECAST
          }
          "HID" -> {
            mBleKey=BleKey.HID
          }
          "WORLD_CLOCK" -> {
            mBleKey=BleKey.WORLD_CLOCK
          }
          "STOCK" -> {
            mBleKey=BleKey.STOCK
          }
          "SMS_QUICK_REPLY_CONTENT" -> {
            mBleKey=BleKey.SMS_QUICK_REPLY_CONTENT
          }
          "NOTIFICATION2" -> {
            mBleKey=BleKey.NOTIFICATION2
          }
          "DATA_ALL" -> {
            mBleKey=BleKey.DATA_ALL
          }
          "ACTIVITY_REALTIME" -> {
            mBleKey=BleKey.ACTIVITY_REALTIME
          }
          "ACTIVITY" -> {
            mBleKey=BleKey.ACTIVITY
          }
          "HEART_RATE" -> {
            mBleKey=BleKey.HEART_RATE
          }
          "SLEEP" -> {
            mBleKey=BleKey.SLEEP
          }
          "LOCATION" -> {
            mBleKey=BleKey.LOCATION
          }
          "TEMPERATURE" -> {
            mBleKey=BleKey.TEMPERATURE
          }
          "BLOOD_OXYGEN" -> {
            mBleKey=BleKey.BLOOD_OXYGEN
          }
          "HRV" -> {
            mBleKey=BleKey.HRV
          }
          "LOG" -> {
            mBleKey=BleKey.LOG
          }
          "SLEEP_RAW_DATA" -> {
            mBleKey=BleKey.SLEEP_RAW_DATA
          }
          "PRESSURE" -> {
            mBleKey=BleKey.PRESSURE
          }
          "WORKOUT2" -> {
            mBleKey=BleKey.WORKOUT2
          }
          "MATCH_RECORD" -> {
            mBleKey=BleKey.MATCH_RECORD
          }
          "CAMERA" -> {
            mBleKey=BleKey.CAMERA
          }
          "REQUEST_LOCATION" -> {
            mBleKey=BleKey.REQUEST_LOCATION
          }
          "INCOMING_CALL" -> {
            mBleKey=BleKey.INCOMING_CALL
          }
          "APP_SPORT_STATE" -> {
            mBleKey=BleKey.APP_SPORT_STATE
          }
          "CLASSIC_BLUETOOTH_STATE" -> {
            mBleKey=BleKey.CLASSIC_BLUETOOTH_STATE
          }
          "DEVICE_SMS_QUICK_REPLY" -> {
            mBleKey=BleKey.DEVICE_SMS_QUICK_REPLY
          }
          "WATCH_FACE" -> {
            mBleKey=BleKey.WATCH_FACE
          }
          "AGPS_FILE" -> {
            mBleKey=BleKey.AGPS_FILE
          }
          "FONT_FILE" -> {
            mBleKey=BleKey.FONT_FILE
          }
          "CONTACT" -> {
            mBleKey=BleKey.CONTACT
          }
          "UI_FILE" -> {
            mBleKey=BleKey.UI_FILE
          }
          "DEVICE_FILE" -> {
            mBleKey=BleKey.DEVICE_FILE
          }
          "LANGUAGE_FILE" -> {
            mBleKey=BleKey.LANGUAGE_FILE
          }
          "BRAND_INFO_FILE" -> {
            mBleKey=BleKey.BRAND_INFO_FILE
          }
          "BLOOD_PRESSURE" -> {
            mBleKey=BleKey.BLOOD_PRESSURE
          }
          else -> {
            mBleKey=BleKey.NONE
          }
        }
        when(call.argument<String>("flag")){
          "UPDATE" -> {
            mBleKeyFlag=BleKeyFlag.UPDATE
          }
          "READ" -> {
            mBleKeyFlag=BleKeyFlag.READ
          }
          "CREATE" -> {
            mBleKeyFlag=BleKeyFlag.CREATE
          }
          "DELETE" -> {
            mBleKeyFlag=BleKeyFlag.DELETE
          }
          "READ_CONTINUE" -> {
            mBleKeyFlag=BleKeyFlag.READ_CONTINUE
          }
          "RESET" -> {
            mBleKeyFlag=BleKeyFlag.RESET
          }
          else -> {
            mBleKeyFlag=BleKeyFlag.NONE
          }
        }
        setupKeyFlagList(mBleKey,mBleKeyFlag,call)
      }
    }
  }

  // 显示该BleKey对应的Flag列表
  private fun setupKeyFlagList(bleKey: BleKey,bleKeyFlag:BleKeyFlag, call: MethodCall) {
    if (bleKey == BleKey.IDENTITY) {
      if (bleKeyFlag == BleKeyFlag.DELETE) { // unbind
        // Send the unbinding command, some devices will trigger BleHandleCallback.onIdentityDelete() after replying
        BleConnector.sendData(bleKey, bleKeyFlag)
        // wait for a while to unbind
        Handler().postDelayed({
          BleConnector.unbind()
          unbindCompleted()
        }, 2000)
        return
      }
    }

    if (mContext != null) {
      doBle(mContext!!) {
        when (bleKey) {
          // BleCommand.UPDATE
//          BleKey.OTA -> FirmwareHelper.gotoOta(mContext)
//          BleKey.WATCH_FACE -> {
////                findViewById<TextView>(R.id.tv_custom1).apply {
////                    visibility = View.VISIBLE
////                    text = "custom 240*240"
////                    setOnClickListener {
////                        startActivity(
////                            Intent(
////                                this@KeyFlagListActivity,
////                                WatchFaceActivity::class.java
////                            ).putExtra("custom", 1)
////                        )
////                    }
////                }
////
////                findViewById<TextView>(R.id.tv_custom2).apply {
////                    visibility = View.VISIBLE
////                    text = "custom 454*454"
////                    setOnClickListener {
////                        startActivity(
////                            Intent(
////                                this@KeyFlagListActivity,
////                                WatchFaceActivity::class.java
////                            ).putExtra("custom", 2)
////                        )
////                    }
////                }
//          }
          BleKey.XMODEM -> BleConnector.sendData(bleKey, bleKeyFlag)
          BleKey.NOTIFICATION -> {
            val mTitle: String? = call.argument<String>("mTitle")
            val mContent : String? = call.argument<String>("mContent")
            val mCategory : String? = call.argument<String>("mCategory")
            val mPackage : String? = call.argument<String>("mPackage")
            when (bleKeyFlag) {
                BleKeyFlag.UPDATE -> {
                  BleNotification(
                        mCategory = if(mCategory=="1"){
                          BleNotification.CATEGORY_INCOMING_CALL
                        }else{
                          BleNotification.CATEGORY_MESSAGE
                        },
                        mTime = Date().time,
                        mPackage = "$mPackage",
                        mTitle = "$mTitle",
                        mContent = "$mContent"
                  ).let { notification ->
                        BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, notification)
                  }
                }
                BleKeyFlag.READ -> {
                  BleConnector.sendData(bleKey, bleKeyFlag)
                }
                BleKeyFlag.DELETE -> {
                  BleNotification(
                        mCategory = if(mCategory=="1"){
                          BleNotification.CATEGORY_INCOMING_CALL
                        }else{
                          BleNotification.CATEGORY_MESSAGE
                        },
                  ).let { notification ->
                        BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.DELETE, notification)
                  }
                }
              else -> {
                Log.i("No Flag","")
              }
            }
          }
          BleKey.NOTIFICATION2 -> {
            val mTitle: String? = call.argument<String>("mTitle")
            val mContent : String? = call.argument<String>("mContent")
            val mCategory : String? = call.argument<String>("mCategory")
            val mPackage : String? = call.argument<String>("mPackage")
            val mPhone : String? = call.argument<String>("mPhone")
            when (bleKeyFlag) {
                BleKeyFlag.UPDATE -> {
                  BleNotification2(
                        mCategory = if(mCategory=="1"){
                          BleNotification.CATEGORY_INCOMING_CALL
                        }else{
                          BleNotification.CATEGORY_MESSAGE
                        },
                        mTime = Date().time,
                        mPackage = "$mPackage",
                        mTitle = "$mTitle",
                        mPhone = "$mPhone",
                        mContent = "$mContent"
                  ).let { notification ->
                        BleConnector.sendObject(BleKey.NOTIFICATION2, BleKeyFlag.UPDATE, notification)
                  }
                }
                BleKeyFlag.READ -> {
                  BleConnector.sendData(bleKey, bleKeyFlag)
                }
                BleKeyFlag.DELETE -> {
                  BleNotification2(
                        mCategory = if(mCategory=="1"){
                          BleNotification.CATEGORY_INCOMING_CALL
                        }else{
                          BleNotification.CATEGORY_MESSAGE
                        },
                  ).let { notification ->
                        BleConnector.sendObject(BleKey.NOTIFICATION2, BleKeyFlag.DELETE, notification)
                  }
                }
              else -> {
                Log.i("No Flag","")
              }
            }
          }
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
              val times: Int? = call.argument<Int>("times")
              if (times != null) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, times)
              } // 0 is off, or 5 ~ 20
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.SEDENTARINESS -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              val mEnabled: Int? = call.argument<Int>("mEnabled")
              val mRepeat: String? = call.argument<String>("mRepeat")
              val mStartHour: Int? = call.argument<Int>("mStartHour")
              val mStartMinute: Int? = call.argument<Int>("mStartMinute")
              val mEndHour: Int? = call.argument<Int>("mEndHour")
              val mEndMinute: Int? = call.argument<Int>("mEndMinute")
              val mInterval: Int? = call.argument<Int>("mInterval")
              val listRepeat : List<String>? = call.argument<List<String>>("listRepeat")
              var bleRepeat : Int? = null
              if(listRepeat!=null){
                bleRepeat=0
                for (item in listRepeat) {
                  var itemRepeat : Int? = null
                  when (item){
                    "MONDAY" -> {
                      itemRepeat =BleRepeat.MONDAY
                    }
                    "TUESDAY" -> {
                      itemRepeat =BleRepeat.TUESDAY
                    }
                    "THURSDAY" -> {
                      itemRepeat =BleRepeat.THURSDAY
                    }
                    "FRIDAY" -> {
                      itemRepeat =BleRepeat.FRIDAY
                    }
                    "SATURDAY" -> {
                      itemRepeat =BleRepeat.SATURDAY
                    }
                    "SUNDAY" -> {
                      itemRepeat =BleRepeat.SUNDAY
                    }
                    "ONCE" -> {
                      itemRepeat =BleRepeat.ONCE
                    }
                    "WORKDAY" -> {
                      itemRepeat =BleRepeat.WORKDAY
                    }
                    "WEEKEND" -> {
                      itemRepeat =BleRepeat.WEEKEND
                    }
                    "EVERYDAY" -> {
                      itemRepeat =BleRepeat.EVERYDAY
                    }
                  }
                  bleRepeat = bleRepeat!!.or(itemRepeat!!)
                }
              }
              if (mRepeat != null) {
                when (mRepeat){
                  "MONDAY" -> {
                    bleRepeat =BleRepeat.MONDAY
                  }
                  "TUESDAY" -> {
                    bleRepeat =BleRepeat.TUESDAY
                  }
                  "THURSDAY" -> {
                    bleRepeat =BleRepeat.THURSDAY
                  }
                  "FRIDAY" -> {
                    bleRepeat =BleRepeat.FRIDAY
                  }
                  "SATURDAY" -> {
                    bleRepeat =BleRepeat.SATURDAY
                  }
                  "SUNDAY" -> {
                    bleRepeat =BleRepeat.SUNDAY
                  }
                  "ONCE" -> {
                    bleRepeat =BleRepeat.ONCE
                  }
                  "WORKDAY" -> {
                    bleRepeat =BleRepeat.WORKDAY
                  }
                  "WEEKEND" -> {
                    bleRepeat =BleRepeat.WEEKEND
                  }
                  "EVERYDAY" -> {
                    bleRepeat =BleRepeat.EVERYDAY
                  }
                }
              }
              // 设置久坐
              val bleSedentariness = BleSedentarinessSettings(
                mEnabled = mEnabled!!,
                // Monday ~ Saturday
                mRepeat = bleRepeat!!,
                mStartHour = mStartHour!!,
                mStartMinute = mStartMinute!!,
                mEndHour = mEndHour!!,
                mEndMinute = mEndMinute!!,
                mInterval = mInterval!!
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
          BleKey.NO_DISTURB_GLOBAL -> {
            val isDoNotDistrub: Boolean? = call.argument<Boolean>("isDoNotDistrub")
            if (isDoNotDistrub != null) {
              BleConnector.sendBoolean(
                bleKey,
                bleKeyFlag,
                isDoNotDistrub
              )
            }
          }
          BleKey.VIBRATION -> {
            val frequency: Int? = call.argument<Int>("frequency")
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置震动次数
              if (frequency != null) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, frequency)
              } // 0~10, 0 is off
            } else if (bleKeyFlag == BleKeyFlag.READ) {
              BleConnector.sendData(bleKey, bleKeyFlag)
            }
          }
          BleKey.GESTURE_WAKE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 设置抬手亮
              val mEnabled: Int? = call.argument<Int>("mEnabled")
              val mStartHour: Int? = call.argument<Int>("mStartHour")
              val mStartMinute: Int? = call.argument<Int>("mStartMinute")
              val mEndHour: Int? = call.argument<Int>("mEndHour")
              val mEndMinute: Int? = call.argument<Int>("mEndMinute")
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
                BleGestureWake(BleTimeRange(mEnabled!!, mStartHour!!, mStartMinute!!, mEndHour!!, mEndMinute!!))
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
            val index: Int? = call.argument<Int>("index")
            val mEnabled: Int? = call.argument<Int>("mEnabled")
            val mRepeat: String? = call.argument<String>("mRepeat")
            val mYear: Int? = call.argument<Int>("mYear")
            val mMonth: Int? = call.argument<Int>("mMonth")
            val mDay: Int? = call.argument<Int>("mDay")
            val mHour: Int? = call.argument<Int>("mHour")
            val mMinute: Int? = call.argument<Int>("mMinute")
            val mTag: String? = call.argument<String>("mTag")
            val listRepeat : List<String>? = call.argument<List<String>>("listRepeat")
            var bleRepeat : Int? = null
            if(listRepeat!=null){
              bleRepeat=0
              for (item in listRepeat) {
                var itemRepeat : Int? = null
                when (item){
                  "MONDAY" -> {
                    itemRepeat =BleRepeat.MONDAY
                  }
                  "TUESDAY" -> {
                    itemRepeat =BleRepeat.TUESDAY
                  }
                  "THURSDAY" -> {
                    itemRepeat =BleRepeat.THURSDAY
                  }
                  "FRIDAY" -> {
                    itemRepeat =BleRepeat.FRIDAY
                  }
                  "SATURDAY" -> {
                    itemRepeat =BleRepeat.SATURDAY
                  }
                  "SUNDAY" -> {
                    itemRepeat =BleRepeat.SUNDAY
                  }
                  "ONCE" -> {
                    itemRepeat =BleRepeat.ONCE
                  }
                  "WORKDAY" -> {
                    itemRepeat =BleRepeat.WORKDAY
                  }
                  "WEEKEND" -> {
                    itemRepeat =BleRepeat.WEEKEND
                  }
                  "EVERYDAY" -> {
                    itemRepeat =BleRepeat.EVERYDAY
                  }
                }
                bleRepeat = bleRepeat!!.or(itemRepeat!!)
              }
            }
            if (mRepeat != null) {
              when (mRepeat){
                "MONDAY" -> {
                  bleRepeat =BleRepeat.MONDAY
                }
                "TUESDAY" -> {
                  bleRepeat =BleRepeat.TUESDAY
                }
                "THURSDAY" -> {
                  bleRepeat =BleRepeat.THURSDAY
                }
                "FRIDAY" -> {
                  bleRepeat =BleRepeat.FRIDAY
                }
                "SATURDAY" -> {
                  bleRepeat =BleRepeat.SATURDAY
                }
                "SUNDAY" -> {
                  bleRepeat =BleRepeat.SUNDAY
                }
                "ONCE" -> {
                  bleRepeat =BleRepeat.ONCE
                }
                "WORKDAY" -> {
                  bleRepeat =BleRepeat.WORKDAY
                }
                "WEEKEND" -> {
                  bleRepeat =BleRepeat.WEEKEND
                }
                "EVERYDAY" -> {
                  bleRepeat =BleRepeat.EVERYDAY
                }
              }
            }
            if (bleKeyFlag == BleKeyFlag.CREATE) {
//              val calendar = Calendar.getInstance().apply { add(Calendar.MINUTE, 1) }
              BleConnector.sendObject(
                bleKey, bleKeyFlag,
//                BleAlarm(
//                  mEnabled = 1,
//                  mRepeat = BleRepeat.,
//                  mYear = calendar.get(Calendar.YEAR),
//                  mMonth = calendar.get(Calendar.MONTH) + 1,
//                  mDay = calendar.get(Calendar.DAY_OF_MONTH),
//                  mHour = calendar.get(Calendar.HOUR_OF_DAY),
//                  mMinute = calendar.get(Calendar.MINUTE),
//                  mTag = "tag"
//                )
               BleAlarm(
                mEnabled = mEnabled!!,
                mRepeat = bleRepeat!!,
                mYear = mYear!!,
                mMonth = mMonth!!,
                mDay = mDay!!,
                mHour = mHour!!,
                mMinute = mMinute!!,
                mTag = mTag!!
              )
              )
            } else if (bleKeyFlag == BleKeyFlag.DELETE) {
              // 如果缓存中有闹钟的话，删除第一个
              val alarms = BleCache.getList(BleKey.ALARM, BleAlarm::class.java)
              if (alarms.isNotEmpty()) {
                BleConnector.sendInt8(bleKey, bleKeyFlag, alarms[index!!].mId)
              }
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 如果缓存中有闹钟的话，切换第一个闹钟的开启状态
              val alarms = BleCache.getList(BleKey.ALARM, BleAlarm::class.java)
              if (alarms.isNotEmpty()) {
                alarms[index!!].let { alarm ->
                  if (mEnabled != null) {
                    alarm.mEnabled = mEnabled
                  }
                  if (bleRepeat != null) {
                    alarm.mRepeat = bleRepeat
                  }
                  if (mYear != null) {
                    alarm.mYear = mYear
                  }
                  if (mMonth != null) {
                    alarm.mMonth = mMonth
                  }
                  if (mDay != null) {
                    alarm.mDay = mDay
                  }
                  if (mHour != null) {
                    alarm.mHour = mHour
                  }
                  if (mMinute != null) {
                    alarm.mMinute = mMinute
                  }
                  if (mTag != null) {
                    alarm.mTag = mTag
                  }
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
          BleKey.ANTI_LOST -> {
            val isAntiLost: Boolean? = call.argument<Boolean>("isAntiLost")
            if (isAntiLost != null) {
              BleConnector.sendBoolean(
                bleKey,
                bleKeyFlag,
                isAntiLost
                // !BleCache.getBoolean(bleKey, false)
              )
            } // 切换
          }
          // 设置心率自动检测
          BleKey.HR_MONITORING -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              val mEnabled: Int? = call.argument<Int>("mEnabled")
              val mStartHour: Int? = call.argument<Int>("mStartHour")
              val mStartMinute: Int? = call.argument<Int>("mStartMinute")
              val mEndHour: Int? = call.argument<Int>("mEndHour")
              val mEndMinute: Int? = call.argument<Int>("mEndMinute")
              val mInterval: Int? = call.argument<Int>("mInterval")
              val hrMonitoring = BleHrMonitoringSettings(
                mBleTimeRange = BleTimeRange(mEnabled!!, mStartHour!!, mStartMinute!!, mEndHour!!, mEndMinute!!),
                mInterval = mInterval!! // an hour
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
          BleKey.TEMPERATURE_UNIT ->{
            val unit: Int? = call.argument<Int>("unit")
            // Beralih, 0: Celcius; 1: Fahrenheit
            BleConnector.sendInt8(bleKey, bleKeyFlag, unit!!)
          }
          // 日期格式设置
          BleKey.DATE_FORMAT -> {
            // 切换, 0: 年月日; 1: 日月年; 2: 月日年;
            // switch, 0: year month day; 1: day month year; 2: month day year;
            val format: Int? = call.argument<Int>("format")
            if (format != null) {
              BleConnector.sendInt8(bleKey, bleKeyFlag, format)
            }
          }
          BleKey.RAW_SLEEP ->
            BleConnector.sendData(bleKey, bleKeyFlag)

          //Default dial switch settings
          BleKey.WATCH_FACE_SWITCH ->
            // value, 0-4;
            BleConnector.sendInt8(bleKey, bleKeyFlag, (BleCache.getInt(bleKey, 0) + 1) % 5)

          // dial id
          BleKey.WATCHFACE_ID -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              mType = 1//Posisi tampilan jam di perangkat
              BleConnector.sendInt32(bleKey, bleKeyFlag, 100)// hanya >=100 atau tidak valid
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
          BleKey.DATA_ALL,BleKey.ACTIVITY, BleKey.ACTIVITY_REALTIME, BleKey.HEART_RATE, BleKey.BLOOD_PRESSURE, BleKey.SLEEP,
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
            val mCameraEntered: Boolean? = call.argument<Boolean>("mCameraEntered")
            if (mCameraEntered!!) {
              BleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.ENTER)
            } else {
              BleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.EXIT)
            }
          }
          BleKey.REQUEST_LOCATION -> {
            // reply location information
            val reply = BleLocationReply(
              mSpeed = 1.11f * mLocationTimes,
              mTotalDistance = 1.11f * mLocationTimes,
              mAltitude = 111 * mLocationTimes
            )
            print("$bleKey $bleKeyFlag")
            BleConnector.sendObject(bleKey, bleKeyFlag, reply)
            print("$reply")
            mLocationTimes++
            if (mLocationTimes > 10) mLocationTimes = 1
          }
          BleKey.APP_SPORT_STATE -> {
            // App 主导的运动，发送运动状态变化
            sportState = when (sportState) {
              BleAppSportState.STATE_START -> BleAppSportState.STATE_PAUSE
              BleAppSportState.STATE_PAUSE -> BleAppSportState.STATE_END
              else -> BleAppSportState.STATE_START
            }
            val reply = BleAppSportState(
              mMode = BleAppSportState.MODE_INDOOR,
              mState = sportState,
            )
            BleConnector.sendObject(bleKey, bleKeyFlag, reply)
            print("$reply")
            LogUtils.d(reply)
          }
          BleKey.INCOMING_CALL -> {
            BleConnector.sendData(bleKey, bleKeyFlag)
          }
          BleKey.CLASSIC_BLUETOOTH_STATE -> {
            // 3.0 开关
            when (mClassicBluetoothState) {
              ClassicBluetoothState.CLOSE_SUCCESSFULLY -> {
                mClassicBluetoothState = ClassicBluetoothState.OPEN
                BleConnector.sendInt8(bleKey, bleKeyFlag, mClassicBluetoothState)
              }
              ClassicBluetoothState.OPEN_SUCCESSFULLY -> {
                mClassicBluetoothState = ClassicBluetoothState.CLOSE
                BleConnector.sendInt8(bleKey, bleKeyFlag, mClassicBluetoothState)
              }
              else -> {
                //3.0状态正在切换中，请稍等
                print("3.0 status is switching, please wait")
              }
            }
          }

          // BleCommand.IO
          BleKey.WATCH_FACE, BleKey.AGPS_FILE, BleKey.FONT_FILE, BleKey.UI_FILE, BleKey.LANGUAGE_FILE, BleKey.BRAND_INFO_FILE -> {
            if (bleKeyFlag == BleKeyFlag.UPDATE) {
              // 发送文件
              val url: String? = call.argument<String>("url")
              if(url!=null){
                DownloadTask(bleKey).execute(url)
//                val executor = Executors.newSingleThreadExecutor()
//                val future = executor.submit {
//                  val url = URL(url)
//                  val connection = url.openConnection()
//                  connection.getInputStream()
//                }
//                val inputStream = future.get()
//                if (inputStream != null) {
//                  BleConnector.sendStream(bleKey ,inputStream as InputStream,0)
//                }
              }
              val path: String? = call.argument<String>("path")
              if(path!=null){
                val inputStream: InputStream = mContext!!.assets.open(path)
                BleConnector.sendStream(bleKey ,inputStream,0)
              }
            }

          }
//          BleKey.CONTACT -> {
//            PermissionUtils
//              .permission(PermissionConstants.CONTACTS)
//              .require(Manifest.permission.READ_CONTACTS) { granted ->
//                if (granted) {
//                  val bytes = getContactBytes()
//                  if (bytes.isNotEmpty()) {
//                    BleConnector.sendStream(BleKey.CONTACT, bytes)
//                  } else {
//                    LogUtils.d("contact is empty")
//                  }
//                }
//              }
//          }
          BleKey.CONTACT -> {
            val listContact : List<Map<String,String>>? = call.argument<List<Map<String,String>>>("listContact")
            val contact = ArrayList<Contact>()
            if (listContact != null) {
              for (cont in listContact) {
                contact.add(Contact(cont["displayName"]!!, cont["phone"]!!))
              }
            }
            //Firmware drafting: name 24 and phone number 16 bytes, so create an array here based on the data size
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
            if (bytes.isNotEmpty()) {
              BleConnector.sendStream(BleKey.CONTACT, bytes)
            } else {
              LogUtils.d("contact is empty")
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


  private fun unbindCompleted() {

  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
//    channel.setMethodCallHandler(null)
//    BleConnector.removeHandleCallback(mBleHandleCallback)
//   mBleScanner.exit()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    mActivity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {

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

  private val onDeviceConnectedResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onDeviceConnectedSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onIdentityCreateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onIdentityCreateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onCommandReplyResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onCommandReplySink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onOTAResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onOTASink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadPowerResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadPowerSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadFirmwareVersionResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadFirmwareVersionSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadBleAddressResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadBleAddressSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadSedentarinessResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadSedentarinessSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadNoDisturbResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadNoDisturbSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadAlarmResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadAlarmSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadCoachingIdsResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadCoachingIdsSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadUiPackVersionResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadUiPackVersionSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadLanguagePackVersionResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadLanguagePackVersionSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onIdentityDeleteByDeviceResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onIdentityDeleteByDeviceSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onCameraStateChangeResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onCameraStateChangeSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onCameraResponseResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onCameraResponseSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onSyncDataResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onSyncDataSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadActivityResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadActivitySink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadHeartRateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadHeartRateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onUpdateHeartRateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onUpdateHeartRateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadBloodPressureResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadBloodPressureSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadSleepResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadSleepSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadLocationResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadLocationSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadTemperatureResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadTemperatureSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadWorkout2ResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadWorkout2Sink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onStreamProgressResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onStreamProgressSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onUpdateAppSportStateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onUpdateAppSportStateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onClassicBluetoothStateChangeResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onClassicBluetoothStateChangeSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onDeviceFileUpdateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onDeviceFileUpdateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }


  private val onReadDeviceFileResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadDeviceFileSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadTemperatureUnitResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadTemperatureUnitSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }



  private val onReadDateFormatResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadDateFormatSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadWatchFaceSwitchResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadWatchFaceSwitchSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onUpdateWatchFaceSwitchResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onUpdateWatchFaceSwitchSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onAppSportDataResponseResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onAppSportDataResponseSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadWatchFaceIdResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadWatchFaceIdSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onWatchFaceIdUpdateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onWatchFaceIdUpdateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onHIDStateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onHIDStateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onHIDValueChangeResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onHIDValueChangeSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }



  private val onDeviceSMSQuickReplyResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onDeviceSMSQuickReplySink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }


  private val onReadDeviceInfoResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadDeviceInfoSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onSessionStateChangeResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onSessionStateChangeSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onNoDisturbUpdateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onNoDisturbUpdateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onAlarmUpdateResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onAlarmUpdateSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onAlarmDeleteResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onAlarmDeleteSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onAlarmAddResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onAlarmAddSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onFindPhoneResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onFindPhoneSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onRequestLocationResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onRequestLocationSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onDeviceRequestAGpsFileResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onDeviceRequestAGpsFileSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadBloodOxygenResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadBloodOxygenSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadWorkoutResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadWorkoutSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadBleHrvResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadBleHrvSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onReadPressureResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onReadPressureSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }

  private val onDeviceConnectingResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onDeviceConnectingSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }
  private val onIncomingCallStatusResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(o: Any?, eventSink: EventSink?) {
      if (eventSink != null) {
        onIncomingCallStatusSink = eventSink
      }
    }
    override fun onCancel(o: Any?) {
    }
  }
}


class DownloadTask(val bleKey: BleKey) : AsyncTask<String, Int, ByteArray>() {

  override fun doInBackground(vararg urls: String): ByteArray {
    val url = URL(urls[0])
    val connection = url.openConnection()
    return connection.getInputStream().readBytes()
  }

  override fun onPostExecute(result: ByteArray) {
    BleConnector.sendStream(bleKey ,result)
  }
}
