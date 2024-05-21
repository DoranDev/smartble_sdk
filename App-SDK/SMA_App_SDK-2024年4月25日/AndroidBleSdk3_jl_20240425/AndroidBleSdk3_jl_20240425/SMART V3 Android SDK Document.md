# 1. Overview

SMART V3 Android SDK is a set of application programming interfaces based on Android 5.1 and above. You can use this set of SDK to develop apps for Android phones. By calling the SMART V3 SDK interface, you can easily build a feature-rich and interactive smart watch supporting app.

# 2. Development guide

## 2.1. Project configuration

1. Import the files in the libs folder into the project. Among them, the three files AndroidBaseBle.aar, AndroidDfuLib.aar and AndroidSmaBle.aar are required. Other files are OTA SDK provided by the chip manufacturer. You can configure build.gralde according to the situation.

```groovy
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation "androidx.appcompat:appcompat:$appcompat_version"
    implementation "androidx.core:core-ktx:$androidxcore_version"

    implementation "com.google.code.gson:gson:2.8.6"
    implementation "com.blankj:utilcodex:1.30.6"
    implementation "androidx.media2:media2-session:1.1.3"

    // Nordic (optional)
    api 'no.nordicsemi.android:dfu:1.12.0'
    implementation 'androidx.localbroadcastmanager:localbroadcastmanager:1.0.0'

    // Goodix (optional)
    implementation 'android.arch.lifecycle:livedata:1.1.1'

    // jieli (optional)
    implementation "androidx.room:room-runtime:2.4.3"
}
```

2. Declare necessary permissions in Androidmanifest.xml:

```xml
<manifest>
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>  
```

If you need to support Nordic devices, you need to register the DFU service for firmware upgrades in Android Manifest.xml:

```xml
<service android:name="com.szabh.androidblesdk3.firmware.n.DfuService" />
```

If you need to support Realtek devices, you need to register the DFU service for firmware upgrade in Android Manifest.xml:

```xml
<service android:name="com.realsil.sdk.dfu.DfuService" />
```

## 2.2. Development Process

1. Initialization, in "Application.on Create()":

```kotlin
override fun onCreate() {
    super.onCreate()

    //It is recommended to save the log output by the sdk to a file, so that it can be easily analyzed if there is a problem
    BleLog.mInterceptor = { level, _, msg ->
        //For details, refer to the sample code of the sdk
        false
    }
    
    val connector = BleConnector.Builder(this)
        .supportNordicOta(true) // Whether to support Nordic device Ota, if not support pass false.
        .supportRealtekDfu(true) // Whether to support Realtek device Dfu, if not support pass false.
        .supportMtkOta(true) // Whether to support MTK device Ota, if not support pass false.
        .supportLauncher(true) // Whether to support the method of automatically connecting Ble Bluetooth devices (if bound), if not, please pass false.
        .supportFilterEmpty(true) // Whether to support filtering empty data, such as ACTIVITY, HEART RATE, BLOOD PRESSURE, SLEEP, WORKOUT, LOCATION, TEMPERATURE, BLOOD OXYGEN, HRV, if not supported, pass false.
        .build()

    //Configure a global callback
    connector.addHandleCallback(object : BleHandleCallback {
        override fun onSessionStateChange(status: Boolean) {
            // If the connection changes, some settings need to be resent to the device if the connection is successful. 
            // Currently, these are necessary, and other settings can be determined by the user.
            if (status) {
                connector.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
                connector.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
                connector.sendInt8(BleKey.HOUR_SYSTEM, BleKeyFlag.UPDATE,
                    if (DateFormat.is24HourFormat(Utils.getApp())) 0 else 1)
                connector.sendData(BleKey.POWER, BleKeyFlag.READ)
                connector.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)
                connector.sendInt8(BleKey.LANGUAGE, BleKeyFlag.UPDATE, Languages.languageToCode())
                connector.sendData(BleKey.MUSIC_CONTROL, BleKeyFlag.READ)
            }
        }
    })
}
```

2. Connect the device and declare the Scanner

```kotlin
private val mBleScanner by lazy {
    // ScannerFactory.newInstance(arrayOf(UUID.fromString(BleConnector.BLE_SERVICE)))
    ScannerFactory.newInstance()
        .setScanDuration(10)
        .setScanFilter(object : BleScanFilter {

            override fun match(device: BleDevice): Boolean {
                //Filter the Bluetooth signal value, the larger the signal value, the stronger the signal, for example -66 > -88
                return device.mRssi > -88
            }
        })
        .setBleScanCallback(object : BleScanCallback {

            override fun onBluetoothDisabled() {
                // Bluetooth is not enabled
            }

            override fun onScan(scan: Boolean) {
                 // Scan started or finished
            }

            override fun onDeviceFound(device: BleDevice) {
                // Device was searched
            }
        })
}
```

3. Start scanning

```kotlin
mBleScanner.scan(true)
```

This operation needs to obtain the location permission, and the location service needs to be enabled on some mobile phones, otherwise the device cannot be searched. If the phone's Bluetooth is turned on, "onScan(true)" will be triggered, otherwise "onBluetoothDisabled()" will be triggered, and "onDeviceFound(device)" will be triggered when a matching device is scanned. After the specified scan Duration time, the scan will stop automatically, and you can also call "mBleScanner.scan(false)" to stop it manually, and "onScan(false)" will be triggered when it stops.

4. Exit scan

When the interface is destroyed, call "m Ble Scanner.exit()" to exit the scan to prevent memory leaks.

5. Connect device

```kotlin
//Connect device
BleConnector.setBleDevice(bleDevice).connect(true)

//Returns true if Ble is connected
BleConnector.isAvailable()

//Triggered when the device is successfully connected
fun onDeviceConnected(device: BluetoothDevice) {}
```

6. bind/login

After the connection is successful, the framework will automatically send binding or login instructions to the device according to the status.

a. If the device is not bound, the binding command will be sent first. After the device confirms the binding, it will save the relevant information of the device and then send the login command.

b. If the device has been bound, send the login command directly.

After successful login, you can communicate with the device.

```kotlin
//Returns true if Ble is paired
BleConnector.isBound()

//When pairing is successfully triggered, some user settings can be synchronized, and BleDeviceInfo recommends saving them
fun onIdentityCreate(status: Boolean, deviceInfo: BleDeviceInfo? = null) {}

//Triggered when the connection status changes, when the status is true, some user settings can be synchronized, such as time, time zone, etc., refer to the sdk sample code
fun onSessionStateChange(status: Boolean) {}

//After the connection is successful, if you want to pair 3.0
BleConnector.connectClassic()
```

BleDeviceInfo  
mBleName: Bluetooth name   
mBleAddress: Ble address   
mPlatform: device platform   
mPrototype: device prototype   
mFirmwareFlag: firmware flag  
mAGpsType: agps type   
mClassicAddress: BT 3.0 address

explanation:  
There are many Ble Device Info attributes, and here are only the attributes that may be used. It is recommended to save the Ble Device Info after obtaining it.

7. Send command

The current protocol uses the method of sending a reply, in which the reply frame has been processed internally, and only the blekey needs to be sent. The main way to send commands is to call the method starting with send in the BleConnector object. Events will be triggered when the device replies to the commands sent by the mobile phone and actively sends commands. These events will be dispatched in the main thread through "BleHandleCallback", and register an event callback through "BleConnector.addHandleCallback(BleHandleCallback)" wherever events need to be processed. The corresponding event can be received and dealt with accordingly. If the callback interface is registered in the UI component, you should call "BleConnector.removeHandleCallback(BleHandleCallback)" to remove the callback interface when the UI component is destroyed, otherwise it will cause a memory leak.   
For example, use "BleConnector.sendData(BleKey.DATA_ALL, BleKeyFlag.READ)" to request all supported data types. For specific requests, please refer to the class "BleKey"  
0x05FF\_DATA\_ALL: A special mark fabricated by the App itself, which refers to all the data supported by the current device.   
0x0502\_ACTIVITY: It includes steps\calories\distance, refer to class "BleActivity"    
0x0503\_HEART\_RATE: heart rate, refer to class "BleHeartRate"    
0x0505\_SLEEP: sleep, refer to class "BleSleep"

8. Unbind the device

```kotlin
// Send an unbind command, some devices will trigger BleHandleCallback.onIdentityDelete() after replying
BleConnector.sendData(BleKey.IDENTITY, BleKeyFlag.DELETE)
// Wait for a while and then unbind
Handler().postDelayed({
    BleConnector.unbind()
    unbindCompleted()
}, 2000)

//Triggered when unbinding, some devices will trigger when unbinding, but some will not
fun onIdentityDelete(status: Boolean) {}

//Triggered when the device is actively unbound, for example, the device is restored to factory settings, or after the ota is completed, the app needs to be re-paired.
fun onIdentityDeleteByDevice(isDevice: Boolean) {}
```

# 3.Function Description

## 3.1. Data

### 3.1.1. Steps, distance, calories burned

Example

```kotlin
//Data can be read when the number of steps of the device changes
BleConnector.sendData(BleKey.ACTIVITY, BleKeyFlag.READ)

//Triggered when data is read
fun onReadActivity(activities: List<BleActivity>) {}
```

BleActivity  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.  
mMode:Sports mode, please refer to the definition in companion object 
mState:Motion state, please refer to the definition in companion object  
mStep:The number of steps, for example, a value of 10 means that 10 steps have been taken
mCalorie:The amount of calories consumed, 1/10000 kcal, for example, the received data is 56045, which means 5.6045 Kcal is approximately equal to 5.6 Kcal  
mDistance:1/10000 meters, for example, the received data is 56045, which means that the moving distance is 5.6045 meters, which is approximately equal to 5.6 meters

### 3.1.2. Heart rate

Example

```kotlin
//The heart rate of the device changes and the data can be read
BleConnector.sendData(BleKey.HEART_RATE, BleKeyFlag.READ)

//Triggered when data is read
fun onReadHeartRate(heartRates: List<BleHeartRate>) {}
```

BleHeartRate  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.    
mBpm: heart rate value

### 3.1.3. Blood pressure

Example

```kotlin
//The blood pressure of the device changes and the data can be read
BleConnector.sendData(BleKey.BLOOD_PRESSURE, BleKeyFlag.READ)

//Triggered when data is read
fun onReadBloodPressure(bloodPressures: List<BleBloodPressure>) {}
```

BleBloodPressure  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.  
mSystolic:systolic blood pressure  
mDiastolic:diastolic pressure

### 3.1.4. Sleep

Example

```kotlin
//Data can be read when the device generates sleep data
BleConnector.sendData(BleKey.SLEEP, BleKeyFlag.READ)

//Triggered when data is read
fun onReadSleep(sleeps: List<BleSleep>) {}
```

BleSleep  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.    
mMode:sleep state  
mSoft:Light motion, that is, relatively slight motion detected during sleep  
mStrong:Heavy movements, that is, relatively violent movements detected during sleep 

Illustrate:
The read "List<BleSleep>" may be multi-day data, and the data can be saved. The App can obtain the daily sleep data according to the time, and calculate the sleep duration. Example

```kotlin
//Analyze sleep data, sleeps is a day's sleep data
val analyseSleep = BleSleep.analyseSleep(sleeps, 1)
val statusSleep = BleSleep.getSleepStatusDuration(analyseSleep, sleeps)
//total sleep time
val deepMinute= statusSleep[BleSleep.DEEP]
val lightMinute= statusSleep[BleSleep.LIGHT]
val awakeMinute= statusSleep[BleSleep.AWAKE]
val totalMinute = statusSleep[BleSleep.TOTAL_LENGTH]
```

### 3.1.5. Sports data

Example

```kotlin
//Data can be read when the device generates motion data
BleConnector.sendData(BleKey.WORKOUT2, BleKeyFlag.READ)

//Triggered when data is read
fun onReadWorkout2(workouts: List<BleWorkout2>) {}
```

BleWorkout2  
mStart:Starting time,The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mStart" into a specific time.  
mEnd: End Time,The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mEnd" into a specific time.  
mDuration:The duration of the exercise, the data is in seconds  
mAltitude:Altitude, data in meters  
mAirPressure:Air pressure, data in kPa  
mSpm:Cadence, the value of steps in minutes, directly available  
mMode:Motion type, consistent with the definition of mMode in BleActivity  
mStep:The number of steps, consistent with the definition of mStep in BleActivity  
mDistance:Meters, in meters, for example, if the received data is 56045, it means 56045 meters, approximately equal to 56.045 Km  
mCalorie:Card, in card units, for example, the received data is 56045, which means 56.045 Kcal is approximately equal to 56 Kcal  
mSpeed:Velocity, received data in meters per hour  
mPace:Pace, received data in kilometers per second  
mAvgBpm:average heart rate  
mMaxBpm:maximum heart rate  
mMinBpm:minimum heart rate  
mUndefined:The placeholder is undefined, and the byte alignment is reserved   
mMaxSpm:Maximum stride frequency, unit: steps per minute  
mMinSpm:Minimum stride frequency, unit: steps per minute  
mMaxPace:Maximum (slowest) pace, unit: second per kilometer  
mMinPace:Minimum (fastest) pace, unit: second per kilometer  
mMaxAltitude:Maximum (highest) altitude, data in meters  
mMinAltitude:Minimum (lowest) altitude, data in meters  

Illustrate:    
Some devices use the BleKey.WORKOUT command, which has expired.

### 3.1.6. GPS data

Example

```kotlin
//Data can be read when the device generates sleep data
BleConnector.sendData(BleKey.LOCATION, BleKeyFlag.READ)

//Triggered when data is read
fun onReadLocation(locations: List<BleLocation>) {}
```

BleLocation  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.   
mActivityMode:Motion type, consistent with the definition of mMode in BleActivity  
mAltitude  
mLongitude  
mLatitude

### 3.1.7. Body temperature

Example

```kotlin
//The temperature of the device changes and the data can be read
BleConnector.sendData(BleKey.TEMPERATURE, BleKeyFlag.READ)

//Triggered when data is read
fun onReadTemperature(temperatures: List<BleTemperature>) {}
```

BleTemperature  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.    
mTemperature:0.1 degrees Celsius, need to divide by 10  

### 3.1.8. Blood oxygen

Example

```kotlin
//The blood oxygen of the device changes and the data can be read
BleConnector.sendData(BleKey.BLOOD_OXYGEN, BleKeyFlag.READ)

//Triggered when data is read
fun onReadBloodOxygen(bloodOxygen: List<BleBloodOxygen>) {}
```

BleBloodOxygen  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.   
mValue:Blood oxygen value, if the transmission is 90, it will be displayed as 90% in the end

### 3.1.9. HRV

Example

```kotlin
//Device HRV changes and data can be read
BleConnector.sendData(BleKey.HRV, BleKeyFlag.READ)

//Triggered when data is read
fun onReadBleHrv(hrv: List<BleHrv>) {}
```

BleHrv  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.    
mValue:If the last measured value is 90, it will be displayed as 90 in the end.

### 3.1.10. Pressure

Example

```kotlin
//Device pressure changes can read data
BleConnector.sendData(BleKey.PRESSURE, BleKeyFlag.READ)

//Triggered when data is read
fun onReadPressure(pressures: List<BlePressure>) {}
```

BlePressure  
mTime:The number of seconds from the local 2000/1/1 00:00:00, you need to use "toTimeMillis()" to convert "mTime" into a specific time.    
mValue:If the last measured value is 90, it will be displayed as 90 in the end.

## 3.2. Setting

### 3.2.1. System time

Example

```kotlin
//System time
BleConnector.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
```

### 3.2.2. Local time zone

Example

```kotlin
//The time zone of the current phone
BleConnector.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
```

### 3.2.3. Electricity

Example

```kotlin
//read
BleConnector.sendData(BleKey.POWER, BleKeyFlag.READ)

//Triggered when data is read
fun onReadPower(power: Int) {}
```

### 3.2.4. Firmware version

Example

```kotlin
//read
BleConnector.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)

//Triggered when data is read
fun onReadFirmwareVersion(version: String) {}
```

### 3.2.5. Ble address

Example

```kotlin
//read
BleConnector.sendData(BleKey.BLE_ADDRESS, BleKeyFlag.READ)

//Triggered when data is read
fun onReadBleAddress(address: String) {}
```

### 3.2.6. User Info

Example

```kotlin
//set
BleConnector.sendObject(BleKey.USER_PROFILE, BleKeyFlag.UPDATE, bleUserProfile)
```

BleUserProfile  
mUnit:Metric and imperial units, 0: metric, 1: imperial    
mGender:Gender, 0: female, 1: male    
mAge:age   
mHeight:Height (0.5 CM), such as 172.1cm  
mWeight:Body weight (0.5 KG), such as 80.1kg

### 3.2.7. Step goal

Example

```kotlin
//Value is an integer, which can be 1000 steps, 10000 steps, etc.
BleConnector.sendInt32(BleKey.STEP_GOAL, BleKeyFlag.UPDATE, value)
```

### 3.2.8. Backlight duration

Example

```kotlin
//0 is off, or 5 ~ 20s
BleConnector.sendInt8(BleKey.BACK_LIGHT, BleKeyFlag.UPDATE, value)
```

### 3.2.9. Sedentary reminder

Example

```kotlin
//set
BleConnector.sendObject(BleKey.SEDENTARINESS, BleKeyFlag.UPDATE, bleSedentariness)

//read
BleConnector.sendData(BleKey.SEDENTARINESS, BleKeyFlag.READ)

//read return
fun onReadSedentariness(sedentarinessSettings: BleSedentarinessSettings) {}
```

BleSedentarinessSettings  
mEnabled:switch  
mRepeat:repeat  
mStartHour:start hour  
mStartMinute:start minutes  
mEndHour:end hour  
mEndMinute:end minute  
mInterval:Reminder interval, minutes

### 3.2.10. Do not disturb

Example

```kotlin
//set
BleConnector.sendObject(BleKey.NO_DISTURB_RANGE, BleKeyFlag.UPDATE, bleNoDisturbSettings)

//read
BleConnector.sendData(BleKey.NO_DISTURB_RANGE, BleKeyFlag.READ)

//read return
fun onNoDisturbUpdate(noDisturbSettings: BleNoDisturbSettings) {}
```

BleNoDisturbSettings  
mEnabled:switch  
mBleTimeRange1:Currently only use this, refer to "BleTimeRange"

### 3.2.11. Vibration

Example

```kotlin
//0 ~ 10, 0 is off
BleConnector.sendInt8(BleKey.VIBRATION, BleKeyFlag.UPDATE, value)

//read
BleConnector.sendData(BleKey.VIBRATION, BleKeyFlag.READ)

//read return
fun onVibrationUpdate(value: Int) {}
```

### 3.2.12. Gesture wake

Example

```kotlin
//set
BleConnector.sendObject(BleKey.GESTURE_WAKE, BleKeyFlag.UPDATE, bleGestureWake)

//read
BleConnector.sendData(BleKey.GESTURE_WAKE, BleKeyFlag.READ)

//read return
fun onReadGestureWake(gestureWake: BleGestureWake) {}
```

BleGestureWake  
mBleTimeRange:Refer to "BleTimeRange"

### 3.2.13. 12/24 hours

Example

```kotlin
// 0: 24-hourly; 1: 12-hourly
BleConnector.sendInt8(BleKey.HOUR_SYSTEM, BleKeyFlag.UPDATE, value)
```

### 3.2.14. Language settings

Example

```kotlin
//Set to the language of the current phone
BleConnector.sendInt8(BleKey.LANGUAGE, BleKeyFlag.UPDATE, Languages.languageToCode())
```

### 3.2.15. Alarm clock

Example

```kotlin
//Add an alarm clock, the example creates a 1-minute alarm clock
val calendar = Calendar.getInstance().apply { add(Calendar.MINUTE, 1) }
BleConnector.sendObject(
    BleKey.ALARM, BleKeyFlag.CREATE,
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

//Read device's alarm clock
BleConnector.sendInt8(BleKey.ALARM, BleKeyFlag.READ, ID_ALL)

//Edit your device's alarm clock
alarm.mEnabled = if (alarm.mEnabled == 0) 1 else 0
BleConnector.sendObject(BleKey.ALARM, BleKeyFlag.UPDATE, alarm)
                                
//delete alarm
BleConnector.sendInt8(BleKey.ALARM, BleKeyFlag.DELETE, alarms[0].mId)

//Triggered when an alarm is created on the device
fun onAlarmAdd(alarm: BleAlarm) {}

//Fired when the device returns to the list of alarms.
fun onReadAlarm(alarms: List<BleAlarm>) {}

//Triggered when the alarm clock is modified on the device side.
fun onAlarmUpdate(alarm: BleAlarm) {}

//Triggered when the device deletes the alarm.
fun onAlarmDelete(id: Int) {}
```

BleAlarm  
mEnabled:0: off, 1: on  
mRepeat:Repeat settings, see BleRepeat for details  
mYear:year  
mMonth:month  
mDay:day  
mHour:hour  
mMinute:minute  
mTag:label description

Note: Because the current alarm clock is cyclic, if the user turns off the alarm clock after the alarm clock responds, it will still respond in the next cycle; if it is a single alarm clock, the app needs to judge by itself.

### 3.2.16. Find phone

Example

```kotlin
//When the device starts to find the mobile phone to trigger, the App can play the sound
fun onFindPhone(start: Boolean) {}
```

### 3.2.17. Anti-lost

Example

```kotlin
// 0: off; 1: on
BleConnector.sendInt8(BleKey.ANTI_LOST, BleKeyFlag.UPDATE, value)
```

### 3.2.18. Timing heart rate

Example

```kotlin
val hrMonitoring = BleHrMonitoringSettings(
  mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
  mInterval = 60 // an hour
)
BleConnector.sendObject(BleKey.HR_MONITORING, BleKeyFlag.UPDATE, hrMonitoring)
```

BleHrMonitoringSettings  
mBleTimeRange:For details, refer to BleTimeRange  
mInterval:Interval time, minutes

### 3.2.19. UI package version

Example

```kotlin
//Get UI version (format x.x.x)
BleConnector.sendData(BleKey.UI_PACK_VERSION, BleKeyFlag.READ)

//Fired when the device returns a firmware version.
fun onReadUiPackVersion(version: String) {}
```

### 3.2.20. Language package version

Example

```kotlin
//Get language pack version (format x.x.x)
BleConnector.sendData(BleKey.LANGUAGE_PACK_VERSION, BleKeyFlag.READ)

//Triggered when the device returns a language pack version
fun onReadLanguagePackVersion(version: BleLanguagePackVersion) {}
```

### 3.2.21. Menstrual period

Example

```kotlin
BleConnector.sendObject(
    BleKey.GIRL_CARE, BleKeyFlag.UPDATE,
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
```

BleGirlCareSettings  
mEnabled:switch  
mReminderHour:reminder hour 
mReminderMinute:reminder minutes  
mMenstruationReminderAdvance:Menstrual period reminder days in advance    
mOvulationReminderAdvance:Days in advance of ovulation reminder    
mLatestYear:Date of last menstrual period    
mLatestMonth
mLatestDay  
mMenstruationDuration:Period duration, days  
mMenstruationPeriod:menstrual cycle, days

### 3.2.22. Temperature unit

Example

```kotlin
//value, 0: Celsius; 1: Fahrenheit
BleConnector.sendInt8(BleKey.TEMPERATURE_UNIT, BleKeyFlag.UPDATE, value)
```

### 3.2.23. Date format

Example

```kotlin
// value, 0: yyyymmdd; 1: ddmmyyyy; 2: mmddyyyy;
BleConnector.sendInt8(BleKey.DATE_FORMAT, BleKeyFlag.UPDATE, value)
```

### 3.2.24. Drink water reminder

Example

```kotlin
BleDrinkWaterSettings(
    mEnabled = 1,
    // Monday ~ Saturday
    mRepeat = MONDAY or TUESDAY or WEDNESDAY or THURSDAY or FRIDAY or SATURDAY,
    mStartHour = 1,
    mStartMinute = 1,
    mEndHour = 22,
    mEndMinute =1,
    mInterval = 60
).also {
    BleConnector.sendObject(BleKey.DRINK_WATER, BleKeyFlag.UPDATE, it)
}
```

### 3.2.25. Find watch

Example

```kotlin
BleConnector.sendInt8(BleKey.FIND_WATCH, BleKeyFlag.UPDATE, 1)
```

### 3.2.26. Power save mode

Example

```kotlin
//value, 0:close, 1:open
BleConnector.sendInt8(BleKey.POWER_SAVE_MODE, BleKeyFlag.UPDATE, value)
```

### 3.2.27. Heart rate warning

Example

```kotlin
BleConnector.sendObject(
   BleKey.HR_WARNING_SET, BleKeyFlag.UPDATE,
   BleHrWarningSettings(
      mHighSwitch = 1,
      mHighValue = 150,
      mLowSwitch = 1,
      mLowValue = 60
   )
)
```

BleHrWarningSettings
mHighSwitch：High heart rate reminder switch, 0: off, 1: on
mHighValue: High heart rate reminder threshold
mLowSwitch: Low heart rate reminder switch, 0: off, 1: on
mLowValue: Low heart rate reminder threshold

### 3.2.31. Standby watchface settings

Example

```kotlin

val standbyWatchFaceSet = BleStandbyWatchFaceSet(
    mStandbyEnable = 1, //Enable the switch. If it is turned off, the settings below will be invalid.
    mEnabled = 1, // The main switch and the lower time period switch are mutually exclusive
    mBleTimeRange1 = BleTimeRange(0, 8, 0, 22, 0),
)
BleConnector.sendObject(BleKey.STANDBY_WATCH_FACE_SET, BleKeyFlag.UPDATE, standbyWatchFaceSet)

//Triggered when reading.
fun onReadStandbyWatchFaceSet(standbyWatchFaceSet: BleStandbyWatchFaceSet) {}

//Fired when the device is updated.
fun onStandbyWatchFaceSetUpdate(standbyWatchFaceSet: BleStandbyWatchFaceSet) {}

```

BleStandbyWatchFaceSet  
mStandbyEnable: Enable switch, turn off the following settings are invalid
mEnabled: Master switch, mutually exclusive with time period switch
mBleTimeRange1: Period

### 3.2.32. Blood oxygen settings

Example

```kotlin

val bloodOxyGenSettings = BleBloodOxyGenSettings(
    mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
    mInterval = 60 // an hour
)
BleConnector.sendObject(BleKey.BLOOD_OXYGEN_SET, BleKeyFlag.UPDATE, bloodOxyGenSettings)

//Triggered when reading
fun onReadBloodOxyGenSettings(bloodOxyGenSettings: BleBloodOxyGenSettings) {}

```

## 4.3. Push

### 4.3.1. Notification

Example

```kotlin
val bleNotification = BleNotification(
                                mCategory = BleNotification.CATEGORY_MESSAGE,
                                mTime = Date().time,
                                mPackage = BleNotification.PACKAGE_SMS,
                                mTitle = "Phone number",
                                mContent = "SMS body"
                            )
BleConnector.sendObject(BleKey.NOTIFICATION, BleKeyFlag.UPDATE, bleNotification)
```

BleNotification  
mCategory:Notification type, please refer to the sdk sample code for specific usage.  
mTime:timestamp, ms  
mPackage:Package names  
mTitle:title  
mContent:notification content

### 4.3.2. Schedule

Example

```kotlin
//Create a schedule in 1 minute
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

//edit schedule
schedule.mHour = 23
BleConnector.sendObject(BleKey.SCHEDULE, BleKeyFlag.UPDATE, schedule)
                                
//delete schedule
BleConnector.sendInt8(BleKey.SCHEDULE, BleKeyFlag.DELETE, schedules[0].mId)
```

BleSchedule  
mYear:year  
mMonth:month  
mDay:day  
mHour:hour  
mMinute:minute  
mAdvance:advance reminder, minutes  
mTitle:title    
mContent:content  

### 4.3.3. Weather

Example

```kotlin
//Send real-time weather
BleConnector.sendObject(
    BleKey.WEATHER_REALTIME, BleKeyFlag.UPDATE, BleWeatherRealtime(
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

//send weather forecast
BleConnector.sendObject(
    BleKey.WEATHER_FORECAST, BleKeyFlag.UPDATE, BleWeatherForecast(
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
```

BleWeather  
mCurrentTemperature:Celsius，for BleWeatherRealtime  
mMaxTemperature:Celsius，for BleWeatherForecast  
mMinTemperature:Celsius，for BleWeatherForecast  
mWeatherCode:weather type，for both  
mWindSpeed:wind speed km/h，for both  
mHumidity:Prominence %，for both  
mVisibility: visibility km，for both  
mUltraVioletIntensity: UV intensity，[0, 2] -> low, [3, 5] -> moderate, [6, 7] -> high, [8, 10] -> very high, >10 -> extreme for BleWeatherForecast  
mPrecipitation: precipitation mm，for both

BleWeatherRealtime  
mTime:timestamp, seconds  
mWeather:Refer to BleWeather

BleWeatherForecast  
mTime:timestamp, seconds  
mWeather1:today's weather,Refer to BleWeather 
mWeather2:the weather tomorrow,Refer to BleWeather 
mWeather3:the weather the day after tomorrow,Refer to BleWeather

Illustrate:  
Make sure that the time and time zone of the device are set, and the device will display the real-time weather and weather forecast information at the same time.

## 4.4. Control

### 4.4.1. Camera

Example

```kotlin
//Press the device to enter the camera function
BleConnector.sendInt8(BleKey.CAMERA, BleKeyFlag.UPDATE, CameraState.ENTER)

//Control the device to exit the camera function
BleConnector.sendInt8(BleKey.CAMERA, BleKeyFlag.UPDATE, CameraState.EXIT)

//Triggered when the device actively performs camera-related operations
fun onCameraStateChange(cameraState: Int) {}
```

CameraState
EXIT = 0 
ENTER = 1
CAPTURE = 2

### 4.4.2. Music control

1. The device controls the mobile phone music player and needs to be configured:

```xml
<service
    android:name=".MyNotificationListenerService"
    android:label="@string/app_name"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService" />
    </intent-filter>
</service>
```

2. request for access

```kotlin
if (MyNotificationListenerService.isEnabled(mContext)) {
    MyNotificationListenerService.checkAndReEnable(mContext)
} else {
    MyNotificationListenerService.toEnable(mContext)
}
```

3. Turn on the music player manually, play a song first, let the App recognize it, and then you can use the device to control it.

### 4.4.3. Start sport mode from device

Sports data is generated by the device, such as steps, heart rate, and so on.

1. Some sports modes, such as outdoor sports, require the GPS-assisted positioning of the mobile phone to record the GPS track.

```kotlin
//Triggered when the device requests positioning. Some non-GPS devices will request mobile phone positioning when they are in motion.
fun onRequestLocation(workoutState: Int) {}

```

WorkoutState
START = 1 //start exercising
ONGOING = 2 //In motion, return every 20s
PAUSE = 3
END = 4

2. WorkoutState == START || WorkoutState == ONGOING
   Need to create a Ble Location Reply, the watch will display relevant information, please refer to the sdk sample code

```kotlin
val reply = BleLocationReply(
    mSpeed = 1.11f * mLocationTimes,
    mTotalDistance = 1.11f * mLocationTimes,
    mAltitude = 111 * mLocationTimes
)
BleConnector.sendObject(BleKey.REQUEST_LOCATION, BleKeyFlag.CREATE, reply)

```

BleLocationReply
mSpeed: speed, km/h
mTotalDistance: Cumulative distance, km
mAltitude: Altitude, meters

illustrate:
After the exercise starts, the app can start recording the gps track

2. If "BleDeviceInfo.mSupportDeviceSportData == 1", it supports motion status linkage and motion data is returned to the App in real time.

```kotlin
//App motion starts or changes, will notify the device
BleConnector.sendObject(
   BleKey.APP_SPORT_STATE, BleKeyFlag.UPDATE, BleAppSportState(
      mMode, mState
   )
)

//Fired when the user controls a motion state change from the device
fun onUpdateAppSportState(state: BleAppSportState) {}


//During the exercise, the device will return the exercise data in real time
fun onDeviceSportDataUpdate(deviceSportData: BleDeviceSportData) {}

```

BleAppSportState
mMode: Motion type, consistent with the definition of mMode in BleActivity
mState: exercise state

mState
STATE_START = 1 //start exercising
STATE_RESUME = 2 //resume sports
STATE_PAUSE = 3 //pause motion
STATE_END = 4 //knot speed exercise

BleDeviceSportData
mDuration: Exercise duration, the data is in seconds
mBpm: Current heart rate, bpm
mSpm: Cadence, minutes of steps
mStep: number of steps, unit step
mDistance: meters in meters
mCalorie: Unit kcal
mSpeed: Velocity, received data in meters per hour
mPace: Pace, received data in kilometers per second
mAltitude: current altitude in meters
mRiseAltitude: Ascent altitude, in meters
mMode: Motion type, consistent with the definition of mMode in BleActivity

### 4.4.4. Call control

```kotlin
//Fired when the device takes control of an incoming call. 0 - answer; 1 - reject
fun onIncomingCallStatus(status: Int) {}

```

### 4.4.5. Start sport mode from the app

Sports data is generated by the app, such as the number of steps is obtained through the sensor of the mobile phone.
You need to pass "BleDeviceInfo.mSupportAppSport == 1" to determine whether the device supports this function.

```kotlin
//App motion starts or changes, will notify the device
BleConnector.sendObject(
   BleKey.APP_SPORT_STATE, BleKeyFlag.UPDATE, BleAppSportState(
      mMode, mState
   )
)

//Fired when the user controls a motion state change from the device
fun onUpdateAppSportState(state: BleAppSportState) {}

//The app sends the calculated data to the device, and the device will display it, which can be sent once per second.
BleConnector.sendObject(
   BleKey.APP_SPORT_DATA, BleKeyFlag.UPDATE, BleAppSportData(
      mStep = mStep,
      mDistance = mDistance,
      mCalorie = mCalorie,
      mDuration = mDuration,
      mSpm = mSpm,
      mAltitude = mAltitude,
      mAirPressure = mAirPressure,
      mPace = mPace,
      mSpeed = mSpeed,
      mMode = mMode
   )
)

//During the exercise, the device will return the heart rate value in real time
fun onUpdateHeartRate(heartRate: BleHeartRate) {}

```

BleAppSportState
mMode: Motion type, consistent with the definition of mMode in BleActivity, here only supports INDOOR, OUTDOOR, CYCLING, CLIMBING four
mState: exercise state

mState
STATE_START = 1 //start exercising
STATE_RESUME = 2 //resume sports
STATE_PAUSE = 3 //pause motion
STATE_END = 4 //knot speed exercise

BleAppSportData
mStep: The number of steps is consistent with the definition of mStep in BleActivity, and the number of steps is obtained from the mobile phone pedometer
mDistance: Meters, in meters, for example, if the received data is 56045, it means 56045 meters, approximately equal to 56.045 Km
mCalorie: in kcal
mDuration: The duration of the exercise, the data is in seconds
mSpm: Average stride frequency, the value of steps in minutes
mAltitude: Altitude, data in meters
mAirPressure: Air pressure, data in kPa
mPace: Average pace, received data in kilometers per second
mSpeed: Average speed, received data in kilometers per hour
mMode: Motion type, consistent with the definition of mMode in BleActivity

illustrate:
App motion features and on-device motion features are two different features.
Main difference:
The device's motion function, when some motion modes require mobile phone-assisted positioning, the corresponding callback will be triggered, and the App will send the calculated positioning information to the device.
The exercise function of the mobile phone can be used independently without binding the device. If the device is bound, the data generated by the exercise state and exercise process can be sent to the device in real time. The device can return the heart rate in real time and control the exercise state.

## 4.5. File

```
//The sending progress of the file uses this callback
fun onStreamProgress(status: Boolean, errorCode: Int, total: Int, completed: Int) {}
```

### 4.5.1. Watch face

```kotlin
BleConnector.sendStream(BleKey.WATCH_FACE, file)
```

### 4.5.2. AGPS

```kotlin
BleConnector.sendStream(BleKey.AGPS_FILE, file)
```

### 4.5.3. Font package

```kotlin
BleConnector.sendStream(BleKey.FONT_FILE, file)
```

### 4.5.4. Contact

```kotlin
//For details, refer to the sample code of the sdk
BleConnector.sendStream(BleKey.CONTACT, bytes)
```

### 4.5.5. UI package

```kotlin
BleConnector.sendStream(BleKey.UI_FILE, file)
```

### 4.5.6. Language package

```kotlin
BleConnector.sendStream(BleKey.LANGUAGE_FILE, file)
```

## 4.6. OTA

Generally, there are three files, which are firmware package, UI package and font package. If multiple languages are supported, there are also language packs. The filename contains version information.  

Firmware: In most cases, only the firmware package can be used. Use the ota sdk provided by the chip platform. For details, please refer to the sample code of the sdk.  

UI package: update only if the UI package needs to be updated or the device interface display is abnormal.  

Font package: Only when the device font display is abnormal, it needs to be updated, and it can be sent directly.
