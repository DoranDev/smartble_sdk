# 1. 概述

SMART V3 Android SDK是一套基于Android 5.1及以上版本的应用程序接口。您可以使用该套SDK开发适用于Android手机的App，通过调用SMART V3 SDK接口，您可以轻松构建功能丰富、交互性强的智能手表配套App。  

# 2. 开发指南

## 2.1. 项目配置

1. 将libs文件夹里的文件导入项目，其中AndroidBaseBle.aar、AndroidDfuLib.aar和AndroidSmaBle.aar这三个文件是必须的，其它文件是芯片厂商提供的OTA SDK，可以根据情况是否引用，配置build.gralde:

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

2. 在AndroidManifest.xm中声明必要权限：

```xml
<manifest>
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>  
```

如果需要支持Nordic的设备，需要在AndroidManifest.xml中注册用于固件升级的DFU服务：

```xml
<service android:name="com.szabh.androidblesdk3.firmware.n.DfuService" />
```

如果需要支持Realtek的设备，需要在AndroidManifest.xml中注册用于固件升级的DFU服务：

```xml
<service android:name="com.realsil.sdk.dfu.DfuService" />
```

## 2.2. 开发流程

1. 初始化，在"Application.onCreate()"中：

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

2. 连接设备，声明Scanner

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

3. 开始扫描

```kotlin
mBleScanner.scan(true)
```

该操作需要获得定位权限，在部分手机还需要开启定位服务，否则搜索不到设备。如果手机蓝牙为开启状态，会触发"onScan(true)"，否则触发"onBluetoothDisabled()"，扫描到匹配的设备时会触发"onDeviceFound(device)"。在指定的scanDuration时间后，扫描会自动停止，中途也可以调用"mBleScanner.scan(false)"手动停止，停止时会触发"onScan(false)"。

4. 退出扫描

在界面销毁时，调用"mBleScanner.exit()"退出扫描，以防止内存泄露。

5. 连接设备

```kotlin
//连接设备
BleConnector.setBleDevice(bleDevice).connect(true)

//Returns true if Ble is connected
BleConnector.isAvailable()

//设备连接成功时触发
fun onDeviceConnected(device: BluetoothDevice) {}
```

6. 绑定/登录

连接成功之后，框架内部会根据状态自动发送绑定或登陆指令到设备。  
a. 未绑定设备，会先发送绑定指令，设备确认绑定后，会保存设备相关信息，然后发送登陆指令。  
b. 如果已经绑定设备，直接发送登陆指令。  
登陆成功之后便可与设备通讯了。

```kotlin
//Returns true if Ble is paired
BleConnector.isBound()

//配对成功触发, 可以同步一些用户设置，BleDeviceInfo建议保存起来
fun onIdentityCreate(status: Boolean, deviceInfo: BleDeviceInfo? = null) {}

//连接状态变化时触发，status为true时可以同步一些用户设置，如时间，时区等，参考sdk示例代码
fun onSessionStateChange(status: Boolean) {}

//连接成功后，如果想配对3.0
BleConnector.connectClassic()
```

BleDeviceInfo  
mBleName:蓝牙名  
mBleAddress:Ble地址  
mPlatform:设备平台  
mPrototype:设备原型  
mFirmwareFlag:固件标记  
mAGpsType:agps类型  
mClassicAddress:BT 3.0地址  
mShowAntiLostSwitch:是否显示防丢开关, BleKey.ANTI_LOST
mSupportDateFormatSet:是否支持日期格式设置, BleKey.DATE_FORMAT
mSupportTemperatureUnitSet:是否支持温度单位设置, BleKey.TEMPERATURE_UNIT
mSupportDrinkWaterSet:是否支持喝水提醒的设置, BleKey.DRINK_WATER
mSupportAppSport:是否支持通过app发起运动，控制运动状态, BleKey.APP_SPORT_STATE, BleKey.APP_SPORT_DATA
mSupportWashSet:是否支持洗手提醒的设置
mSupportFindWatch:是否支持找手表
mSupportWorldClock:是否支持世界时钟
mSupportStock:是否支持股票
mSupportPowerSaveMode:是否支持省电模式
mSupportWeather2:是否支持七天天气
mSupport2DAcceleration:是否支持2d加速
mSupportHrWarnSet:是否支持心率预警设置

说明:
BleDeviceInfo属性比较多，这里只列出可能要用到的属性，获取到后建议把BleDeviceInfo保存起来。

7. 发送指令

当前协议是采用发送/回复的方式，其中回复框架内部已作处理，只需要发送blekey就行。发送指令的主要方式为调用BleConnector对象中以send开头的方法。当设备回复手机发送的指令和主动发送指令时，都会触发事件，这些事件会通过"BleHandleCallback"在主线程派发，在任何需要处理事件的地方通过"BleConnector.addHandleCallback(BleHandleCallback)"注册一个事件回调，就能收到相应的事件，并做出相应的处理。如果回调接口是在UI组件中注册的，在UI组件销毁时应调"BleConnector.removeHandleCallback(BleHandleCallback)"移除该回调接口，否则会导致内存泄漏。  
例如使用"BleConnector.sendData(BleKey.DATA_ALL, BleKeyFlag.READ)"，请求所有支持数据类型。   
具体请求可参考类 "BleKey"    
0x05FF\_DATA\_ALL：App本身虚构的一个特殊标记，指代当前设备支持的所有数据。  
0x0502\_ACTIVITY：其包含步数\卡路里\距离，可参考类 "BleActivity"  
0x0503\_HEART\_RATE：心率，可参考类 "BleHeartRate"  
0x0505\_SLEEP：睡眠，可参考类 "BleSleep"  

8. 解绑设备

```kotlin
// Send an unbind command, some devices will trigger BleHandleCallback.onIdentityDelete() after replying
BleConnector.sendData(BleKey.IDENTITY, BleKeyFlag.DELETE)
// Wait for a while and then unbind
Handler().postDelayed({
    BleConnector.unbind()
    unbindCompleted()
}, 2000)

//解绑时触发，有些设备解绑会触发，但有些不会
fun onIdentityDelete(status: Boolean) {}

//设备主动解绑时触发，例如设备恢复出厂设置，或者ota完成后，app需要重新配对。
fun onIdentityDeleteByDevice(isDevice: Boolean) {}
```

# 3.功能说明

## 3.1. 数据

### 3.1.1. 步数、距离、消耗卡路里

示例

```kotlin
//设备步数发生变化可以读取数据
BleConnector.sendData(BleKey.ACTIVITY, BleKeyFlag.READ)

//读取到数据时触发
fun onReadActivity(activities: List<BleActivity>) {}
```

BleActivity  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间  
mMode:运动模式
mState:运动状态
mStep: 步数，例如值为10，即代表走了10步  
mCalorie:消耗的卡路量，1/10000千卡，例如接收到的数据为56045，则代表 5.6045 Kcal 约等于 5.6 Kcal  
mDistance:1/10000米，例如接收到的数据为56045，则代表移动距离 5.6045 米 约等于 5.6 米  

mState
BEGIN = 0 // 开始
ONGOING = 1 // 进行中
PAUSE = 2 // 暂停
RESUME = 3 // 继续
END = 4 // 结束

mMode
RUNNING = 7     // 跑步  
INDOOR = 8      // 室内运动，跑步机  
OUTDOOR = 9     // 户外运动  
CYCLING = 10    // 骑行  
SWIMMING = 11   // 游泳  
WALKING = 12    // 步行，健走  
CLIMBING = 13   // 爬山  
YOGA = 14       // 瑜伽  
SPINNING = 15   // 动感单车  
BASKETBALL = 16 // 篮球  
FOOTBALL = 17   // 足球  
BADMINTON = 18  // 羽毛球  
MARATHON = 19  // 马拉松 
INDOOR_WALKING = 20  // 室内步行  
FREE_EXERCISE = 21  // 自由锻炼  
AEROBIC_EXERCISE = 22  // 有氧运动  
WEIGHTTRANNING = 23  // 力量训练  
WEIGHTLIFTING = 24  // 举重  
BOXING = 25   // 拳击  
JUMP_ROPE = 26    // 跳绳  
CLIMB_STAIRS = 27 // 爬楼梯  
SKI = 28  // 滑雪  
SKATE = 29    // 滑冰  
ROLLER_SKATING = 30   // 轮滑  
HULA_HOOP = 32    // 呼啦圈 
GOLF = 33 // 高尔夫  
BASEBALL = 34 // 棒球 
DANCE = 35    // 舞蹈  
PING_PONG = 36    // 乒乓球 
HOCKEY = 37   // 曲棍球  
PILATES = 38  // 普拉提  
TAEKWONDO = 39    // 跆拳道  
HANDBALL = 40 // 手球  
DANCE_STREET = 41 // 街舞  
VOLLEYBALL = 42   // 排球  
TENNIS = 43   // 网球  
DARTS = 44    // 飞镖  
GYMNASTICS = 45   // 体操  
STEPPING = 46 // 踏步  
ELLIPIICAL = 47 //椭圆机  
ZUMBA = 48 //尊巴  
CRICHKET = 49  // 板球  
TREKKING = 50 // 徒步旅行  
AEROBICS = 51 // 有氧运动  
ROWING_MACHINE = 52    // 划船机  
RUGBY = 53    // 橄榄球  
SIT_UP = 54   // 仰卧起坐  
DUM_BLE = 55  // 哑铃  
BODY_EXERCISE = 56     // 健身操  
KARATE = 57   // 空手道  
FENCING = 58  // 击剑  
MARTIAL_ARTS = 59      // 武术  
TAI_CHI = 60  // 太极拳  
FRISBEE = 61  // 飞盘  
ARCHERY = 62  // 射箭  
HORSE_RIDING = 63      // 骑马 
BOWLING = 64  // 保龄球  
SURF = 65     // 冲浪  
SOFTBALL = 66 // 垒球  
SQUASH = 67   // 壁球  
SAILBOAT = 68 // 帆船  
PULL_UP = 69  // 引体向上  
SKATEBOARD = 70 // 滑板  
TRAMPOLINE = 71 // 蹦床  
FISHING = 72  // 钓鱼  
POLE_DANCING = 73      // 钢管舞  
SQUARE_DANCE = 74      // 广场舞  
JAZZ_DANCE = 75 // 爵士舞  
BALLET = 76   // 芭蕾舞  
DISCO = 77    // 迪斯科  
TAP_DANCE = 78// 踢踏舞  
MODERN_DANCE = 79      // 现代舞  
PUSH_UPS = 80 // 俯卧撑  
SCOOTER = 81  // 滑板车  
PLANK = 82     // 平板支撑  
BILLIARDS = 83 // 桌球  
ROCK_CLIMBING = 84
DISCUS = 85    // 铁饼  
RACE_RIDING = 86 // 赛马  
WRESTLING = 87 // 摔跤  
HIGH_JUMP = 88 // 跳高  
PARACHUTE = 89 // 跳伞  
SHOT_PUT = 90  // 铅球  
LONG_JUMP = 91 // 跳远  
JAVELIN = 92   // 标枪  
HAMMER = 93    // 链球  
SQUAT = 94     // 深蹲  
LEG_PRESS = 95 // 压腿  
OFF_ROAD_BIKE = 96 // 越野自行车  
MOTOCROSS = 97 // 越野摩托车 
ROWING = 98    // 赛艇  
CROSSFIT = 99  // CROSSFIT  
WATER_BIKE = 100 // 水上自行车  
KAYAK = 101    // 皮划艇  
CROQUET = 102  // 槌球  
FLOOR_BALL = 103   //  地板球  
THAI = 104     // 泰拳 
JAI_BALL = 105 // 回力球  
TENNIS_DOUBLES = 106    // 网球(双打)  
BACK_TRAINING = 107     // 背部训练  
WATER_VOLLEYBALL = 108  // 水上排球  
WATER_SKIING = 109      // 滑水  
MOUNTAIN_CLIMBER = 110  // 登山机  
HIIT = 111     // HIIT  高强度间歇性训练  
BODY_COMBAT = 112  // BODY COMBAT 搏击（拳击）的一种  
BODY_BALANCE = 113  // BODY BALANCE  瑜伽、太极和普拉提融合在一起的身心训练项目  
TRX = 114      // TRX 全身抗阻力锻炼 全身抗阻力锻炼  
TAE_BO = 115   // 跆搏（TAE BO）   集跆拳道、空手道、拳击、自由搏击、舞蹈韵律操为一体  


### 3.1.2. 心率 

示例

```kotlin
//设备心率发生变化可以读取数据
BleConnector.sendData(BleKey.HEART_RATE, BleKeyFlag.READ)

//读取到数据时触发
fun onReadHeartRate(heartRates: List<BleHeartRate>) {}
```

BleHeartRate  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间  
mBpm: 心率值

参考等级:
1.心率 < 60 低
2.心率 60 ~ 100 正常
3.心率 > 100 高

### 3.1.3. 血压

示例

```kotlin
//设备血压发生变化可以读取数据
BleConnector.sendData(BleKey.BLOOD_PRESSURE, BleKeyFlag.READ)

//读取到数据时触发
fun onReadBloodPressure(bloodPressures: List<BleBloodPressure>) {}
```

BleBloodPressure  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间  
mSystolic:收缩压  
mDiastolic:舒张压  

### 3.1.4. 睡眠

示例

```kotlin
//设备产生睡眠数据时可以读取数据
BleConnector.sendData(BleKey.SLEEP, BleKeyFlag.READ)

//读取到数据时触发
fun onReadSleep(sleeps: List<BleSleep>) {}
```

BleSleep  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间    
mMode:睡眠状态  
mSoft: 轻动，即睡眠过程中检测到相对轻微的动作  
mStrong: 重动，即睡眠过程中检测到相对剧烈的运动  

说明：  
读取到的"List<BleSleep>"有可能是多天的数据，可以将数据保存起来，App根据时间分开得到每天的sleep数据，计算得出睡眠时长，示例

```kotlin
//分析睡眠数据，sleeps为一天的睡眠数据
val analyseSleep = BleSleep.analyseSleep(sleeps, 1)
val statusSleep = BleSleep.getSleepStatusDuration(analyseSleep, sleeps)
//睡眠总时长
val deepMinute= statusSleep[BleSleep.DEEP]
val lightMinute= statusSleep[BleSleep.LIGHT]
val awakeMinute= statusSleep[BleSleep.AWAKE]
val totalMinute = statusSleep[BleSleep.TOTAL_LENGTH]
```

参考等级:
1.总时长 > 9 * 60（分钟）差
2.总时长 > 7 * 60（分钟)
   深睡时长 >= 2 * 60（分钟）良好
   深睡时长 >= 1 * 60（分钟）一般
   深睡时长 < 1 * 60（分钟）差
3.总时长 < 7 * 60（分钟) 差


### 3.1.5. 运动数据

示例

```kotlin
//设备产生运动数据时可以读取数据
BleConnector.sendData(BleKey.WORKOUT2, BleKeyFlag.READ)

//读取到数据时触发
fun onReadWorkout2(workouts: List<BleWorkout2>) {}
```

BleWorkout2  
mStart: 开始时间， 距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间  
mEnd: 结束时间， 距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间  
mDuration:运动持续时长，数据以秒为单位  
mAltitude:海拔高度，数据以米为单位  
mAirPressure: 气压，数据以 kPa 为单位  
mSpm: 步频，步数/分钟的值，直接可用  
mMode: 运动类型，与 BleActivity 中的 mMode 定义一致  
mStep:步数，与 BleActivity 中的 mStep 定义一致  
mDistance: 米，以米为单位，例如接收到的数据为56045，则代表 56045 米 约等于 56.045 Km  
mCalorie: 卡，以卡为单位，例如接收到的数据为56045，则代表 56.045 Kcal 约等于 56 Kcal  
mSpeed:速度，接收到的数据以 米/小时 为单位  
mPace: 配速，接收到的数据以 秒/千米 为单位  
mAvgBpm: 平均心率  
mMaxBpm:最大心率  
mMinBpm:最小心率  
mUndefined:占位用未定义，字节对齐预留  
mMaxSpm: 最大步频，单位：步数每分钟  
mMinSpm: 最小步频，单位：步数每分钟  
mMaxPace: 最大(最慢)配速，单位：秒每公里  
mMinPace: 最小(最快)配速，单位：秒每公  
mMaxAltitude: 最大（最高）海拔高度，数据以米为单位  
mMinAltitude: 最小（最低）海拔高度，数据以米为单位  

说明：  
有些设备使用的是BleKey.WORKOUT指令，这个指令已经过期。  

### 3.1.6. GPS数据

示例

```kotlin
//设备产生睡眠数据时可以读取数据
BleConnector.sendData(BleKey.LOCATION, BleKeyFlag.READ)

//读取到数据时触发
fun onReadLocation(locations: List<BleLocation>) {}
```

BleLocation  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间   
mActivityMode:运动类型，与 BleActivity 中的 mMode 定义一致  
mAltitude  
mLongitude  
mLatitude  

### 3.1.7. 体温

示例

```kotlin
//设备体温发生变化可以读取数据
BleConnector.sendData(BleKey.TEMPERATURE, BleKeyFlag.READ)

//读取到数据时触发
fun onReadTemperature(temperatures: List<BleTemperature>) {}
```

BleTemperature  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间    
mTemperature: 0.1摄氏度，需要除以10  

### 3.1.8. 血氧

示例

```kotlin
//设备血氧发生变化可以读取数据
BleConnector.sendData(BleKey.BLOOD_OXYGEN, BleKeyFlag.READ)

//读取到数据时触发
fun onReadBloodOxygen(bloodOxygen: List<BleBloodOxygen>) {}
```

BleBloodOxygen  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间   
mValue: 血氧值，如果传输过来的是90，则最终显示为 90% 即可  

参考等级:
1.血氧 < 92 低
2.血氧 >= 92 正常

### 3.1.9. HRV

示例

```kotlin
//设备HRV发生变化可以读取数据
BleConnector.sendData(BleKey.HRV, BleKeyFlag.READ)

//读取到数据时触发
fun onReadBleHrv(hrv: List<BleHrv>) {}
```

BleHrv  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间   
mValue: 最近一次测量的值，如果传输过来的是90，则最终显示为 90 即可  

参考等级:
1.HRV < 60 低
2.HRV 60 ~ 100 正常
3.HRV > 100 高

### 3.1.10. 压力

示例

```kotlin
//设备压力发生变化可以读取数据
BleConnector.sendData(BleKey.PRESSURE, BleKeyFlag.READ)

//读取到数据时触发
fun onReadPressure(pressures: List<BlePressure>) {}
```

BlePressure  
mTime:距离当地2000/1/1 00:00:00的秒数，需使用"toTimeMillis()"将"mTime"转成具体时间   
mValue: 最近一次测量的值，如果传输过来的是90，则最终显示为 90 即可   

参考等级:
1.压力值 < 25 轻松
2.压力值 < 50 正常
3.压力值 < 75 中度压力
3.压力值 < 100 高度压力

## 3.2. 设置

### 3.2.1. 系统时间

示例

```kotlin
//当前手机的时间
BleConnector.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
```

### 3.2.2. 本地时区

示例

```kotlin
//当前手机的时区
BleConnector.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
```

### 3.2.3. 电量

示例

```kotlin
//读取
BleConnector.sendData(BleKey.POWER, BleKeyFlag.READ)

//读取到数据时触发
fun onReadPower(power: Int) {}
```

### 3.2.4. 固件版本

示例

```kotlin
//读取
BleConnector.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)

//读取到数据时触发
fun onReadFirmwareVersion(version: String) {}
```

### 3.2.5. Ble地址

示例

```kotlin
//读取
BleConnector.sendData(BleKey.BLE_ADDRESS, BleKeyFlag.READ)

//读取到数据时触发
fun onReadBleAddress(address: String) {}
```

### 3.2.6. 用户信息

示例

```kotlin
//设置
BleConnector.sendObject(BleKey.USER_PROFILE, BleKeyFlag.UPDATE, bleUserProfile)
```

BleUserProfile  
mUnit:公英制单位，0：公制，1：英制  
mGender:性别，0：女，1：男   
mAge: 年龄   
mHeight: 身高（0.5 CM），如172.1cm  
mWeight: 体重（0.5 KG）, 如80.1kg  

### 3.2.7. 步数目标

示例

```kotlin
//value为整数，可以是1000步，10000步等。
BleConnector.sendInt32(BleKey.STEP_GOAL, BleKeyFlag.UPDATE, value)
```

### 3.2.8. 背光时长

示例

```kotlin
//0 is off, or 5 ~ 20s
BleConnector.sendInt8(BleKey.BACK_LIGHT, BleKeyFlag.UPDATE, value)
```

### 3.2.9. 久坐提醒

示例

```kotlin
//设置
BleConnector.sendObject(BleKey.SEDENTARINESS, BleKeyFlag.UPDATE, bleSedentariness)

//读取
BleConnector.sendData(BleKey.SEDENTARINESS, BleKeyFlag.READ)

//读取返回
fun onReadSedentariness(sedentarinessSettings: BleSedentarinessSettings) {}
```

BleSedentarinessSettings  
mEnabled: 开关  
mRepeat: 重复  
mStartHour: 开始小时  
mStartMinute: 开时分钟  
mEndHour: 结束小时  
mEndMinute: 结束分钟  
mInterval:提醒间隔，分钟数  

### 3.2.10. 勿扰

示例

```kotlin
//设置
BleConnector.sendObject(BleKey.NO_DISTURB_RANGE, BleKeyFlag.UPDATE, bleNoDisturbSettings)

//读取
BleConnector.sendData(BleKey.NO_DISTURB_RANGE, BleKeyFlag.READ)

//读取返回
fun onNoDisturbUpdate(noDisturbSettings: BleNoDisturbSettings) {}
```

BleNoDisturbSettings  
mEnabled: 开关  
mBleTimeRange1:目前只用到这个，参考"BleTimeRange"  

### 3.2.11. 震动

示例

```kotlin
//0 ~ 10, 0 is off
BleConnector.sendInt8(BleKey.VIBRATION, BleKeyFlag.UPDATE, value)

//读取
BleConnector.sendData(BleKey.VIBRATION, BleKeyFlag.READ)

//读取返回
fun onVibrationUpdate(value: Int) {}
```

### 3.2.12. 抬手亮屏

示例

```kotlin
//设置
BleConnector.sendObject(BleKey.GESTURE_WAKE, BleKeyFlag.UPDATE, bleGestureWake)

//读取
BleConnector.sendData(BleKey.GESTURE_WAKE, BleKeyFlag.READ)

//读取返回
fun onReadGestureWake(gestureWake: BleGestureWake) {}
```

BleGestureWake  
mBleTimeRange:参考"BleTimeRange"  

### 3.2.13. 12/24小时制

示例

```kotlin
// 0: 24-hourly; 1: 12-hourly
BleConnector.sendInt8(BleKey.HOUR_SYSTEM, BleKeyFlag.UPDATE, value)
```

### 3.2.14. 语言设置

示例

```kotlin
//设置成当前手机的语言
BleConnector.sendInt8(BleKey.LANGUAGE, BleKeyFlag.UPDATE, Languages.languageToCode())
```

### 3.2.15. 闹钟

示例

```kotlin
//添加闹钟，示例创建一个1分钟闹钟
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

//读取设备的闹钟
BleConnector.sendInt8(BleKey.ALARM, BleKeyFlag.READ, ID_ALL)

//编辑设备的闹钟
alarm.mEnabled = if (alarm.mEnabled == 0) 1 else 0
BleConnector.sendObject(BleKey.ALARM, BleKeyFlag.UPDATE, alarm)
                                
//删除闹钟
BleConnector.sendInt8(BleKey.ALARM, BleKeyFlag.DELETE, alarms[0].mId)

//设备端创建闹钟时触发。
fun onAlarmAdd(alarm: BleAlarm) {}

//设备返回闹钟列表时触发。
fun onReadAlarm(alarms: List<BleAlarm>) {}

//设备端修改闹钟时触发。
fun onAlarmUpdate(alarm: BleAlarm) {}

//设备端删除闹钟时触发。
fun onAlarmDelete(id: Int) {}
```

BleAlarm  
mEnabled: 0：关闭，1：开启  
mRepeat: 重复设置,详细看BleRepeat 
mYear: 年  
mMonth: 月  
mDay: 日  
mHour: 小时  
mMinute: 分钟  
mTag: 标签说明  

注：因为目前闹钟都是可循环的，所以如果闹钟响应后, 用户关掉了闹钟，那么下一个循环周期还是会响应；如果是单次闹钟，则需要App端自己判断。 

### 3.2.16. 找手机

示例

```kotlin
//当设备发起找手机触发, App可以播放声音
fun onFindPhone(start: Boolean) {}

//找到手机后，app可以发送指令给设备（仅部分设备支持）
BleConnector.sendInt8(BleKey.FIND_PHONE, BleKeyFlag.UPDATE, 1)
```

### 3.2.17. 防丢

示例

```kotlin
// 0: off; 1: on
BleConnector.sendInt8(BleKey.ANTI_LOST, BleKeyFlag.UPDATE, value)
```

### 3.2.18. 定时心率

示例

```kotlin
val hrMonitoring = BleHrMonitoringSettings(
  mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
  mInterval = 60 // an hour
)
BleConnector.sendObject(BleKey.HR_MONITORING, BleKeyFlag.UPDATE, hrMonitoring)
```

BleHrMonitoringSettings  
mBleTimeRange: 具体参考BleTimeRange  
mInterval: 间隔时间，分钟  

### 3.2.19. UI包版本

示例

```kotlin
//获取UI版本(格式x.x.x)
BleConnector.sendData(BleKey.UI_PACK_VERSION, BleKeyFlag.READ)

//设备返回固件版本时触发。
fun onReadUiPackVersion(version: String) {}
```

### 3.2.20. 语言包版本

示例

```kotlin
//获取语言包版本(格式x.x.x)
BleConnector.sendData(BleKey.LANGUAGE_PACK_VERSION, BleKeyFlag.READ)

//设备返回语言包版本时触发
fun onReadLanguagePackVersion(version: BleLanguagePackVersion) {}
```

### 3.2.21. 生理期

示例

```kotlin
//设置生理期
BleConnector.sendObject(
    BleKey.GIRL_CARE, BleKeyFlag.UPDATE,
    BleGirlCareSettings(
        mReminderEnable = 0,//0：关 1：开, 提醒开关设置，BleDeviceInfo.mSupportGirlCareReminder==1才有效
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

//读取生理期设置
BleConnector.sendData(BleKey.GIRL_CARE, BleKeyFlag.READ)

//读取返回
fun onReadGirlCareSettings(girlCareSettings: BleGirlCareSettings) {}

```

BleGirlCareSettings  
mReminderEnable: 提醒开关设置，0：关 1：开, BleDeviceInfo.mSupportGirlCareReminder==1才有效
mEnabled:显示开关  
mReminderHour:提醒小时 
mReminderMinute:提醒分钟  
mMenstruationReminderAdvance:生理期提醒提前天数  
mOvulationReminderAdvance:排卵期提醒提前天数  
mLatestYear:上次生理期日期  
mLatestMonth 
mLatestDay  
mMenstruationDuration:生理期持续时间，天 
mMenstruationPeriod:生理期周期，天  

### 3.2.22. 温度单位

示例

```kotlin
// value, 0: 摄氏度; 1: 华氏度
BleConnector.sendInt8(BleKey.TEMPERATURE_UNIT, BleKeyFlag.UPDATE, value)
```

### 3.2.23. 日期格式

示例

```kotlin
// value, 0: yyyymmdd; 1: ddmmyyyy; 2: mmddyyyy;
BleConnector.sendInt8(BleKey.DATE_FORMAT, BleKeyFlag.UPDATE, value)
```

### 3.2.24. 喝水提醒

示例

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

### 3.2.25. 找手表

示例

```kotlin
BleConnector.sendInt8(BleKey.FIND_WATCH, BleKeyFlag.UPDATE, 1)
```

### 3.2.26. 省电模式

示例

```kotlin
//value, 0:close, 1:open
BleConnector.sendInt8(BleKey.POWER_SAVE_MODE, BleKeyFlag.UPDATE, value)
```

### 3.2.27. 心率警告

示例

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
mHighSwitch：心率过高提醒开关，0：关，1：开
mHighValue: 过高心率提醒阈值
mLowSwitch: 心率过低提醒开关，0：关，1：开
mLowValue: 过低心率提醒阈值

### 3.2.28. 测量设置

APP控制设备进入心率，血压，血氧，压力测量模式

示例

```kotlin

BleConnector.sendObject(
   bleKey,
   bleKeyFlag,
   BleRealTimeMeasurement(
      mHRSwitch = 1, //测量心率,同一时间只能开启一个模式
      mBOSwitch = 0,
      mBPSwitch = 0,
      mStressSwitch = 0,
      mState = BleRealTimeMeasurement.STATE_START
   )
)

//测量结束后会触发回调，如果超过60s没有响应，有可能测量失败
override fun onRealTimeMeasurement(realTimeMeasurement: BleRealTimeMeasurement) {
   //测量成功
   if (realTimeMeasurement.mHRSwitch == 1
      && realTimeMeasurement.mState == BleRealTimeMeasurement.STATE_DONE
   ) {
      //测量结束后可以读取心率值
      BleConnector.sendData(BleKey.HEART_RATE, BleKeyFlag.READ)
   }
}
```

BleRealTimeMeasurement
mHRSwitch: 心率，0：关，1：开
mBOSwitch: 血氧，0：关，1：开
mBPSwitch: 血压，0：关，1：开
mStressSwitch: 压力，0：关，1：开
mState: 测量状态, 0：测量成功/结果，1：测量停止/失败，2：测试开始

### 3.2.29. SOS设置

示例

```kotlin

//S0S设置
BleConnector.sendObject(bleKey, bleKeyFlag, BleSOSSettings(
   mEnabled = 1,
   mPhone = "13012345678"
))

//读取SOS设置
BleConnector.sendData(BleKey.SOS_SET, BleKeyFlag.READ)

//读取SOS设置时触发
fun onReadSOSSettings(sosSettings: BleSOSSettings) {}

```

BleSOSSettings
mEnabled: 开关，0：关，1：开
mPhone: 手机号

### 3.2.30. 设备语言

示例

```kotlin

//读取语言列表
BleConnector.sendData(BleKey.DEVICE_LANGUAGES, BleKeyFlag.READ)

//读取时触发
fun onReadDeviceLanguages(deviceLanguages: BleDeviceLanguages) {}

```

BleDeviceLanguages
mCode: 当前语言id
mSize: 支持语言总数
mList: 语言列表, 参考下面的定义

```kotlin
 //语言定义
 private val LANGUAGES = mapOf(
     "zh" to 0x00, // 中文(简体)
     "en" to 0x01, // 英语
     "tr" to 0x02, // 土耳其语
     "ru" to 0x04, // 俄语
     "es" to 0x05, // 西班牙语
     "it" to 0x06, // 意大利语
     "ko" to 0x07, // 韩语
     "pt" to 0x08, // 葡萄牙语
     "de" to 0x09, // 德语
     "fr" to 0x0A, // 法语
     "nl" to 0x0B, // 荷兰语
     "pl" to 0x0C, // 波兰语
     "cs" to 0x0D, // 捷克语
     "hu" to 0x0E, // 匈牙利语
     "sk" to 0x0F, // 斯洛伐克语
     "ja" to 0x10, // 日语
     "da" to 0x11, // 丹麦
     "fi" to 0x12, // 芬兰
     "no" to 0x13, // 挪威
     "sv" to 0x14, // 瑞典
     "sr" to 0x15, // 塞尔维亚
     "th" to 0x16, // 泰语
     "hi" to 0x17, // 印地语
     "el" to 0x18, // 希腊语
     "Hant" to 0x19, // 中文繁体
     "lt" to 0x1A,  // 立陶宛
     "vi" to 0x1B,  // 越南
     "ar" to 0x1C,  // 阿拉伯语
     "in" to 0x1D,  // 印尼语
     "uk" to 0x1E,  // 乌克兰
     "iw" to 0x20,  // 希伯来语
     "bn" to 0x21,  // 孟加拉语
     "et" to 0x22,  // 爱沙尼亚
     "sl" to 0x23,  // 斯洛文尼亚
     "fa" to 0x24,  // 波斯语
     "ro" to 0x25,  // 罗马尼亚
     "bg" to 0x26,  // 保加利亚
     "hr" to 0x27,  // 克罗地亚
     "ur" to 0x28,  // 乌尔都语
     "ms" to 0x29,  // 马来西亚语
     "jv" to 0x30,  // 爪哇语
     "mr" to 0x31,  // 马拉地语
     "lv" to 0x32,  // 拉脱维亚语
     "la" to 0x33,  // 拉丁语
     "ph" to 0x34,  // 菲律宾语
     "mm" to 0x35,  // 缅甸语
     "ta" to 0x36,  // 泰米尔语
     "te" to 0x37,  // 泰卢固语
     "kn" to 0x38   // 卡纳达语
 )

```

### 3.2.31. 待机表盘设置

示例

```kotlin

val standbyWatchFaceSet = BleStandbyWatchFaceSet(
    mStandbyEnable = 1, //使能开关，如果关闭下方的设置无效
    mEnabled = 1, // 总开关与下方时间段开关互斥
    mBleTimeRange1 = BleTimeRange(0, 8, 0, 22, 0),
)
BleConnector.sendObject(BleKey.STANDBY_WATCH_FACE_SET, BleKeyFlag.UPDATE, standbyWatchFaceSet)

//读取时触发。
fun onReadStandbyWatchFaceSet(standbyWatchFaceSet: BleStandbyWatchFaceSet) {}

//当设备更新时触发。
fun onStandbyWatchFaceSetUpdate(standbyWatchFaceSet: BleStandbyWatchFaceSet) {}

```

BleStandbyWatchFaceSet  
mStandbyEnable: 使能开关，关闭下面的设置无效
mEnabled: 总开关，与时间段开关互斥
mBleTimeRange1: 时间段

### 3.2.32. 血氧设置

示例

```kotlin

val bloodOxyGenSettings = BleBloodOxyGenSettings(
    mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0),
    mInterval = 60 // an hour
)
BleConnector.sendObject(BleKey.BLOOD_OXYGEN_SET, BleKeyFlag.UPDATE, bloodOxyGenSettings)

//读取时触发。
fun onReadBloodOxyGenSettings(bloodOxyGenSettings: BleBloodOxyGenSettings) {}

```

## 4.3. 推送

### 4.3.1. 通知

示例

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
mCategory:通知类型，具体使用参考sdk示例代码。  
mTime:时间戳 ms  
mPackage:包名  
mTitle:标题  
mContent:通知内容  

### 4.3.2. 日程

示例

```kotlin
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

//编辑日程
schedule.mHour = 23
BleConnector.sendObject(BleKey.SCHEDULE, BleKeyFlag.UPDATE, schedule)
                                
//删除日程
BleConnector.sendInt8(BleKey.SCHEDULE, BleKeyFlag.DELETE, schedules[0].mId)
```

BleSchedule  
mYear: 年  
mMonth: 月  
mDay: 日  
mHour: 小时  
mMinute: 分钟  
mAdvance: 提前提醒，分钟
mTitle: 标题  
mContent: 内容  

### 4.3.3. 天气

示例

```kotlin
//发送实时天气
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

//发送天气预报
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
mCurrentTemperature: 摄氏度，for BleWeatherRealtime  
mMaxTemperature: 摄氏度，for BleWeatherForecast  
mMinTemperature: 摄氏度，for BleWeatherForecast  
mWeatherCode:天气类型，for both  
mWindSpeed: 风速km/h，for both  
mHumidity: 显度%，for both  
mVisibility: 能见度km，for both  
mUltraVioletIntensity: 紫外线强度，[0, 2] -> low, [3, 5] -> moderate, [6, 7] -> high, [8, 10] -> very high, >10 -> extreme for BleWeatherForecast  
mPrecipitation: 降水量 mm，for both  

BleWeatherRealtime  
mTime: 时间戳，秒数  
mWeather: 参考BleWeather  

BleWeatherForecast  
mTime: 时间戳，秒数  
mWeather1: 今天天气，参考BleWeather  
mWeather2: 明天天气，参考BleWeather  
mWeather3: 后天天气，参考BleWeather  

说明：  
先确保设备的时间和时区已设置，需要同时发送实时天气和天气预报信息，设备才会显示。 

## 4.4. 控制

### 4.4.1. 相机

示例

```kotlin
//按控设备进入相机功能
BleConnector.sendInt8(BleKey.CAMERA, BleKeyFlag.UPDATE, CameraState.ENTER)

//控制设备退出相机功能
BleConnector.sendInt8(BleKey.CAMERA, BleKeyFlag.UPDATE, CameraState.EXIT)

//设备主动执行拍照相关操作时触发
fun onCameraStateChange(cameraState: Int) {}
```

CameraState
EXIT = 0 //退出
ENTER = 1 //进入
CAPTURE = 2 //拍照

### 4.4.2. 音乐控制

1. 设备控制手机音乐播放器，需要配置：

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

2. 申请权限

```kotlin
if (MyNotificationListenerService.isEnabled(mContext)) {
    MyNotificationListenerService.checkAndReEnable(mContext)
} else {
    MyNotificationListenerService.toEnable(mContext)
}
```

3. 手动打开音乐播放器，先播放一首歌曲，让App识别到，接下来就可以使用设备控制了。

### 4.4.3. 设备运动

运动数据由设备生成，如步数、心率等等。

1. 有些运动模式，如户外运动，需要手机GPS辅助定位来记录GPS轨迹。

```kotlin
//设备请求定位时触发，一些无Gps设备在运动时会请求手机定位。
fun onRequestLocation(workoutState: Int) {}

```

WorkoutState
START = 1 //开始运动
ONGOING = 2 //运动中，每20s返回一次
PAUSE = 3
END = 4

2. WorkoutState == START || WorkoutState == ONGOING
   需要创建一个BleLocationReply，手表会显示相关的信息，可参考sdk示例代码

```kotlin
val reply = BleLocationReply(
    mSpeed = 1.11f * mLocationTimes,
    mTotalDistance = 1.11f * mLocationTimes,
    mAltitude = 111 * mLocationTimes
)
BleConnector.sendObject(BleKey.REQUEST_LOCATION, BleKeyFlag.CREATE, reply)

```

BleLocationReply
mSpeed: 速度，千米/小时
mTotalDistance: 累积距离，千米
mAltitude: 海拔，米

说明：
运动开始后，App就可以开始记录gps轨迹

2. 如果“BleDeviceInfo.mSupportDeviceSportData == 1”，支持运动状态联动、运动数据实时返回App。

```kotlin
//App运动开启或者变化，将会通知设备
BleConnector.sendObject(
   BleKey.APP_SPORT_STATE, BleKeyFlag.UPDATE, BleAppSportState(
      mMode, mState
   )
)

//当用户从设备控制运动状态变化时触发
fun onUpdateAppSportState(state: BleAppSportState) {}


//运动的过程中设备会实时返回运动数据
fun onDeviceSportDataUpdate(deviceSportData: BleDeviceSportData) {}

```

BleAppSportState
mMode: 运动类型，与 BleActivity 中的 mMode 定义一致
mState: 运动状态

mState
STATE_START = 1 //开始运动
STATE_RESUME = 2 //恢复运动
STATE_PAUSE = 3 //暂停运动
STATE_END = 4 //结速运动

BleDeviceSportData
mDuration: 运动时长，数据以秒为单位
mBpm: 当前心率，bpm
mSpm: 步频，步数/分钟
mStep: 步数，单位步
mDistance: 米，以米为单位
mCalorie: 单位kcal
mSpeed: 速度，接收到的数据以 米/小时 为单位
mPace: 配速，接收到的数据以 秒/千米 为单位
mAltitude: 当前海拔，以米为单位
mRiseAltitude: 上升海拔，以米为单位
mMode: 运动类型，与 BleActivity 中的 mMode 定义一致

### 4.4.4. 来电控制

```kotlin
//当设备控制来电时触发。  0 -接听 ； 1-拒接
fun onIncomingCallStatus(status: Int) {}

```

### 4.4.5. APP运动

运动数据由app生成，如步数通过手机传感器获取。
需要先通过"BleDeviceInfo.mSupportAppSport == 1"来判断设备是否支持该功能。

```kotlin
//App运动开启或者变化，将会通知设备
BleConnector.sendObject(
   BleKey.APP_SPORT_STATE, BleKeyFlag.UPDATE, BleAppSportState(
      mMode, mState
   )
)

//当用户从设备控制运动状态变化时触发
fun onUpdateAppSportState(state: BleAppSportState) {}

//App将计算出来的数据发给设备，设备会显示出来，可以每秒发一次。
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

//运动的过程中设备会实时返回心率值
fun onUpdateHeartRate(heartRate: BleHeartRate) {}

```

BleAppSportState
mMode: 运动类型，与 BleActivity 中的 mMode 定义一致，这里只支持INDOOR, OUTDOOR, CYCLING, CLIMBING四种
mState: 运动状态

mState
STATE_START = 1 //开始运动
STATE_RESUME = 2 //恢复运动
STATE_PAUSE = 3 //暂停运动
STATE_END = 4 //结速运动

BleAppSportData
mStep: 步数，与 BleActivity 中的 mStep 定义一致，步数是从手机计步器获取
mDistance: 米，以米为单位，例如接收到的数据为56045，则代表 56045 米 约等于 56.045 Km
mCalorie: 以千卡为单位
mDuration: 运动持续时长，数据以秒为单位
mSpm: 平均步频，步数/分钟的值
mAltitude: 海拔高度，数据以米为单位
mAirPressure: 气压，数据以 kPa 为单位
mPace: 平均配速，接收到的数据以 秒/千米 为单位
mSpeed: 平均速度，接收到的数据以 千米/小时 为单位
mMode: 运动类型，与 BleActivity 中的 mMode 定义一致

说明:
App运动功能与设备上的运动功能是两个不同的功能。
主要区别：
设备运动功能，有些运动模式需要手机辅助定位时，会触发相应的回调，App将计算好的定位信息发给设备。  
手机运动功能，可以在没有绑定设备的情况下独立使用，如果绑定了设备，可以将运动状态和运动过程产生的数据实时发给设备，设备可以实时返回心率，也可以控制运动状态。  


## 4.5. 文件

```
//文件的发送进度使用这个回调
fun onStreamProgress(status: Boolean, errorCode: Int, total: Int, completed: Int) {}
```

### 4.5.1. 表盘

```kotlin
BleConnector.sendStream(BleKey.WATCH_FACE, file)
```

### 4.5.2. AGPS

```kotlin
BleConnector.sendStream(BleKey.AGPS_FILE, file)
```

### 4.5.3. 字体包

```kotlin
BleConnector.sendStream(BleKey.FONT_FILE, file)
```

### 4.5.4. 联系人

```kotlin
//具体参考sdk的示例代码
BleConnector.sendStream(BleKey.CONTACT, bytes)
```

### 4.5.5. UI包

```kotlin
BleConnector.sendStream(BleKey.UI_FILE, file)
```

### 4.5.6. 语言包

```kotlin
BleConnector.sendStream(BleKey.LANGUAGE_FILE, file)
```

## 4.6. OTA

一般有三个文件，分别为固件包、UI包和字体包。如果支持多国语言，还有语言包。文件名包含版本信息。  

固件包：大部分情况只使用固件包就可以了，使用芯片平台提供的ota sdk，具体可以参考sdk的示例代码。  

UI包：只有UI包需要更新或者设备界面显示异常才更新。  

字库包：只有设备字体显示异常时需要更新，直接发送过去即可。 
