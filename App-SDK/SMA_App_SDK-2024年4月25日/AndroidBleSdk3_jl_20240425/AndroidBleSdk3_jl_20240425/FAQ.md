# 1. Jieli platform OTA problem

The Jieli platform currently uses a single backup OTA, the process:

Download the loader -> restart the device (run the loader) -> connect back to the device -> upgrade the firmware

Single backup OTA has a certain probability of failure to upgrade (Bluetooth disconnected, APP kills and terminates OTA, etc.).

The connection back operation has been implemented inside the sdk. 
At the beginning, you only need to pass in the ble address, and if the device stays on the ota interface, pass in the dfu address.

OTA failure generally stays in OTA mode. At this time, the dfu address of the device = ble address + 1. 
You can use onNeedReconnect to determine whether the dfu address is needed to connect.

During this process, the app can record the OTA status by itself, and check the OTA status after exiting the app and re-entering. 
If it fails, the app can display a firmware repair prompt.

Staying on the OTA interface, you can generally find the Bluetooth broadcast of the device. 
The format of the broadcast packet can refer to the following link:
(Jieli's document is only available in Chinese, users can use Google to translate)
https://doc.zh-jieli.com/Apps/Android/ota/zh-cn/master/other/qa.html#x300b

The app can identify the current status of the device through broadcasts, 
and determine whether it is necessary to display firmware repair prompts.

You can also refer to this official example:
(Jieli's document is only available in Chinese, users can use Google to translate)
https://github.com/Jieli-Tech/Android-JL_OTA

# 2.Problems distinguishing firmware features

After the pairing is successful, onIdentityCreate will be triggered, and BleDeviceInfo is recommended to be saved, or use BleCache.mDeviceInfo.

```kotlin

//Pairing successful trigger
fun onIdentityCreate(status: Boolean, deviceInfo: BleDeviceInfo? = null) {}

```
The mBleName and mFirmwareFlag in BleDeviceInfo, 
if the mBleName is the same, the firmware can be distinguished by the mFirmwareFlag.

BleDeviceInfo  
mBleName:bluetooth name  
mBleAddress:Ble address  
mPlatform:platform  
mPrototype:prototype  
mFirmwareFlag:firmware tag  
mAGpsType:agps type  
mClassicAddress:BT 3.0 address 
mShowAntiLostSwitch:Whether to display the anti-lost switch, BleKey.ANTI_LOST
mSupportDateFormatSet:Whether to support date format setting, BleKey.DATE_FORMAT
mSupportTemperatureUnitSet:Whether to support temperature unit setting, BleKey.TEMPERATURE_UNIT
mSupportDrinkWaterSet:Whether to support the setting of drinking water reminder, BleKey.DRINK_WATER
mSupportAppSport:Whether to support initiating motion through the app and controlling the state of motion, BleKey.APP_SPORT_STATE, BleKey.APP_SPORT_DATA
mSupportWashSet:Does it support the setting of hand washing reminder
mSupportFindWatch:Does it support looking for watches?
mSupportWorldClock:Whether to support the world clock
mSupportStock:Whether to support stocks
mSupportPowerSaveMode:Whether to support power saving mode
mSupportWeather2:Whether to support seven-day weather
mSupport2DAcceleration:Whether to support 2D acceleration, mainly because the watchface function needs to be used
mSupportHrWarnSet:Whether to support heart rate warning setting

# 3. Watchface file synchronization problem

For dials with the same resolution, the dial files can generally be used universally.
If the user needs to upload the watch face to the server, 
he can use the mBleName and mFirmwareFlag to determine which watch face file to use.

# 4. Code obfuscation
-keep class com.bestmafen.baseble.data.**{*;}
-keep class com.szabh.smable3.entity.**{*;}
-keep class com.szabh.smable3.component.**{*;}
-keep class com.szabh.smable3.watchface.**{*;}
-keep class com.jieli.**{*;}