//
// Created by Best Mafen on 2019/9/21.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc
protocol BleHandleDelegate {

    /**
     * 设备连接成功时触发。
     */
    @objc optional func onDeviceConnected(_ peripheral: CBPeripheral)
    
    /**
     * 设备正在连接时触发。
     */
    @objc optional func onDeviceConnecting(_ status: Bool)

    /**
     * 绑定时触发。
     */
    @objc optional func onIdentityCreate(_ status: Bool)

    /**
     * 解绑时触发。
     */
    @objc optional func onIdentityDelete(_ status: Bool)

    /**
     * 设备主动解绑时触发。
     */
    @objc optional func onIdentityDeleteByDevice(_ status: Bool)

    /**
     * 连接状态变化时触发。
     */
    @objc optional func onSessionStateChange(_ status: Bool)

    /**
     * 设备回复某些指令时触发。
     */
    @objc optional func onCommandReply(_ bleKey: Int, _ keyFlag: Int, _ status: Bool)

    /**
     * 设备进入OTA时触发。
     */
    @objc optional func onOTA(_ status: Bool)

    /**
     * MTK设备返回固件信息，该信息需要通过[BleConnector.SERVICE_MTK]和[BleConnector.CH_MTK_OTA_META]来读取，
     * 设备返回该信息后会通过[BleCache.putMtkOtaMeta]保存该信息，然后通过[BleCache.getMtkOtaMeta]可以获取该信息。
     * mid=xx;mod=xx;oem=xx;pf=xx;p_id=xx;p_sec=xx;ver=xx;d_ty=xx;
     */
    @objc optional func onReadMtkOtaMeta()

    @objc optional func onXModem(_ status: UInt8)

    /**
     * 设备返回电量时触发。
     */
    @objc optional func onReadPower(_ power: Int)

    /**
     * 设备返回固件版本时触发。
     */
    @objc optional func onReadFirmwareVersion(_ version: String)

    /**
     * 设备返回mac地址时触发。
     */
    @objc optional func onReadBleAddress(_ address: String)

    /**
     * 设备返回久坐设置时触发。
     */
    @objc optional func onReadSedentariness(_ sedentarinessSettings: BleSedentarinessSettings)

    /**
     * 设备返回勿扰设置时触发。
     */
    @objc optional func onReadNoDisturb(_ noDisturbSettings: BleNoDisturbSettings)

    /**
     * 设备端修改勿扰设置时触发。
     */
    @objc optional func onNoDisturbUpdate(_ noDisturbSettings: BleNoDisturbSettings)

    /**
     * 设备返回闹钟列表时触发。
     */
    @objc optional func onReadAlarm(_ alarms: [BleAlarm])

    /**
     * 设备端修改闹钟时触发。
     */
    @objc optional func onAlarmUpdate(_ alarm: BleAlarm)

    /**
     * 设备端删除闹钟时触发。
     */
    @objc optional func onAlarmDelete(_ id: Int)

    /**
     * 设备端创建闹钟时触发。
     */
    @objc optional func onAlarmAdd(_ alarm: BleAlarm)

    /**
     * 设备返回Coaching id时触发。
     */
    @objc optional func onReadCoachingIds(_ coachingIds: BleCoachingIds)

    /**
     * 当设备发起找手机触发。
     */
    @objc optional func onFindPhone(_ start: Bool)

    /**
     * 设备返回UI包版本时触发，BleDeviceInfo.PLATFORM_REALTEK专属。
     */
    @objc optional func onReadUiPackVersion(_ version: String)

    /**
     * 设备返回语言包信息时触发，BleDeviceInfo.PLATFORM_REALTEK专属。
     */
    @objc optional func onReadLanguagePackVersion(_ version: BleLanguagePackVersion)

    /**
     * 同步数据时触发。
     * @param syncState SyncState
     * @param bleKey 正在同步的数据类型
     */
    @objc optional func onSyncData(_ syncState: Int, _ bleKey: Int)

    /**
     * 当设备返回BleActivity时触发。
     */
    @objc optional func onReadActivity(_ activities: [BleActivity])

    /**
     * 当设备返回BleHeartRate时触发。
     */
    @objc optional func onReadHeartRate(_ heartRates: [BleHeartRate])

    /**
     * 当设备返回BleBloodPressure时触发。
     */
    @objc optional func onReadBloodPressure(_ bloodPressures: [BleBloodPressure])

    /**
     * 当设备返回BleSleep时触发。
     */
    @objc optional func onReadSleep(_ sleeps: [BleSleep])

    /**
     * 当设备返回BleWorkout时触发。
     */
    @objc optional func onReadWorkOut(_ WorkOut: [BleWorkOut])
    
    @objc optional func onReadWorkOut2(_ WorkOut: [BleWorkOut2])

    /**
     * 当设备返回BleWorkout时触发。
     */
    @objc optional func onReadMatchRecord(_ matchRecord: [BleMatchRecord])
    
    /**
     * 当设备返回BleLocation时触发。
     */
    @objc optional func onReadLocation(_ locations: [BleLocation])

    /**
    * 当设备返回BleTemperature时触发。
    */
    @objc optional func onReadTemperature(_ temperatures: [BleTemperature])

    /**
    * 当设备返回BleBloodOxygen时触发。
    */
    @objc optional func onReadBloodOxygen(_ BloodOxygen: [BleBloodOxygen])

    /**
    * 当设备返回BleHeartRateVariability时触发。
    */
    @objc optional func onReadHeartRateVariability(_ HeartRateVariability: [BleHeartRateVariability])

    /**
    * 当设备返回TemperatureUnit时触发。
      0 ->℃
      1 ->℉
    */
    @objc optional func onReadTemperatureUnitSettings(_ state: Int)

    /**
    * 当设备返回DateFormatSetting时触发。
      0 ->YYYY/MM/dd
      1 ->dd/MM/YYYY
      2 ->MM/dd/YYYY
    */
    @objc optional func onReadDateFormatSettings(_ status: Int)

    /**
    * 当设备返回BleAerobicSettings时触发。
    */
    @objc optional func onReadAerobicSettings(_ AerobicSettings: BleAerobicSettings)

    /**
    * 当设备返回BlePressure时触发。
    */
    @objc optional func onReadPressures(_ pressures: [BlePressure])

    /**
     * 设备主动执行拍照相关操作时触发。
     * @param cameraState: CameraState
     */
    @objc optional func onCameraStateChange(_ cameraState: Int)

    /**
     * 设备请求定位时触发，一些无Gps设备在锻炼时会请求手机定位。
     * @param workoutState WorkoutState
     */
    @objc optional func onPhoneGPSSport(_ workoutState: Int)

    /**
     * 手机执行拍照相关操作，设备回复时触发。
     * 手机发起后设备响应。用于确认设备是否能立即响应手机发起的操作，比如设备在某些特定界面是不能进入相机的，
     * 如果手机发起进入相机指令，设备会回复失败
     * cameraState: CameraState
     */
    @objc optional func onCameraResponse(_ status: Bool, _ cameraState: Int)

    /**
     * 调用BleConnector.sendStream后触发，用于回传发送进度。
     */
    @objc optional func onStreamProgress(_ status: Bool, _ errorCode: Int, _ total: Int, _ completed: Int)

    /**
     * 设备开启Gps时，如果检测到没有aGps文件，或aGps文件已过期，设备发起请求aGps文件。
     * url aGps文件的下载链接。
     */
    @objc optional func onDeviceRequestAGpsFile(_ url: String)

    /**
     * 读取设备多媒体文件时回调
     *
     */
    @objc optional func onReadMediaFile(_ media: BleFileTransmission)

    /**
     * 返回设备睡眠原始数据,此数据为固件分析用,保存即可
     *
     */
    @objc optional func onReadSleepRaw(_ sleepRawData: Data)


    /**
     * 设备语言环境主动跟随手机触时发
     *
     */
    @objc optional func onFollowSystemLanguage (_ systemLanguage: Bool)
    
    /**
     * 设备主动要求更新天气信息
     *
     */
    @objc optional func onReadWeatherRealtime (_ update: Bool)
    
    /**
     * 0x050B 设备运行日志
     *
     */
    @objc optional func onReadDataLog (_ logs: [BleLogText])
    
    /**
     * 0x021F 读取设备当前设置表盘
     *
     */
    @objc optional func onReadWatchFaceSwitch(_ value: Int)
    
    /**
     * 0x021F 设置表盘callback
     * status -> false 表盘不存在,数组越界
     */
    @objc optional func onUpdateWatchFaceSwitch(_ status: Bool)
    
    /**
     * 0x0220
     * 设备主动调用,app端定位成功后发BleAgpsPrerequisite到设备
     */
    @objc optional func onRequestAgpsPrerequisite()
    
    /** 0x0221
     * 设备返回喝水提醒设置时触发。
     */
    @objc optional func onReadDrinkWaterSettings(_ drinkWater: BleDrinkWaterSettings)
    
    /** 0x0225
     * 设备返回血氧监测设置时触发。
     */
    @objc optional func onReadBloodOxyGenSettings(_ bloodOxyGenSet: BleBloodOxyGenSettings)
    
    /** 0x0226
     * 设备返回洗手提醒设置时触发。
     */
    @objc optional func onReadWashSettings(_ washSet: BleWashSettings)
    
    /**
     * appd端更新设置指令回调
     */
    @objc optional func onUpdateSettings(_ bleKey: BleKey.RawValue)
    
    /**
     * 设备端主动传输心率
     */
    @objc optional func onUpdateRealTimeHR(_ itemHR: ABHRealTimeHR)
    
    /**
     * 设备端主动传输体温
     */
    @objc optional func onUpdateRealTimeTemperature(_ temperature: BleTemperature)
    
    /**
     * 设备端主动传输血压
     */
    @objc optional func onUpdateRealTimeBloodPressure(_ bloodPressures: BleBloodPressure)
    
    /**
     * 手机运动模式
     */
    @objc optional func onUpdatePhoneWorkOutStatus(_ status:BlePhoneWorkOutStatus)
    
    /**
     * 设备主动更新震动状态
     */
    @objc optional func onVibrationUpdate(_ value:Int)
    /**
     * 获取设备iBeacon开关状态
     * 0 -> off
     * 1 -> on
     */
    @objc optional func onReadiBeaconStatus(_ value:Int)
    /**
     * 获取设备watchface ID列表
     */
    @objc optional func onReadWatchFaceId(_ watchFaceId:BleWatchFaceId)
    /**
     * 设置新watchface ID 回调,接到此回调开始传输表盘文件
     */
    @objc optional func onWatchFaceIdUpdate(_ status: Bool)
    /**
     * 设置新watchface ID 回调,接到此回调开始传输表盘文件
     */
    @objc optional func onCommandSendTimeout(_ bleKey: Int,_ bleKeyFlag: Int)
    /**
     * 设备返回世界时钟列表时触发
     */
    @objc optional func onReadWorldClock(_ worldClocks:[BleWorldClock])
    /**
     * 设备端删除世界时钟时触发
     */
    @objc optional func onWorldClockDelete(_ clockID:Int)
    /**
     * 设备返回股票列表时触发
     */
    @objc optional func onReadStock(_ stocks:[BleStock])
    /**
     * 设备删除股票列表时触发
     */
    @objc optional func onStockDelete(_ stockID:Int)
    /**
     * 设备主动请求更新股票列表时触发
     */
    @objc optional func onDeviceReadStock(_ status: Bool)
    /**
     * App主动测量反馈状态时触发
     */
    @objc optional func onRealTimeMeasurement(_ measurement: BleRealTimeMeasurement)
}

