//
//  KeyFlagsController.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/30.
//  Copyright © 2019 szabh. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class KeyFlagsController: UITableViewController {
    var mBleKey: BleKey!
    var mBleKeyFlags: [BleKeyFlag]!

    private var mCameraEntered = false
    var progressLab = UILabel()
    var proDuration = 0
    var phoneWorkOut = 0
    let mode = BlePhoneWorkOut()
    let mJLOTA = JLOTA.shared()
    var watchFaceIdNum = 0
    var selectView = ABHSelectWatchFaceId()
    var bleWatchFaceID : BleWatchFaceId?
    var watchFileURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = mBleKey.mDisplayName

        mBleKeyFlags = mBleKey.getBleKeyFlags()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BleConnector.shared.addBleHandleDelegate(String(obj: self), self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BleConnector.shared.removeBleHandleDelegate(String(obj: self))
        UIApplication.shared.isIdleTimerDisabled = false
        progressLab.removeFromSuperview()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mBleKeyFlags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyFlagCell", for: indexPath) as! KeyFlagCell
        cell.label.text = "\(mBleKeyFlags[indexPath.row])"
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleCommand(mBleKey, mBleKeyFlags[indexPath.row])
    }

    func handleCommand(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag) {
        if bleKey == .IDENTITY {
            if bleKeyFlag == .DELETE {
                if BleConnector.shared.isAvailable() {
                    _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
                }
                BleConnector.shared.unbind()
                unbindCompleted()
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
                gotoOta()
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
                if mCameraEntered {
                    _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.EXIT)
                } else {
                    _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.ENTER)
                }
            case .APP_SPORT_STATE:
                bleLog("PHONE_WORKOUT_SWITCH - \(phoneWorkOut)")
                let mode = BlePhoneWorkOutStatus()
                mode.mMode = PhoneWorkOutStatus.Treadmill
                switch phoneWorkOut {
                case 0:
                    phoneWorkOut = 2
                    mode.mStatus = PhoneWorkOutStatus.modeStart
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.senderPhoneWorkOut()
                    }
                    break
                case 1:
                    phoneWorkOut = 3
                    mode.mStatus = PhoneWorkOutStatus.modeContinues
                    break
                case 2:
                    phoneWorkOut = 3
                    mode.mStatus = PhoneWorkOutStatus.modePause
                    break
                case 3:
                    phoneWorkOut = 0
                    mode.mStatus = PhoneWorkOutStatus.modeEnd
                    break
                default:
                    break
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
                selectWatchType()
                break
            case .AGPS_FILE, .FONT_FILE, .UI_FILE, .LANGUAGE_FILE:
                if bleKeyFlag == .DELETE {
                    _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
                    return
                }
                let selectVC = selectOTAFileController()
                selectVC.reloadBlock = { (fileURL) in
                    bleLog("\(bleKey) - \(String(describing: fileURL))")
                    _ = bleConnector.sendStream(bleKey, URL.init(fileURLWithPath: fileURL))
                    self.proDuration = Int(Date().timeIntervalSince1970)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                        progressLab.frame = CGRect(x: 50, y: 60, width: 230, height: 100)
                        progressLab.numberOfLines = 0
                        progressLab.backgroundColor = .black
                        progressLab.textColor = .white
                        progressLab.textAlignment = .center
                        self.tableView.addSubview(progressLab)
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                }
                self.navigationController?.pushViewController(selectVC, animated: true)
            case .CONTACT:
                //address book 同步通讯录到设备
                if addressBookAuthorization() {
                    selectAddressBook()
                }
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
    // MARK: - Phone WorkOut
    func senderPhoneWorkOut(){        
        mode.mStep += 10
        mode.mDistance += 1
        mode.mCalories += 1
        mode.mDuration += 1
        mode.mSmp = 1
        mode.mAltitude = -5
        mode.mAirPressure = 1
        mode.mAvgPace = 1
        mode.mAvgSpeed = 1
        mode.mModeSport = 8
        if BleConnector.shared.sendObject(.APP_SPORT_DATA, .UPDATE, mode){
            bleLog(" -- senderPhoneWorkOut --")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.senderPhoneWorkOut()
        }
    }
    
    // MARK: - AddressBook
    func selectAddressBook(){
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let Select = UIAlertAction(title: "Select Contact", style: .default) {[weak self] (action) in
            self!.selectContact()
        }
        let notchoose = UIAlertAction(title: "Not choose", style: .default) { [weak self](action) in
            self!.sendAddressBook()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(Select)
        alert.addAction(notchoose)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectContact(){
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func sendAddressBook() {
        bleLog("Address Book")
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        var sendArray: [BleContactPerson] = []
        do {
            try contactStore.enumerateContacts(with: request) { (contact: CNContact, stop) in
                var userName: String = " "

                userName = contact.givenName + contact.familyName

                var phoneString: String = ""
                if contact.phoneNumbers.count > 0 {
                    let phoneNums = contact.phoneNumbers.first
                    phoneString = phoneNums!.value.stringValue
                }
//                let phone = phoneString.replacingOccurrences(of: " ", with: "")
                let phone = self.stringReplacingOccurrencesOfString(phoneString)
                //Name
                var bytes: [UInt8] = []
                var index = 0
                for items in userName.utf8 {
                    if index < 24 {
                        index += 1
                        bytes.append(items.advanced(by: 0))
                    }
                }

                let newDate = Data(bytes: bytes, count: bytes.count)
                userName = String.init(data: newDate, encoding: .utf8) ?? ""

                if phone.count > 2 {
                    sendArray.append(BleContactPerson.init(username: userName, userphone: phone))
                }
            }
        } catch {
        }

        let send: BleAddressBook = BleAddressBook.init(array: sendArray)
        if BleConnector.shared.sendStream(.CONTACT, send.toData()) {
            bleLog("sendStream - AddressBook")
        }
    }

    func addressBookAuthorization() -> Bool {
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        if status == .notDetermined {
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts, completionHandler: { (_ granted, _ error) in
                if granted {
                    bleLog("notDetermined - succ")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.selectAddressBook()
                    }
                }
            })
            return false
        } else if status == .authorized {
            bleLog("addressBook - authorized")
            return true
        } else {
            bleLog("addressBook - other")
            return false
        }
    }
    //replace special characters
    func stringReplacingOccurrencesOfString(_ str:String) ->String {
        let str1: NSString = str as NSString
        let charactersInString = "[]{}（#%-*=_）\\|//~(＜＞$%^&*)_€£¥:;!@.`,"
        let doNotWant = CharacterSet.init(charactersIn: charactersInString)
        let componentsArrays = str1.components(separatedBy: doNotWant)
        let hmutStr = componentsArrays.joined(separator: "")
        return hmutStr
    }

    private func doBle(_ action: (BleConnector) -> Void) {
        let bleConnector = BleConnector.shared
        if bleConnector.isAvailable() {
            action(bleConnector)
        } else {
            print("BleConnector is not available!")
        }
    }

    private func unbindCompleted() {
        present(storyboard!.instantiateViewController(withIdentifier: "devices"), animated: true)
    }

    private func gotoOta() {
        switch BleCache.shared.mPlatform {
        case BleDeviceInfo.PLATFORM_NORDIC, BleDeviceInfo.PLATFORM_GOODIX:
            _ = BleConnector.shared.sendData(.OTA, .UPDATE)
        case BleDeviceInfo.PLATFORM_MTK:
            _ = BleConnector.shared.read(BleConnector.SERVICE_MTK, BleConnector.CH_MTK_OTA_META)
        default:
            break
        }
    }
    
    // MARK: - 0x0701_WATCH_FACE
    func selectWatchType(){
        if BleCache.shared.mSupportWatchFaceId == 1{
            _ = BleConnector.shared.sendData(.WATCHFACE_ID, .READ)
        }
        let alert = UIAlertController.init(title: "WATCH FACE", message: nil, preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "default watch face", style: .default) { [weak self](action) in
            self!.senderDefaultWatchFace()
        }
        let customizeAction = UIAlertAction(title: "customize watch face", style: .default) { [weak self](action) in
            self!.selectCustomizeWatchFace()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        alert.addAction(customizeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func senderDefaultWatchFace(){
        proDuration = 0
        let selectVC = selectOTAFileController()
        selectVC.reloadBlock = { (fileURL) in
            bleLog("senderDefaultWatchFace - \(String(describing: fileURL))")
            if BleCache.shared.mPlatform == BleDeviceInfo.PLATFORM_JL {//&&
//                BleCache.shared.mSupportJLWatchFace == 1
                self.senderJLWatchFace(fileURL)
            }else if BleCache.shared.mSupportWatchFaceId == 1{
                self.watchFileURL = fileURL
                self.isShowSelectWatchFaceId()
            }else{
                _ = BleConnector.shared.sendStream(.WATCH_FACE, URL.init(fileURLWithPath: fileURL))
                self.proDuration = Int(Date().timeIntervalSince1970)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                    progressLab.frame = CGRect(x: 20, y: 70, width: MaxWidth-40, height: 100)
                    progressLab.numberOfLines = 0
                    progressLab.font = .systemFont(ofSize: 15)
                    progressLab.backgroundColor = .black
                    progressLab.textColor = .white
                    progressLab.textAlignment = .center
                    self.tableView.addSubview(progressLab)
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
        }
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    func selectCustomizeWatchFace(){
        let cusVC = BleCustomizeWatchFace()
        self.navigationController?.pushViewController(cusVC, animated: true)
    }
    
    func senderJLWatchFace(_ filePath:String){
        mJLOTA.watchFaceName = "WATCH1"
        mJLOTA.watchFacePath = filePath
        mJLOTA.isWatchFace = true
        if mJLOTA.isConnect == true{
            mJLOTA.openWatchFace()
        }else{
            mJLOTA.connectPeripheral(withUUID: (BleConnector.shared.mPeripheral?.identifier.uuidString)!)
        }
        
    }
}
// MARK: - mSupportWatchFaceId == 1
extension KeyFlagsController {
    func isShowSelectWatchFaceId(){

        selectView = ABHSelectWatchFaceId()
        let bkBtn = UIButton()
        bkBtn.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        bkBtn.addTarget(self, action: #selector(selectRemoveFromSuperview(_ :)), for: .touchUpInside)
        bkBtn.frame = CGRect(x: 0, y: 0, width: MaxWidth, height: MaxHeight)
        self.view.addSubview(bkBtn)
    
        selectView.frame = CGRect(x: 0, y: MaxHeight-400, width: MaxWidth, height: 300)
        self.view.addSubview(selectView)
        if bleWatchFaceID != nil{
            selectView.watchFaceId = bleWatchFaceID
        }
        selectView.makeView()
        selectView.selectItem = ({ (num:Int) in
            bleLog("selectItem - \(num)")
            self.watchFaceIdNum = num
            self.saveSelectImage(num)
            self.senderWatchFaceID(num)
            bkBtn.sendActions(for: .touchUpInside)
        })
        
        
    }
    
    @objc func selectRemoveFromSuperview(_ sender:UIButton) {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        sender.removeFromSuperview()
        self.selectView.removeFromSuperview()
    }
    
    func saveSelectImage(_ selectNum:Int){
        let fileName = "WatchFaceID"+"\(selectNum)"
        var imageName = "bg_1"
        if selectNum%2 == 0{
            imageName = "bg_2"
        }
        let imageSvae = UIImage.init(named: imageName)
        saveNSDataImage(currentData: imageSvae!.pngData()! as NSData, imageName: fileName)
    }
    
    func senderWatchFaceID(_ number:Int){
        let watchFaceId : Int32 = Int32(number+10000) //ID >= 100
        _ = BleConnector.shared.sendInt32(.WATCHFACE_ID, .UPDATE, Int(watchFaceId))
    }
    
    func senderBinFile(){
        if watchFileURL.count>0{
            _ = BleConnector.shared.sendStream(.WATCH_FACE, URL.init(fileURLWithPath: watchFileURL),self.watchFaceIdNum)
            self.proDuration = Int(Date().timeIntervalSince1970)
            progressLab.frame = CGRect(x: 20, y: 70, width: MaxWidth-40, height: 100)
            progressLab.numberOfLines = 0
            progressLab.font = .systemFont(ofSize: 15)
            progressLab.backgroundColor = .black
            progressLab.textColor = .white
            progressLab.textAlignment = .center
            self.tableView.addSubview(progressLab)
            UIApplication.shared.isIdleTimerDisabled = true
            watchFileURL = ""
        }
    }
    
    func saveNSDataImage(currentData: NSData, imageName: String){
        let fullPath = NSHomeDirectory().appending("/Documents/").appending(imageName)
        currentData.write(toFile: fullPath, atomically: true)
    }
}

//MARK: address book
extension KeyFlagsController :CNContactPickerDelegate{
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        var dataSource :[BleContactPerson] = []
        for contact in contacts{
            var userName :String = " "
            userName  = contact.givenName+contact.familyName
            var phoneString :NSString = ""
            if contact.phoneNumbers.count>0{
                let phoneNums  = contact.phoneNumbers.first
                phoneString  = phoneNums!.value.stringValue as NSString
            }
            var phone = phoneString.replacingOccurrences(of: " ", with: "")
            phone = phone.stringReplacingOccurrencesOfString()

            if phone.count>2{
                dataSource.append(BleContactPerson.init(username: userName, userphone: phone))
            }
            bleLog("userName - \(userName) phone \(phone)")
        }
        if dataSource.count>0 {
            let sende :BleAddressBook = BleAddressBook.init(array: dataSource)
            if BleConnector.shared.sendStream(.CONTACT,sende.toData()){
                bleLog("sendStream - AddressBook")
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension KeyFlagsController: BleHandleDelegate {

    func onDeviceConnected(_ peripheral: CBPeripheral){
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            if BleCache.shared.miBeacon == 1{
                //manually open the iBeacon protocol
                _ =  BleConnector.shared.sendInt8(.IBEACON_SET, .UPDATE, 1)
            }
        }
    }
    
    func onOTA(_ status: Bool) {
        print("onOTA \(status)")
    }

    func onReadPower(_ power: Int) {
        print("onReadPower \(power)")
    }

    func onReadFirmwareVersion(_ version: String) {
        print("onReadFirmwareVersion \(version)")
    }

    func onReadBleAddress(_ address: String) {
        print("onReadBleAddress \(address)")
    }

    func onReadSedentariness(_ sedentarinessSettings: BleSedentarinessSettings) {
        print("onReadSedentariness \(sedentarinessSettings)")
    }

    func onReadNoDisturb(_ noDisturbSettings: BleNoDisturbSettings) {
        print("onReadNoDisturb \(noDisturbSettings)")
    }

    func onReadAlarm(_ alarms: Array<BleAlarm>) {
        print("onReadAlarm \(alarms)")
    }

    func onIdentityDelete(_ status: Bool) {
        print("onIdentityDelete \(status)")
        if status {
            unbindCompleted()
        }
    }

    func onSyncData(_ syncState: Int, _ bleKey: Int) {
        print("onSyncData \(syncState) \(bleKey)")
    }

    func onReadActivity(_ activities: [BleActivity]) {
        print("onReadActivity \(activities)")
    }

    func onReadHeartRate(_ heartRates: [BleHeartRate]) {
        print("onReadHeartRate \(heartRates)")
    }

    func onReadBloodPressure(_ bloodPressures: [BleBloodPressure]) {
        print("onReadBloodPressure \(bloodPressures)")
    }

    func onReadSleep(_ sleeps: [BleSleep]) {
        if BleCache.shared.mSleepAlgorithmType == 1 {
            for item in sleeps {
                if item.mMode == 4 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("sleep time total length - \(time)min")
                } else if item.mMode == 5 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("deep sleep time length - \(time)min")
                } else if item.mMode == 6 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("light sleep time length - \(time)min")
                } else if item.mMode == 7 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("awake time length - \(time)min")
                }
            }
        } else {
            print("onReadSleep \(sleeps)")
        }
    }

    func onReadSleepRaw(_ sleepRawData: Data) {
        /**
         this is the original firmware data, which can be saved to a text file for the firmware technician to
         analyze the problem
         固件原始数据,app端无需处理,如需固件端分析问题可以保存到text文件提供给我们固件技术员
         */
        print("onReadSleepRaw - \(sleepRawData.mHexString)")
    }

    func onReadLocation(_ locations: [BleLocation]) {
        print("onReadLocation \(locations)")
    }

    func onReadTemperature(_ temperatures: [BleTemperature]) {
        print("onReadTemperature \(temperatures)")
    }

    func onCameraStateChange(_ cameraState: Int) {
        print("onCameraStateChange \(CameraState.getState(cameraState))")
        if cameraState == CameraState.ENTER {
            mCameraEntered = true
        } else if cameraState == CameraState.EXIT {
            mCameraEntered = false
        }
    }

    func onCameraResponse(_ status: Bool, _ cameraState: Int) {
        print("onCameraResponse \(status) \(CameraState.getState(cameraState))")
        if status {
            if cameraState == CameraState.ENTER {
                mCameraEntered = true
            } else if cameraState == CameraState.EXIT {
                mCameraEntered = false
            }
        }
    }

    func onStreamProgress(_ status: Bool, _ errorCode: Int, _ total: Int, _ completed: Int) {
        
        let progressValue = CGFloat(completed) / CGFloat(total)
        var mSpeed :Double = 0.0
        let nowTime = Int(Date().timeIntervalSince1970)
        let sTime = nowTime-proDuration
        if errorCode == 0 && total == completed {
            mSpeed = Double(total/1024)/Double(sTime)
            progressLab.text = "speed:\(String.init(format: "%.3f",mSpeed)) kb/s \n time:"+String.init(format: "%02d:%02d:%02d", sTime/3600,(sTime%3600)/60,sTime%60)+" MTU:\(BleConnector.shared.mBaseBleMessenger.mPacketSize)"
//            self.navigationController?.popToRootViewController(animated: true)
        }else{
            
            if completed>0{
                mSpeed = Double(completed/1024)/Double(sTime)
            }
            progressLab.text = "progress:\(String(format: "%.f", progressValue * 100.0))% - \(String.init(format: "%.3f",mSpeed)) kb/s"+"\n"+String.init(format: "%02d:%02d:%02d", sTime/3600,(sTime%3600)/60,sTime%60)
        }
        
//        print("onStreamProgress \(status) \(errorCode) \(total) \(completed) - \(String.init(format: "%.3f",mSpeed))")
    }

    func onReadAerobicSettings(_ AerobicSettings: BleAerobicSettings) {
        print("onReadAerobicSettings - \(AerobicSettings)")
    }

    func onReadTemperatureUnitSettings(_ state: Int) {
        print("onReadTemperatureUnitSettings - \(state)")
    }

    func onReadDateFormatSettings(_ status: Int) {
        print("onReadDateFormatSettings - \(status)")
    }
    
    func onReadWatchFaceSwitch(_ value: Int){
        print("onReadWatchFaceSwitch - \(value)")
        
    }
    
    func onUpdateWatchFaceSwitch(_ status: Bool) {
        if status{
            print("set the default watch face success")
        }
    }
    
    func onUpdateSettings(_ bleKey: BleKey.RawValue) {
        switch bleKey {
        case BleKey.NO_DISTURB_RANGE.rawValue:
            bleLog("NO_DISTURB_RANGE is success")
            break
        default:
            break
        }
    }
    
    func onReadWatchFaceId(_ watchFaceId: BleWatchFaceId) {
        bleWatchFaceID = watchFaceId
    }
    
    func onWatchFaceIdUpdate(_ status: Bool) {
        senderBinFile()
    }
}

extension String {
    // MARK: 过滤字符串中的特殊字符
    func stringReplacingOccurrencesOfString() ->String {
        let str: NSString = self as NSString
        let charactersInString = "[]{}（#%-*=_）\\|//~(＜＞$%^&*)_+€£¥:;!@.`,"
        let doNotWant = CharacterSet.init(charactersIn: charactersInString)
        let componentsArrays = str.components(separatedBy: doNotWant)
        let hmutStr = componentsArrays.joined(separator: "")
        return hmutStr
    }
}
