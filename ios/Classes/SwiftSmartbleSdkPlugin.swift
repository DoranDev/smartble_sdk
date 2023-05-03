import Flutter
import UIKit
import CoreBluetooth

public class SwiftSmartbleSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    static let eventChannelNameScan = "smartble_sdk/scan";
      
    var scanSink: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        switch arguments as? String {
        case SwiftSmartbleSdkPlugin.eventChannelNameScan:
            scanSink = events
            break;
        default:
            break
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }

    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "smartble_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftSmartbleSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      
    let scanChannel = FlutterEventChannel(name: eventChannelNameScan, binaryMessenger:registrar.messenger())
    scanChannel.setStreamHandler(instance)
  }
    
    
    let mBleConnector = BleConnector.shared
    let mBleScanner = BleScanner(/*[CBUUID(string: BleConnector.BLE_SERVICE)]*/)
    var mDevices = [[String:String]()]
 var bleKey: BleKey = BleKey.NONE
 var bleKeyFlag: BleKeyFlag=BleKeyFlag.NONE
    private func doBle(_ action: (BleConnector) -> Void) {
        let bleConnector = BleConnector.shared
        if bleConnector.isAvailable() {
            action(bleConnector)
        } else {
            print("BleConnector is not available!")
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
        let args = call.arguments as? Dictionary<String, Any>
        let flag = args?["flag"] as? String
        let mtd = call.method
        switch mtd {
        case "scan":
            let isScan = args?["isScan"] as? Bool ?? false
            mBleScanner.scan(isScan)
            break;
        case "setAddress":
            var bmac = (args?["bmac"] as? String)!
            mBleConnector.setTargetIdentifier(bmac)
            break;
       case "connect":
            mBleConnector.connect(true)
            break;
        case "isAvailable":
            result(mBleConnector.isAvailable())
             break;
        case "OTA":
            bleKey = .OTA
            break;
        case "XMODEM":
            bleKey = .XMODEM
            break;
        case "TIME":
            bleKey = .TIME
            break;
        case "TIME_ZONE":
            bleKey = .TIME_ZONE
            break;
        case "POWER":
            bleKey = .POWER
            break;
        case "FIRMWARE_VERSION":
            bleKey = .FIRMWARE_VERSION
            break;
        case "BLE_ADDRESS":
            bleKey = .BLE_ADDRESS
            break;
        case "USER_PROFILE":
            bleKey = .USER_PROFILE
            break;
        case "STEP_GOAL":
            bleKey = .STEP_GOAL
            break;
        case "BACK_LIGHT":
            bleKey = .BACK_LIGHT
            break;
        case "SEDENTARINESS":
            bleKey = .SEDENTARINESS
            break;
        case "NO_DISTURB_RANGE":
            bleKey = .NO_DISTURB_RANGE
            break;
        case "VIBRATION":
            bleKey = .VIBRATION
            break;
        case "GESTURE_WAKE":
            bleKey = .GESTURE_WAKE
            break;
        case "HR_ASSIST_SLEEP":
            bleKey = .HR_ASSIST_SLEEP
            break;
        case "HOUR_SYSTEM":
            bleKey = .HOUR_SYSTEM
            break;
        case "LANGUAGE":
            bleKey = .LANGUAGE
            break;
        case "ALARM":
            bleKey = .ALARM
            break;
        case "COACHING":
            bleKey = .COACHING
            break;
        case "FIND_PHONE":
            bleKey = .FIND_PHONE
            break;
        case "NOTIFICATION_REMINDER":
            bleKey = .NOTIFICATION_REMINDER
            break;
        case "ANTI_LOST":
            bleKey = .ANTI_LOST
            break;
        case "HR_MONITORING":
            bleKey = .HR_MONITORING
            break;
        case "UI_PACK_VERSION":
            bleKey = .UI_PACK_VERSION
            break;
        case "LANGUAGE_PACK_VERSION":
            bleKey = .LANGUAGE_PACK_VERSION
            break;
        case "SLEEP_QUALITY":
            bleKey = .SLEEP_QUALITY
            break;
//        case "GIRL_CARE":
//            bleKey = .GIRLCARE
        case "TEMPERATURE_DETECTING":
            bleKey = .TEMPERATURE_DETECTING
            break;
        case "AEROBIC_EXERCISE":
            bleKey = .AEROBIC_EXERCISE
            break;
        case "TEMPERATURE_UNIT":
            bleKey = .TEMPERATURE_UNIT
            break;
        case "DATE_FORMAT":
            bleKey = .DATE_FORMAT
            break;
        case "WATCH_FACE_SWITCH":
            bleKey = .WATCH_FACE_SWITCH
            break;
        case "AGPS_PREREQUISITE":
            bleKey = .AGPS_PREREQUISITE
            break;
        case "DRINK_WATER":
            bleKey = .DRINKWATER
            break;
//        case "SHUTDOWN":
//            bleKey = .SHUTDOWN
        case "APP_SPORT_DATA":
            bleKey = .APP_SPORT_DATA
            break;
        case "REAL_TIME_HEART_RATE":
            bleKey = .REAL_TIME_HEART_RATE
            break;
        case "BLOOD_OXYGEN_SET":
            bleKey = .BLOOD_OXYGEN_SET
            break;
        case "WASH_SET":
            bleKey = .WASH_SET
            break;
        case "WATCHFACE_ID":
            bleKey = .WATCHFACE_ID
            break;
        case "IBEACON_SET":
            bleKey = .IBEACON_SET
            break;
        case "MAC_QRCODE":
            bleKey = .MAC_QRCODE
            break;
        case "REAL_TIME_TEMPERATURE":
            bleKey = .REAL_TIME_TEMPERATURE
            break;
        case "REAL_TIME_BLOOD_PRESSURE":
            bleKey = .REAL_TIME_BLOOD_PRESSURE
            break;
        case "TEMPERATURE_VALUE":
            bleKey = .TEMPERATURE
            break;
        case "GAME_SET":
            bleKey = .GAME_SET
            break;
        case "FIND_WATCH":
            bleKey = .FIND_WATCH
            break;
        case "SET_WATCH_PASSWORD":
            bleKey = BleKey.SET_WATCH_PASSWORD
            break;
        case "REALTIME_MEASUREMENT":
            bleKey = BleKey.REALTIME_MEASUREMENT
            break;
//        case "LOCATION_GSV":
//            bleKey = BleKey.LOCATION_GSV
//        case "HR_RAW":
//            bleKey = BleKey.HR_RAW
        case "REALTIME_LOG":
            bleKey = BleKey.REALTIME_LOG
            break;
        case "GSENSOR_OUTPUT":
            bleKey = BleKey.GSENSOR_OUTPUT
            break;
        case "GSENSOR_RAW":
            bleKey = BleKey.GSENSOR_RAW
            break;
        case "MOTION_DETECT":
            bleKey = BleKey.MOTION_DETECT
            break;
        case "LOCATION_GGA":
            bleKey = BleKey.LOCATION_GGA
            break;
        case "RAW_SLEEP":
            bleKey = BleKey.RAW_SLEEP
            break;
        case "NO_DISTURB_GLOBAL":
            bleKey = BleKey.NO_DISTURB_GLOBAL
            break;
        case "IDENTITY":
            bleKey = BleKey.IDENTITY
            break;
        case "SESSION":
            bleKey = BleKey.SESSION
            break;
        case "NOTIFICATION":
            bleKey = BleKey.NOTIFICATION_REMINDER
            break;
        case "MUSIC_CONTROL":
            bleKey = BleKey.MUSIC_CONTROL
            break;
        case "SCHEDULE":
            bleKey = BleKey.SCHEDULE
            break;
        case "WEATHER_REALTIME":
            bleKey = BleKey.WEATHER_REALTIME
            break;
        case "WEATHER_FORECAST":
            bleKey = BleKey.WEATHER_FORECAST
            break;
//        case "HID":
//            bleKey = BleKey.HID
        case "WORLD_CLOCK":
            bleKey = BleKey.WORLD_CLOCK
            break;
        case "STOCK":
            bleKey = BleKey.STOCK
            break;
//        case "SMS_QUICK_REPLY_CONTENT":
//            bleKey = BleKey.SMS_QUICK_REPLY_CONTENT
        case "NOTIFICATION2":
            bleKey = BleKey.NOTIFICATION_REMINDER
            break;
        case "DATA_ALL":
            bleKey = BleKey.DATA_ALL
            break;
        case "ACTIVITY_REALTIME":
            bleKey = BleKey.ACTIVITY_REALTIME
            break;
        case "ACTIVITY":
            bleKey = BleKey.ACTIVITY
            break;
        case "HEART_RATE":
            bleKey = BleKey.HEART_RATE
            break;
        case "SLEEP":
            bleKey = BleKey.SLEEP
            break;
        case "LOCATION":
            bleKey = BleKey.LOCATION
            break;
        case "TEMPERATURE":
            bleKey = BleKey.TEMPERATURE
            break;
        case "BLOOD_OXYGEN":
            bleKey = BleKey.BLOODOXYGEN
            break;
        case "HRV":
            bleKey = BleKey.HRV
            break;
        case "LOG":
            bleKey = BleKey.LOG
            break;
        case "SLEEP_RAW_DATA":
            bleKey = BleKey.SLEEP_RAW_DATA
            break;
        case "PRESSURE":
            bleKey = BleKey.PRESSURE
            break;
        case "WORKOUT2":
            bleKey = BleKey.WORKOUT2
            break;
        case "MATCH_RECORD":
            bleKey = BleKey.MATCH_RECORD
            break;
        case "CAMERA":
            bleKey = BleKey.CAMERA
            break;
        case "REQUEST_LOCATION":
            bleKey = BleKey.PHONE_GPSSPORT
            break;
//        case "INCOMING_CALL":
//            bleKey = BleKey.INCOMING_CALL
        case "APP_SPORT_STATE":
            bleKey = BleKey.APP_SPORT_STATE
            break;
//        case "CLASSIC_BLUETOOTH_STATE":
//            bleKey = BleKey.CLASSIC_BLUETOOTH_STATE
//        case "DEVICE_SMS_QUICK_REPLY":
//            bleKey = BleKey.DEVICE_SMS_QUICK_REPLY
        case "WATCH_FACE":
            bleKey = BleKey.WATCH_FACE
            break;
        case "AGPS_FILE":
            bleKey = BleKey.AGPS_FILE
            break;
        case "FONT_FILE":
            bleKey = BleKey.FONT_FILE
            break;
        case "CONTACT":
            bleKey = BleKey.CONTACT
            break;
        case "UI_FILE":
            bleKey = BleKey.UI_FILE
            break;
//        case "DEVICE_FILE":
//            bleKey = BleKey.DEVICE_FILE
        case "LANGUAGE_FILE":
            bleKey = BleKey.LANGUAGE_FILE
            break;
//        case "BRAND_INFO_FILE":
//            bleKey = BleKey.BRAND_INFO_FILE
        case "BLOOD_PRESSURE":
            bleKey = BleKey.BLOOD_PRESSURE
            break;
        default:
            bleKey=BleKey.NONE
    }
        switch flag {
            case "UPDATE":
                bleKeyFlag=BleKeyFlag.UPDATE
                break;
            case "READ":
                bleKeyFlag=BleKeyFlag.READ
                break;
            case "CREATE":
                bleKeyFlag=BleKeyFlag.CREATE
                break;
            case "DELETE":
                bleKeyFlag=BleKeyFlag.DELETE
                break;
            default:
                bleKeyFlag=BleKeyFlag.NONE
        }
      if bleKey == .IDENTITY {
          if bleKeyFlag == .DELETE {
              if BleConnector.shared.isAvailable() {
                  _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
              }
              BleConnector.shared.unbind()
             // unbindCompleted()
              return
          }
      }
      if !BleConnector.shared.isAvailable() {
          bleLog("device not connected")
          return
      }
      doBle { bleConnector in
          switch bleKey {
              // BleCommand.UPDATE
          case .OTA:
             // gotoOta()
              print("OTA")
          case .XMODEM:
              _ = bleConnector.sendData(bleKey, bleKeyFlag)

              // BleCommand.SET
          case .TIME:
              if bleKeyFlag == .UPDATE {
                  //设置设备时间
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleTime.local())
              } else if bleKeyFlag == .READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .TIME_ZONE:
              if bleKeyFlag == .UPDATE {
                  //设置设备时区
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleTimeZone())
              } else if bleKeyFlag == .READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .POWER:
              //bleKeyFlag = .READ 获取设备电量
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case .FIRMWARE_VERSION:
              //bleKeyFlag = .READ 获取设备固件版本号
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case .BLE_ADDRESS:
              //bleKeyFlag = .READ 获取设备Mac地址
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case .USER_PROFILE:
              if bleKeyFlag == .UPDATE {
                  //更新设备上的用户个人信息
                  let bleUserProfile = BleUserProfile(0, 0, 20, 170.0, 60.0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, bleUserProfile)
              } else if bleKeyFlag == .READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .STEP_GOAL:
              if bleKeyFlag == .UPDATE {
                  //更新设备上的运动目标
                  _ = bleConnector.sendInt32(bleKey, bleKeyFlag, 0x1234)
              } else if bleKeyFlag == .READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .BACK_LIGHT:
              if bleKeyFlag == .UPDATE {
                  //背光设置
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 4) // 0～20, 0 is off
              } else if bleKeyFlag == .READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .SEDENTARINESS:
              //久坐提醒
              if bleKeyFlag == .UPDATE {
                  let bleSedentariness = BleSedentarinessSettings()
                  bleSedentariness.mEnabled = 1
                  bleSedentariness.mRepeat = 63 // Monday ~ Saturday
                  bleSedentariness.mStartHour = 1
                  bleSedentariness.mEndHour = 22
                  bleSedentariness.mInterval = 60
                  _ = bleConnector.sendObject(bleKey, .UPDATE, bleSedentariness)
              } else if bleKeyFlag == .READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .NOTIFICATION_REMINDER:
              //消息提醒CALL
              if bleKeyFlag == .UPDATE {
                  let bleNotificationSettings = BleNotificationSettings()
                  bleNotificationSettings.enable(BleNotificationSettings.MIRROR_PHONE)
                  bleNotificationSettings.enable(BleNotificationSettings.WE_CHAT)
                  print(bleNotificationSettings)
                  _ = bleConnector.sendObject(bleKey, .UPDATE, bleNotificationSettings)
              }
          case .NO_DISTURB_RANGE:
              //设置勿扰
              if bleKeyFlag == .UPDATE {
                  let noDisturb = BleNoDisturbSettings()
                  noDisturb.mBleTimeRange1 = BleTimeRange(1, 2, 0, 18, 0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, noDisturb)
              } else {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .NO_DISTURB_GLOBAL:
              // on
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, true)
          case .WATCHFACE_ID:
              if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }else if  bleKeyFlag == BleKeyFlag.UPDATE{
                  let watchFaceId : Int32 = 111 //ID >= 100
                  _ = bleConnector.sendInt32(bleKey, bleKeyFlag, Int(watchFaceId))
              }
              break
          case .IBEACON_SET:
              if bleKeyFlag == .UPDATE{
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 1)
              }
              break
          case .WATCH_FACE_SWITCH:
              //设置默认表盘
              if bleKeyFlag == .UPDATE {
                  let value = 4 //watch face number
                  _ = BleConnector.shared.sendInt8(.WATCH_FACE_SWITCH, .UPDATE, value)
              } else if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
              break
          case .GESTURE_WAKE:
              //抬手亮
              if bleKeyFlag == .UPDATE {
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag,
                      BleGestureWake(BleTimeRange(1, 8, 0, 22, 0)))
              } else if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .VIBRATION:
              //震动设置
              if bleKeyFlag == .UPDATE {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 3) // 0~10, 0 is off
              } else if bleKeyFlag == .READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .HR_ASSIST_SLEEP:
              // on 睡眠辅助设备
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, true)
          case .HOUR_SYSTEM:
              // 0: 24-hourly; 1: 12-hourly 小时制
              _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 1)
          case .LANGUAGE:
              //设备语言设置
              _ = bleConnector.sendInt8(bleKey, bleKeyFlag, Languages.languageToCode())
          case .ALARM:
              if bleKeyFlag == .CREATE {
                  // 创建一个一分钟后的闹钟
                  let calendar = Calendar.current
                  var date = Date()
                  date.addTimeInterval(60.0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleAlarm(
                      1, // mEnabled
                      BleRepeat.EVERYDAY, // mRepeat
                      calendar.component(.year, from: date), // mYear
                      calendar.component(.month, from: date), // mMonth
                      calendar.component(.day, from: date), // mDay
                      calendar.component(.hour, from: date), // mHour
                      calendar.component(.minute, from: date), // mMinute
                      "tag" // mTag
                  ))
              } else if bleKeyFlag == .DELETE {
                  // 如果缓存中有闹钟的话，删除第一个
                  let alarms: [BleAlarm] = BleCache.shared.getArray(.ALARM)
                  if !alarms.isEmpty {
                      _ = bleConnector.sendInt8(bleKey, bleKeyFlag, alarms[0].mId)
                  }
              } else if bleKeyFlag == .UPDATE {
                  // 如果缓存中有闹钟的话，切换第一个闹钟的开启状态
                  let alarms: [BleAlarm] = BleCache.shared.getArray(.ALARM)
                  if !alarms.isEmpty {
                      let alarm = alarms[0]
                      alarm.mEnabled ^= 1
                      _ = bleConnector.sendObject(bleKey, bleKeyFlag, alarm)
                  }
              } else if bleKeyFlag == .READ {
                  // 读取设备上所有的闹钟
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
              } else if bleKeyFlag == .RESET {
                  // 重置设备上的闹钟
                  let calendar = Calendar.current
                  let date = Date()
                  var alarms = [BleAlarm]()
                  for i in 0..<8 {
                      alarms.append(BleAlarm(
                          i % 2, // mEnabled
                          i, // mRepeat
                          calendar.component(.year, from: date), // mYear
                          calendar.component(.month, from: date), // mMonth
                          calendar.component(.day, from: date), // mDay
                          calendar.component(.hour, from: date), // mHour
                          i, // mMinute
                          "\(i)" // mTag
                      ))
                  }
                  _ = bleConnector.sendArray(bleKey, bleKeyFlag, alarms)
              }
          case .COACHING:
              //锻炼模式设置
              if bleKeyFlag == .CREATE {
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleCoaching(
                      "My title", // title
                      "My description", // description
                      3, // repeat
                      [BleCoachingSegment(
                          CompletionCondition.DURATION.rawValue, // completion condition
                          "My name", // name
                          0, // activity
                          Stage.WARM_UP.rawValue, // stage
                          10, // completion value
                          0 // hr zone
                      )]
                  ))
              } else if bleKeyFlag == .UPDATE {
                  // 如果缓存中有Coaching的话，修改第一个Coaching的标题
                  let coachings: [BleCoaching] = BleCache.shared.getArray(.COACHING)
                  if !coachings.isEmpty {
                      let coaching = coachings[0]
                      coaching.mTitle += " nice"
                      _ = bleConnector.sendObject(bleKey, bleKeyFlag, coaching)
                  }
              } else if bleKeyFlag == .READ {
                  // 读取所有Coaching
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
              }
          case .ANTI_LOST:
              // on 防丢提醒设备
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, true)
          case .HR_MONITORING:
              //定时心率检查设置
              if bleKeyFlag == .UPDATE {
                  let hrMonitoring = BleHrMonitoringSettings()
                  hrMonitoring.mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0)
                  hrMonitoring.mInterval = 60 // an hour
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, hrMonitoring)
              } else if bleKeyFlag == .READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .DRINKWATER:
              if bleKeyFlag == .UPDATE {
                  let drinkWater = BleDrinkWaterSettings()
                  drinkWater.mEnabled = 1
                  drinkWater.mInterval = 1
                  drinkWater.mRepeat = 63 // Monday ~ Saturday
                  drinkWater.mStartHour = 7
                  drinkWater.mEndHour = 22
                  _ = bleConnector.sendObject(.DRINKWATER, .UPDATE, drinkWater)
              }
              break
          case .UI_PACK_VERSION:
              //Realtek UI包 版本
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case .LANGUAGE_PACK_VERSION:
              //Realtek 语言包 版本
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case .SLEEP_QUALITY:
              //睡眠总结设置
              _ = bleConnector.sendObject(bleKey, bleKeyFlag,
                  BleSleepQuality(202, 201, 481))
          case .HEALTH_CARE:
              //生理期设置
              _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleHealthCare(
                  9, 0, // 提醒时间
                  2, // 生理期提醒提前天数
                  2, // 排卵期提醒提前天数
                  2020, // 上次生理期日期
                  1,
                  1,
                  30, // 生理期周期，天
                  1,
                  7 // 生理期持续时间，天
              ))
          case .TEMPERATURE_DETECTING:
              //定时体温监测
              let detecting = BleTemperatureDetecting()
              detecting.mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0)
              detecting.mInterval = 60 // an hour
              _ = bleConnector.sendObject(bleKey, bleKeyFlag, detecting)

              // BleCommand.CONNECT
          case .IDENTITY:
              //绑定设备
              if bleKeyFlag == .CREATE {
                  _ = bleConnector.sendInt32(bleKey, bleKeyFlag, Int.random(in: 1..<0xffffffff))
              } else if bleKeyFlag == .READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .PAIR:
              //蓝牙配对
              _ = bleConnector.sendData(bleKey, bleKeyFlag)

              // BleCommand.PUSH
          case .SCHEDULE:
              if bleKeyFlag == .CREATE {
                  // 创建一个1分钟后的日程
                  let calendar = Calendar.current
                  var date = Date()
                  date.addTimeInterval(60.0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleSchedule(
                      calendar.component(.year, from: date), // mYear
                      calendar.component(.month, from: date), // mMonth
                      calendar.component(.day, from: date), // mDay
                      calendar.component(.hour, from: date), // mHour
                      calendar.component(.minute, from: date), // mMinute
                      0, // mAdvance
                      "Title8", // mTitle
                      "Content9" // mContent
                  ))
              } else if bleKeyFlag == .DELETE {
                  // 如果缓存中有日程的话，删除第一个
                  let schedules: [BleSchedule] = BleCache.shared.getArray(.SCHEDULE)
                  if !schedules.isEmpty {
                      _ = bleConnector.sendInt8(bleKey, bleKeyFlag, schedules[0].mId)
                  }
              } else if bleKeyFlag == .UPDATE {
                  // 如果缓存中有日程的话，修改第一个日程的时间
                  //mContent -> count<50
                  let schedules: [BleSchedule] = BleCache.shared.getArray(.SCHEDULE)
                  if !schedules.isEmpty {
                      let schedule = schedules[0]
                      schedule.mHour = Int.random(in: 1..<24)
                      _ = bleConnector.sendObject(bleKey, bleKeyFlag, schedule)
                  }
              }
          case .WEATHER_REALTIME:
              //实时天气
              if bleKeyFlag == .UPDATE {
                  // let weatherRealtime: BleWeatherRealtime? = BleCache.shared.getObject(.WEATHER_REALTIME)
                  _ = bleConnector.sendObject(BleKey.WEATHER_REALTIME, bleKeyFlag, BleWeatherRealtime(
                      time: Int(Date().timeIntervalSince1970),
                      weather: BleWeather(
                          currentTemperature: 1,
                          maxTemperature: 1,
                          minTemperature: 1,
                          weatherType: BleWeather.SUNNY,
                          windSpeed: 1,
                          humidity: 1,
                          visibility: 1,
                          ultraVioletIntensity: 1,
                          precipitation: 1
                      )
                  ))
              }
          case .WEATHER_FORECAST:
              //天气预报
              if bleKeyFlag == .UPDATE {
                  // let weatherForecast: BleWeatherForecast? = BleCache.shared.getObject(.WEATHER_FORECAST)
                  _ = bleConnector.sendObject(BleKey.WEATHER_FORECAST, bleKeyFlag, BleWeatherForecast(
                      time: Int(Date().timeIntervalSince1970),
                      weather1: BleWeather(
                          currentTemperature: 2,
                          maxTemperature: 2,
                          minTemperature: 2,
                          weatherType: BleWeather.CLOUDY,
                          windSpeed: 2,
                          humidity: 2,
                          visibility: 2,
                          ultraVioletIntensity: 2,
                          precipitation: 2),
                      weather2: BleWeather(
                          currentTemperature: 3,
                          maxTemperature: 3,
                          minTemperature: 3,
                          weatherType: BleWeather.OVERCAST,
                          windSpeed: 3,
                          humidity: 3,
                          visibility: 3,
                          ultraVioletIntensity: 3,
                          precipitation: 3),
                      weather3: BleWeather(
                          currentTemperature: 4,
                          maxTemperature: 4,
                          minTemperature: 4,
                          weatherType: BleWeather.RAINY,
                          windSpeed: 4,
                          humidity: 4,
                          visibility: 4,
                          ultraVioletIntensity: 4,
                          precipitation: 4)
                  ))
              }
          case .APP_SPORT_DATA:
              bleLog("-- PHONEWORKOUT --")
              break
          case .REAL_TIME_HEART_RATE:
              bleLog("-- REALTIMEHR --")
              break
              // BleCommand.DATA
          case .DATA_ALL, .ACTIVITY, .HEART_RATE, .BLOOD_PRESSURE, .SLEEP, .WORKOUT, .LOCATION, .TEMPERATURE,
                  .BLOODOXYGEN, .HRV, .WORKOUT2, .MATCH_RECORD:
              //Exercise data
              _ = bleConnector.sendData(bleKey, bleKeyFlag)

              // BleCommand.CONTROL
          case BleKey.CAMERA:
              //camera 相机拍照、或者退出拍照
              let mCameraEntered = args?["mCameraEntered"] as? Bool
              if mCameraEntered==true {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.EXIT)
              } else {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.ENTER)
              }
          case .APP_SPORT_STATE:
              bleLog("PHONE_WORKOUT_SWITCH")
              let mode = BlePhoneWorkOutStatus()
              mode.mMode = PhoneWorkOutStatus.Treadmill
              mode.mStatus = PhoneWorkOutStatus.modeEnd
              let sportStateInt = args?["sportState"] as? Int
              let sportModeInt = args?["sportMode"] as? Int
                  switch sportStateInt {
                  case 1:
                      mode.mStatus = PhoneWorkOutStatus.modeStart
                  case 2:
                      mode.mStatus = PhoneWorkOutStatus.modeContinues
                  case 3:
                      mode.mStatus = PhoneWorkOutStatus.modePause
                  case 4:
                      mode.mStatus = PhoneWorkOutStatus.modeEnd
                  default:
                      mode.mStatus = PhoneWorkOutStatus.modeEnd
                  }

                  switch sportModeInt {
                  case 1:
                      mode.mStatus = PhoneWorkOutStatus.Treadmill
                  case 2:
                      mode.mStatus = PhoneWorkOutStatus.OutdoorRun
                  case 3:
                      mode.mStatus = PhoneWorkOutStatus.Cycling
                  case 4:
                      mode.mStatus = PhoneWorkOutStatus.Climbing
                  default:
                      mode.mStatus = PhoneWorkOutStatus.Treadmill
                  }
        
              _ = bleConnector.sendObject(bleKey, bleKeyFlag, mode)
              break
          case .IBEACON_CONTROL:
              if bleKeyFlag == .UPDATE {
                  _ = BleConnector.shared.sendInt8(bleKey, bleKeyFlag, 0)
              }
              break
              // BleCommand.IO
          case .WATCH_FACE:
              if bleKeyFlag == .DELETE {
                  _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
                  return
              }
             // selectWatchType()
              break
//          case .AGPS_FILE, .FONT_FILE, .UI_FILE, .LANGUAGE_FILE:
//              if bleKeyFlag == .DELETE {
//                  _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
//                  return
//              }
//              let selectVC = selectOTAFileController()
//              selectVC.reloadBlock = { (fileURL) in
//                  bleLog("\(bleKey) - \(String(describing: fileURL))")
//                  _ = bleConnector.sendStream(bleKey, URL.init(fileURLWithPath: fileURL))
//                  self.proDuration = Int(Date().timeIntervalSince1970)
//                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
//                      progressLab.frame = CGRect(x: 50, y: 60, width: 230, height: 100)
//                      progressLab.numberOfLines = 0
//                      progressLab.backgroundColor = .black
//                      progressLab.textColor = .white
//                      progressLab.textAlignment = .center
//                      self.tableView.addSubview(progressLab)
//                      UIApplication.shared.isIdleTimerDisabled = true
//                  }
//              }
//              self.navigationController?.pushViewController(selectVC, animated: true)
//          case .CONTACT:
//              //address book 同步通讯录到设备
//             if addressBookAuthorization() {
//               selectAddressBook()
//            }
          case .AEROBIC_EXERCISE:
              if bleKeyFlag == .UPDATE {
                  let aerobic = BleAerobicSettings()
                  aerobic.mHour = 1
                  aerobic.mMin = 30
                  aerobic.mHRMin = 80
                  aerobic.mHRMax = 110
                  aerobic.mHRMinTime = 30
                  aerobic.mHRMinVibration = 4
                  aerobic.mHRMaxTime = 20
                  aerobic.mHRMaxVibration = 4
                  aerobic.mHRIntermediate = 30
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, aerobic)
              } else if bleKeyFlag == .READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .TEMPERATURE_UNIT:
              if bleKeyFlag == .UPDATE {
                  //0 - Celsius ℃ 1 - Fahrenheit ℉
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 1)
              } else if bleKeyFlag == .READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case .DATE_FORMAT:
              if bleKeyFlag == .UPDATE {
                  /**
                    0 ->YYYY/MM/dd
                    1 ->dd/MM/YYYY
                    2 ->MM/dd/YYYY
                    */
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 2)
              } else if bleKeyFlag == .READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          default:
              print("NO CASE -\(bleKey.mDisplayName)")
          }
      }
      }
}


extension SwiftSmartbleSdkPlugin: BleScanDelegate, BleScanFilter {

    func onBluetoothDisabled() {
        //btnScan.setTitle("Please enable the Bluetooth", for: .normal)
    }

    func onBluetoothEnabled() {
       // btnScan.setTitle("Scan", for: .normal)
    }

    func onScan(_ scan: Bool) {
        if scan {
           // btnScan.setTitle("Scanning", for: .normal)
            mDevices.removeAll()
           // tableView.reloadData()
        } else {
           // btnScan.setTitle("Scan", for: .normal)
        }
    }

    func onDeviceFound(_ device: BleDevice) {
        var item = [String : String]();
        item["deviceName"] = device.name
        item["deviceMacAddress"] = device.identifier
        if !mDevices.contains(item) {
            mDevices.append(item)
//            let newIndexPath = IndexPath(row: mDevices.count - 1, section: 0)
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        if let sink = scanSink {
            // Use the unwrapped value of `sink` here
            sink(mDevices)
        } else {
            // Handle the case where `flutterEventSink` is nil
        }
       
        
    }

    
    func match(_ device: BleDevice) -> Bool {
        device.mRssi > -82
    }
}

extension SwiftSmartbleSdkPlugin: BleHandleDelegate {

    func onDeviceConnected(_ peripheral: CBPeripheral) {
        print("onDeviceConnected - \(peripheral)")
    }
    
    func onDeviceConnecting(_ status: Bool) {
        print("onDeviceConnecting - \(status)")
    }

    func onIdentityCreate(_ status: Bool) {
        if status {
            _ = mBleConnector.sendData(.PAIR, .UPDATE)
//            dismiss(animated: true)
//            present(storyboard!.instantiateViewController(withIdentifier: "nav"), animated: true)
        }
    }
    
    
}




