package com.szabh.androidblesdk3.activity

import android.Manifest
import android.annotation.SuppressLint
import android.app.ListActivity
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.*
import android.provider.ContactsContract
import android.telecom.TelecomManager
import android.view.KeyEvent
import android.view.View
import android.widget.ArrayAdapter
import android.widget.TextView
import com.bestmafen.baseble.data.mHexString
import com.bestmafen.baseble.util.BleLog
import com.blankj.utilcode.constant.PermissionConstants
import com.blankj.utilcode.util.*
import com.szabh.androidblesdk3.*
import com.szabh.androidblesdk3.firmware.FirmwareHelper
import com.szabh.androidblesdk3.tools.*
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.*
import com.szabh.smable3.entity.*
import com.szabh.smable3.entity.BleRepeat.EVERYDAY
import com.szabh.smable3.entity.BleRepeat.FRIDAY
import com.szabh.smable3.entity.BleRepeat.MONDAY
import com.szabh.smable3.entity.BleRepeat.SATURDAY
import com.szabh.smable3.entity.BleRepeat.THURSDAY
import com.szabh.smable3.entity.BleRepeat.TUESDAY
import com.szabh.smable3.entity.BleRepeat.WEDNESDAY
import com.szabh.smable3.entity.BleUserProfile.Companion.FEMALE
import com.szabh.smable3.entity.BleUserProfile.Companion.METRIC
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileOutputStream
import java.net.InetSocketAddress
import java.net.Socket
import java.util.*
import kotlin.concurrent.thread
import kotlin.random.Random


class KeyFlagListActivity : ListActivity() {
    private val mContext by lazy { this }

    private lateinit var mBleKey: BleKey

    private var mType = 0

    data class Contact(var name: String, var phone: String)

    private val mBleHandleCallback by lazy {
        object : BleHandleCallback {

            override fun onCommandReply(bleKey: BleKey, bleKeyFlag: BleKeyFlag, status: Boolean) {
                toast(mContext, "onCommandReply $bleKey $bleKeyFlag -> $status")
            }

            override fun onOTA(status: Boolean) {
                toast(mContext, "onOTA $status")
                if (!status) return

                FirmwareHelper.gotoOtaReally(mContext)
            }

            override fun onReadMtkOtaMeta() {
                FirmwareHelper.gotoOtaReally(mContext)
            }

            override fun onReadPower(power: Int) {
                toast(mContext, "onReadPower $power")
            }

            override fun onReadFirmwareVersion(version: String) {
                toast(mContext, "onReadFirmwareVersion $version")
            }

            override fun onReadUserProfile(userProfile: BleUserProfile) {
                toast(mContext, "onReadUserProfile $userProfile")
            }

            override fun onReadStepGoal(value: Int) {
                toast(mContext, "onReadStepGoal $value")
            }

            override fun onStepGoalUpdate(stepGoal: Int) {
                toast(mContext, "onStepGoalUpdate $stepGoal")
            }

            override fun onReadCaloriesGoal(value: Int) {
                toast(mContext, "onReadCaloriesGoal $value")
            }

            override fun onCaloriesGoalUpdate(value: Int) {
                toast(mContext, "onCaloriesGoalUpdate $value")
            }

            override fun onReadDistanceGoal(value: Int) {
                toast(mContext, "onReadDistanceGoal $value")
            }

            override fun onDistanceGoalUpdate(value: Int) {
                toast(mContext, "onDistanceGoalUpdate $value")
            }

            override fun onReadSleepGoal(value: Int) {
                toast(mContext, "onReadSleepGoal $value")
            }

            override fun onReadBleAddress(address: String) {
                toast(mContext, "onReadBleAddress $address")
            }

            override fun onReadSedentariness(sedentarinessSettings: BleSedentarinessSettings) {
                toast(mContext, "onReadSedentariness $sedentarinessSettings")
            }

            override fun onReadNoDisturb(noDisturbSettings: BleNoDisturbSettings) {
                toast(mContext, "onReadNoDisturb $noDisturbSettings")
            }

            override fun onReadAlarm(alarms: List<BleAlarm>) {
                toast(mContext, "onReadAlarm $alarms")
            }

            override fun onReadCoachingIds(bleCoachingIds: BleCoachingIds) {
                toast(mContext, "onReadCoachingIds $bleCoachingIds")
            }

            override fun onReadUiPackVersion(version: String) {
                toast(mContext, "onReadUiPackVersion $version")
            }

            override fun onReadLanguagePackVersion(version: BleLanguagePackVersion) {
                toast(mContext, "onReadLanguagePackVersion $version")
            }

            override fun onIdentityDeleteByDevice(isDevice: Boolean) {
                toast(mContext, "onIdentityDeleteByDevice $isDevice")
                BleConnector.unbind()
                unbindCompleted()
            }

            override fun onCameraStateChange(cameraState: Int) {
                toast(mContext, "onCameraStateChange ${CameraState.getState(cameraState)}")
                if (cameraState == CameraState.ENTER) {
                    mCameraEntered = true
                } else if (cameraState == CameraState.EXIT) {
                    mCameraEntered = false
                }
            }

            override fun onCameraResponse(status: Boolean, cameraState: Int) {
                toast(mContext, "onCameraResponse $status ${CameraState.getState(cameraState)}")
                if (status) {
                    if (cameraState == CameraState.ENTER) {
                        mCameraEntered = true
                    } else if (cameraState == CameraState.EXIT) {
                        mCameraEntered = false
                    }
                }
            }

            override fun onFactoryTestUpdate(factoryTest: BleFactoryTest) {
                toast(mContext, "onFactoryTestUpdate $factoryTest")
            }

            override fun onSyncData(syncState: Int, bleKey: BleKey) {
                LogUtils.d( "onSyncData syncState=$syncState, bleKey=$bleKey")
            }

            override fun onReadActivity(activities: List<BleActivity>) {
                toast(mContext, "$activities")

                //blexxxx.mTime to milliseconds demo
//                toTimeMillis(activities[0].mTime)
            }

            override fun onReadHeartRate(heartRates: List<BleHeartRate>) {
                toast(mContext, "$heartRates")
            }

            override fun onUpdateHeartRate(heartRate: BleHeartRate) {
                toast(mContext, "$heartRate")
            }

            override fun onReadBloodPressure(bloodPressures: List<BleBloodPressure>) {
                // toast(mContext, "$bloodPressures")
            }

            override fun onReadSleep(sleeps: List<BleSleep>) {
                //分析睡眠数据
                val analyseSleep = BleSleep.analyseSleep(sleeps, 1)
                val statusSleep = BleSleep.getSleepStatusDuration(analyseSleep, sleeps)
                //睡眠总时长
                val deepMinute= statusSleep[BleSleep.DEEP]
                val lightMinute= statusSleep[BleSleep.LIGHT]
                val awakeMinute= statusSleep[BleSleep.AWAKE]
                val totalMinute = statusSleep[BleSleep.TOTAL_LENGTH]

                // toast(mContext, "$sleeps")
            }

            override fun onReadLocation(locations: List<BleLocation>) {
                // toast(mContext, "$locations")
            }

            override fun onReadTemperature(temperatures: List<BleTemperature>) {
                // toast(mContext, "$temperatures")
            }

            override fun onReadWorkout2(workouts: List<BleWorkout2>) {
                toast(mContext, "$workouts")
            }

            override fun onReadEcg(ecgs: List<BleEcg>) {
                toast(mContext, "$ecgs")

                //blexxxx.mTime to milliseconds demo
//                toTimeMillis(ecgs[0].mTime)
            }

            override fun onRealTimeMeasurement(realTimeMeasurement: BleRealTimeMeasurement) {
                toast(mContext, "onRealTimeMeasurement $realTimeMeasurement")
            }

            override fun onReadSOSSettings(sosSettings: BleSOSSettings) {
                toast(mContext, "onReadSOSSettings $sosSettings")
            }

            override fun onReadGirlCareSettings(girlCareSettings: BleGirlCareSettings) {
                toast(mContext, "onReadGirlCareSettings $girlCareSettings")
            }

            override fun onReadDeviceLanguages(deviceLanguages: BleDeviceLanguages) {
                toast(mContext, "onReadDeviceLanguages $deviceLanguages")
            }

            override fun onReadLanguage(value: Int) {
                toast(mContext, "onReadLanguage $value")
            }

            override fun onDeviceSportDataUpdate(deviceSportData: BleDeviceSportData) {
                toast(mContext, "onDeviceSportDataUpdate $deviceSportData")
            }

            override fun onReadNotificationSettings2(notificationSettings2: BleNotificationSettings2) {
                toast(mContext, "onReadNotificationSettings2 $notificationSettings2")
            }

            override fun onNotificationSettings2Update(notificationSettings2: BleNotificationSettings2) {
                toast(mContext, "onNotificationSettings2Update $notificationSettings2")
            }

            override fun onReadNotificationLightScreenSet(value: Int) {
                toast(mContext, "onReadNotificationLightScreenSet $value")
            }

            override fun onNotificationLightScreenSetUpdate(value: Int) {
                toast(mContext, "onNotificationLightScreenSetUpdate $value")
            }

            override fun onTimeUpdate() {
                toast(mContext, "onTimeUpdate")
                BleConnector.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
                BleConnector.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
            }

            override fun onStreamProgress(
                status: Boolean,
                errorCode: Int,
                total: Int,
                completed: Int
            ) {
                toast(mContext, "onStreamProgress $status $errorCode $total $completed")
            }

            override fun onReceiveRecordPacket(recordPacket: BleRecordPacket) {
                val opusFile = File(PathUtils.getExternalAppDataPath() + "/files/record.opus")
                val pcmFile = File(PathUtils.getExternalAppDataPath() + "/files/record.pcm")
                when (recordPacket.mStatus) {
                    BleRecordPacket.TRANSFER_STATUS_START -> {
                        toast(mContext, "onReceiveRecordPacket start")
                        opusFile.delete()
                    }
                    BleRecordPacket.TRANSFER_STATUS_GO_ON -> {
                        FileIOUtils.writeFileFromBytesByStream(
                            opusFile,
                            recordPacket.mPacket,
                            true
                        )
                    }
                    BleRecordPacket.TRANSFER_STATUS_END -> {
                        toast(mContext, "onReceiveRecordPacket end")
                    }
                }
            }

            @SuppressLint("MissingPermission")
            override fun onIncomingCallStatus(status: Int) {
                if (status == 0) {
                    //接听电话
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val manager =
                                getSystemService(Context.TELECOM_SERVICE) as TelecomManager?
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
                                getSystemService(Context.AUDIO_SERVICE) as AudioManager?
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
                                        getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                                    manager.endCall()
                                }
                            }
                    }
                }

            }

            override fun onUpdateAppSportState(appSportState: BleAppSportState) {
                toast(mContext, "$appSportState")
            }

            override fun onClassicBluetoothStateChange(state: Int) {
                toast(mContext, ClassicBluetoothState.getState(state))
                mClassicBluetoothState = state
            }

            override fun onDeviceFileUpdate(deviceFile: BleDeviceFile) {
                LogUtils.d("onDeviceFileUpdate $deviceFile")
                toast(mContext, "$deviceFile")
            }

            override fun onReadDeviceFile(deviceFile: BleDeviceFile) {
                if (deviceFile.mFileSize != 0) {
                    BleConnector.sendData(BleKey.DEVICE_FILE, BleKeyFlag.READ_CONTINUE)
                }
                LogUtils.d("onReadDeviceFile $deviceFile")
                toast(mContext, "$deviceFile")
                FileIOUtils.writeFileFromBytesByStream(
                    File(PathUtils.getExternalAppDataPath() + "/voice/${deviceFile.mTime}.wav"),
                    deviceFile.mFileContent,
                    true
                )

            }

            override fun onReadTemperatureUnit(value: Int) {
                toast(mContext, "onReadTemperatureUnit $value")
            }

            override fun onReadDateFormat(value: Int) {
                toast(mContext, "onReadDateFormat $value")
            }

            override fun onReadWatchFaceSwitch(value: Int) {
                toast(mContext, "onReadWatchFaceSwitch $value")
            }

            override fun onUpdateWatchFaceSwitch(status: Boolean) {
                toast(mContext, "onUpdateWatchFaceSwitch $status")
            }

            override fun onAppSportDataResponse(status: Boolean) {
                toast(mContext, "$status")
            }

            override fun onReadWatchFaceId(watchFaceId: BleWatchFaceId) {
                toast(mContext, "onReadWatchFaceId ${watchFaceId.mIdList}")
            }

            override fun onWatchFaceIdUpdate(status: Boolean) {
                chooseFile(mContext, BleKey.WATCH_FACE.mKey)
            }

            override fun onHIDState(state: Int) {
                toast(mContext, "$state")
                if(state == HIDState.DISCONNECTED){
                    BleConnector.connectHID()
                }
            }

            override fun onHIDValueChange(value: Int) {
                toast(mContext, "$value")
            }

            override fun onDeviceSMSQuickReply(smsQuickReply: BleSMSQuickReply) {
                toast(mContext, smsQuickReply.toString())
            }

            override fun onReadDeviceInfo(deviceInfo: BleDeviceInfo) {
                toast(mContext, deviceInfo.toString())
            }

            override fun onReadLoveTapUser(loveTapUsers: List<BleLoveTapUser>) {
                toast(mContext, "loveTapUsers $loveTapUsers")
            }

            override fun onLoveTapUserUpdate(loveTapUser: BleLoveTapUser) {
                toast(mContext, "loveTapUser $loveTapUser")
            }

            override fun onLoveTapUserDelete(id: Int) {
                toast(mContext, "delete id:$id")
            }

            override fun onReadMedicationReminder(medicationReminders: List<BleMedicationReminder>) {
                toast(mContext, "medicationReminders $medicationReminders")
            }

            override fun onMedicationReminderUpdate(medicationReminder: BleMedicationReminder) {
                toast(mContext, "medicationReminder $medicationReminder")
            }

            override fun onMedicationReminderDelete(id: Int) {
                toast(mContext, "delete id:$id")
            }

            override fun onLoveTapUpdate(loveTap: BleLoveTap) {
                toast(mContext, "loveTap $loveTap")

                Handler().postDelayed({
                    BleConnector.sendObject(BleKey.LOVE_TAP, BleKeyFlag.UPDATE, loveTap)
                }, 1000)
            }

            override fun onReadUnit(value: Int) {
                toast(mContext, "onReadUnit $value")
            }

            override fun onReadDeviceInfo2(deviceInfo: BleDeviceInfo2) {
                toast(mContext, deviceInfo.toString())
            }

            override fun onReadHrMonitoringSettings(hrMonitoringSettings: BleHrMonitoringSettings) {
                toast(mContext, "hrMonitoringSettings $hrMonitoringSettings")
            }

            override fun onReadBodyStatus(bodyData: List<BleBodyStatus>) {
                toast(mContext, "onReadBodyData $bodyData")

                val time = toTimeMillis(bodyData[0].mTime)
                LogUtils.d(Date(time))
            }

            override fun onReadMindStatus(feelingData: List<BleMindStatus>) {
                toast(mContext, "onReadFeelingData $feelingData")

                val time = toTimeMillis(feelingData[0].mTime)
                LogUtils.d(Date(time))
            }

            override fun onReadCalorieIntake(calorieIntakes: List<BleCalorieIntake>) {
                toast(mContext, "onReadCalorieIntake $calorieIntakes")

                val time = toTimeMillis(calorieIntakes[0].mTime)
                LogUtils.d(Date(time))
            }

            override fun onReadFoodBalance(foodBalances: List<BleFoodBalance>) {
                toast(mContext, "onReadFoodBalance $foodBalances")

                val time = toTimeMillis(foodBalances[0].mTime)
                LogUtils.d(Date(time))
            }

            override fun onReadTuyaKey(tuyaKey: BleTuyaKey) {
                toast(mContext, "onReadTuyaKey $tuyaKey")
            }

            /**
             * BleConnector.sendData(BleKey.BAC, BleKeyFlag.READ)
             */
            override fun onReadBAC(bacs: List<BleBAC>) {
                toast(mContext, "onReadBAC $bacs")
            }

            /**
             * 设备返回数据回调
             */
            override fun onUpdateBAC(bac: BleBAC) {
                toast(mContext, "onUpdateBAC $bac")
            }

            override fun onReadAvgHeartRate(heartRates: List<BleAvgHeartRate>) {
                toast(mContext, "onReadAvgHeartRate $heartRates")
            }

            override fun onReadAlipayBindInfo(alipayBindInfo: List<BleAlipayBindInfo>) {
                toast(mContext, "onReadAlipayBindInfo $alipayBindInfo")
            }

            override fun onReadPackageStatus(packageStatus: BlePackageStatus) {
                toast(mContext, "onReadPackageStatus $packageStatus")
            }

            override fun onReadMatchRecord2(matchRecords: List<BleMatchRecord2>) {
                toast(mContext, "onReadMatchRecord2 $matchRecords")
            }

            override fun onReadAlipaySettings(alipaySettings: BleAlipaySettings) {
                toast(mContext, "onReadAlipaySettings $alipaySettings")
            }

            override fun onReadWatchPassword(watchPassword: BleSettingWatchPassword) {
                toast(mContext, "onReadWatchPassword $watchPassword")
            }

            override fun onWatchPasswordUpdate(watchPassword: BleSettingWatchPassword) {
                toast(mContext, "onWatchPasswordUpdate $watchPassword")
            }

            override fun onReadStandbyWatchFaceSet(standbyWatchFaceSet: BleStandbyWatchFaceSet) {
                toast(mContext, "onReadStandbyWatchFaceSet $standbyWatchFaceSet")
            }

            override fun onStandbyWatchFaceSetUpdate(standbyWatchFaceSet: BleStandbyWatchFaceSet) {
                toast(mContext, "onStandbyWatchFaceSetUpdate $standbyWatchFaceSet")
            }

            override fun onReadPressureTimingMeasurement(pressureTimingMeasurement: BlePressureTimingMeasurement) {
                toast(mContext, "onReadPressureTimingMeasurement $pressureTimingMeasurement")
            }

            override fun onReadDoubleScreenSettings(doubleScreenSettings: BleDoubleScreenSettings) {
                toast(mContext, "onReadDoubleScreenSettings $doubleScreenSettings")
            }

            override fun onDoubleScreenSettingsUpdate(doubleScreenSettings: BleDoubleScreenSettings) {
                toast(mContext, "onDoubleScreenSettingsUpdate $doubleScreenSettings")
            }

            override fun onReadBloodOxyGenSettings(bloodOxyGenSettings: BleBloodOxyGenSettings) {
                toast(mContext, "onReadBloodOxyGenSettings $bloodOxyGenSettings")
            }

            override fun onReadClassicBluetoothState(state: Int) {
                toast(mContext, "onReadClassicBluetoothState $state")
            }

            override fun onReadFallSet(value: Int) {
                toast(mContext, "onReadFallSet $value")
            }

            override fun onFallSetUpdate(value: Int) {
                toast(mContext, "onFallSetUpdate $value")
            }

            override fun onReadSDCardInfo(sdCardInfo: BleSDCardInfo) {
                toast(mContext, "onReadSDCardInfo $sdCardInfo")
            }

            override fun onReadActivityDetail(activityDetail: BleActivityDetail) {
                toast(mContext, "onReadActivityDetail $activityDetail")
            }

            override fun onReadBloodPressureCalibration(bloodPressureCalibration: BleBloodPressureCalibration) {
                toast(mContext, "onReadBloodPressureCalibration $bloodPressureCalibration")
            }

            override fun onReadEarphonePower(earphonePower: BleEarphonePower) {
                toast(mContext, "onReadEarphonePower $earphonePower")
            }

            override fun onReadEarphoneAncSettings(earphoneAncSettings: BleEarphoneAncSettings) {
                toast(mContext, "onReadEarphoneAncSettings $earphoneAncSettings")
            }

            override fun onEarphoneAncSettingsUpdate(earphoneAncSettings: BleEarphoneAncSettings) {
                toast(mContext, "onEarphoneAncSettingsUpdate $earphoneAncSettings")
            }

            override fun onReadEarphoneSoundEffectsSettings(earphoneSoundEffectsSettings: BleEarphoneSoundEffectsSettings) {
                toast(mContext, "onReadEarphoneSoundEffectsSettings $earphoneSoundEffectsSettings")
            }

            override fun onEarphoneSoundEffectsSettingsUpdate(earphoneSoundEffectsSettings: BleEarphoneSoundEffectsSettings) {
                toast(mContext, "onEarphoneSoundEffectsSettingsUpdate $earphoneSoundEffectsSettings")
            }

            override fun onReadScreenBrightnessSet(value: Int) {
                toast(mContext, "onReadScreenBrightnessSet $value")
            }

            override fun onScreenBrightnessSetUpdate(value: Int) {
                toast(mContext, "onScreenBrightnessSetUpdate $value")
            }


            override fun onReadEarphoneInfo(earphoneInfo: BleEarphoneInfo) {
                toast(mContext, "onReadEarphoneInfo $earphoneInfo")
            }

            override fun onReadEarphoneState(earphoneState: BleEarphoneState) {
                toast(mContext, "onReadEarphoneState $earphoneState")
            }

            override fun onEarphoneStateUpdate(earphoneState: BleEarphoneState) {
                toast(mContext, "onEarphoneStateUpdate $earphoneState")
            }


            override fun onReadEarphoneCall(value: Int) {
                toast(mContext, "onReadEarphoneCall $value")
            }

            override fun onEarphoneCallUpdate(value: Int) {
                toast(mContext, "onEarphoneCallUpdate $value")
            }

            override fun onReadGoMoreSettings(goMoreSettings: BleGoMoreSettings) {
                toast(mContext, "onReadGoMoreSettings $goMoreSettings")
            }

            override fun onReadRingVibrationSet(ringVibrationSettings: BleRingVibrationSettings) {
                toast(mContext, "onReadRingVibrationSet $ringVibrationSettings")
            }

            override fun onRingVibrationSetUpdate(ringVibrationSettings: BleRingVibrationSettings) {
                toast(mContext, "onRingVibrationSetUpdate $ringVibrationSettings")
            }

            override fun onReadNetworkFirmwareVersion(version: String) {
                toast(mContext, "onReadNetworkFirmwareVersion $version")
            }
        }
    }

    private var mCameraEntered = false
    private var mLocationTimes = 1
    private var mClassicBluetoothState = 3
    private var sportState = BleAppSportState.STATE_START

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_key_flag_list)
        mBleKey = intent.getSerializableExtra("BleKey") as BleKey
        setupKeyFlagList(mBleKey)
        BleConnector.addHandleCallback(mBleHandleCallback)
    }

    override fun onDestroy() {
        BleConnector.removeHandleCallback(mBleHandleCallback)
        super.onDestroy()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        dispatchChooseFileActivityResult(this, requestCode, resultCode, data, mType)
    }

    // 显示该BleKey对应的Flag列表
    private fun setupKeyFlagList(bleKey: BleKey) {
        val bleKeyFlags = bleKey.getBleKeyFlags()
        listView.apply {
            adapter =
                ArrayAdapter<BleKeyFlag>(mContext, android.R.layout.simple_list_item_1, bleKeyFlags)
            setOnItemClickListener { _, _, position, _ ->
                handleCommand(mBleKey, bleKeyFlags[position])
            }
        }

        when (bleKey) {
            BleKey.WATCH_FACE -> {
                findViewById<TextView>(R.id.tv_custom1).apply {
                    visibility = View.VISIBLE
                    text = "custom 240*240"
                    setOnClickListener {
                        startActivity(
                            Intent(
                                this@KeyFlagListActivity,
                                WatchFaceActivity::class.java
                            ).putExtra("custom", 1)
                        )
                    }
                }

                findViewById<TextView>(R.id.tv_custom2).apply {
                    visibility = View.VISIBLE
                    text = "custom 454*454"
                    setOnClickListener {
                        startActivity(
                            Intent(
                                this@KeyFlagListActivity,
                                WatchFaceActivity::class.java
                            ).putExtra("custom", 2)
                        )
                    }
                }
                findViewById<TextView>(R.id.tv_custom3).apply {
                    visibility = View.VISIBLE
                    text = "custom 240*286"
                    setOnClickListener {
                        startActivity(
                            Intent(
                                this@KeyFlagListActivity,
                                WatchFaceActivity::class.java
                            ).putExtra("custom", 3)
                        )
                    }
                }
            }
            else -> {}
        }

    }

    // 发送相应的指令
    private fun handleCommand(bleKey: BleKey, bleKeyFlag: BleKeyFlag) {
        if (bleKey == BleKey.IDENTITY) {
            if (bleKeyFlag == BleKeyFlag.DELETE) { // 解除绑定
                // Send an unbind command, some devices will trigger BleHandleCallback.onIdentityDelete() after replying
                BleConnector.sendData(bleKey, bleKeyFlag)
                // Wait for a while and then unbind
                Handler().postDelayed({
                    BleConnector.unbind()
                    unbindCompleted()
                }, 2000)
                return
            }
        } else if (bleKey == BleKey.OTA) {
            FirmwareHelper.gotoOta(mContext)
            return
        }

        doBle(mContext) {
            when (bleKey) {
                // BleCommand.UPDATE
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
                            mUnit = METRIC,
                            mGender = FEMALE,
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
                        BleConnector.sendInt32(bleKey, bleKeyFlag, 10000)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.CALORIES_GOAL -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 1cal
                        BleConnector.sendInt32(bleKey, bleKeyFlag, 2000)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.DISTANCE_GOAL -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 1m
                        BleConnector.sendInt32(bleKey, bleKeyFlag, 2000)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.SLEEP_GOAL -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 1分钟
                        BleConnector.sendInt16(bleKey, bleKeyFlag, 480)
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
                            mRepeat = MONDAY or TUESDAY or WEDNESDAY or THURSDAY or FRIDAY or SATURDAY,
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
                                mRepeat = EVERYDAY,
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

                BleKey.UNIT_SET -> {
                    // 公英制切换, 0: 公制; 1: 英制
                    BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)
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
                        true
                    ) // 切换
                // 设置心率自动检测
                BleKey.HR_MONITORING -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val hrMonitoring = BleHrMonitoringSettings(
                            mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
                            mInterval = 60 // an hour
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
                BleKey.GIRL_CARE ->
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            bleKey, bleKeyFlag,
                            BleGirlCareSettings(
                                mReminderEnable = 0,//0：关 1：开, 提醒开关设置，BleDeviceInfo.mSupportGirlCareReminder==1才有效
                                mEnabled = 1,//打开设备才会显示
                                mReminderHour = 9,
                                mReminderMinute = 0,
                                mMenstruationReminderAdvance = 2,
                                mOvulationReminderAdvance = 2,
                                mLatestYear = 2023,
                                mLatestMonth = 7,
                                mLatestDay = 18,
                                mMenstruationDuration = 7,
                                mMenstruationPeriod = 30
                            )
                        )
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
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

                BleKey.DRINK_WATER -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 喝水提醒
                        BleDrinkWaterSettings(
                            mEnabled = 1,
                            // Monday ~ Saturday
                            mRepeat = MONDAY or TUESDAY or WEDNESDAY or THURSDAY or FRIDAY or SATURDAY,
                            mStartHour = 1,
                            mStartMinute = 1,
                            mEndHour = 22,
                            mEndMinute = 1,
                            mInterval = 60
                        ).also {
                            BleConnector.sendObject(bleKey, bleKeyFlag, it)
                        }
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.SHUTDOWN -> {
                    BleConnector.sendInt8(bleKey, bleKeyFlag, 0)
                }

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

                BleKey.FIND_PHONE -> {
                    BleConnector.sendInt8(bleKey, bleKeyFlag, 1)
                }

                BleKey.REALTIME_MEASUREMENT -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            bleKey,
                            bleKeyFlag,
                            BleRealTimeMeasurement(
                                mHRSwitch =0,
                                mBOSwitch = 0,
                                mBPSwitch = 0,
                                mStressSwitch = 1,
                                mState = BleRealTimeMeasurement.STATE_START
                            )
                        )
                    } else {
                        BleConnector.sendObject(
                            bleKey,
                            bleKeyFlag,
                            BleRealTimeMeasurement(
                                mHRSwitch = 0,
                                mBOSwitch = 0,
                                mBPSwitch = 0,
                                mStressSwitch = 1,
                                mState = BleRealTimeMeasurement.STATE_PAUSE
                            )
                        )
                    }
                }

                BleKey.POWER_SAVE_MODE -> {
                    //0:close, 1:open
                    BleConnector.sendInt8(bleKey, bleKeyFlag, 0)
                }

                BleKey.BAC_SET -> {
                    BleConnector.sendObject(bleKey, bleKeyFlag, BleRange(mStart = 100, mEnd = 200))
                }

                BleKey.LOVE_TAP_USER -> {
                    if (bleKeyFlag == BleKeyFlag.CREATE) {
                        BleConnector.sendObject(
                            bleKey, bleKeyFlag,
                            BleLoveTapUser(
                                mName = "User ${(1..Int.MAX_VALUE).random()}"
                            )
                        )
                    } else if (bleKeyFlag == BleKeyFlag.DELETE) {
                        // 如果缓存中有的话，删除第一个
                        val loveTapUsers =
                            BleCache.getList(BleKey.LOVE_TAP_USER, BleLoveTapUser::class.java)
                        if (loveTapUsers.isNotEmpty()) {
                            BleConnector.sendInt8(bleKey, bleKeyFlag, loveTapUsers[0].mId)
                        }
                    } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 如果缓存中有的话，更新第一个
                        val loveTapUsers =
                            BleCache.getList(BleKey.ALARM, BleLoveTapUser::class.java)
                        if (loveTapUsers.isNotEmpty()) {
                            loveTapUsers[0].let { loveTapUser ->
                                loveTapUser.mName =
                                    loveTapUser.mName + " ${(1..Int.MAX_VALUE).random()}"
                                BleConnector.sendObject(bleKey, bleKeyFlag, loveTapUser)
                            }
                        }
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        // 读取设备上所有的数据
                        BleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
                    } else if (bleKeyFlag == BleKeyFlag.RESET) {
                        // 重置设备上的数据
                        BleConnector.sendList(bleKey, bleKeyFlag, List(8) {
                            BleLoveTapUser(
                                mName = "User $it"
                            )
                        })
                    }
                }

                BleKey.MEDICATION_REMINDER -> {
                    val calendar = Calendar.getInstance()
                    val year = calendar.get(Calendar.YEAR)
                    val month = calendar.get(Calendar.MONTH)
                    val day = calendar.get(Calendar.DAY_OF_MONTH)
                    val hour = calendar.get(Calendar.HOUR_OF_DAY)
                    val min = calendar.get(Calendar.MINUTE)
                    if (bleKeyFlag == BleKeyFlag.CREATE) {
                        BleConnector.sendObject(
                            bleKey, bleKeyFlag,
                            BleMedicationReminder(
                                mType = BleMedicationReminder.TYPE_TABLET, //药物类型
                                mUnit = BleMedicationReminder.UNIT_PIECE, //药物单位，片、粒等
                                mDosage = 1, //药物剂量,根据药物单位来定
                                mRepeat = MONDAY or TUESDAY or WEDNESDAY or THURSDAY or FRIDAY or SATURDAY, //重复提醒位Bit
                                mRemindTimes = 6,//提醒的次数
                                mRemindTime1 = BleHmTime(mHour = hour, mMinute = 1),//第1次提醒时间
                                mRemindTime2 = BleHmTime(mHour = hour, mMinute = 2),//第2次提醒时间
                                mRemindTime3 = BleHmTime(mHour = hour, mMinute = 3),//第3次提醒时间
                                mRemindTime4 = BleHmTime(mHour = hour, mMinute = 4),//第4次提醒时间
                                mRemindTime5 = BleHmTime(mHour = hour, mMinute = 5),//第5次提醒时间
                                mRemindTime6 = BleHmTime(mHour = hour, mMinute = 6),//第6次提醒时间
                                mStartYear = year, //提醒开始日期
                                mStartMonth = month + 1,
                                mStartDay = day - 1,
                                mEndYear = year, //结束开始日期
                                mEndMonth = month + 2,
                                mEndDay = day,
                                mName = "Name  ${(1..Int.MAX_VALUE).random()}", //药物名称，UTF-8编码
                                mLabel = "Label ${(1..Int.MAX_VALUE).random()}" //药物说明标签(UTF8编码)
                            )
                        )
                    } else if (bleKeyFlag == BleKeyFlag.DELETE) {
                        // 如果缓存中有的话，删除第一个
                        val medicationReminders = BleCache.getList(
                            BleKey.MEDICATION_REMINDER,
                            BleMedicationReminder::class.java
                        )
                        if (medicationReminders.isNotEmpty()) {
                            BleConnector.sendInt8(bleKey, bleKeyFlag, medicationReminders[0].mId)
                        }
                    } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 如果缓存中有的话，更新第一个
                        val medicationReminders = BleCache.getList(
                            BleKey.MEDICATION_REMINDER,
                            BleMedicationReminder::class.java
                        )
                        if (medicationReminders.isNotEmpty()) {
                            medicationReminders[0].let { medicationReminder ->
                                medicationReminder.mName =
                                    medicationReminder.mName + " ${(1..Int.MAX_VALUE).random()}"
                                BleConnector.sendObject(bleKey, bleKeyFlag, medicationReminder)
                            }
                        }
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        // 读取设备上所有的数据
                        BleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
                    } else if (bleKeyFlag == BleKeyFlag.RESET) {
                        // 重置设备上的数据
                        BleConnector.sendList(bleKey, bleKeyFlag, List(8) {
                            BleMedicationReminder(
                                mType = BleMedicationReminder.TYPE_TABLET, //药物类型
                                mUnit = BleMedicationReminder.UNIT_PIECE, //药物单位，片、粒等
                                mDosage = 1, //药物剂量,根据药物单位来定
                                mRepeat = MONDAY or TUESDAY or WEDNESDAY or THURSDAY or FRIDAY or SATURDAY, //重复提醒位Bit
                                mRemindTimes = 6,//提醒的次数
                                mRemindTime1 = BleHmTime(mHour = hour, mMinute = 1),//第1次提醒时间
                                mRemindTime2 = BleHmTime(mHour = hour, mMinute = 2),//第2次提醒时间
                                mRemindTime3 = BleHmTime(mHour = hour, mMinute = 3),//第3次提醒时间
                                mRemindTime4 = BleHmTime(mHour = hour, mMinute = 4),//第4次提醒时间
                                mRemindTime5 = BleHmTime(mHour = hour, mMinute = 5),//第5次提醒时间
                                mRemindTime6 = BleHmTime(mHour = hour, mMinute = 6),//第6次提醒时间
                                mStartYear = year, //提醒开始日期
                                mStartMonth = month + 1,
                                mStartDay = day - 1,
                                mEndYear = year, //结束开始日期
                                mEndMonth = month + 2,
                                mEndDay = day,
                                mName = "Name  $it", //药物名称，UTF-8编码
                                mLabel = "Label $it" //药物说明标签(UTF8编码)
                            )
                        })
                    }
                }

                BleKey.DEVICE_INFO -> {
                    BleConnector.sendData(bleKey, bleKeyFlag)
                }

                BleKey.HR_WARNING_SET -> {
                    BleConnector.sendObject(
                        bleKey,
                        bleKeyFlag,
                        BleHrWarningSettings(
                            mHighSwitch = 1,
                            mHighValue = 150,
                            mLowSwitch = 1,
                            mLowValue = 60
                        )
                    )
                }

                BleKey.SLEEP_MONITORING -> {
                    BleConnector.sendObject(
                        bleKey,
                        bleKeyFlag,
                        BleSleepMonitoringSettings(
                            mEnabled = 0,
                            mStartHour = 12,
                            mStartMinute = 0,
                            mEndHour = 12,
                            mEndMinute = 0
                        )
                    )
                }

                BleKey.STANDBY_SET -> {
                    //0:off , 1:on
                    BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)
                }

                BleKey.BT_NAME -> {
                    BleConnector.sendObject(bleKey, bleKeyFlag, BleBtName("BtName_abcde"))
                }

                BleKey.TUYA_KEY_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            bleKey,
                            bleKeyFlag,
                            BleTuyaKey(
                                mUuid = "uuid5649c3624c5e",
                                mKey = "afKMyFE3gb3jhNXECWc87QwLpLiQ1KjL",
                                mMac = "DC234F11AE21"
                            )
                        )
                    } else {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.BAC_RESULT_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val v = intArrayOf(0, 1, 2)
                        BleConnector.sendObject(
                            bleKey, bleKeyFlag, BleBACResultSettings(
                                mLow = BleBACResultSettings.LEVE_RED,//含量低于预设范围
                                mHigh = BleBACResultSettings.LEVE_YELLOW,//含量高于预设范围
                                mNormal = BleBACResultSettings.LEVE_GREEN,//含量在预设范围内
                                mDuration = 2,//秒为单位
                                mVibrate = v[(0..2).random()],//震动提醒强度, 可以设置比如0 1 2,
                            )
                        )
                    }
                }

                BleKey.MATCH_SET -> {
                    //YOUTH Match
                    var matchYouthSettings = BleMatchYouthSettings().apply {
                        mPeriods = 1
                        mPeriodTime = List(9) { 60 + it }.toMutableList()
                        mBreakTime = List(8) { 60 + it }.toMutableList()
                        mVibration = 1
                        mButtonType = MatchButtomType.DOUBLE_PRESS
                        mHomeTeamColor = MatchColor.BLACK
                        mGuestTeamColor = MatchColor.BLUE
                        mPenaltyTime = 80
                        mGps = 1
                        mScreen = 1
                        mMatchView = MatchMainView.DAYLIGHT
                        mTeamNames = List(2) { "TeamName $it" }.toMutableList()
                        mRefereeRole = List(4) { "RefereeRole $it" }.toMutableList()
                    }
//                    BleConnector.sendObject(bleKey, bleKeyFlag, matchYouthSettings)

                    //CLASSIC Match
                    var matchClassicSettings = BleMatchClassicSettings().apply {
                        mPeriods = 1
                        mPeriodTime = List(9) { 60 + it }.toMutableList()
                        mBreakTime = List(8) { 60 + it }.toMutableList()
                        mVibration = 1
                        mButtonType = MatchButtomType.DOUBLE_PRESS
                        mGps = 1
                        mScreen = 1
                        mMatchView = MatchMainView.DAYLIGHT
                        mTeamNames = List(2) { "TeamName $it" }.toMutableList()
                        mRefereeRole = List(4) { "RefereeRole $it" }.toMutableList()
                    }

//                    BleConnector.sendObject(bleKey, bleKeyFlag, matchClassicSettings)

                    //PRO Match
                    var matchProSettings = BleMatchProSettings().apply {
                        mPeriods = 2
                        mPeriodTime = List(9) { 60 + it }.toMutableList()
                        mBreakTime = List(8) { 60 + it }.toMutableList()
                        mVibration = 1
                        mButtonType = MatchButtomType.DOUBLE_PRESS
                        mHomeTeamColor = MatchColor.BLACK
                        mGuestTeamColor = MatchColor.BLUE
                        mGps = 1
                        mScreen = 1
                        mMatchView = MatchMainView.DAYLIGHT
                        mTeamNames = List(2) { "TeamName $it" }.toMutableList()
                        mRefereeRole = List(4) { "RefereeRole $it" }.toMutableList()
                        mGoalTypes = List(5) { "GoalType $it" }.toMutableList()
                        mYellowCardTypes = List(5) { "YellowCardType $it" }.toMutableList()
                        mRedCardTypes = List(5) { "RedCardType $it" }.toMutableList()
                    }
                    BleConnector.sendObject(bleKey, bleKeyFlag, matchProSettings)

                    //Interval Training
                    var matchTrainingSettings = BleMatchTrainingSettings().apply {
                        mPeriods = 2
                        mTrainingTime = 99
                        mRestingTime = 100
                        mFinshRestingTime = 60
                        mVibration = 3
                        mScreen = 1
                    }
                    BleConnector.sendObject(bleKey, bleKeyFlag, matchTrainingSettings)

                    //主队 Player list
                    var homePlayerSettings = BleMatchPlayerSettings().apply {
                        mMatchSetType = MatchSetType.HOME_TEAM_PLAYER_LIST
                        mPlayerList = List(25) {
                            BleMatchPlayer(
                                mName = "home player $it",
                                mNum = it
                            )
                        }
                    }
                    BleConnector.sendObject(bleKey, bleKeyFlag, homePlayerSettings)
                    //客队Player list
                    var guestPlayerSettings = BleMatchPlayerSettings().apply {
                        mMatchSetType = MatchSetType.GUEST_TEAM_PLAYER_LIST
                        mPlayerList = List(25) {
                            BleMatchPlayer(
                                mName = "guest player $it",
                                mNum = it
                            )
                        }
                    }
                    BleConnector.sendObject(bleKey, bleKeyFlag, guestPlayerSettings)
                }

                BleKey.PACKAGE_STATUS -> {
                    BleConnector.sendData(bleKey, bleKeyFlag)
                }

                BleKey.NOTIFICATION_REMINDER2 -> {
                    if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val settings2 =
                            BleCache.getObject(bleKey, BleNotificationSettings2::class.java)
                                ?: BleNotificationSettings2()
                        settings2.toggle(BleNotificationSettings2.CALL)
                        BleConnector.sendObject(bleKey, bleKeyFlag, settings2)
                    }
                }

                BleKey.ALIPAY_SET -> {
                    if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            bleKey, bleKeyFlag, BleAlipaySettings(
                                0,
                                0,
                                ConvertUtils.hexString2Bytes("2ABEA3EA0814").apply {
                                    this[0] = (0..255).random().toByte()
                                    this[5] = (0..255).random().toByte()
                                }
                            )
                        )
                    }
                }

                BleKey.BLE_ADDRESS_SET -> {
                    val macs = mutableListOf("1ABEA3EA0814", "1ABEA3EA0824", "1ABEA3EA0844")
                    BleConnector.sendObject(
                        bleKey, bleKeyFlag, BleAddressSettings(
                            ConvertUtils.hexString2Bytes(macs[(0..2).random()])
                        )
                    )
                }
                BleKey.NAVI_INFO -> {
                    BleConnector.sendObject(
                        bleKey, bleKeyFlag, BleNaviInfo(
                            mState = 0,
                            mTime = System.currentTimeMillis(),
                            mTurnType = 2,
                            mRemainDistance = 1234,
                            mRemainTime = 30 * 60,
                            mDistance = 60,
                            mRoadName = "RoadName abcd"
                        )
                    )
                }

                BleKey.SOS_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(bleKey, bleKeyFlag, BleSOSSettings(
                            mEnabled = 1,
                            mPhone = "13012345678"
                        ))
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.DEVICE_LANGUAGES -> {
                    BleConnector.sendData(bleKey, bleKeyFlag)
                }

                BleKey.NAVI_INFO -> {
                    BleConnector.sendObject(
                        bleKey, bleKeyFlag, BleNaviInfo(
                            mState = 0,
                            mTime = System.currentTimeMillis(),
                            mTurnType = 2,
                            mRemainDistance = 1234,
                            mRemainTime = 30 * 60,
                            mDistance = 60,
                            mRoadName = "RoadName abcd"
                        )
                    )
                }

                BleKey.GAME_TIME_REMINDER -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(bleKey, bleKeyFlag, BleGameTimeReminder(
                            mEnabled = 1,
                            mMinute = 15
                        ))
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.PRESSURE_TIMING_MEASUREMENT -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val pressureTimingMeasurement = BlePressureTimingMeasurement(
                            mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
                            mInterval = 60 // an hour
                        )
                        BleConnector.sendObject(bleKey, bleKeyFlag, pressureTimingMeasurement)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.BLOOD_OXYGEN_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val bloodOxyGenSettings = BleBloodOxyGenSettings(
                            mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
                            mInterval = 10 // an hour
                        )
                        BleConnector.sendObject(bleKey, bleKeyFlag, bloodOxyGenSettings)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.STANDBY_WATCH_FACE_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val standbyWatchFaceSet = BleStandbyWatchFaceSet(
                            mStandbyEnable = 1, //使能开关，如果关闭下面的设置无效
                            mEnabled = 1, // 总开关与时间段开关互斥
                            mBleTimeRange1 = BleTimeRange(0, 8, 0, 22, 0),
                        )
                        BleConnector.sendObject(bleKey, bleKeyFlag, standbyWatchFaceSet)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.FALL_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        //0:off , 1:on
                        BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.BW_NAVI_INFO -> {
                    BleConnector.sendObject(
                        bleKey, bleKeyFlag, BleBWNaviInfo(
                            mState = 0,
                            mTime = System.currentTimeMillis(),
                            mMode = 1,
                            mSpeed = 75000,
                            mAltitude = 102,
                            mTurnType = 2,
                            mRemainTime = "1小时2分钟",
                            mRemainDistance = "600米",
                            mRoadGuide = "沿东路直行200米"
                        )
                    )
                }

                BleKey.SDCARD_INFO -> {
                    BleConnector.sendData(bleKey, bleKeyFlag)
                }

                BleKey.ACTIVITY_DETAIL -> {
                    BleConnector.sendInt8(bleKey, bleKeyFlag, (0..2).random())
                }

                BleKey.NOTIFICATION_LIGHT_SCREEN_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        //0:off , 1:on
                        BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                BleKey.BLOOD_PRESSURE_CALIBRATION -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {

                        BleConnector.sendObject(bleKey, bleKeyFlag, BleBloodPressureCalibration(
                            mSystolic = 120, // 高压标定值（收缩压）
                            mDiastolic = 80 // 低压标定值（舒张压）
                        ))
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.AIR_PRESSURE_CALIBRATION -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        //单位Pa
                        BleConnector.sendInt32(bleKey, bleKeyFlag, (10000..Int.MAX_VALUE).random())
                    }
                }
                BleKey.EARPHONE_POWER -> {
                    BleConnector.sendData(bleKey, bleKeyFlag)
                }
                BleKey.EARPHONE_ANC_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(bleKey, bleKeyFlag, BleEarphoneAncSettings(
                            mMode = BleEarphoneAncSettings.MODE_DENOISE,
                            mAncModeList = mutableListOf(
                                //MODE_CLOSE
                                BleAncMode(
                                    mLeftMax = 0,
                                    mRightMax = 0,
                                    mLeftCurVal = 0,
                                    mRightCurVal = 0
                                ),
                                //MODE_DENOISE
                                BleAncMode(
                                    mLeftMax = 16384,
                                    mRightMax = 16384,
                                    mLeftCurVal = 8000,
                                    mRightCurVal = 8000
                                ),
                                //MODE_TRANSPARENT
                                BleAncMode(
                                    mLeftMax = 16384,
                                    mRightMax = 16384,
                                    mLeftCurVal = 8000,
                                    mRightCurVal = 8000
                                )
                            )
                        ))
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.EARPHONE_SOUND_EFFECTS_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(bleKey, bleKeyFlag, BleEarphoneSoundEffectsSettings(
                            mMode = BleEarphoneSoundEffectsSettings.MODE_USER, // 自定义
                            mValue = byteArrayOf(3, 1, 0, -2, -4, -4, -2, 0, 1, 2)
                        ))
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.SCREEN_BRIGHTNESS_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        //value 0-4
                        BleConnector.sendInt8(bleKey, bleKeyFlag, intArrayOf(0, 2, 4).random())
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.EARPHONE_INFO -> {
                    BleConnector.sendData(bleKey, bleKeyFlag)
                }
                BleKey.EARPHONE_STATE -> {
                    BleConnector.sendData(bleKey, bleKeyFlag)
                }
                BleKey.EARPHONE_CALL -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        //0:off , 1:on
                        BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.GOMORE_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            bleKey,
                            bleKeyFlag,
                            BleGoMoreSettings(
                                "54534d160450524e393732303002633a",
                                "MEE2EANAGCeSCtGOdLEefdfedfffdfafdfdSRarOITDS08928fd63358fb9941bf"
                            )
                        )
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.RING_VIBRATION_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            bleKey,
                            bleKeyFlag,
                            BleRingVibrationSettings(
                                0,
                                1
                            )
                        )
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.GPS_FIRMWARE_VERSION, BleKey.NETWORK_FIRMWARE_VERSION -> BleConnector.sendData(bleKey, bleKeyFlag)
                // 设置心电自动检测
                BleKey.ECG_SET -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val ecgSettings = BleEcgSettings(
                            mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
                            mInterval = 60 // an hour
                        )
                        BleConnector.sendObject(bleKey, bleKeyFlag, ecgSettings)
                    }
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
                                smsQuickReply.mContent =
                                    "我正在会议中，${Random.nextInt(10)}请稍后再联系我"
                                BleConnector.sendObject(bleKey, bleKeyFlag, smsQuickReply)
                            }
                        }
                    }
                }

                BleKey.NEWS_FEED -> {
                    BleConnector.sendObject(
                        bleKey, bleKeyFlag, BleNewsFeed(
                            mCategory = 0x01,
                            mUid = (1..100).random(),
                            mTime = Date().time,
                            mTitle = "title ${(1..Int.MAX_VALUE).random()}",
                            mContent = "content ${(1..Int.MAX_VALUE).random()}"
                        )
                    )
                }
                // 发送实时天气2
                BleKey.WEATHER_REALTIME2 -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            BleKey.WEATHER_REALTIME2, bleKeyFlag, BleWeatherRealtime2(
                                mTime = (Date().time / 1000L).toInt(),
                                mCityName = "city 1",
                                mWeather = BleWeather2(
                                    mCurrentTemperature = 1,
                                    mMaxTemperature = 1,
                                    mMinTemperature = 1,
                                    mWeatherCode = BleWeather.RAINY,
                                    mWindSpeed = 1,
                                    mHumidity = 1,
                                    mVisibility = 1,
                                    mUltraVioletIntensity = 1,
                                    mPrecipitation = 1,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                )
                            )
                        )
                    }
                }
                // 发送天气预报2
                BleKey.WEATHER_FORECAST2 -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        BleConnector.sendObject(
                            BleKey.WEATHER_FORECAST2, bleKeyFlag, BleWeatherForecast2(
                                mTime = (Date().time / 1000L).toInt(),
                                mCityName = "city 1",
                                mWeather1 = BleWeather2(
                                    mCurrentTemperature = 2,
                                    mMaxTemperature = 2,
                                    mMinTemperature = 3,
                                    mWeatherCode = BleWeather2.CLOUDY,
                                    mWindSpeed = 2,
                                    mHumidity = 2,
                                    mVisibility = 2,
                                    mUltraVioletIntensity = 2,
                                    mPrecipitation = 2,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                ),
                                mWeather2 = BleWeather2(
                                    mCurrentTemperature = 3,
                                    mMaxTemperature = 3,
                                    mMinTemperature = 3,
                                    mWeatherCode = BleWeather2.OVERCAST,
                                    mWindSpeed = 3,
                                    mHumidity = 3,
                                    mVisibility = 3,
                                    mUltraVioletIntensity = 3,
                                    mPrecipitation = 3,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                ),
                                mWeather3 = BleWeather2(
                                    mCurrentTemperature = 4,
                                    mMaxTemperature = 4,
                                    mMinTemperature = 4,
                                    mWeatherCode = BleWeather2.RAINY,
                                    mWindSpeed = 4,
                                    mHumidity = 4,
                                    mVisibility = 4,
                                    mUltraVioletIntensity = 4,
                                    mPrecipitation = 4,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                ),
                                mWeather4 = BleWeather2(
                                    mCurrentTemperature = 5,
                                    mMaxTemperature = 5,
                                    mMinTemperature = 5,
                                    mWeatherCode = BleWeather2.RAINY,
                                    mWindSpeed = 5,
                                    mHumidity = 5,
                                    mVisibility = 5,
                                    mUltraVioletIntensity = 5,
                                    mPrecipitation = 5,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                ),
                                mWeather5 = BleWeather2(
                                    mCurrentTemperature = 6,
                                    mMaxTemperature = 6,
                                    mMinTemperature = 6,
                                    mWeatherCode = BleWeather2.RAINY,
                                    mWindSpeed = 6,
                                    mHumidity = 6,
                                    mVisibility = 6,
                                    mUltraVioletIntensity = 6,
                                    mPrecipitation = 6,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                ),
                                mWeather6 = BleWeather2(
                                    mCurrentTemperature = 7,
                                    mMaxTemperature = 7,
                                    mMinTemperature = 7,
                                    mWeatherCode = BleWeather2.RAINY,
                                    mWindSpeed = 7,
                                    mHumidity = 7,
                                    mVisibility = 7,
                                    mUltraVioletIntensity = 7,
                                    mPrecipitation = 7,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                ),
                                mWeather7 = BleWeather2(
                                    mCurrentTemperature = 8,
                                    mMaxTemperature = 8,
                                    mMinTemperature = 8,
                                    mWeatherCode = BleWeather2.RAINY,
                                    mWindSpeed = 8,
                                    mHumidity = 8,
                                    mVisibility = 8,
                                    mUltraVioletIntensity = 8,
                                    mPrecipitation = 8,
                                    mSunriseHour = 8,
                                    mSunrisMinute = 1,
                                    mSunrisSecond = 2,
                                    mSunsetHour = 18,
                                    mSunsetMinute = 1,
                                    mSunsetSecond = 2
                                )
                            )
                        )
                    }
                }

                BleKey.LOGIN_DAYS -> {
                    //在线天数
                    BleConnector.sendInt16(bleKey, bleKeyFlag, 365)
                }

                BleKey.TARGET_COMPLETION -> {
                    //0-100
                    BleConnector.sendInt8(bleKey, bleKeyFlag, 80)
                }

                // BleCommand.DATA
                BleKey.DATA_ALL, BleKey.ACTIVITY, BleKey.HEART_RATE, BleKey.BLOOD_PRESSURE, BleKey.SLEEP,
                BleKey.WORKOUT, BleKey.LOCATION, BleKey.TEMPERATURE, BleKey.BLOOD_OXYGEN, BleKey.HRV, BleKey.PRESSURE, BleKey.LOG,
                BleKey.WORKOUT2, BleKey.MATCH_RECORD, BleKey.BLOOD_GLUCOSE, BleKey.BODY_STATUS, BleKey.MIND_STATUS,
                BleKey.CALORIE_INTAKE, BleKey.FOOD_BALANCE, BleKey.BAC, BleKey.MATCH_RECORD2, BleKey.AVG_HEART_RATE,
                BleKey.ALIPAY_BIND_INFO, BleKey.RRI, BleKey.ECG ->
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
                        mPace = 900
                    )
                    BleConnector.sendObject(bleKey, bleKeyFlag, reply)
                    toast(mContext, "$reply")
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
                    toast(mContext, "$reply")
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
                    toast(mContext, "$reply")
                    LogUtils.d(reply)
                }

                BleKey.CLASSIC_BLUETOOTH_STATE -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 3.0 开关
                        if (mClassicBluetoothState == ClassicBluetoothState.CLOSE_SUCCESSFULLY) {
                            mClassicBluetoothState = ClassicBluetoothState.OPEN
                            BleConnector.sendInt8(bleKey, bleKeyFlag, mClassicBluetoothState)
                        } else if (mClassicBluetoothState == ClassicBluetoothState.OPEN_SUCCESSFULLY) {
                            mClassicBluetoothState = ClassicBluetoothState.CLOSE
                            BleConnector.sendInt8(bleKey, bleKeyFlag, mClassicBluetoothState)
                        } else {
                            //3.0状态正在切换中，请稍等
                            toast(mContext, "3.0 status is switching, please wait")
                        }
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.LOVE_TAP -> {
                    BleConnector.sendObject(
                        bleKey, bleKeyFlag, BleLoveTap(
                            mTime = System.currentTimeMillis(),
                            mId = 1,
                            mActionType = (1..2).random()
                        )
                    )
                }
                BleKey.DOUBLE_SCREEN -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        val settings = BleDoubleScreenSettings().apply {
                            mBleTimeRange1 = BleTimeRange(1, 2, 0, 18, 0)
                        }
                        BleConnector.sendObject(bleKey, bleKeyFlag, settings)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }
                BleKey.INCOMING_CALL_RING -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        //0:off , 1:on
                        BleConnector.sendInt8(bleKey, bleKeyFlag, BleCache.getInt(bleKey, 0) xor 1)
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        BleConnector.sendData(bleKey, bleKeyFlag)
                    }
                }

                // BleCommand.IO
                BleKey.WATCH_FACE, BleKey.FONT_FILE, BleKey.UI_FILE, BleKey.LANGUAGE_FILE,
                BleKey.BRAND_INFO_FILE, BleKey.OTA_FILE, BleKey.GPS_FIRMWARE_FILE -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        // 发送文件
                        chooseFile(this, bleKey.mKey)
                    }/* else if (bleKeyFlag == BleKeyFlag.DELETE) {
                        // 删除设备上的文件
                        BleConnector.sendInt8(bleKey, bleKeyFlag, 1)
                    }*/
                }
                BleKey.LOGO_FILE -> {
                    //用的也是品牌包的格式
                    genBrandInfo(bleKey)
                }

                BleKey.AGPS_FILE -> {
                    val aGpsFile = File(externalCacheDir, "agps")
                    if (BleDeviceInfo.AGPS_AGNSS == BleCache.mAGpsType) {
                        aGpsFileSocket(22.578945, 113.868121, aGpsFile)
                    } else {
                        BleLog.d("url -> ${BleCache.mAGpsFileUrl}")
                        // TODO: BleCache.mAGpsFileUrl 自己实现agps文件下载,下载完成后使用下面的代码同步agps
//                        if (BleCache.mAGpsType == BleDeviceInfo.AGPS_EPO2) {
//                            sendAGPSEPO2File(aGpsFile)
//                        } else {
//                            BleConnector.sendStream(BleKey.AGPS_FILE, aGpsFile)
//                        }
                    }
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
                    toast(mContext, "$bleKey")
                }
            }
        }
    }

    /**
     * 创建客户端Socket，指定服务器的IP地址和端口，然后获取AGPS文件
     * 每个小时一千次，如下载请求超限，连接会出现异常
     */
    private fun aGpsFileSocket(latitude: Double, longitude: Double, aGpsFile: File) {
        thread {
            try {
                LogUtils.v("aGpsFileSocket socket connect")
                val socket = Socket()
                socket.connect(InetSocketAddress("121.41.40.95", 2621),5000)
                val output = socket.getOutputStream()
                output.write("user=206459476@qq.com;pwd=smartwatch;cmd=full;lat=${latitude};lon=${longitude};alt=0;".toByteArray())
                output.flush()

                val writer = BufferedOutputStream(FileOutputStream(aGpsFile))

                val input = BufferedInputStream(socket.getInputStream())
                var data: ByteArray?

                while (input.readBytes().also { data = it }.isNotEmpty()) {
                    writer.write(data)
                }
                writer.flush()
                socket.shutdownInput()
                socket.shutdownOutput()

                writer.close()
                input.close()
                output.close()
                socket.close()
                BleConnector.sendStream(BleKey.AGPS_FILE, aGpsFile)
            } catch (e: java.lang.Exception) {
                BleLog.d("aGpsFileSocket error: ${e.message}")
            }
        }
    }

    /**
     * AGPS_EPO2类型文件需要重新处理一下文件
     */
    private fun sendAGPSEPO2File(file: File) {
        try {
            val dat = file.inputStream()
            val byteArray = ByteArray(dat.available())
            val finalByteArray = ByteArray(dat.available())
            val gpsByteArray = ArrayList<Byte>()
            val gnsByteArray = ArrayList<Byte>()
            dat.read(byteArray)
//          LogUtils.d(ConvertUtils.bytes2HexString(byteArray))
            //每个卫星的的GPS+GNS数据总长度
            val lineLength = 32 * 72 + 24 * 72
            val gpsLength = 32 * 72 * 12
            //固定12个卫星数据，
            for (index in 0..11) {
                for (date in byteArray.indices) {
                    if (date < (32 * 72)) {
                        //gps 每行的 前 32*72 字节
                        gpsByteArray.add(byteArray[date + index * lineLength])
                    } else if (date < lineLength) {
                        //gns 每行的 后 24*72字节
                        gnsByteArray.add(byteArray[date + index * lineLength])
                    } else {
                        break
                    }
                }
            }
            for (index in gpsByteArray.indices) {
                finalByteArray[index] = gpsByteArray[index]
            }
            for (index in gnsByteArray.indices) {
                finalByteArray[index + gpsLength] = gnsByteArray[index]
            }
            LogUtils.d(ConvertUtils.bytes2HexString(finalByteArray))
            BleConnector.sendStream(BleKey.AGPS_FILE, finalByteArray)
        } catch (e: java.lang.Exception) {
            BleLog.d("sendAGPSEPO2File error: ${e.message}")
        }
    }

    private fun getContactBytes(): ByteArray {
        val cursor = mContext.contentResolver.query(
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
                    contact.add(Contact(disPlayName, phone))
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
        LogUtils.d(bytes.mHexString)
        return bytes
    }

    private fun unbindCompleted() {
        val intent = Intent(mContext, LauncherActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK.or(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }


    /**
     * 生成品牌包示例
     */
    fun genBrandInfo(bleKey: BleKey) {

        val bleName = BleCache.mBleName

        val item = BrandInfoImageItem().apply {
            mX = 0
            mY = 0
            mAnchor = BrandInfoBuilder.GRAVITY_X_LEFT or BrandInfoBuilder.GRAVITY_Y_TOP
            mPlayInterval = 500

            val imageCount = 4//图片总数
            val imageInfos = ArrayList<BrandInfoImage>()
            val hasAlpha = false
            for (i in 1..imageCount) {
                convertPng(
                    File(PathUtils.getExternalAppDataPath(), "files/brand_info_file$i.png"),//24位png
                    hasAlpha
                )?.let {
                    imageInfos.add(
                        BrandInfoImage(
                            mWidth = 240,
                            mHeight = 297,
                            mCompression = if (BleCache.mSupport2DAcceleration == 1) {
                                BrandInfoBuilder.CD_BITMAP_COMPRESSION_JL
                            } else BrandInfoBuilder.CD_BITMAP_COMPRESSION_RLE_LINE,
                            mPixelFormat = BrandInfoBuilder.CD_RGB_565,
                            hasAlpha = if (hasAlpha) 1 else 0,
                            mImageBuffer = it
                        )
                    )
                }
            }
            mImageInfos = imageInfos.toTypedArray()
        }


        val bytes = BrandInfoBuilder.build(bleName, item)
        LogUtils.d("${bytes.size} => "+bytes.mHexString)
        FileIOUtils.writeFileFromBytesByStream(File(PathUtils.getExternalAppDataPath(), "${bleName}_brandinfo.bin"), bytes)
        BleConnector.sendStream(bleKey, bytes)
    }
}