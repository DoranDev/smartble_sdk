//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleDeviceInfo: BleReadable {
    static let PLATFORM_NORDIC = "Nordic"
    static let PLATFORM_REALTEK = "Realtek"
    static let PLATFORM_MTK = "MTK"
    static let PLATFORM_GOODIX = "Goodix"
    static let PLATFORM_JL = "JL"//杰里

    // Nordic
    static let PROTOTYPE_10G = "SMA-10G"
    static let PROTOTYPE_GTM5 = "SMA-GTM5"
    static let PROTOTYPE_F1N = "SMA-F1N"
    static let PROTOTYPE_ND09 = "SMA-ND09"
    static let PROTOTYPE_ND08 = "SMA-ND08"
    static let PROTOTYPE_FA86 = "SMA_FA_86"
    static let PROTOTYPE_MC11 = "SMA_MC_11"

    // Realtek
    static let PROTOTYPE_R4 = "SMA-R4"
    static let PROTOTYPE_R5 = "SMA-R5"
    static let PROTOTYPE_F1RT = "SMA-F1RT"
    static let PROTOTYPE_F2 = "SMA-F2"
    static let PROTOTYPE_F3C = "SMA-F3C"
    static let PROTOTYPE_F3R = "SMA-F3R"
    static let PROTOTYPE_F3L = "F3-LH"
    static let PROTOTYPE_R7 = "SMA-R7"
    static let PROTOTYPE_F13 = "SMA-F13"
    static let PROTOTYPE_F13J = "F13J"
    static let PROTOTYPE_B5CRT = "SMA-B5CRT"
    static let PROTOTYPE_R10 = "R10"
    static let PROTOTYPE_R10Pro = "R10Pro"
    static let PROTOTYPE_R11 = "R11"
    static let PROTOTYPE_R11S = "R11S"
    static let PROTOTYPE_F5 = "F5"
    static let PROTOTYPE_F6 = "F6"
    static let PROTOTYPE_F7 = "F7"
    static let PROTOTYPE_F9 = "F9"
    static let PROTOTYPE_R9 = "R9"
    static let PROTOTYPE_SW01 = "SMA-SW01"
    static let PROTOTYPE_F2R = "SMA-F2R"
    static let PROTOTYPE_GTM5R = "REALTEK_GTM5"
    static let PROTOTYPE_F1 = "SMA-F1"
    static let PROTOTYPE_F2D = "SMA-F2D"
    static let PROTOTYPE_T78 = "T78"
    static let PROTOTYPE_SMAV1 = "SMA-V1"
    static let PROTOTYPE_Y1 = "Y1"
    static let PROTOTYPE_Y2 = "Y2"
    static let PROTOTYPE_V2 = "V2"
    static let PROTOTYPE_Y3 = "Y3"
    static let PROTOTYPE_R3Pro = "R3Pro"
    static let PROTOTYPE_F2Pro = "F2Pro"
    static let PROTOTYPE_Match_S1 = "Match_S1"
    static let PROTOTYPE_S2 = "S2"
    static let PROTOTYPE_S03 = "SMA_S03"
    static let PROTOTYPE_B9 = "B9"
    static let PROTOTYPE_V5  = "V5"
    static let PROTOTYPE_V3  = "V3"
    static let PROTOTYPE_LG19T = "LG19T"
    static let PROTOTYPE_F2K = "F2K"
    static let PROTOTYPE_W9 = "W9"
    static let PROTOTYPE_Explorer = "Explorer"
    static let PROTOTYPE_NY58 = "NY58"
    static let PROTOTYPE_F12 = "F12"
    static let PROTOTYPE_AM01 = "AM01"
    static let PROTOTYPE_F11 = "F11"
    static let PROTOTYPE_F13A = "F13A"
    static let PROTOTYPE_F2R_NEW = "F2R"
    static let PROTOTYPE_F1_NEW = "F1"
    static let PROTOTYPE_S4 = "S4"
    static let PROTOTYPE_R6_PRO_DK = "R6_PRO_DK"
    static let PROTOTYPE_GB1 = "GB1" /// 这个设备有点特殊, 仅仅需要OTA即可, 其他都不要, 所以开发需要注意下
    static let PROTOTYPE_SPORT4 = "Sport4"
    
    // Goodix
    static let PROTOTYPE_R3H = "R3H"
    static let PROTOTYPE_R3Q = "R3Q"

    // MTK
    static let PROTOTYPE_R2 = "R2"
    static let PROTOTYPE_F3 = "F3"
    static let PROTOTYPE_M3 = "M3"
    static let PROTOTYPE_M4 = "M4"
    static let PROTOTYPE_M4C = "M4C"
    static let PROTOTYPE_M5C = "M5C"
    static let PROTOTYPE_M4S = "M4S"
    static let PROTOTYPE_M7 = "M7"
    static let PROTOTYPE_M7S = "M7S"
    static let PROTOTYPE_M6 = "M6"
    static let PROTOTYPE_M6C = "M6C"
    static let PROTOTYPE_M7C = "M7C"
    // JL
    static let PROTOTYPE_R9J = "R9J"
    static let PROTOTYPE_F13B = "F13B"
    static let PROTOTYPE_A7 = "A7"
    static let PROTOTYPE_A8 = "A8"
    static let PROTOTYPE_AM01J = "AM01J"
    static let PROTOTYPE_F17 = "F17"
    static let PROTOTYPE_AM02J = "AM02J"
    static let PROTOTYPE_HW01 = "HW01"
    static let PROTOTYPE_F12Pro = "F12Pro"
    static let PROTOTYPE_K18 = "K18"
    static let PROTOTYPE_AW12 = "AW12"
    static let PROTOTYPE_AM05 = "AM05"
    static let PROTOTYPE_K30 = "K30"
    static let PROTOTYPE_FC1 = "FC1"
    static let PROTOTYPE_FC2 = "FC2"
    static let PROTOTYPE_F6Pro = "F6Pro"
    static let PROTOTYPE_FT5 = "FT5"
    static let PROTOTYPE_R16 = "R16"
    static let PROTOTYPE_A8_Ultra_Pro = "A8_Ultra_Pro"
    static let PROTOTYPE_AM08 = "AM08"
    static let PROTOTYPE_JX621D = "JX621D"
    static let PROTOTYPE_V61 = "V61"
    static let PROTOTYPE_AM11 = "AM11"
    static let PROTOTYPE_AW37 = "AW37"
    
    
    static let AGPS_NONE = 0 // 无GPS芯片
    static let AGPS_EPO = 1 // MTK EPO
    static let AGPS_UBLOX = 2
    static let AGPS_AGNSS = 6 // 中科微
    static let AGPS_EPO_ONLY  = 7 //MTK EPO
    static let AGPS_LTO = 8
    static let AGPS_6228 = 9 // for volt

    static let WATCH_FACE_NONE = 0 // 不支持表盘
    static let WATCH_FACE_10G = 1
    static let WATCH_FACE_F3 = 2   //sma通用表盘-MTK 240x240-旧表盘
    static let WATCH_FACE_REALTEK = 3 //Realtek bmp格式表盘 方形
    static let WATCH_FACE_240x280 = 4    //MTK-小尺寸表盘 要求表盘文件不超过40K
    static let WATCH_FACE_320x385 = 5    //MTK-表盘文件分辨率320x385
    static let WATCH_FACE_320x363 = 6    //MTK-表盘文件分辨率320x363
    static let WATCH_FACE_REALTEK_ROUND = 7 //Realtek bmp格式表盘 圆形
    static let WATCH_FACE_GOODIX = 8 //汇顶平台表盘
    static let WATCH_FACE_REALTEK_RACKET = 9    //瑞昱R6,R8球拍屏，240x240
    static let WATCH_FACE_REALTEK_SQUARE_240x280 = 10  //瑞昱240*280方形表盘BMP格式
    static let WATCH_FACE_REALTEK_ROUND_240x240 = 11 //瑞昱bmp格式表盘,圆形表盘文件分辨率240*240，双模蓝牙
    static let WATCH_FACE_REALTEK_SQUARE_240x240 = 12 //瑞昱bmp格式表盘，方形表盘 240*240 双模蓝牙
    static let WATCH_FACE_240_240 = 13   //MTK 240x240-新表盘
    static let WATCH_FACE_REALTEK_SQUARE_80x160 = 14 //瑞昱80*160方形表盘BMP格式
    static let WATCH_FACE_REALTEK_ROUND_360x360 = 15 //BMP 圆形-目前应用于瑞昱平台
    static let WATCH_FACE_REALTEK_SQUARE_240x280_2 = 16 //瑞昱240*280方形表盘BMP格式（双蓝牙）
    static let WATCH_FACE_REALTEK_ROUND_454x454 = 17 //瑞昱 454x454 圆形 双蓝牙 R9 （中间件项目，表盘需字节对齐）
    static let WATCH_FACE_REALTEK_ROUND_CENTER_240x240 = 18 //瑞昱 240x240 圆形 单蓝牙 GTM5（中间件项目，表盘需字节对齐)
    static let WATCH_FACE_REALTEK_SQUARE_240x280_19 = 19 //标记10扩展 瑞昱240*280方形表盘BMP格式（单蓝牙）
    static let WATCH_FACE_REALTEK_SQUARE_240x280_20 = 20 //标记10扩展 瑞昱240*280方形表盘BMP格式（双蓝牙）
    static let WATCH_FACE_REALTEK_SQUARE_240x295_21 = 21 //瑞昱240*295方形表盘BMP格式（双蓝牙）
    static let WATCH_FACE_SERVER  = 99 //服务器表盘标记位
    
    /// 自定义蓝牙名后, 用于查找原始名称的分隔符
    private let kRAW_NAME_SEPARATOR = "<>"
    
    var mId: Int = 0

    /**
     * 设备支持读取的数据列表。
     */
    var mDataKeys: [Int] = []

    /**
     * 设备蓝牙名。
     */
    var mBleName: String = ""
    /**
     * 用户自定义的蓝牙名
     */
    var mBleCustomName: String = ""

    /**
     * 设备蓝牙4.0地址。
     */
    var mBleAddress: String = ""

    /**
     * 芯片平台，Nordic、RealTek、MTK,、Goodix等。
     */
    var mPlatform: String = ""

    /**
     * 设备原型，代表是基于哪款设备开发。
     */
    var mPrototype: String = ""

    /**
     * 固件标记，固件那边所说的制造商，但严格来说，制造商表述并不恰当，且避免与后台数据结构中的分销商语义冲突，
     * 因为其仅仅用来区分固件，所以命名为FirmwareFlag，与BleName联合确定唯一固件。
     */
    var mFirmwareFlag: String = ""

    /**
     * aGps文件类型，不同读GPS芯片需要下载不同的aGps文件，AGPS_EPO、AGPS_UBLOX或AGPS_AGNSS等，
     * 如果为0，代表不支持GPS。
     */
    var mAGpsType: Int = 0 // aGps文件类型

    /**
     * 发送BleCommand.IO的Buffer大小，见BleConnector.sendStream。
     */
    var mIOBufferSize: Int = 0

    /**
     * 表盘类型，WATCH_FACE_10G或WATCH_FACE_F3。
     */
    var mWatchFaceType: Int = 0

    /**
     * 设备蓝牙3.0地址。
     */
    var mClassicAddress: String = ""

    /**
     * 不显示数字电量。
     */
    var mHideDigitalPower: Int = 0

    /**
     * 显示防丢开关。
     */
    var mAntiLostSwitch: Int = 0

    /**
     * 新睡眠算法
     */
    var mSleepAlgorithmType: Int = 0

    /**
     * 日期格式修改
     */
    var mDateFormat: Int = 0

    var mSupportReadDeviceInfo: Int = 0
    /**
     * 是否支持修改体温单位
     */
    var mTemperatureUnit : Int = 0
    /**
     * 是否支持喝水提醒设置
     */
    var mDrinkWater : Int = 0
    /**
     * 是否支持3.0协议
     */
    var mChangeClassicBluetoothState : Int = 0
    /**
     * 是否支持App、手表运动模式联动协议
     */
    var mAppSport : Int = 0
    /**
     * 是否支持血氧定时监测设置
     */
    var mBloodOxyGenSet : Int = 0
    /**
     * 是否支持洗手提醒的设置
     */
    var mWashSet : Int = 0
    /**
     * 是否支持按需更新天气
     */
    var mDemandWeather : Int = 0
    /**
     * 是否支持HID协议
     */
    var mSupportHID : Int = 0
    /**
     * 是否支持iBeacon协议
     */
    var miBeacon : Int = 0
    /**
     * 是否支持设置表盘ID
     */
    var mSupportWatchFaceId : Int = 0
    /**
     * 是否支持IOS withoutResponse传输
     */
    var mSupportNewTransportMode : Int = 0
    /**
     * 是否支持杰里SDK传输表盘
     */
    var mSupportJLWatchFace : Int = 0
    /**
     * 是否支持找手表
     */
    var mSupportFindWatch : Int = 0
    /**
     * 是否支持世界时钟
     */
    var mSupportWorldClock : Int = 0
    /**
     * 是否支持股票
     */
    var mSupportStock : Int = 0
    /**
     * 是否支持快捷短信回复(Android使用)
     */
    var mSupportSMSQuickReply : Int = 0
    /**
     * 是否App勿扰时间段
     */
    var mSupportNoDisturbSet : Int = 0
    /**
     * 设备是否支持设置密码
     */
    var mSupportSetWatchPassword : Int = 0
    /**
     * 设备是否支持实时测量心率、血压、血氧
     */
    var mSupportRealTimeMeasurement : Int = 0
    /**
     * 设备是否支持是否支持省电模式功能
     */
    var mSupportPowerSaveMode: Int = 0
    
    /// 设备是否支持是否支持LoveTap功能
    var mSupportLoveTap: Int = 0
    
    /// 设备是否支持是否支持Newsfeed功能
    var mSupportNewsfeed: Int = 0
    
    /// 设备是否支持是否支持吃药提醒, [SUPPORT_MEDICATION_REMINDER_0], [SUPPORT_MEDICATION_REMINDER_1]
    var mSupportMedicationReminder: Int = 0
    /// 设备是否支持是否同步二维码, [SUPPORT_QRCODE_0], [SUPPORT_QRCODE_1]
    var mSupportQrcode: Int = 0
    /// 设备是否支持新的天气协议(支持7天)
    var mSupportWeather2: Int = 0
    /// 是否支持支付宝
    var mSupportAliPay: Int = 0
    /// 是否支持待机设置
    var mSupportStandbySetting: Int = 0
    /// 是否支持2D加速资源, 例如在线表盘, 自定义表盘之类的
    var mSupport2DAcceleration: Int = 0
    /// 是否支持涂鸦授权码修改
    var mSupportDoodleAuthorizationCode: Int = 0
    /// 是否支持药物提醒2简化版功能, 这个是简化版本的吃药提醒, 就类似闹钟
    var mSupportMedicationAlarm: Int = 0
    /// 是否支持读取获取手表字库/UI/语言包/信息
    var mSupportReadPackageStatus: Int = 0
    /// 支持的联系人数量, 如果返回0, 默认20条, 返回大于0, 则是size = value * 10
    var mSupportContactSize: Int = 0
    /// 是否支持语音助手（小度）
    var mSupportVoiceAssistant_XiaoDu: Int = 0
    /// 是否支持导航
    var mSupportNavigation: Int = 0
    /// 是否支持心率警报设置
    var mSupportHeartRateAlarmSetting: Int = 0
    
    
    required init(_ data: Data?, _ byteOrder: ByteOrder) {
        super.init(data, byteOrder)
    }

    override func decode() {
        super.decode()
        mId = Int(readInt32())
        let dataKeyData = readDataUtil(0)
        let dataCount = dataKeyData.count / 2
        mDataKeys.removeAll()
        for i in 0..<dataCount {
            mDataKeys.append(Data(dataKeyData[i * 2..<(i + 1) * 2]).getUInt(0, 2))
        }
        mBleName = readStringUtil(0)
        mBleAddress = readStringUtil(0)
        mPlatform = readStringUtil(0)
        mPrototype = readStringUtil(0)
        mFirmwareFlag = readStringUtil(0)

        // 如果固件标记包含特殊分隔符
        if mFirmwareFlag.contains(kRAW_NAME_SEPARATOR) {
            
            if let rawName = mFirmwareFlag.components(separatedBy: kRAW_NAME_SEPARATOR).last {
                
                // rawName不为空, 并且和mBleName一致, 就是用户修改了蓝牙名, 需要重新调整显示的蓝牙名
                if rawName != mBleName {
                    mBleCustomName = mBleName  // 保存自定义名称
                    mBleName = rawName  // mBleName 始终都显示正确的蓝牙名
                }
            }
        }
        
        mAGpsType = Int(readInt8())
        mIOBufferSize = Int(readUInt16())
        mWatchFaceType = Int(readInt8())
        mClassicAddress = readStringUtil(0)
        mHideDigitalPower = Int(readInt8())
        mAntiLostSwitch = Int(readInt8())
        mSleepAlgorithmType = Int(readInt8())
        mDateFormat = Int(readInt8())
        mSupportReadDeviceInfo = Int(readInt8())
        mTemperatureUnit = Int(readInt8())
        mDrinkWater = Int(readInt8())
        mChangeClassicBluetoothState = Int(readInt8())
        mAppSport = Int(readInt8())
        mBloodOxyGenSet = Int(readInt8())
        mWashSet = Int(readInt8())
        mDemandWeather = Int(readInt8())
        mSupportHID = Int(readInt8())
        miBeacon = Int(readInt8())
        mSupportWatchFaceId = Int(readInt8())
        mSupportNewTransportMode = Int(readInt8())
        mSupportJLWatchFace = Int(readInt8())
        mSupportFindWatch = Int(readInt8())
        mSupportWorldClock = Int(readInt8())
        mSupportStock = Int(readInt8())
        mSupportSMSQuickReply = Int(readInt8())
        mSupportNoDisturbSet = Int(readInt8())
        mSupportSetWatchPassword = Int(readInt8())
        mSupportRealTimeMeasurement = Int(readInt8())
        mSupportPowerSaveMode = Int(readInt8())
        mSupportLoveTap = Int(readInt8())
        mSupportNewsfeed = Int(readInt8())
        mSupportMedicationReminder = Int(readInt8())
        mSupportQrcode = Int(readInt8())
        mSupportWeather2 = Int(readInt8())
        mSupportAliPay = Int(readInt8())
        mSupportStandbySetting = Int(readInt8())
        mSupport2DAcceleration = Int(readInt8())
        mSupportDoodleAuthorizationCode = Int(readInt8())
        mSupportMedicationAlarm = Int(readInt8())
        mSupportReadPackageStatus = Int(readInt8())
        mSupportContactSize = Int(readInt8()) * 10
        mSupportVoiceAssistant_XiaoDu = Int(readInt8())
        mSupportNavigation = Int(readInt8())
        mSupportHeartRateAlarmSetting = Int(readInt8())
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mId = try container.decode(Int.self, forKey: .mId)
        mDataKeys = try container.decode([Int].self, forKey: .mDataKeys)
        mBleName = try container.decode(String.self, forKey: .mBleName)
        mBleCustomName = try container.decode(String.self, forKey: .mBleCustomName)
        mBleAddress = try container.decode(String.self, forKey: .mBleAddress)
        mPlatform = try container.decode(String.self, forKey: .mPlatform)
        mPrototype = try container.decode(String.self, forKey: .mPrototype)
        mFirmwareFlag = try container.decode(String.self, forKey: .mFirmwareFlag)
        mAGpsType = try container.decode(Int.self, forKey: .mAGpsType)
        mIOBufferSize = try container.decodeIfPresent(Int.self, forKey: .mIOBufferSize) ?? BleStreamPacket.BUFFER_MAX_SIZE
        mWatchFaceType = try container.decodeIfPresent(Int.self, forKey: .mWatchFaceType) ?? BleDeviceInfo.WATCH_FACE_NONE
        mClassicAddress = try container.decodeIfPresent(String.self, forKey: .mClassicAddress) ?? ""
        mHideDigitalPower = try container.decodeIfPresent(Int.self, forKey: .mHideDigitalPower) ?? 0
        mAntiLostSwitch = try container.decodeIfPresent(Int.self, forKey: .mAntiLostSwitch) ?? 0
        mSleepAlgorithmType = try container.decodeIfPresent(Int.self, forKey: .mSleepAlgorithmType) ?? 0
        mDateFormat = try container.decodeIfPresent(Int.self, forKey: .mDateFormat) ?? 0
        mSupportReadDeviceInfo = try container.decodeIfPresent(Int.self, forKey: .mSupportReadDeviceInfo) ?? 0
        mTemperatureUnit = try container.decodeIfPresent(Int.self, forKey: .mTemperatureUnit) ?? 0
        mDrinkWater = try container.decodeIfPresent(Int.self, forKey: .mDrinkWater) ?? 0
        mChangeClassicBluetoothState = try container.decodeIfPresent(Int.self, forKey: .mChangeClassicBluetoothState) ?? 0
        mAppSport  = try container.decodeIfPresent(Int.self, forKey: .mAppSport) ?? 0
        mBloodOxyGenSet  = try container.decodeIfPresent(Int.self, forKey: .mBloodOxyGenSet) ?? 0
        mWashSet  = try container.decodeIfPresent(Int.self, forKey: .mWashSet) ?? 0
        mDemandWeather = try container.decodeIfPresent(Int.self, forKey: .mDemandWeather) ?? 0
        mSupportHID = try container.decodeIfPresent(Int.self, forKey: .mSupportHID) ?? 0
        miBeacon = try container.decodeIfPresent(Int.self, forKey: .miBeacon) ?? 0
        mSupportWatchFaceId = try container.decodeIfPresent(Int.self, forKey: .mSupportWatchFaceId) ?? 0
        mSupportNewTransportMode = try container.decodeIfPresent(Int.self, forKey: .mSupportNewTransportMode) ?? 0
        mSupportJLWatchFace = try container.decodeIfPresent(Int.self, forKey: .mSupportJLWatchFace) ?? 0
        mSupportFindWatch = try container.decodeIfPresent(Int.self, forKey: .mSupportFindWatch) ?? 0
        mSupportWorldClock = try container.decodeIfPresent(Int.self, forKey: .mSupportWorldClock) ?? 0
        mSupportStock = try container.decodeIfPresent(Int.self, forKey: .mSupportStock) ?? 0
        mSupportSMSQuickReply = try container.decodeIfPresent(Int.self, forKey: .mSupportSMSQuickReply) ?? 0
        mSupportNoDisturbSet = try container.decodeIfPresent(Int.self, forKey: .mSupportNoDisturbSet) ?? 0
        mSupportSetWatchPassword = try container.decodeIfPresent(Int.self, forKey: .mSupportSetWatchPassword) ?? 0
        mSupportRealTimeMeasurement = try container.decodeIfPresent(Int.self, forKey: .mSupportRealTimeMeasurement) ?? 0
        mSupportPowerSaveMode = try container.decodeIfPresent(Int.self, forKey: .mSupportPowerSaveMode) ?? 0
        mSupportLoveTap = try container.decodeIfPresent(Int.self, forKey: .mSupportLoveTap) ?? 0
        mSupportNewsfeed = try container.decodeIfPresent(Int.self, forKey: .mSupportNewsfeed) ?? 0
        mSupportMedicationReminder = try container.decodeIfPresent(Int.self, forKey: .mSupportMedicationReminder) ?? 0
        mSupportQrcode = try container.decodeIfPresent(Int.self, forKey: .mSupportQrcode) ?? 0
        mSupportWeather2 = try container.decodeIfPresent(Int.self, forKey: .mSupportWeather2) ?? 0
        mSupportAliPay = try container.decodeIfPresent(Int.self, forKey: .mSupportAliPay) ?? 0
        mSupportStandbySetting = try container.decodeIfPresent(Int.self, forKey: .mSupportStandbySetting) ?? 0
        mSupport2DAcceleration = try container.decodeIfPresent(Int.self, forKey: .mSupport2DAcceleration) ?? 0
        mSupportDoodleAuthorizationCode = try container.decodeIfPresent(Int.self, forKey: .mSupportDoodleAuthorizationCode) ?? 0
        mSupportMedicationAlarm = try container.decodeIfPresent(Int.self, forKey: .mSupportMedicationAlarm) ?? 0
        mSupportReadPackageStatus = try container.decodeIfPresent(Int.self, forKey: .mSupportReadPackageStatus) ?? 0
        mSupportContactSize = try container.decodeIfPresent(Int.self, forKey: .mSupportContactSize) ?? 0
        mSupportVoiceAssistant_XiaoDu = try container.decodeIfPresent(Int.self, forKey: .mSupportVoiceAssistant_XiaoDu) ?? 0
        mSupportNavigation = try container.decodeIfPresent(Int.self, forKey: .mSupportNavigation) ?? 0
        mSupportHeartRateAlarmSetting = try container.decodeIfPresent(Int.self, forKey: .mSupportHeartRateAlarmSetting) ?? 0
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mId, forKey: .mId)
        try container.encode(mDataKeys, forKey: .mDataKeys)
        try container.encode(mBleName, forKey: .mBleName)
        try container.encode(mBleCustomName, forKey: .mBleCustomName)
        try container.encode(mBleAddress, forKey: .mBleAddress)
        try container.encode(mPlatform, forKey: .mPlatform)
        try container.encode(mPrototype, forKey: .mPrototype)
        try container.encode(mFirmwareFlag, forKey: .mFirmwareFlag)
        try container.encode(mAGpsType, forKey: .mAGpsType)
        try container.encode(mIOBufferSize, forKey: .mIOBufferSize)
        try container.encode(mWatchFaceType, forKey: .mWatchFaceType)
        try container.encode(mClassicAddress, forKey: .mClassicAddress)
        try container.encode(mHideDigitalPower, forKey: .mHideDigitalPower)
        try container.encode(mAntiLostSwitch, forKey: .mAntiLostSwitch)
        try container.encode(mSleepAlgorithmType, forKey: .mSleepAlgorithmType)
        try container.encode(mDateFormat, forKey: .mDateFormat)
        try container.encode(mSupportReadDeviceInfo, forKey: .mSupportReadDeviceInfo)
        try container.encode(mTemperatureUnit, forKey: .mTemperatureUnit)
        try container.encode(mDrinkWater, forKey: .mDrinkWater)
        try container.encode(mChangeClassicBluetoothState, forKey: .mChangeClassicBluetoothState)
        try container.encode(mAppSport, forKey: .mAppSport)
        try container.encode(mBloodOxyGenSet, forKey: .mBloodOxyGenSet)
        try container.encode(mWashSet, forKey: .mWashSet)
        try container.encode(mDemandWeather, forKey: .mDemandWeather)
        try container.encode(mSupportHID, forKey: .mSupportHID)
        try container.encode(miBeacon, forKey: .miBeacon)
        try container.encode(mSupportWatchFaceId, forKey: .mSupportWatchFaceId)
        try container.encode(mSupportNewTransportMode, forKey: .mSupportNewTransportMode)
        try container.encode(mSupportJLWatchFace, forKey: .mSupportJLWatchFace)
        try container.encode(mSupportFindWatch, forKey: .mSupportFindWatch)
        try container.encode(mSupportWorldClock, forKey: .mSupportWorldClock)
        try container.encode(mSupportStock, forKey: .mSupportStock)
        try container.encode(mSupportSMSQuickReply, forKey: .mSupportSMSQuickReply)
        try container.encode(mSupportNoDisturbSet, forKey: .mSupportNoDisturbSet)
        try container.encode(mSupportSetWatchPassword, forKey: .mSupportSetWatchPassword)
        try container.encode(mSupportRealTimeMeasurement, forKey: .mSupportRealTimeMeasurement)
        try container.encode(mSupportPowerSaveMode, forKey: .mSupportPowerSaveMode)
        try container.encode(mSupportLoveTap, forKey: .mSupportLoveTap)
        try container.encode(mSupportNewsfeed, forKey: .mSupportNewsfeed)
        try container.encode(mSupportMedicationReminder, forKey: .mSupportMedicationReminder)
        try container.encode(mSupportQrcode, forKey: .mSupportQrcode)
        try container.encode(mSupportWeather2, forKey: .mSupportWeather2)
        try container.encode(mSupportAliPay, forKey: .mSupportAliPay)
        try container.encode(mSupportStandbySetting, forKey: .mSupportStandbySetting)
        try container.encode(mSupport2DAcceleration, forKey: .mSupport2DAcceleration)
        try container.encode(mSupportDoodleAuthorizationCode, forKey: .mSupportDoodleAuthorizationCode)
        try container.encode(mSupportMedicationAlarm, forKey: .mSupportMedicationAlarm)
        try container.encode(mSupportReadPackageStatus, forKey: .mSupportReadPackageStatus)
        try container.encode(mSupportContactSize, forKey: .mSupportContactSize)
        try container.encode(mSupportVoiceAssistant_XiaoDu, forKey: .mSupportVoiceAssistant_XiaoDu)
        try container.encode(mSupportNavigation, forKey: .mSupportNavigation)
        try container.encode(mSupportHeartRateAlarmSetting, forKey: .mSupportHeartRateAlarmSetting)
    }

    private enum CodingKeys: String, CodingKey {
        case mId, mDataKeys, mBleName, mBleCustomName, mBleAddress, mPlatform, mPrototype, mFirmwareFlag, mAGpsType
        case mIOBufferSize, mWatchFaceType, mClassicAddress, mHideDigitalPower, mAntiLostSwitch
        case mSleepAlgorithmType, mDateFormat, mSupportReadDeviceInfo, mTemperatureUnit,mDrinkWater,mChangeClassicBluetoothState,mAppSport,mBloodOxyGenSet,mWashSet,mDemandWeather,mSupportHID
        case miBeacon,mSupportWatchFaceId,mSupportNewTransportMode,mSupportJLWatchFace
        case mSupportFindWatch,mSupportWorldClock,mSupportStock,mSupportSMSQuickReply,mSupportNoDisturbSet,mSupportSetWatchPassword
        case mSupportRealTimeMeasurement
        case mSupportPowerSaveMode
        case mSupportLoveTap, mSupportNewsfeed, mSupportMedicationReminder, mSupportQrcode, mSupportWeather2
        case mSupportAliPay, mSupportStandbySetting, mSupport2DAcceleration, mSupportDoodleAuthorizationCode, mSupportMedicationAlarm
        case mSupportReadPackageStatus, mSupportContactSize, mSupportVoiceAssistant_XiaoDu, mSupportNavigation
        case mSupportHeartRateAlarmSetting
    }

    override var description: String {
        "BleDeviceInfo("
            + "mId: \(String(format: "0x%08X", mId))"
            + ", mDataKeys: \(mDataKeys.map({ "\(BleKey(rawValue: $0) ?? BleKey.NONE)" }))"
            + ", mBleName: \(mBleName), mBleCustomName: \(mBleCustomName), mBleAddress: \(mBleAddress), mPlatform: \(mPlatform)"
            + ", mPrototype: \(mPrototype), mFirmwareFlag: \(mFirmwareFlag), mAGpsType: \(mAGpsType)"
            + ", mIOBufferSize: \(mIOBufferSize), mWatchFaceType: \(mWatchFaceType)"
            + ", mClassicAddress: \(mClassicAddress), mHideDigitalPower: \(mHideDigitalPower)"
            + ", mAntiLostSwitch: \(mAntiLostSwitch), mSleepAlgorithmType:\(mSleepAlgorithmType)"
            + " ,mDateFormat:\(mDateFormat), mSupportReadDeviceInfo:\(mSupportReadDeviceInfo)"
            + ", mTemperatureUnit:\(mTemperatureUnit), mDrinkWater:\(mDrinkWater)"
            + ", mChangeClassicBluetoothState:\(mChangeClassicBluetoothState), mAppSport:\(mAppSport)"
            + ", mBloodOxyGenSet:\(mBloodOxyGenSet), mWashSet:\(mWashSet)"
            + ", mDemandWeather:\(mDemandWeather), mSupportHID:\(mSupportHID), miBeacon:\(miBeacon)"
        + ", mSupportWatchFaceId:\(mSupportWatchFaceId), mSupportNewTransportMode:\(mSupportNewTransportMode),mSupportJLWatchFace:\(mSupportJLWatchFace)"
        + ", mSupportFindWatch:\(mSupportFindWatch),mSupportWorldClock:\(mSupportWorldClock),mSupportStock:\(mSupportStock),mSupportSMSQuickReply:\(mSupportSMSQuickReply),mSupportNoDisturbSet:\(mSupportNoDisturbSet)"
        + ", mSupportSetWatchPassword:\(mSupportSetWatchPassword), mSupportRealTimeMeasurement:\(mSupportRealTimeMeasurement)"
        + ", mSupportPowerSaveMode:\(mSupportPowerSaveMode), mSupportLoveTap:\(mSupportLoveTap)"
        + ", mSupportNewsfeed:\(mSupportNewsfeed), mSupportMedicationReminder:\(mSupportMedicationReminder), mSupportQrcode:\(mSupportQrcode)"
        + ", mSupportWeather2:\(mSupportWeather2)" + ", mSupportAliPay:\(mSupportAliPay)" + ", mSupportStandbySetting:\(mSupportStandbySetting)"
        + ", mSupport2DAcceleration:\(mSupport2DAcceleration)" + ", mSupportDoodleAuthorizationCode:\(mSupportDoodleAuthorizationCode)"
        + ", mSupportMedicationAlarm:\(mSupportMedicationAlarm), mSupportReadPackageStatus:\(mSupportReadPackageStatus)"
        + ", mSupportContactSize:\(mSupportContactSize), mSupportVoiceAssistant_XiaoDu:\(mSupportVoiceAssistant_XiaoDu)"
        + ", mSupportNavigation:\(mSupportNavigation), mSupportHeartRateAlarmSetting:\(mSupportHeartRateAlarmSetting)"
            + ")"
    }
    
    
    func toDictionary(_ status:Bool)->[String:Any]{
        
        let dic : [String : Any] = [
            "mId":mId,
            "mDataKeys":mDataKeys,
            "mBleName":mBleName,
            "mBleCustomName":mBleCustomName,
            "mBleAddress":mBleAddress,
            "mPlatform":mPlatform,
            "mPrototype":mPrototype,
            "mFirmwareFlag":mFirmwareFlag,
            "mAGpsType":mAGpsType,
            "mIOBufferSize":mIOBufferSize,
            "mWatchFaceType":mWatchFaceType,
            "mClassicAddress":mClassicAddress,
            "mHideDigitalPower":mHideDigitalPower,
            "mShowAntiLostSwitch":mAntiLostSwitch,
            "mSleepAlgorithmType":mSleepAlgorithmType,
            "mSupportDateFormatSet":mDateFormat,
            "mSupportReadDeviceInfo":mSupportReadDeviceInfo,
            "mSupportTemperatureUnitSet":mTemperatureUnit,
            "mSupportDrinkWaterSet":mDrinkWater,
            "mSupportChangeClassicBluetoothState":mChangeClassicBluetoothState,
            "mSupportAppSport":mAppSport,
            "mSupportBloodOxyGenSet":mBloodOxyGenSet,
            "mSupportWashSet":mWashSet,
            "mSupportRequestRealtimeWeather":mDemandWeather,
            "mSupportHID":mSupportHID,
            "mSupportIBeaconSet":miBeacon,
            "mSupportWatchFaceId":mSupportWatchFaceId,
            "mSupportNewTransportMode":mSupportNewTransportMode,
            "mSupportJLTransport":mSupportJLWatchFace,
            "mSupportFindWatch":mSupportFindWatch,
            "mSupportWorldClock":mSupportWorldClock,
            "mSupportStock":mSupportStock,
            "mSupportSMSQuickReply":mSupportSMSQuickReply,
            "mSupportNoDisturbSet":mSupportNoDisturbSet,
            "mSupportSetWatchPassword":mSupportSetWatchPassword,
            "mSupportRealTimeMeasurement":mSupportRealTimeMeasurement,
            "mSupportPowerSaveMode":mSupportPowerSaveMode,
            "mSupportLoveTap":mSupportLoveTap,
            "mSupportNewsfeed":mSupportNewsfeed,
            "mSupportMedicationReminder":mSupportMedicationReminder,
            "mSupportQrcode":mSupportQrcode,
            "mSupportWeather2":mSupportWeather2,
            "mSupportAliPay":mSupportAliPay,
            "mSupportStandbySetting":mSupportStandbySetting,
            "mSupport2DAcceleration":mSupport2DAcceleration,
            "mSupportDoodleAuthorizationCode":mSupportDoodleAuthorizationCode,
            "mSupportMedicationAlarm":mSupportMedicationAlarm,
            "mSupportReadPackageStatus":mSupportReadPackageStatus,
            "mSupportContactSize": mSupportContactSize,
            "mSupportVoiceAssistant_XiaoDu":mSupportVoiceAssistant_XiaoDu,
            "mSupportNavigation":mSupportNavigation,
            "mSupportHeartRateAlarmSetting": mSupportHeartRateAlarmSetting,
            "status":status
        ]
        return dic
    }
}
