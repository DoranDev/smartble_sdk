# 1. 杰里平台OTA问题

杰里平台目前使用的是单备份OTA，流程：

下载loader -> 设备重启（运行loader）-> 回连设备 -> 升级固件

单备份OTA是有一定几率升级失败(蓝牙断开、APP杀死中止OTA等等)。

sdk内部已经实现了回连操作。开始只需传入ble地址，如果设备停留在ota界面则传入dfu地址。

OTA失败一般停留在OTA模式，这个时候设备的dfu地址=ble地址+1，可以通过onNeedReconnect来判断是否需要dfu地址来连接。

在这个过程中，app可以自己实现OTA状态的记录，退出app重新进入后检查OTA状态，如果失败App可以显示固件修复提示。

停留在OTA界面，一般可以搜到设备的蓝牙广播，广播包的格式可以参考以下连接：
https://doc.zh-jieli.com/Apps/Android/ota/zh-cn/master/other/qa.html#x300b

app可以通过广播来识别设备当前的状态，判断是否需要显示固件修复提示。

也可以参考这个官方的示例:
https://github.com/Jieli-Tech/Android-JL_OTA

# 2.区分固件功能的问题

配对成功后会触发onIdentityCreate, BleDeviceInfo建议保存起来，或者使用BleCache.mDeviceInfo。

```kotlin

//配对成功触发
fun onIdentityCreate(status: Boolean, deviceInfo: BleDeviceInfo? = null) {}

```
BleDeviceInfo里面的mBleName和mFirmwareFlag，如果mBleName相同，可以通过mFirmwareFlag区分固件。

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
mSupport2DAcceleration:是否支持2d加速，主要是表盘功能需要用到
mSupportHrWarnSet:是否支持心率预警设置

# 3. 表盘文件同步问题

相同分辨率的表盘，表盘文件一般是可以通用的。
用户如果需要把表盘上传到服务器，可以通过mBleName和mFirmwareFlag来判断使用哪个表盘文件。

# 4. 混淆
-keep class com.bestmafen.baseble.data.**{*;}
-keep class com.szabh.smable3.entity.**{*;}
-keep class com.szabh.smable3.component.**{*;}
-keep class com.szabh.smable3.watchface.**{*;}
-keep class com.jieli.**{*;}