//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleCache {
    static let PREFIX = "ble_"
    static let DEVICE_IDENTIFY = "device_identify"
    private static let MTK_OTA_META = "mtk_ota_meta"

    static let shared = BleCache()

    private var mUserDefault = UserDefaults.standard

    // 设备信息会包含其aGps文件类型，发送aGps时需要根据类型来检索下载链接。
    private let mAGpsFileUrls = [
        BleDeviceInfo.AGPS_EPO: "http://wepodownload.mediatek.com/EPO_GR_3_1.DAT",
        BleDeviceInfo.AGPS_UBLOX: "https://alp.u-blox.com/current_1d.alp",
        BleDeviceInfo.AGPS_AGNSS: "https://api.smawatch.cn/epo/ble_epo_offline.bin",
        BleDeviceInfo.AGPS_EPO_ONLY: "https://sma-product.oss-accelerate.aliyuncs.com/a-gps/file_info_3335_epo.DAT",
        BleDeviceInfo.AGPS_LTO: "https://sma-product.oss-accelerate.aliyuncs.com/a-gps/file_info_7dv5_lto.brm",
    ]

    // 必须在绑定设备之后调用，否则返回的信息没有任何意义。
    var mDeviceInfo: BleDeviceInfo? = nil

    var mDataKeys: [Int] {
        mDeviceInfo?.mDataKeys ?? []
    }

    var mBleName: String {
        mDeviceInfo?.mBleName ?? ""
    }

    var mBleAddress: String {
        mDeviceInfo?.mBleAddress ?? ""
    }

    var mPlatform: String {
        mDeviceInfo?.mPlatform ?? ""
    }

    var mPrototype: String {
        mDeviceInfo?.mPrototype ?? ""
    }

    var mFirmwareFlag: String {
        mDeviceInfo?.mFirmwareFlag ?? ""
    }

    var mAGpsType: Int {
        mDeviceInfo?.mAGpsType ?? BleDeviceInfo.AGPS_NONE
    }

    var mIOBufferSize: Int {
        var size = mDeviceInfo?.mIOBufferSize
        if size == nil || size == 0 {
            size = BleStreamPacket.BUFFER_MAX_SIZE
        }
        return size!
    }

    var mWatchFaceType: Int {
        mDeviceInfo?.mWatchFaceType ?? BleDeviceInfo.WATCH_FACE_NONE
    }

    var mHideDigitalPower: Int {
        mDeviceInfo?.mHideDigitalPower ?? 0
    }
    
    var mAntiLostSwitch: Int {
        mDeviceInfo?.mAntiLostSwitch ?? 0
    }
    
    var mSleepAlgorithmType :Int{
        mDeviceInfo?.mSleepAlgorithmType ?? 0
    }
    
    var mDateFormat: Int {
        mDeviceInfo?.mDateFormat ?? 0
    }

    var mSupportReadDeviceInfo: Int {
        mDeviceInfo?.mSupportReadDeviceInfo ?? 0
    }
    
    var mTemperatureUnit: Int {
        mDeviceInfo?.mTemperatureUnit ?? 0
    }
    
    /// 是否支持App、手表运动模式联动协议
    var mAppSport: Int {
        mDeviceInfo?.mAppSport ?? 0
    }
    
    var mDrinkWater: Int {
        mDeviceInfo?.mDrinkWater ?? 0
    }
    
    var mBloodOxyGenSet: Int {
        mDeviceInfo?.mBloodOxyGenSet ?? 0
    }
    
    var mWashSet: Int {
        mDeviceInfo?.mWashSet ?? 0
    }
    
    var mDemandWeather: Int {
        mDeviceInfo?.mDemandWeather ?? 0
    }
    
    var mSupportHID: Int{
        mDeviceInfo?.mSupportHID ?? 0
    }
    
    var miBeacon: Int{
        mDeviceInfo?.miBeacon ?? 0
    }
    
    var mSupportWatchFaceId: Int{
        mDeviceInfo?.mSupportWatchFaceId ?? 0
    }
    
    var mSupportNewTransportMode: Int{
        mDeviceInfo?.mSupportNewTransportMode ?? 0
    }
    
    var mSupportJLWatchFace: Int{
        mDeviceInfo?.mSupportJLWatchFace ?? 0
    }
    
    var mSupportFindWatch : Int{
        mDeviceInfo?.mSupportFindWatch ?? 0
    }
    
    var mSupportWorldClock : Int{
        mDeviceInfo?.mSupportWorldClock ?? 0
    }
    
    var mSupportStock : Int{
        mDeviceInfo?.mSupportStock ?? 0
    }
    
    var mSupportSMSQuickReply : Int{
        mDeviceInfo?.mSupportSMSQuickReply ?? 0
    }
    
    var mSupportNoDisturbSet : Int{
        mDeviceInfo?.mSupportNoDisturbSet ?? 0
    }
    
    var mSupportSetPassWord : Int{
        mDeviceInfo?.mSupportSetPassWord ?? 0
    }
    
    var mSupportRealTimeMeasurement : Int{
        mDeviceInfo?.mSupportRealTimeMeasurement ?? 0
    }
    
    var mAGpsFileUrl: String {
        mAGpsFileUrls[mAGpsType] ?? ""
    }

    var mNotificationBundleIds: [String] {
        var bundleIds = BleNotificationSettings.ORIGIN_BUNDLE_IDS
        bundleIds.append(BleNotificationSettings.BAND)
        bundleIds.append(BleNotificationSettings.TELEGRAM)
        bundleIds.append(BleNotificationSettings.BETWEEN)
        bundleIds.append(BleNotificationSettings.NAVERCAFE)
        bundleIds.append(BleNotificationSettings.YOUTUBE)
        bundleIds.append(BleNotificationSettings.NETFLIX)
        switch mPrototype {
        default:
            return bundleIds
        }
    }

    private init() {

    }

    /**
     * 保存绑定设备的identify。
     */
    func putDeviceIdentify(_ identify: String?) {
        bleLog("BleCache putDeviceIdentify -> \(identify ?? "")")
        if identify == nil {
            mUserDefault.removeObject(forKey: getKey(BleCache.DEVICE_IDENTIFY))
        } else {
            mUserDefault.set(identify, forKey: getKey(BleCache.DEVICE_IDENTIFY))
        }
    }

    /**
     * 获取绑定设备的identify。
     */
    func getDeviceIdentify() -> String? {
        mUserDefault.string(forKey: getKey(BleCache.DEVICE_IDENTIFY))
    }

    /**
     * 存入Bool。
     */
    func putBool(_ bleKey: BleKey, _ value: Bool, _ keyFlag: BleKeyFlag? = nil) {
        bleLog("BleCache putBool -> \(getKey(bleKey, keyFlag)), \(value)")
        mUserDefault.set(value, forKey: getKey(bleKey, keyFlag))
    }

    /**
     * 取出Bool。
     */
    func getBool(_ bleKey: BleKey, _ keyFlag: BleKeyFlag? = nil) -> Bool {
        let value = mUserDefault.bool(forKey: getKey(bleKey, keyFlag))
        bleLog("BleCache getBool -> \(getKey(bleKey, keyFlag)), \(value)")
        return value
    }

    /**
     * 存入Int。
     */
    func putInt(_ bleKey: BleKey, _ value: Int, _ keyFlag: BleKeyFlag? = nil) {
        bleLog("BleCache putInt -> \(getKey(bleKey, keyFlag)), \(value)")
        mUserDefault.set(value, forKey: getKey(bleKey, keyFlag))
    }

    /**
     * 取出Int。
     */
    func getInt(_ bleKey: BleKey, _ keyFlag: BleKeyFlag? = nil) -> Int {
        let value = mUserDefault.integer(forKey: getKey(bleKey, keyFlag))
        bleLog("BleCache getInt -> \(getKey(bleKey, keyFlag)), \(value)")
        return value
    }

    /**
     * 存入字符串。
     */
    func putString(_ bleKey: BleKey, _ value: String, _ keyFlag: BleKeyFlag? = nil) {
        bleLog("BleCache putString -> \(getKey(bleKey, keyFlag)), \(value)")
        mUserDefault.set(value, forKey: getKey(bleKey, keyFlag))
    }

    /**
    * 取出字符串。
    */
    func getString(_ bleKey: BleKey, _ keyFlag: BleKeyFlag? = nil) -> String {
        let value = mUserDefault.string(forKey: getKey(bleKey, keyFlag)) ?? ""
        bleLog("BleCache getString -> \(getKey(bleKey, keyFlag)), \(value)")
        return value
    }

    /**
     * 存入对象。
     */
    func putObject<T: Encodable>(_ bleKey: BleKey, _ object: T?, _ keyFlag: BleKeyFlag? = nil) {
        do {
            if object == nil {
                bleLog("BleCache putObject -> \(getKey(bleKey, keyFlag)), nil")
                mUserDefault.set(nil, forKey: getKey(bleKey, keyFlag))
            } else {
                let data = try JSONEncoder().encode(object)
                bleLog("BleCache putObject -> \(getKey(bleKey, keyFlag)), \(String(describing: object))"
                    + ", \(String(data: data, encoding: .utf8) ?? "")")
                mUserDefault.set(data, forKey: getKey(bleKey, keyFlag))
            }
        } catch {

        }
    }

    /**
     * 取出对象，可能为nil。
     */
    func getObject<T: Decodable>(_ bleKey: BleKey, _ keyFlag: BleKeyFlag? = nil) -> T? {
        do {
            if let data = mUserDefault.data(forKey: getKey(bleKey, keyFlag)) {
                let t: T = try JSONDecoder().decode(T.self, from: data)
                bleLog("BleCache getObject -> \(getKey(bleKey, keyFlag))"
                    + ", \(String(data: data, encoding: .utf8) ?? ""), \(t)")
                return t
            }
        } catch {
        }
        return nil
    }

    /**
     * 取出对象，不为nil。
     */
    func getObjectNotNil<T: BleReadable>(_ bleKey: BleKey, _ t: T? = nil, _ keyFlag: BleKeyFlag? = nil) -> T {
        (getObject(bleKey, keyFlag) ?? t) ?? T.init()
    }

    /**
     * 存入数组。
     */
    func putArray<T: Encodable>(_ bleKey: BleKey, _ array: [T]?, _ keyFlag: BleKeyFlag? = nil) {
        putObject(bleKey, array, keyFlag)
    }

    /**
     * 取出数组。
     */
    func getArray<T: Decodable>(_ bleKey: BleKey, keyFlag: BleKeyFlag? = nil) -> [T] {
        getObject(bleKey, keyFlag) ?? [T]()
    }

    /**
     * 保存MTK设备的固件信息。
     * mid=xx;mod=xx;oem=xx;pf=xx;p_id=xx;p_sec=xx;ver=xx;d_ty=xx;
     */
    func putMtkOtaMeta(meta: String) {
        bleLog("BleCache putMtkOtaMeta -> \(meta)")
        mUserDefault.set(meta, forKey: BleCache.MTK_OTA_META)
    }

    /**
     * 获取MTK设备的固件信息。
     * mid=xx;mod=xx;oem=xx;pf=xx;p_id=xx;p_sec=xx;ver=xx;d_ty=xx;
     */
    func getMtkOtaMeta() -> String {
        let value = mUserDefault.string(forKey: BleCache.MTK_OTA_META) ?? ""
        bleLog("BleCache getMtkOtaMeta -> \(value)")
        return value
    }

    /**
     * 移除一个指令的缓存。
     */
    func remove(_ bleKey: BleKey, _ keyFlag: BleKeyFlag? = nil) {
        mUserDefault.removeObject(forKey: getKey(bleKey, keyFlag))
    }

//    func getArray<T: BleReadable>(_ bleKey: BleKey, _ itemLength: Int) -> [T] {
//        var array: [T] = []
//        if let data = mUserDefault.data(forKey: getKey(bleKey.mDisplayName)) {
//            array.append(contentsOf: BleReadable.ofArray(data, itemLength) as [T])
//        }
//        bleLog("BleCache getArray -> \(bleKey.mDisplayName), \(array)")
//        return array
//    }

    /**
     * 判定一个指令是否需要缓存，只在手机端发送时判定。设备回复和主动发送指令时，不依赖该方法的返回值，如果有需要，会直接缓存。
     */
    func requireCache(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag) -> Bool {
        switch bleKey.mBleCommand {
        case .SET:
            return bleKeyFlag == .CREATE || bleKeyFlag == .DELETE || bleKeyFlag == .UPDATE || bleKeyFlag == .RESET
        case .PUSH:
            return (bleKey == .SCHEDULE && (bleKeyFlag == .CREATE || bleKeyFlag == .DELETE || bleKeyFlag == .UPDATE))
                || (bleKey == .WEATHER_REALTIME && bleKeyFlag == .UPDATE)
                || (bleKey == .WEATHER_FORECAST && bleKeyFlag == .UPDATE)
                || (bleKey == .WORLD_CLOCK && (bleKeyFlag == .CREATE || bleKeyFlag == .DELETE))
                || (bleKey == .STOCK && (bleKeyFlag == .CREATE || bleKeyFlag == .DELETE))
        default:
            return false
        }
    }

    /**
     * 获取某些指令的BleIdObject数组。
     */
    func getIdObjects(_ bleKey: BleKey) -> [BleIdObject] {
        if bleKey == .ALARM {
            let alarms: [BleAlarm] = getArray(bleKey)
            return alarms
        } else if bleKey == .SCHEDULE {
            let schedules: [BleSchedule] = getArray(bleKey)
            return schedules
        } else if bleKey == .COACHING {
            let coachings: [BleCoaching] = getArray(bleKey)
            return coachings
        }else if bleKey == .WORLD_CLOCK {
            let worldClock: [BleWorldClock] = getArray(bleKey)
            return worldClock
        }else if bleKey == .STOCK {
            let mStock: [BleStock] = getArray(bleKey)
            return mStock
        }
        return []
    }

    private func getKey(_ key: String) -> String {
        BleCache.PREFIX + key
    }

    /**
     * 根据BleKey和BleKeyFlag生成一个用于缓存的key。
     */
    private func getKey(_ bleKey: BleKey, _ keyFlag: BleKeyFlag? = nil) -> String {
        if keyFlag == nil {
            return getKey(bleKey.mDisplayName)
        } else {
            return getKey("\(bleKey.mDisplayName)_\(keyFlag!.mDisplayName)")
        }
    }

    /**
     * 清除所有缓存。
     */
    func clear() {
        for (key, _) in mUserDefault.dictionaryRepresentation() {
            if key.starts(with: BleCache.PREFIX) {
                mUserDefault.removeObject(forKey: key)
            }
        }
        mUserDefault.synchronize()
    }
}
