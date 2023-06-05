//
// Created by Best Mafen on 2019/9/21.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleConnector: BaseBleConnector {
    static let BLE_SERVICE = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    private static let BLE_CH_WRITE = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    private static let BLE_CH_NOTIFY = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

    // 用于读取MTK设备的固件信息，即艾拉比平台上相关项目配置。
    static let SERVICE_MTK = "C6A22905-F821-18BF-9704-0266F20E80FD"
    static let CH_MTK_OTA_META = "C6A22916-F821-18BF-9704-0266F20E80FD"

    private static let SERVICE_MTK_OTA = "C6A2B98B-F821-18BF-9704-0266F20E80FD"
    private static let CH_MTK_OTA_SIZE = "C6A22920-F821-18BF-9704-0266F20E80FD"
    private static let CH_MTK_OTA_FLAG = "C6A22922-F821-18BF-9704-0266F20E80FD"
    private static let CH_MTK_OTA_DATA = "C6A22924-F821-18BF-9704-0266F20E80FD"
    private static let CH_MTK_OTA_MD5 = "C6A22926-F821-18BF-9704-0266F20E80FD"

    // MTK设备Ota时，每包的长度。
    private static let MTK_OTA_PACKET_SIZE = 180

    static let shared = BleConnector()

    private var mLaunched = false

    private let mBleMessenger = BleMessenger()
    private let mBleParser = BleParser()

    private let mBleCache = BleCache.shared
    private var mBleHandleDelegates = [String: BleHandleDelegate]()

    private var mBleState = BleState.DISCONNECTED

    private var mDataKeys = [BleKey]()
    private var mSyncTimeout: Timer? = nil
    private var mBleKeyTimeout: Timer? = nil

    /**
      控制同步数据是否过滤 Control data notifyHandlers()
     */
    private var mSupportFilterEmpty = true

    private var mBleStream: BleStream? = nil
    private var mStreamProgressTotal = -1
    private var mStreamProgressCompleted = -1
    private var mTransmissionSpeed = 0
    private var mDataResume = 0 //标记当前发送包位置
    private var mResumeNumber = 0 //尝试续传次数
    private var mResumeTime: Timer? = nil
    private var mResumeBleKey :BleKey = .NONE
    private init() {
        super.init(BleConnector.BLE_SERVICE, BleConnector.BLE_CH_NOTIFY, mBleMessenger, mBleParser)
        mBleConnectorDelegate = self
        mBleCache.mDeviceInfo = mBleCache.getObject(.IDENTITY)
    }

    func launch() {
        if let identity = mBleCache.getDeviceIdentify() {
            bleLog("BleConnector launch -> identity=\(identity)")
            setTargetIdentifier(identity)
            if mLaunched {
                // 初始化时，会触发centralManagerDidUpdateState代理方法，该方法会调用connect()，所以无需手动调用
                // 调用close之后再调用，需要手动调用connect
                connect(true)
            }
        } else {
            bleLog("BleConnector launch -> identity=nil")
        }
        if !mLaunched {
            mLaunched = true
        }
    }

    func addBleHandleDelegate(_ tag: String, _ bleHandleDelegate: BleHandleDelegate) {
        bleLog("addBleHandleDelegate: \(tag)")
        if mBleHandleDelegates[tag] != nil {
            fatalError("Tag already exists")
        }

        mBleHandleDelegates[tag] = bleHandleDelegate
    }

    func removeBleHandleDelegate(_ tag: String) {
        bleLog("removeBleHandleDelegate: \(tag)")
        if mBleHandleDelegates[tag] == nil {
            fatalError("Tag dose not exist")
        } else {
            mBleHandleDelegates[tag] = nil
        }
    }

    func sendData(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ data: Data? = nil,
                  _ reply: Bool = false, _ nack: Bool = false) -> Bool {
        bleLog("BleConnector sendData -> \(bleKey.mDisplayName), \(bleKeyFlag.mDisplayName)")
        if !isAvailable() {
            return false
        }

        if bleKey == .DATA_ALL && bleKeyFlag == .READ {
            return syncData()
        }

        var headerFlag = 0
        if reply {
            headerFlag |= MessageFactory.HEADER_REPLY
        }
        if nack {
            headerFlag |= MessageFactory.HEADER_NACK
        }
        if bleKey == .WATCH_FACE ||
            bleKey == .AGPS_FILE ||
            bleKey == .FONT_FILE ||
            bleKey == .CONTACT ||
            bleKey == .UI_FILE ||
            bleKey == .LANGUAGE_FILE {
            if self.mTransmissionSpeed < 946656000 {
                self.mTransmissionSpeed = Int(Date().timeIntervalSince1970)
            }
        }
        let message = WriteMessage(BleConnector.BLE_SERVICE, BleConnector.BLE_CH_WRITE,
            MessageFactory.create(headerFlag, bleKey, bleKeyFlag, data))
        if reply {
            mBleMessenger.replyMessage(message)
        } else {
            mBleMessenger.enqueueMessage(message)
        }
//        openBleKeyTimeout(bleKey,bleKeyFlag)
        return true
    }

    func sendBool(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ value: Bool, _ reply: Bool = false,
                  _ nack: Bool = false) -> Bool {
        let data = Data(boolValue: value)
        let result = sendData(bleKey, bleKeyFlag, data, reply, nack)
        if result && mBleCache.requireCache(bleKey, bleKeyFlag) {
            mBleCache.putBool(bleKey, value)
        }
        return result
    }

    func sendInt8(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ value: Int, _ reply: Bool = false,
                  _ nack: Bool = false) -> Bool {
        let data = Data(int8: value)
        let result = sendData(bleKey, bleKeyFlag, data, reply, nack)
        if result && mBleCache.requireCache(bleKey, bleKeyFlag) {
            if bleKey.isIdObjectKey() {
                var idObjects: [BleIdObject] = mBleCache.getIdObjects(bleKey)
                if bleKeyFlag == .DELETE {
                    if value == ID_ALL {
                        idObjects.removeAll()
                    } else {
                        if let index = idObjects.firstIndex(where: { $0.mId == value }) {
                            idObjects.remove(at: index)
                        }
                    }
                }
                mBleCache.putArray(bleKey, idObjects)
            } else {
                mBleCache.putInt(bleKey, value)
            }
        }
        return result
    }

    func sendInt16(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ value: Int, _ order: ByteOrder = .BIG_ENDIAN,
                   _ reply: Bool = false, _ nack: Bool = false) -> Bool {
        let data = Data(int16: value, order)
        let result = sendData(bleKey, bleKeyFlag, data, reply, nack)
        if result && mBleCache.requireCache(bleKey, bleKeyFlag) {
            mBleCache.putInt(bleKey, value)
        }
        return result
    }

    func sendInt24(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ value: Int, _ order: ByteOrder = .BIG_ENDIAN,
                   _ reply: Bool = false, _ nack: Bool = false) -> Bool {
        let data = Data(int24: value, order)
        let result = sendData(bleKey, bleKeyFlag, data, reply, nack)
        if result && mBleCache.requireCache(bleKey, bleKeyFlag) {
            mBleCache.putInt(bleKey, value)
        }
        return result
    }

    func sendInt32(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ value: Int, _ order: ByteOrder = .BIG_ENDIAN,
                   _ reply: Bool = false, _ nack: Bool = false) -> Bool {
        let data = Data(int32: value, order)
        let result = sendData(bleKey, bleKeyFlag, data, reply, nack)
        if result && mBleCache.requireCache(bleKey, bleKeyFlag) {
            mBleCache.putInt(bleKey, value)
        }
        return result
    }

    func sendObject<T: BleWritable>(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ object: T?,
                                    _ reply: Bool = false, _ nack: Bool = false) -> Bool {
        if !isAvailable() {
            return false
        }

        var idObjects: [T] = [] // 本地缓存的数组
        if object is BleIdObject {
            idObjects = mBleCache.getArray(bleKey)
            if bleKeyFlag == .CREATE {
                var ids = idObjects.map({ ($0 as! BleIdObject).mId }) // 本地缓存的id
                if object is BleCoaching { // coaching除了本地有缓存，设备端也可能有缓存
                    if let coachingIds: BleCoachingIds = mBleCache.getObject(.COACHING, .READ) {
                        ids.append(contentsOf: coachingIds.mIds)
                    }
                }
                for i in 0..<ID_ALL { // 分配一个0～0xfe之间还未缓存的id
                    if !ids.contains(i) {
                        (object as! BleIdObject).mId = i
                        break
                    }
                }
                idObjects.append(object!)
            } else if bleKeyFlag == .UPDATE {
                // 根据id查到本地缓存
                if let index = idObjects.firstIndex(where: { ($0 as! BleIdObject).mId == (object as! BleIdObject).mId }) {
                    idObjects[index] = object!
                }
            }
        }
//        if bleKey == .WATCH_FACE ||
//            bleKey == .FONT_FILE ||
//            bleKey == .LANGUAGE_FILE ||
//            bleKey == .UI_FILE{
//            mBleMessenger.isWithoutResponse = true
//        }else{
//            mBleMessenger.isWithoutResponse = false
//        }
        let result = sendData(bleKey, bleKeyFlag, object?.toData(), reply, nack)
        if result && mBleCache.requireCache(bleKey, bleKeyFlag) {
            if object is BleIdObject {
                mBleCache.putArray(bleKey, idObjects) // 缓存追加或者修改后的列表
            } else {
                mBleCache.putObject(bleKey, object)
            }
        }
        return result
    }

    // 非IdObject的情况逻辑不一定正确，但是现在还没有非IdObject的情况，如果有的话需要修改相关代码
    func sendArray<T: BleWritable>(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag, _ objects: [T]?,
                                   _ reply: Bool = false, _ nack: Bool = false) -> Bool {
        if !isAvailable() {
            return false
        }

        var data = Data()
        var idObjects: [T] = []
        if T() is BleIdObject {
            idObjects = mBleCache.getArray(bleKey)
            if bleKeyFlag == .CREATE {
                var ids = idObjects.map({ ($0 as! BleIdObject).mId }) // 本地缓存的id
                objects?.forEach({
                    for i in 0..<ID_ALL { // 分配一个0～0xfe之间还未缓存的id
                        if !ids.contains(i) {
                            ($0 as! BleIdObject).mId = i
                            data.append(contentsOf: $0.toData())
                            idObjects.append($0)
                            ids.append(i)
                            break
                        }
                    }
                })
            } else if bleKeyFlag == .RESET {
                idObjects.removeAll()
                var index = 0
                objects?.forEach({
                    ($0 as! BleIdObject).mId = index
                    data.append(contentsOf: $0.toData())
                    idObjects.append($0)
                    index += 1
                })
                // 发送Delete All会删除设备和本地所有缓存
                _ = sendInt8(bleKey, .DELETE, ID_ALL)
            }
        } else {
            data = bufferArrayToData(objects)
        }
        let result = sendData(bleKey, bleKeyFlag == .RESET ? .CREATE : bleKeyFlag, data, reply, nack)
        if result && mBleCache.requireCache(bleKey, bleKeyFlag) {
            if bleKey.isIdObjectKey() {
                if bleKeyFlag == .CREATE || bleKeyFlag == .RESET {
                    mBleCache.putArray(bleKey, idObjects)
                }
            } else {
                mBleCache.putArray(bleKey, objects)
            }
        }
        return result
    }

    /**
     * 发送过程中会触发BleHandleDelegate.onStreamProgress
     */
    func sendStream(_ bleKey: BleKey, _ data: Data, _ type: Int = 0) -> Bool {
        if data.isEmpty {
            return false
        }

        mBleStream = BleStream(bleKey, type, data)
        let streamPacket = mBleStream?.getPacket(0, mBleCache.mIOBufferSize)
        if streamPacket != nil {
            if (bleKey == .WATCH_FACE ||
                bleKey == .AGPS_FILE ||
                bleKey == .FONT_FILE ||
                bleKey == .CONTACT ||
                bleKey == .UI_FILE ||
                bleKey == .LANGUAGE_FILE) &&
                BleCache.shared.mSupportNewTransportMode == 1 &&
                BleCache.shared.mPlatform == BleDeviceInfo.PLATFORM_JL{
                self.mDataResume = 0
                self.mResumeBleKey = bleKey
//                startBreakpointResume()
            }
            return sendObject(bleKey, .UPDATE, streamPacket)
        }

        return false
    }

    func sendStream(_ bleKey: BleKey, forResource name: String, ofType ext: String, _ type: Int = 0) -> Bool {
        if let path = Bundle.main.path(forResource: name, ofType: ext) {
            if let data = NSData(contentsOfFile: path) {
                return sendStream(bleKey, data as Data, type)
            }
        }
        return false
    }

    func sendStream(_ bleKey: BleKey, _ url: URL, _ type: Int = 0) -> Bool {
        if let data = NSData(contentsOf: url) {
            return sendStream(bleKey, data as Data, type)
        }

        return false
    }

    func sendStream(_ bleKey: BleKey, _ path: String, _ type: Int = 0) -> Bool {
        if let data = NSData(contentsOfFile: path) {
            return sendStream(bleKey, data as Data, type)
        }

        return false
    }

    func mtkOta(_ data: Data) {
        if !isAvailable() || data.isEmpty {
            return
        }

        let bufferSize = BleConnector.MTK_OTA_PACKET_SIZE
        if data.count % bufferSize == 0 {
            mStreamProgressTotal = data.count / bufferSize
        } else {
            mStreamProgressTotal = data.count / bufferSize + 1
        }
        mStreamProgressCompleted = 0

        mBleMessenger.enqueueMessage(WriteMessage(BleConnector.SERVICE_MTK_OTA, BleConnector.CH_MTK_OTA_SIZE,
            Data(int32: data.count, .LITTLE_ENDIAN)))
        mBleMessenger.enqueueMessage(WriteMessage(BleConnector.SERVICE_MTK_OTA, BleConnector.CH_MTK_OTA_FLAG,
            Data([0x01])))
        for i in 0..<mStreamProgressTotal {
            let index = i * bufferSize
            let packet: Data
            if i == mStreamProgressTotal - 1 {
                packet = data[index..<data.count]
            } else {
                packet = data[index..<index + bufferSize]
            }
            mBleMessenger.enqueueMessage(WriteMessage(BleConnector.SERVICE_MTK_OTA,
                BleConnector.CH_MTK_OTA_DATA, packet))
        }
        mBleMessenger.enqueueMessage(WriteMessage(BleConnector.SERVICE_MTK_OTA, BleConnector.CH_MTK_OTA_FLAG,
            Data([0x02])))
        mBleMessenger.enqueueMessage(WriteMessage(BleConnector.SERVICE_MTK_OTA, BleConnector.CH_MTK_OTA_MD5,
            "b3b27696771768c6648f237a43c37a39".data(using: .utf8) ?? Data()))
    }

    func mtkOta(forResource name: String, ofType ext: String) {
        if let path = Bundle.main.path(forResource: name, ofType: ext) {
            if let data = NSData(contentsOfFile: path) {
                mtkOta(data as Data)
            }
        }
    }

    func mtkOta(_ url: URL) {
        if let data = NSData(contentsOf: url) {
            mtkOta(data as Data)
        }
    }

    func mtkOta(_ path: String) {
        if let data = NSData(contentsOfFile: path) {
            mtkOta(data as Data)
        }
    }

    private func syncData() -> Bool {
        mDataKeys = mBleCache.mDataKeys
            .filter({ $0 != BleKey.DATA_ALL.rawValue })
            .map({ (BleKey(rawValue: $0) ?? BleKey.NONE) })
        if mDataKeys.isEmpty {
            notifySyncState(SyncState.COMPLETED, .NONE)
            return true
        } else {
            postDelaySyncTimeout()
            return sendData(mDataKeys[0], .READ)
        }
    }

    func read(_ service: String, _ characteristic: String) -> Bool {
        bleLog("BleConnector read -> \(service), \(characteristic)")
        if !isAvailable() {
            return false
        }

        let message = ReadMessage(service, characteristic)
        mBleMessenger.enqueueMessage(message)
        return true
    }

    private func bind() {
        _ = sendInt32(.IDENTITY, .CREATE, Int.random(in: 1..<0xffffffff))
    }

    func unbind() {
        mBleCache.mDeviceInfo = nil
        mBleCache.putDeviceIdentify(nil)
        mBleCache.remove(.IDENTITY)
        closeConnection(true)
    }

    func isBound() -> Bool {
        mBleCache.getDeviceIdentify() != nil
    }

    private func login(_ id: Int) {
        _ = sendInt32(.SESSION, .CREATE, id)
    }

    func isAvailable() -> Bool {
        mBleState >= BleState.READY
    }

    private func handleData(_ data: Data) {
        let isReply = MessageFactory.isReply(data)
        if isReply {
            mBleMessenger.dequeueMessage()
        }

        if !MessageFactory.isValid(data) {
            return
        }

        var dataCount = 0
        guard let bleKey = BleKey(rawValue: data.getUInt(MessageFactory.LENGTH_BEFORE_CMD, 2)) else {
            return
        }

        guard let bleKeyFlag = BleKeyFlag(rawValue: Int(data[MessageFactory.LENGTH_BEFORE_CMD + 2])) else {
            return
        }

        bleLog("BleConnector handleData -> key=\(bleKey.mDisplayName), keyFlag=\(bleKeyFlag.mDisplayName)" +
            ", isReply=\(isReply)")
        switch bleKey {
            // BleCommand.UPDATE
        case .OTA:
            if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                return
            }

            let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
            bleLog("BleConnector handleData onOTA -> \(status))")
            notifyHandlers({ $0.onOTA?(status) })
        case .XMODEM:
            if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                return
            }

//            let status = data[MessageFactory.LENGTH_BEFORE_DATA]
//            bleLog("BleConnector handleData onXModem -> \(BleUtils.getXModemStatus(status))")
//            notifyHandlers({ $0.onXModem?(status) })

            // BleCommand.SET
        case .POWER:
            if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                return
            }

            let power = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
            bleLog("BleConnector handleData onReadPower -> \(power)")
            notifyHandlers({ $0.onReadPower?(power) })
        case .FIRMWARE_VERSION, .UI_PACK_VERSION:
            if isReply && bleKeyFlag == .READ {
                let bleVersion: BleVersion = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                let version = bleVersion.mVersion
                if bleKey == .FIRMWARE_VERSION {
                    bleLog("BleConnector handleData onReadFirmwareVersion -> \(version)")
                    let oldVersion = mBleCache.getString(bleKey)
                    if !oldVersion.isEmpty && oldVersion != version
                           && mBleCache.mSupportReadDeviceInfo == 1 {
                        _ = sendData(BleKey.IDENTITY, BleKeyFlag.READ)
                    }
                    mBleCache.putString(bleKey, version)
                    notifyHandlers({ $0.onReadFirmwareVersion?(version) })
                } else if bleKey == .UI_PACK_VERSION {
                    bleLog("BleConnector handleData onReadUiPackVersion -> \(version)")
                    mBleCache.putString(bleKey, version)
                    notifyHandlers({ $0.onReadUiPackVersion?(version) })
                }
            }
        case .LANGUAGE_PACK_VERSION:
            if isReply && bleKeyFlag == .READ {
                let languagePackVersion: BleLanguagePackVersion =
                    BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                mBleCache.putObject(bleKey, languagePackVersion)
                bleLog("BleConnector handleData onReadLanguagePackVersion -> \(languagePackVersion)")
                notifyHandlers({ $0.onReadLanguagePackVersion?(languagePackVersion) })
            }
        case .LANGUAGE:
            if !isReply && (bleKeyFlag == .DELETE || bleKeyFlag == .READ) {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                bleLog("BleConnector handleData onFollowSystemLanguage")
                notifyHandlers({ $0.onFollowSystemLanguage?(true) })
            }
            break
        case .DRINKWATER:
            if isReply && bleKeyFlag == BleKeyFlag.READ {
                let drinkWater: BleDrinkWaterSettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadDrinkWaterSettings -> \(drinkWater)")
                notifyHandlers({ $0.onReadDrinkWaterSettings?(drinkWater) })
            }
            break
        case .WATCH_FACE_SWITCH:
            if isReply && bleKeyFlag == .READ {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    bleLog("BleConnector handleData onReadWatchFaceSwitch error")
                    return
                }
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                mBleCache.putInt(bleKey, value)
                bleLog("BleConnector handleData onReadWatchFaceSwitch -> \(value)")
                notifyHandlers({ $0.onReadWatchFaceSwitch?(value) })
            }else if isReply && bleKeyFlag == .UPDATE {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    bleLog("BleConnector handleData onUpdateWatchFaceSwitch error")
                    return
                }
                let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
                bleLog("BleConnector handleData onUpdateWatchFaceSwitch -> \(status)")
                notifyHandlers({ $0.onUpdateWatchFaceSwitch?(status) })
            }
            break
        case .AEROBIC_EXERCISE:
            if isReply && bleKeyFlag == .READ {
                let AerobicSettings: BleAerobicSettings =
                    BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                mBleCache.putObject(bleKey, AerobicSettings)
                bleLog("BleConnector handleData onReadAerobicSettings -> \(AerobicSettings)")
                notifyHandlers({ $0.onReadAerobicSettings?(AerobicSettings) })
            }
            break
        case .TEMPERATURE_UNIT:
            if isReply && bleKeyFlag == .READ {
                let state = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                bleLog("BleConnector handleData onReadTemperatureUnitSettings -> \(state)")
                mBleCache.putInt(bleKey, state)
                notifyHandlers({ $0.onReadTemperatureUnitSettings?(state) })
            }
            break
        case .DATE_FORMAT:
            if isReply && bleKeyFlag == .READ {
                let Status = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                bleLog("BleConnector handleData onReadDateFormatSettings -> \(Status)")
                mBleCache.putInt(bleKey, Status)
                notifyHandlers({ $0.onReadDateFormatSettings?(Status) })
            }
            break
        case .BLE_ADDRESS:
            let bleAddress: BleBleAddress = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
            let address = bleAddress.mAddress
            bleLog("BleConnector handleData onReadBleAddress -> \(address)")
            notifyHandlers({
                $0.onReadBleAddress?(address)
            })
        case .SEDENTARINESS:
            if isReply && bleKeyFlag == BleKeyFlag.READ {
                let sedentariness: BleSedentarinessSettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadSedentariness -> \(sedentariness)")
                notifyHandlers({ $0.onReadSedentariness?(sedentariness) })
            }
        case .NO_DISTURB_RANGE:
            if isReply && bleKeyFlag == .READ {
                let noDisturb: BleNoDisturbSettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadNoDisturb -> \(noDisturb)")
                if noDisturb.mEnabled != 0x1F { // R5老版本不支持读取该指令，会返回一个字节0x1F
                    mBleCache.putObject(bleKey, noDisturb)
                    notifyHandlers({ $0.onReadNoDisturb?(noDisturb) })
                }
            } else if !isReply && bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                let noDisturb: BleNoDisturbSettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onNoDisturbUpdate -> \(noDisturb)")
                mBleCache.putObject(bleKey, noDisturb)
                notifyHandlers({ $0.onNoDisturbUpdate?(noDisturb) })
            }else if isReply && bleKeyFlag == .UPDATE {
                notifyHandlers({ $0.onUpdateSettings?(bleKey.rawValue) })
            }
        case .VIBRATION:
            if !isReply && bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                mBleCache.putInt(bleKey, value)
                notifyHandlers({ $0.onVibrationUpdate?(value) })
            }
            break
        case .ALARM:
            if isReply {
                if bleKeyFlag == .READ {
                    let alarms: [BleAlarm] = BleReadable.ofArray(data, BleAlarm.ITEM_LENGTH,
                        MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onReadAlarm -> \(alarms)")
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onReadAlarm?(alarms) })
                }
            } else {
                if bleKeyFlag == .UPDATE {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let alarm: BleAlarm = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onAlarmUpdate -> \(alarm)")
                    var alarms: [BleAlarm] = mBleCache.getArray(bleKey)
                    if let index = alarms.firstIndex(where: { $0.mId == alarm.mId }) {
                        alarms[index] = alarm
                    }
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onAlarmUpdate?(alarm) })
                } else if bleKeyFlag == .DELETE {
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                        return
                    }

                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let id = Int(data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 1))
                    var alarms: [BleAlarm] = mBleCache.getArray(bleKey)
                    if id == ID_ALL {
                        alarms.removeAll()
                    } else {
                        if let index = alarms.firstIndex(where: { $0.mId == id }) {
                            alarms.remove(at: index)
                        }
                    }
                    bleLog("BleConnector handleData onAlarmDelete -> \(id)")
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onAlarmDelete?(id) })
                } else if bleKeyFlag == .CREATE {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let alarm: BleAlarm = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onAlarmAdd -> \(alarm)")
                    var alarms: [BleAlarm] = mBleCache.getArray(bleKey)
                    alarms.append(alarm)
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onAlarmAdd?(alarm) })
                }
            }
        case .COACHING:
            if isReply {
                if bleKeyFlag == .READ {
                    let coachingIds: BleCoachingIds = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onReadCoachingIds -> \(coachingIds)")
                    mBleCache.putObject(bleKey, coachingIds, bleKeyFlag)
                    notifyHandlers({ $0.onReadCoachingIds?(coachingIds) })
                } else if bleKeyFlag == .UPDATE {
                    let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
                    notifyHandlers({
                        $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, status)
                    })
                    bleLog("BleConnector handleData onCommandReply \(bleKey), \(bleKeyFlag) -> \(status)")
                }
            }
            break
        case .WORLD_CLOCK:
            if isReply {
                if bleKeyFlag == .READ {
                    let worldClocks: [BleWorldClock] = BleReadable.ofArray(data, BleWorldClock.TITLE_LENGTH,
                        MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onReadWorldClock -> \(worldClocks)")
                    mBleCache.putArray(bleKey, worldClocks)
                    notifyHandlers({ $0.onReadWorldClock?(worldClocks) })
                }
            }else{
                if bleKeyFlag == .DELETE{
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                        return
                    }

                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let id = Int(data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 1))
                    var worldClocks: [BleWorldClock] = mBleCache.getArray(bleKey)
                    if id == ID_ALL {
                        worldClocks.removeAll()
                    } else {
                        if let index = worldClocks.firstIndex(where: { $0.mId == id }) {
                            worldClocks.remove(at: index)
                        }
                    }
                    bleLog("BleConnector handleData onWorldClockDelete -> \(id)")
                    mBleCache.putArray(bleKey, worldClocks)
                    notifyHandlers({ $0.onWorldClockDelete?(id) })
                }
            }
            break
        case .STOCK:
            if isReply {
                if bleKeyFlag == .READ {
                    let stocks: [BleStock] = BleReadable.ofArray(data, BleStock.TITLE_LENGTH,
                        MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onReadStock -> \(stocks)")
                    mBleCache.putArray(bleKey, stocks)
                    notifyHandlers({ $0.onReadStock?(stocks) })
                }
                
            }else{
                if bleKeyFlag == .DELETE{
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                        return
                    }

                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let id = Int(data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 1))
                    var stocks: [BleStock] = mBleCache.getArray(bleKey)
                    if id == ID_ALL {
                        stocks.removeAll()
                    } else {
                        if let index = stocks.firstIndex(where: { $0.mId == id }) {
                            stocks.remove(at: index)
                        }
                    }
                    bleLog("BleConnector handleData onStockDelete -> \(id)")
                    mBleCache.putArray(bleKey, stocks)
                    notifyHandlers({ $0.onStockDelete?(id) })
                }else if bleKeyFlag == .READ {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    bleLog("BleConnector handleData onDeviceReadStock")
                    notifyHandlers({ $0.onDeviceReadStock?(true) })
                }
            }
            break
        case .FIND_PHONE:
            if !isReply && bleKeyFlag == .UPDATE {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }

                let start = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                bleLog("BleConnector handleData onFindPhone -> \(start ? "started" : "stopped"))")
                notifyHandlers({ $0.onFindPhone?(start) })
            }
        case .AGPS_PREREQUISITE:
            if !isReply && bleKeyFlag == .READ {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                bleLog("BleConnector handleData onRequestAgpsPrerequisite")
                notifyHandlers({ $0.onRequestAgpsPrerequisite?() })
            }

        case .REAL_TIME_HEART_RATE:
            if isReply == false {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                let itemHR: ABHRealTimeHR = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onUpdateRealTimeHR -> \(itemHR)")
                notifyHandlers({ $0.onUpdateRealTimeHR?(itemHR) })
            }
        case .REAL_TIME_TEMPERATURE:
            if isReply == false {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                let itemTemperature: BleTemperature = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onUpdateRealTimeTemperature -> \(itemTemperature)")
                notifyHandlers({ $0.onUpdateRealTimeTemperature?(itemTemperature) })
            }
            break
        case .REAL_TIME_BLOOD_PRESSURE:
            if isReply == false {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                let itemBP: BleBloodPressure = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onUpdateRealTimeBloodPressure -> \(itemBP)")
                notifyHandlers({ $0.onUpdateRealTimeBloodPressure?(itemBP) })
            }
            break
        case .BLOOD_OXYGEN_SET:
            if isReply && bleKeyFlag == BleKeyFlag.READ {
                let bloodOxySet: BleBloodOxyGenSettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadBloodOxyGenSettings -> \(bloodOxySet)")
                notifyHandlers({ $0.onReadBloodOxyGenSettings?(bloodOxySet) })
            }
            break
        case .WASH_SET:
            if isReply && bleKeyFlag == BleKeyFlag.READ {
                let washSet: BleWashSettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadWashSettings -> \(washSet)")
                notifyHandlers({ $0.onReadWashSettings?(washSet) })
            }
            break
        case .WATCHFACE_ID:
            if isReply {
                if bleKeyFlag == BleKeyFlag.READ{
                    let watchFaceId: BleWatchFaceId = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("onReadWatchFaceId - \(watchFaceId)")
                    notifyHandlers({ $0.onReadWatchFaceId?(watchFaceId) })
                }else if bleKeyFlag == BleKeyFlag.UPDATE{
                    bleLog("onWatchFaceIdUpdate UPDATE ")
                    notifyHandlers({ $0.onWatchFaceIdUpdate?(true) })
                }
            }
            break
        case .IBEACON_SET:
            if isReply && bleKeyFlag == BleKeyFlag.READ {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                let status = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                bleLog("BleConnector handleData onReadiBeaconStatus -> \(status)")
                notifyHandlers({ $0.onReadiBeaconStatus?(status) })
            }
            break
            
        case .REALTIME_MEASUREMENT:
            if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                return
            }
            if isReply == false {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
            }
            let itemTM: BleRealTimeMeasurement = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
            notifyHandlers({ $0.onRealTimeMeasurement?(itemTM) })
            bleLog("BleConnector handleData onRealTimeMeasurement -> \(itemTM)")
            break
            // BleCommand.CONNECT
        case .IDENTITY:
            if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                return
            }

            let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
            if bleKeyFlag == .CREATE {
                if !status {
                    bleLog("BleConnector handleData onIdentityCreate -> false")
                    notifyHandlers({ $0.onIdentityCreate?(false) })
                }
            } else if bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                if status {
                    mBleCache.mDeviceInfo = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA + 1)
                    if let deviceInfo = mBleCache.mDeviceInfo {
                        bleLog("BleConnector handleData onIdentityCreate -> true, \(deviceInfo)")
                        mBleCache.putObject(bleKey, deviceInfo)
                        mBleCache.putDeviceIdentify(mTargetIdentifier)
                        notifyHandlers({ $0.onIdentityCreate?(true) })
                        login(deviceInfo.mId)
                    }
                } else {
                    bleLog("BleConnector handleData onIdentityCreate -> false")
                    notifyHandlers({ $0.onIdentityCreate?(false) })
                }
            } else if bleKeyFlag == .DELETE {
                bleLog("BleConnector handleData onIdentityDelete -> \(status)")
                if isReply {
                    if status {
                        unbind()
                    }
                    notifyHandlers({ $0.onIdentityDelete?(status) })
                } else {
                    //viewController make judgments ->unbind
                    notifyHandlers({ $0.onIdentityDeleteByDevice?(status) })
                }
            } else if bleKeyFlag == .READ {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 17 { // 这里的17只是大概防呆一下
                    return
                }

                let deviceInfo: BleDeviceInfo = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA + 1)
                bleLog("BleConnector handleData onReadDeviceInfo -> \(status), \(deviceInfo)")
                if status {
                    mBleCache.mDeviceInfo = deviceInfo
                    mBleCache.putObject(bleKey, deviceInfo)
                }
            }
        case .SESSION:
            if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                return
            }

            let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
            if status {
                bleLog("BleConnector handleData onSessionStateChange -> true")
                notifyHandlers({ $0.onSessionStateChange?(true) })
            }

            // BleCommand.PUSH
        case .MUSIC_CONTROL:
            if bleKeyFlag == .UPDATE && !isReply {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
            }
        case .WEATHER_REALTIME:
            if bleKeyFlag == .READ && !isReply {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                bleLog("BleConnector handleData onReadWeatherRealtime -> true")
                notifyHandlers({ $0.onReadWeatherRealtime?(true) })
            }
            // BleCommand.DATA
        case .ACTIVITY:
            if bleKeyFlag == .READ && isReply {
                let activities: [BleActivity] = BleReadable.ofArray(data, BleActivity.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadActivity -> \(activities)")
                dataCount = activities.count
                if mSupportFilterEmpty {
                    if !activities.isEmpty {
                        notifyHandlers({ $0.onReadActivity?(activities) })
                    }
                } else {
                    notifyHandlers({ $0.onReadActivity?(activities) })
                }
            }
        case .HEART_RATE:
            
            bleLog("==  SmartV3_HEART_RATE  bleKeyFlag:\(bleKeyFlag) isReply:\(isReply) 原始数据Data: \(data.hexadecimal())")
            if bleKeyFlag == .READ && isReply {
                let heartRates: [BleHeartRate] = BleReadable.ofArray(data, BleHeartRate.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadHeartRate -> \(heartRates)")
                dataCount = heartRates.count
                
                if mSupportFilterEmpty {
                    if !heartRates.isEmpty {
                        notifyHandlers({ $0.onReadHeartRate?(heartRates) })
                    }
                } else {
                    notifyHandlers({ $0.onReadHeartRate?(heartRates) })
                }
            }
        case .BLOOD_PRESSURE:
            if bleKeyFlag == .READ && isReply {
                let bloodPressures: [BleBloodPressure] = BleReadable.ofArray(data, BleBloodPressure.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadBloodPressure -> \(bloodPressures)")
                dataCount = bloodPressures.count
                if mSupportFilterEmpty {
                    if !bloodPressures.isEmpty {
                        notifyHandlers({ $0.onReadBloodPressure?(bloodPressures) })
                    }
                } else {
                    notifyHandlers({ $0.onReadBloodPressure?(bloodPressures) })
                }
            }
        case .SLEEP:
            if bleKeyFlag == .READ && isReply {
                let sleeps: [BleSleep] = BleReadable.ofArray(data, BleSleep.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadSleep -> \(sleeps)")
                dataCount = sleeps.count
                if mSupportFilterEmpty {
                    if !sleeps.isEmpty {
                        notifyHandlers({ $0.onReadSleep?(sleeps) })
                    }
                } else {
                    notifyHandlers({ $0.onReadSleep?(sleeps) })
                }
            }
        case .SLEEP_RAW_DATA, .RAW_SLEEP:
            if bleKeyFlag == .READ && isReply {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                let sleepData: Data = data[MessageFactory.LENGTH_BEFORE_DATA..<data.count]
                bleLog("BleConnector handleData onReadSleepRaw -> \(sleepData.count)")
                notifyHandlers({ $0.onReadSleepRaw?(sleepData) })
            }
            break
        case .WORKOUT:
            if bleKeyFlag == .READ && isReply {
                let workOut: [BleWorkOut] = BleReadable.ofArray(data, BleWorkOut.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadWorkOut -> \(workOut)")
                dataCount = workOut.count
                if mSupportFilterEmpty {
                    if !workOut.isEmpty {
                        notifyHandlers({ $0.onReadWorkOut?(workOut) })
                    }
                } else {
                    notifyHandlers({ $0.onReadWorkOut?(workOut) })
                }
            }
        case .LOCATION:
            if bleKeyFlag == .READ && isReply {
                let locations: [BleLocation] = BleReadable.ofArray(data, BleLocation.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadLocation -> \(locations)")
                dataCount = locations.count
                if mSupportFilterEmpty {
                    if !locations.isEmpty {
                        notifyHandlers({ $0.onReadLocation?(locations) })
                    }
                } else {
                    notifyHandlers({ $0.onReadLocation?(locations) })
                }
            }
        case .TEMPERATURE:
            if bleKeyFlag == .READ && isReply {
                let temperatures: [BleTemperature] = BleReadable.ofArray(data, BleTemperature.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadTemperature -> \(temperatures)")
                dataCount = temperatures.count
                if mSupportFilterEmpty {
                    if !temperatures.isEmpty {
                        notifyHandlers({ $0.onReadTemperature?(temperatures) })
                    }
                } else {
                    notifyHandlers({ $0.onReadTemperature?(temperatures) })
                }
            }
        case .BLOODOXYGEN:
            if bleKeyFlag == .READ && isReply {
                let BloodOxys: [BleBloodOxygen] = BleReadable.ofArray(data, BleBloodOxygen.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadBloodOxygen -> \(BloodOxys)")
                dataCount = BloodOxys.count
                if mSupportFilterEmpty {
                    if !BloodOxys.isEmpty {
                        notifyHandlers({ $0.onReadBloodOxygen?(BloodOxys) })
                    }
                } else {
                    notifyHandlers({ $0.onReadBloodOxygen?(BloodOxys) })
                }
            }
        case .HRV:
            if bleKeyFlag == .READ && isReply {
                let HRVs: [BleHeartRateVariability] = BleReadable.ofArray(data, BleHeartRateVariability.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadHeartRateVariability -> \(HRVs)")
                dataCount = HRVs.count
                if mSupportFilterEmpty {
                    if !HRVs.isEmpty {
                        notifyHandlers({ $0.onReadHeartRateVariability?(HRVs) })
                    }
                } else {
                    notifyHandlers({ $0.onReadHeartRateVariability?(HRVs) })
                }
            }
            
        case .LOG:
            if bleKeyFlag == .READ && isReply {
                let logData: [BleLogText] = BleReadable.ofArray(data, BleLogText.ITEM_LENGTH,MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadDataLog -> \(logData.count)")
                if logData.count>0 {
                    notifyHandlers({ $0.onReadDataLog?(logData) })
                }
                
            }
            break
        case .PRESSURE:
            if bleKeyFlag == .READ && isReply {
                let pressures: [BlePressure] = BleReadable.ofArray(data, BlePressure.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadPressures -> \(pressures)")
                dataCount = pressures.count
                if mSupportFilterEmpty {
                    if !pressures.isEmpty {
                        notifyHandlers({ $0.onReadPressures?(pressures) })
                    }
                } else {
                    notifyHandlers({ $0.onReadPressures?(pressures) })
                }
            }
            break
        case .WORKOUT2:
            if bleKeyFlag == .READ && isReply {
                let workOut2: [BleWorkOut2] = BleReadable.ofArray(data, BleWorkOut2.ITEM_LENGTH,
                    MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadWorkOut2 -> \(workOut2)")
                dataCount = workOut2.count
                if mSupportFilterEmpty {
                    if !workOut2.isEmpty {
                        notifyHandlers({ $0.onReadWorkOut2?(workOut2) })
                    }
                } else {
                    notifyHandlers({ $0.onReadWorkOut2?(workOut2) })
                }
            }
            break
        case .MATCH_RECORD:
            if bleKeyFlag == .READ && isReply {
                let matchRecord: [BleMatchRecord] = BleReadable.ofArray(data, BleMatchRecord.ITEM_LENGTH,MessageFactory.LENGTH_BEFORE_DATA)
                dataCount = matchRecord.count
                bleLog("BleConnector handleData onReadMatchRecord -> \(matchRecord)")
                if mSupportFilterEmpty {
                    if !matchRecord.isEmpty {
                        notifyHandlers({ $0.onReadMatchRecord?(matchRecord) })
                    }
                } else {
                    notifyHandlers({ $0.onReadMatchRecord?(matchRecord) })
                }
            }
            break
            // BleCommand.CONTROL
        case .CAMERA:
            if isReply {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 2 {
                    return
                }

                let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
                let cameraState = Int(data[MessageFactory.LENGTH_BEFORE_DATA + 1])
                bleLog("BleConnector handleData onCameraResponse -> status=\(status)" +
                    ", cameraState=\(CameraState.getState(cameraState))")
                notifyHandlers({ $0.onCameraResponse?(status, cameraState) })
            } else {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }

                _ = sendData(bleKey, bleKeyFlag, nil, true)
                let cameraState = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                bleLog("BleConnector handleData onCameraStateChange -> \(CameraState.getState(cameraState))")
                notifyHandlers({ $0.onCameraStateChange?(cameraState) })
            }
        case .PHONE_GPSSPORT:
            if !isReply{
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }

                _ = sendData(bleKey, bleKeyFlag, nil, true)
                let workoutState = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                bleLog("BleConnector handleData onPhoneGPSSport -> \(WorkoutState.getState(workoutState))")
                notifyHandlers({ $0.onPhoneGPSSport?(workoutState) })
            }
            break
        case .APP_SPORT_STATE:
            _ = sendData(bleKey, bleKeyFlag, nil, true)
            if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                return
            }
            let workOutStatus: BlePhoneWorkOutStatus = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
            bleLog("BleConnector handleData onUpdatePhoneWorkOutStatus -> \(workOutStatus) isReply - \(isReply)")
            
            if !isReply{
                notifyHandlers({ $0.onUpdatePhoneWorkOutStatus?(workOutStatus) })
            }
            break
            // BleCommand.IO
        case .WATCH_FACE, .AGPS_FILE, .FONT_FILE, .CONTACT, .UI_FILE, .LANGUAGE_FILE:
            if isReply {
                if bleKeyFlag == .UPDATE {
                    closeBreakpointResume()
                    // 出错时可能只返回一个字节
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                        return
                    }

                    let streamProgress: BleStreamProgress = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    let progressValue = CGFloat(streamProgress.mCompleted)/CGFloat(streamProgress.mTotal)
                    let progressString = progressValue > 0 ? String.init(format: "%.2f%%", progressValue * 100.0) : ""
                    var mSpeed :Double = 0.0
                    if streamProgress.mCompleted > 0{
                        let nowTime = Int(Date().timeIntervalSince1970)
                        let sTime = nowTime-self.mTransmissionSpeed
                        mSpeed = Double(streamProgress.mCompleted/1024)/Double(sTime)
                    }else{
                        if streamProgress.mCompleted >= streamProgress.mTotal{
                            self.mTransmissionSpeed = 0
                        }
                    }
                    bleLog("BleConnector handleData onStreamProgress -> progress:\(progressString) speed:\(String.init(format: "%.2f",mSpeed))kb/s \(streamProgress)")
                    if streamProgress.mStatus == BLE_OK {
                        if streamProgress.mTotal == streamProgress.mCompleted {
                            mDataResume = 0
                            mBleStream = nil
                        } else {
                            let streamPacket = mBleStream?.getPacket(streamProgress.mCompleted, mBleCache.mIOBufferSize)
                            if streamPacket != nil {
                                if BleCache.shared.mSupportNewTransportMode == 1 &&
                                    BleCache.shared.mPlatform == BleDeviceInfo.PLATFORM_JL{
                                    mDataResume = streamProgress.mCompleted
                                    mResumeBleKey = bleKey
    //                                startBreakpointResume()
                                }
                                bleLog("onStreamProgress mDataResume -> \(mDataResume)")
                                _ = sendObject(bleKey, .UPDATE, streamPacket)
                                
                            }
                        }
                    } else {
                        mBleStream = nil
                    }
                    notifyHandlers {
                        $0.onStreamProgress?(streamProgress.mStatus == BLE_OK, streamProgress.mErrorCode,
                            streamProgress.mTotal, streamProgress.mCompleted)
                    }
                }
            } else {
                if bleKey == .AGPS_FILE && bleKeyFlag == .UPDATE {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    bleLog("BleConnector onDeviceRequestAGpsFile -> \(mBleCache.mAGpsFileUrl)")
                    notifyHandlers({ $0.onDeviceRequestAGpsFile?(mBleCache.mAGpsFileUrl) })
                }
            }
        case .MEDIA_FILE:
            if (bleKeyFlag == .READ || bleKeyFlag == .READ_CONTINUE) && isReply {
                let mediaFile: BleFileTransmission = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector onReadMediaFile -> \(mediaFile.mTime) data - \(mediaFile.mFileData.count)")
                notifyHandlers({ $0.onReadMediaFile?(mediaFile) })
            }
            break
        default:
            if !isReply {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
            }
        }

        if bleKey.mBleCommand == .DATA && bleKeyFlag == .READ && isReply {
            notifySyncState(SyncState.SYNCING, bleKey)
            if dataCount > 0 {
                _ = sendData(bleKey, .DELETE)
            }
            if dataCount <= 1 { // 该类型数据已同步完成
                if !mDataKeys.isEmpty {
                    mDataKeys.remove(at: 0)
                }
                if mDataKeys.isEmpty { // 整个数据同步完成
                    removeSyncTimeout()
                    notifySyncState(SyncState.COMPLETED, bleKey)
                } else { // 同步下个数据类型
                    _ = sendData(mDataKeys[0], .READ)
                    postDelaySyncTimeout()
                }
            } else { // 该类型数据还未同步完成，继续同步
                if !mDataKeys.isEmpty {
                    _ = sendData(mDataKeys[0], .READ)
                    postDelaySyncTimeout()
                } else {
                    _ = sendData(bleKey, .READ)
                    postDelaySyncTimeout()
                }
            }
        }
    }

    private func notifyHandlers(_ action: (BleHandleDelegate) -> Void) {
        for (_, handler) in mBleHandleDelegates {
            action(handler)
        }
    }

    private func notifySyncState(_ syncState: Int, _ bleKey: BleKey) {
        bleLog("BleConnector onSyncData -> \(SyncState.getState(syncState)), \(bleKey)")
        notifyHandlers({ $0.onSyncData?(syncState, bleKey.rawValue) })
    }

    private func postDelaySyncTimeout() {
        removeSyncTimeout()
        mSyncTimeout = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false, block: { _ in
            if self.mDataKeys.count > 0 {
                self.notifySyncState(SyncState.TIMEOUT, self.mDataKeys[0])
                self.mDataKeys.removeAll()
            }
        })
    }

    private func removeSyncTimeout() {
        mSyncTimeout?.invalidate()
        mSyncTimeout = nil
    }

    private func bufferArrayToData(_ bufs: [BleBuffer]?) -> Data {
        var data = Data()
        bufs?.forEach({
            data.append($0.toData())
        })
        return data
    }

    /**
     * 检查文件传输进度，用于非BleCommand.IO时，比如MTK固件升级。
     */
    private func checkStreamProgress() {
//        bleLog("BleConnector checkStreamProgress -> \(isAvailable()), \(mStreamProgressTotal)" +
//            ", \(mStreamProgressCompleted)")
        if (isAvailable()) {
            if mStreamProgressTotal > 0 && mStreamProgressCompleted > 0 {
                bleLog("BleConnector onStreamProgress -> mStreamProgressTotal=\(mStreamProgressTotal)" +
                    ", mStreamProgressCompleted=\(mStreamProgressCompleted)")
                notifyHandlers {
                    $0.onStreamProgress?(true, 0, mStreamProgressTotal, mStreamProgressCompleted)
                    if mStreamProgressTotal == mStreamProgressCompleted {
                        mStreamProgressTotal = -1
                        mStreamProgressCompleted = -1
                    }
                }
            }
        } else {
            if mStreamProgressTotal > 0 && mStreamProgressCompleted >= 0
                   && mStreamProgressCompleted < mStreamProgressTotal {
                notifyHandlers {
                    $0.onStreamProgress?(false, -1, mStreamProgressTotal, mStreamProgressCompleted)
                    if mStreamProgressTotal == mStreamProgressCompleted {
                        mStreamProgressTotal = -1
                        mStreamProgressCompleted = -1
                    }
                }
            }
        }
    }

    func supportFilterEmpty(_ empty: Bool) {
        mSupportFilterEmpty = empty
    }
    
    func openBleKeyTimeout(_ bleKey:BleKey,_ bleKeyFlag:BleKeyFlag){
        if mBleKeyTimeout == nil{
            mBleKeyTimeout = Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false, block: { [self] _ in
                closeBleKeyTimeout()
                bleLog("openBleKeyTimeout -\(bleKey) \(bleKeyFlag)")
                self.notifyHandlers({ $0.onCommandSendTimeout?(bleKey.rawValue, bleKeyFlag.rawValue) })
                    
            })
        }
    }
    
    func closeBleKeyTimeout(){
        if mBleKeyTimeout != nil {
            mBleKeyTimeout?.invalidate()
            mBleKeyTimeout = nil
        }
    }
    
    // MARK: - 断点续传
    /**
     容错:固件端在正常传输过程中无故不返回,无法继续下发下一个消息
     BleMessenger 单个小包超时机制为4*3次 12s 单个消息拆包N个小包逐个发送
     小包发送完成,固件端没有返回触发下一个消息进入队列时启用断点续传
     该功能主要针对杰里平台在升级UI包、字体库传输时概率中断
     0905与固件端协商后暂时屏蔽,固件端的解释为,出现传输中断原因是蓝牙中断,app需要在蓝牙重连后续传
     app端在蓝牙断开时做了防呆,蓝牙断开会清空所有消息。
     封存代码,后续容易复现再做测试
     使用withoutResponse才会出现,使用withResponse传输速度(HW01板子8-9kb/s ,F13B整机5-6kb/s) JL平台可以考虑mSupportNewTransportMode == 0保证传输不会有问题
     */
    func startBreakpointResume(){
        if mResumeTime == nil{
            mResumeTime = Timer.scheduledTimer(withTimeInterval: 12.5, repeats: false, block: { [self] _ in
                mResumeNumber += 1
                bleLog("进入断点续传 startBreakpointResume- \(mResumeNumber)")
                closeBreakpointResume()
                mBleStreamBreakpointResume()
                BreakpointResumeCount()
                    
            })
        }
    }
    
    func BreakpointResumeCount(){
        Timer.scheduledTimer(withTimeInterval: 12.5, repeats: false, block: { [self] _ in
            mResumeNumber += 1
            bleLog("断点续传 BreakpointResumeCount - \(mResumeNumber)")
            if mResumeNumber > 0 && mResumeNumber <= 3{
                mBleStreamBreakpointResume()
                BreakpointResumeCount()
            }
                
        })
    }
    
    func mBleStreamBreakpointResume(){
        if mDataResume < 1{
            bleLog("断点续传失败 - \(mDataResume)")
            return
        }
        let streamPacket = mBleStream?.getPacket(mDataResume, mBleCache.mIOBufferSize)
        if streamPacket != nil {
            bleLog("断点续传 -> \(mDataResume)")
            _ = sendObject(mResumeBleKey, .UPDATE, streamPacket)
        }else{
            bleLog("断点续传 nil -> \(mDataResume) \(String(describing: streamPacket))")
        }
    }
    
    func closeBreakpointResume(){
        mResumeNumber = 0
        if mResumeTime != nil{
            mResumeTime?.invalidate()
            mResumeTime = nil
        }
    }
}

extension BleConnector: BleConnectorDelegate {
    func didConnectionChange(_ connected: Bool) {
        if connected {
            bleLog("BleConnector onDeviceConnected -> \(mPeripheral?.identifier.uuidString ?? "")")
            mBleState = BleState.CONNECTED
            notifyHandlers({ $0.onDeviceConnected?(mPeripheral!) })
            mStreamProgressTotal = -1
            mStreamProgressCompleted = -1
        } else {
            bleLog("BleConnector onSessionStateChange -> false")
            mBleState = BleState.DISCONNECTED
            notifyHandlers({ $0.onSessionStateChange?(false) })
            if !mDataKeys.isEmpty {
                notifySyncState(SyncState.DISCONNECTED, mDataKeys[0])
                mDataKeys.removeAll()
                removeSyncTimeout()
            }
            if mBleStream != nil {
                notifyHandlers({ $0.onStreamProgress?(false, -1, 0, 0) })
            }
            mBleMessenger.reset()
            checkStreamProgress()
        }
        mBleStream = nil
    }
    
    func didConnectingChange(_ connected: Bool){
        notifyHandlers({ $0.onDeviceConnecting?(connected) })
    }

    func didCharacteristicRead(_ characteristicUuid: String, _ data: Data, _ text: String) {
        if characteristicUuid == BleConnector.CH_MTK_OTA_META {
            mBleCache.putMtkOtaMeta(meta: text)
            notifyHandlers({ $0.onReadMtkOtaMeta?() })
        }
    }

    func didCharacteristicWrite(_ characteristicUuid: String) {
        if characteristicUuid == BleConnector.CH_MTK_OTA_SIZE
               || characteristicUuid == BleConnector.CH_MTK_OTA_FLAG
               || characteristicUuid == BleConnector.CH_MTK_OTA_DATA
               || characteristicUuid == BleConnector.CH_MTK_OTA_MD5 {
            mBleMessenger.dequeueMessage()
        }
        if characteristicUuid == BleConnector.CH_MTK_OTA_DATA {
            mStreamProgressCompleted += 1
            checkStreamProgress()
        }
    }

    func didCharacteristicChange(_ characteristicUuid: String, _ data: Data) {
        //bleLog("==SmartV3_didCharacteristicChange 返回数据characteristicUuid: \(characteristicUuid)")
        bleLog("==SmartV3_didCharacteristicChange_返回原始数据Data: \(data.hexadecimal())")
        handleData(data)
    }

    func didUpdateNotification(_ characteristicUuid: String) {
        mBleState = BleState.READY
        if let deviceInfo = mBleCache.mDeviceInfo {
            login(deviceInfo.mId)
        } else {
            bind()
        }
    }
}
