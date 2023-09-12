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
            bleLog("BleConnector launch -> identity=\(identity) mLaunched:\(mLaunched)")
            
            // 初始化时候, 根据传入的identity 是什么, 来确定使用那个方式连接, 主要处理Flutter
            // E9:7F:EA:F6:79:7D
            if identity.count == 17 && identity.contains(":") {
                setTargetIdentifier(identity, .macAddress)
            } else {
                setTargetIdentifier(identity, .systemUUID)
            }
            
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
            bleLog("mBleHandleDelegates中取出来的tag:\(tag) 为nil")
            //fatalError("Tag dose not exist")
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
            bleKey == .LANGUAGE_FILE ||
            bleKey == .BRAND_INFO_FILE ||
            bleKey == .QRCode ||
            bleKey == .THIRD_PARTY_DATA {
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
                
                if bleKey == .LOVE_TAP_USER {
                    
                    // 2023-05-04 这个指令客户要求, 自己来控制mId参数所以不需要再判断什么, 直接发送给设备即可
                    idObjects.append(object!)
                } else {
                    // 2023-04-25 为了兼容Flutter和Swift交互, 处理Flutter调用时, SDK内部泛型类型不一致, 无法解析出mId值
                    // 例如添加闹钟, mBleCache.getArray(bleKey) 无法解析出mId, 返回的mId全是等于0, 就导致无法添加多个闹钟数据
                    var ids = [Int]()
                    if bleKey.isIdObjectKey() {
                        
                        // 如果是Flutter调用, 这里返回的是真实的Swift 类型, 可以正确读取出mId
                        let idObjRaw: [BleIdObject] = mBleCache.getIdObjects(bleKey)
                        ids = idObjRaw.map({ $0.mId })
                    } else {
                        // 这个之前的代码, 获取添加的mId属性, 使用原生SDK Swift代码访问能够正常返回mId
                        ids = idObjects.map({ ($0 as! BleIdObject).mId }) // 本地缓存的id
                    }
                    
                    // 2023-04-25 注释之前的代码, 为了兼容Flutter和Swift交互
                    //var ids = idObjects.map({ ($0 as! BleIdObject).mId }) // 本地缓存的id
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
                }
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
                bleKey == .LANGUAGE_FILE ||
                bleKey == .QRCode ||
                bleKey == .THIRD_PARTY_DATA) &&
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
        case .SLEEP_QUALITY: // 睡眠质量
            if isReply {
                if bleKeyFlag == .READ {
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + BleSleepQuality.ITEM_LENGTH {
                        return
                    }
                    
                    let sleepQuality: BleSleepQuality = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    BleCache.shared.putObject(bleKey, sleepQuality)
                    
                    bleLog("BleConnector handleData onReadSleepQuality -> \(sleepQuality)")
                    notifyHandlers({ $0.onReadSleepQuality?(sleepQuality) })
                } else {
                 
                    bleLog("BleConnector handleData SLEEP_QUALITY onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
                }
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
        case .TEMPERATURE_UNIT:  // 温度单位设置
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
        case .USER_PROFILE: // 用户信息
            if bleKeyFlag == .READ {
                let userProfile: BleUserProfile = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                BleCache.shared.putObject(bleKey, userProfile)
                
                bleLog("BleConnector handleData onReadUserPorfile -> \(userProfile)")
                notifyHandlers({ $0.onReadUserPorfile?(userProfile) })
            } else {
                if bleKeyFlag == .UPDATE {
                    let status = true
                    bleLog("BleConnector handleData USER_PROFILE onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, status) })
                    return
                }
            }
            
        case .STEP_GOAL:  // 目标步数
            if bleKeyFlag == .READ {
                
                if !isReply {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                }
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 4) {
                    bleLog("READ STEP_GOAL返回的数据格式, 不合法")
                    break
                }
                
                // "0xAB, 0x11, 0x00, 0x07, 0x0A, 0xE3, 0x02, 0x07, 0x10, 0x00, 0x00, 0x03, 0xE8"
                // 数据是 MessageFactory.LENGTH_BEFORE_DATA 后4个字节  0x00, 0x00, 0x03, 0xE8
                let sufData: Data = Data(data.suffix(4))
            
                let value = sufData.hexToDecimal()
                mBleCache.putInt(bleKey, value)

                // 设备返回目标步数时触发
                notifyHandlers({ $0.onReadStepGoal?(value)})
            }
            
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
        case .POWER_SAVE_MODE:  // 省电模式
            if bleKeyFlag == .READ {
                
                if !isReply {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                }
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("READ省电模式返回的数据格式, 不合法")
                    break
                }
                // ab010004b671023700 01
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                //print("READ省电模式, 主动返回数据:\(value)")
                mBleCache.putInt(bleKey, value)
                
                // 设备返回当前省电模式状态时触发。
                notifyHandlers({ $0.onPowerSaveModeState?(value)})

            } else if !isReply && bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("UPDATE省点模式返回的数据格式, 不合法")
                    break
                }
                
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                //print("UPDATE省电模式, 主动返回数据:\(value)")
                mBleCache.putInt(bleKey, value)
                
                // 设备的省电模式状态变化时触发
                notifyHandlers({ $0.onPowerSaveModeStateChange?(value)})
            }
            
        case .VIBRATION:  // 震动
            
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
        case .ALARM:  // 闹钟
            if isReply {
                if bleKeyFlag == .READ {
                    let alarms: [BleAlarm] = BleReadable.ofArray(data, BleAlarm.ITEM_LENGTH,
                        MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onReadAlarm -> \(alarms)")
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onReadAlarm?(alarms) })
                } else {
                    bleLog("BleConnector handleData ALARM onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
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
        case .MEDICATION_ALARM:  // 简化版本的吃药提醒, 药物提醒, 功能和闹钟差不多
            if isReply {
                if bleKeyFlag == .READ {
                    let alarms: [BleMedicationAlarm] = BleReadable.ofArray(data, BleMedicationAlarm.ITEM_LENGTH,
                        MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onReadMedicationAlarm -> \(alarms)")
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onReadMedicationAlarm?(alarms) })
                } else {
                    bleLog("BleConnector handleData MEDICATION_ALARM onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
                }
            } else {
                if bleKeyFlag == .UPDATE {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let alarm: BleMedicationAlarm = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onMedicationAlarmUpdate -> \(alarm)")
                    var alarms: [BleMedicationAlarm] = mBleCache.getArray(bleKey)
                    if let index = alarms.firstIndex(where: { $0.mId == alarm.mId }) {
                        alarms[index] = alarm
                    }
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onMedicationAlarmUpdate?(alarm) })
                } else if bleKeyFlag == .DELETE {
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                        return
                    }

                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let id = Int(data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 1))
                    var alarms: [BleMedicationAlarm] = mBleCache.getArray(bleKey)
                    if id == ID_ALL {
                        alarms.removeAll()
                    } else {
                        if let index = alarms.firstIndex(where: { $0.mId == id }) {
                            alarms.remove(at: index)
                        }
                    }
                    bleLog("BleConnector handleData onMedicationAlarmDelete -> \(id)")
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onMedicationAlarmDelete?(id) })
                } else if bleKeyFlag == .CREATE {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    let alarm: BleMedicationAlarm = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onMedicationAlarmAdd -> \(alarm)")
                    var alarms: [BleMedicationAlarm] = mBleCache.getArray(bleKey)
                    alarms.append(alarm)
                    mBleCache.putArray(bleKey, alarms)
                    notifyHandlers({ $0.onMedicationAlarmAdd?(alarm) })
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
                    bleLog("BleConnector handleData COACHING onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
                }
            }
            break
        case .SCHEDULE:
            if isReply {
                if bleKeyFlag == .CREATE {
                    bleLog("BleConnector handleData SCHEDULE onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
                }
            }
        case .WORLD_CLOCK:
            if isReply {
                if bleKeyFlag == .READ {
                    let worldClocks: [BleWorldClock] = BleReadable.ofArray(data, BleWorldClock.TITLE_LENGTH,
                        MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("BleConnector handleData onReadWorldClock -> \(worldClocks)")
                    mBleCache.putArray(bleKey, worldClocks)
                    notifyHandlers({ $0.onReadWorldClock?(worldClocks) })
                } else {
                    bleLog("BleConnector handleData WORLD_CLOCK onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
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
                } else {
                    bleLog("BleConnector handleData STOCK onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
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
        case .REAL_TIME_TEMPERATURE:  // 体温
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
        case .BLOOD_OXYGEN_SET:  // 血氧
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
                    notifyHandlers({ $0.onIdentityCreate?(false, nil) })
                }
            } else if bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                if status {
                    mBleCache.mDeviceInfo = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA + 1)
                    if let deviceInfo = mBleCache.mDeviceInfo {
                        bleLog("BleConnector handleData onIdentityCreate -> true, \(deviceInfo)")
                        mBleCache.putObject(bleKey, deviceInfo)
                        mBleCache.putDeviceIdentify(mTargetIdentifier)
                        notifyHandlers({ $0.onIdentityCreate?(true, deviceInfo) })
                        login(deviceInfo.mId)
                    }
                } else {
                    bleLog("The user clicks 'x' of the binding box to disconnect")
                    bleLog("BleConnector handleData onIdentityCreate -> false")
                    // 用户点击了设备绑定框的 'x', 由于iOS系统的原因, 这里需要执行下断开系统和设备的蓝牙连接操作
                    closeConnection(true)
                    
                    notifyHandlers({ $0.onIdentityCreate?(false, nil) })
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
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
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
                
                notifyHandlers({ $0.onReadDeviceInfo?(status, deviceInfo) })
            }
        case .DEVICE_INFO2:  // 获取手表信息, 设备基础信息返回
            
            if bleKeyFlag == .READ {
                
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                
                
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 17 { // 这里的17只是大概防呆一下
                    return
                }
                
                let deviceInfo2: BleDeviceInfo2 = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadDeviceInfo2 -> \(deviceInfo2)")
                //    if status {
                //        mBleCache.mDeviceInfo = deviceInfo
                //        mBleCache.putObject(bleKey, deviceInfo)
                //    }
                
                notifyHandlers({ $0.onReadDeviceInfo2?(deviceInfo2) })
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
        case .BLOOD_GLUCOSE:  //血糖
            if isReply && bleKeyFlag == BleKeyFlag.READ {
                
                let bloodGlucoseArr: [BleBloodGlucose] = BleReadable.ofArray(data, BleBloodGlucose.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadBloodGlucose -> \(bloodGlucoseArr)")
                
                dataCount = bloodGlucoseArr.count
                if mSupportFilterEmpty {  // ab11000987db0510 102b0ade7d0041
                    if !bloodGlucoseArr.isEmpty {
                        notifyHandlers({ $0.onReadBloodGlucose?(bloodGlucoseArr) })
                    }
                } else {
                    notifyHandlers({ $0.onReadBloodGlucose?(bloodGlucoseArr) })
                }
                //notifyHandlers({ $0.onReadBloodGlucose?(bloodGlucoseArr) })
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
        case .MATCH_RECORD2:
            if bleKeyFlag == .READ && isReply {
                let matchRecord2: [BleMatchRecord2] = BleReadable.ofArray(data, BleMatchRecord2.ITEM_LENGTH,MessageFactory.LENGTH_BEFORE_DATA)
                dataCount = matchRecord2.count
                bleLog("BleConnector handleData onReadMatchRecord2 -> \(matchRecord2)")
                if mSupportFilterEmpty {
                    if !matchRecord2.isEmpty {
                        notifyHandlers({ $0.onReadMatchRecord2?(matchRecord2) })
                    }
                } else {
                    notifyHandlers({ $0.onReadMatchRecord2?(matchRecord2) })
                }
            }
            
        case .BODY_STATUS:  // 身体状态
            if bleKeyFlag == .READ && isReply {
                
                let bodyStatusArr: [BleBodyStatus] = BleReadable.ofArray(data, BleBodyStatus.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadBodyStatus -> bodyStatusArr:\(bodyStatusArr.count)")
                if mSupportFilterEmpty {
                    if !bodyStatusArr.isEmpty {
                        notifyHandlers({ $0.onReadBodyStatus?(bodyStatusArr) })
                    }
                } else {
                    notifyHandlers({ $0.onReadBodyStatus?(bodyStatusArr) })
                }
            }
            
        case .MIND_STATUS:  // 心情状态
            if bleKeyFlag == .READ && isReply {

                let mindStatusArr: [BleMindStatus] = BleReadable.ofArray(data, BleMindStatus.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadMindStatus -> mindStatusArr:\(mindStatusArr.count)")
                if mSupportFilterEmpty {
                    if !mindStatusArr.isEmpty {
                        notifyHandlers({ $0.onReadMindStatus?(mindStatusArr) })
                    }
                } else {
                    notifyHandlers({ $0.onReadMindStatus?(mindStatusArr) })
                }
            }
        case .CALORIE_INTAKE:  // 摄入卡路里
            if bleKeyFlag == .READ && isReply {

                let calorieIntakeArr: [BleCalorieIntake] = BleReadable.ofArray(data, BleCalorieIntake.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadCalorieIntake -> calorieIntakeArr:\(calorieIntakeArr.count)")
                if mSupportFilterEmpty {
                    if !calorieIntakeArr.isEmpty {
                        notifyHandlers({ $0.onReadCalorieIntake?(calorieIntakeArr) })
                    }
                } else {
                    notifyHandlers({ $0.onReadCalorieIntake?(calorieIntakeArr) })
                }
            }
            
        case .FOOD_BALANCE:  // 食物均衡, 饮食均衡
            if bleKeyFlag == .READ && isReply {

                let foodBalanceArr: [BleFoodBalance] = BleReadable.ofArray(data, BleFoodBalance.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadFoodBalance -> foodBalanceArr:\(foodBalanceArr.count)")
                if mSupportFilterEmpty {
                    if !foodBalanceArr.isEmpty {
                        notifyHandlers({ $0.onReadFoodBalance?(foodBalanceArr) })
                    }
                } else {
                    notifyHandlers({ $0.onReadFoodBalance?(foodBalanceArr) })
                }
            }
            
            
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
            if !isReply && bleKeyFlag == .UPDATE {
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
        case .WATCH_FACE, .AGPS_FILE, .FONT_FILE, .CONTACT, .UI_FILE, .LANGUAGE_FILE, .QRCode, .THIRD_PARTY_DATA:
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
                } else if (bleKey == .THIRD_PARTY_DATA && bleKeyFlag == .UPDATE) {
                    // 第三方应用数据, 这个也是流, 需要 mBleStream = nil 处理, 否则影响其他功能
                    
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    
                    bleLog("THIRD_PARTY_DATA heandleData 接收到第三方, 支付宝大小:\(data.count) 原始数据\(data.mHexString)")
                    
                    let thirdPartyData: BleThirdPartyData = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("THIRD_PARTY_DATA heandleData onBleThirdPartyDataUpdate:\(thirdPartyData)")
                    
                    BleCache.shared.putObject(bleKey, thirdPartyData)
                    notifyHandlers({ $0.onBleThirdPartyDataUpdate?(thirdPartyData)})
                }
            }
        case .MEDIA_FILE:
            if (bleKeyFlag == .READ || bleKeyFlag == .READ_CONTINUE) && isReply {
                let mediaFile: BleFileTransmission = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector onReadMediaFile -> \(mediaFile.mTime) data - \(mediaFile.mFileData.count)")
                notifyHandlers({ $0.onReadMediaFile?(mediaFile) })
            }
            break
        case .GESTURE_WAKE:  // 抬手亮屏
            
            if bleKeyFlag == .READ {
                
                if !isReply {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                }
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("READ 抬手亮屏 返回的数据格式, 不合法")
                    //print("READ抬手亮屏返回的数据格式, 不合法")
                    break
                }
                
                let bleGes: BleGestureWake = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData READ 抬手亮屏收到通知 -> \(bleGes)")
                mBleCache.putObject(bleKey, bleGes)
                
                // 设备返回当前抬手亮屏状态时触发。
                notifyHandlers({ $0.onReadGestureWake?(bleGes) })

            } else if !isReply && bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("UPDATE 抬手亮屏 返回的数据格式, 不合法")
                    break
                }
                
                let bleGes: BleGestureWake = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData update 抬手亮屏收到通知 -> \(bleGes)")
                mBleCache.putObject(bleKey, bleGes)
                
                // 设备的抬手亮屏状态变化时触发
                notifyHandlers({ $0.onGestureWakeUpdate?(bleGes) })
            }
        case .HOUR_SYSTEM: // 读取当前是否为24小时制
            if bleKeyFlag == .READ {
                
                if !isReply {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                }
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("READ 当前小时制 返回的数据格式, 不合法")
                    break
                }
                
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                mBleCache.putInt(bleKey, value)

                bleLog("BleConnector handleData onReadHourSystem -> value:\(value)")
                // 设备的背光状态变化时触发
                notifyHandlers({ $0.onReadHourSystem?(value) })
            }
            
            
        case .BACK_LIGHT:  // 背光
            
            if bleKeyFlag == .READ {
                
                if !isReply {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                }
                
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("READ 当前背光 返回的数据格式, 不合法")
                    break
                }
                
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                mBleCache.putInt(bleKey, value)

                bleLog("BleConnector handleData onReadBacklight -> value:\(value)")
                // 设备的背光状态变化时触发
                notifyHandlers({ $0.onReadBacklight?(value) })
                
            } else if !isReply && bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("UPDATE 背光 返回的数据格式, 不合法")
                    break
                }
                
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                bleLog("BleConnector handleData update 背光收到通知value:\(value)")
                mBleCache.putInt(bleKey, value)
                
                // 设备的背光状态变化时触发
                notifyHandlers({ $0.onBacklightupdate?(value)})
            }
        
        case .BAC:  // 酒精数据
            
            if isReply && bleKeyFlag == .READ {
                
                let bacs: [BleBAC] = BleReadable.ofArray(data, BleBAC.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadBAC BAC -> bacs:\(bacs)")
                dataCount = bacs.count
                if mSupportFilterEmpty {
                    if !bacs.isEmpty {
                        notifyHandlers({ $0.onReadBAC?(bacs) })
                    }
                } else {
                    notifyHandlers({ $0.onReadBAC?(bacs) })
                }
            }
        case .BAC_SET:  // 酒精浓度检测设置
            break
            //if isReply && bleKeyFlag == .UPDATE {
            //
            //    let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
            //    #if DEBUG
            //    let cameraState = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
            //    bleLog("BleConnector handleData onCommandReply BAC_SET -> cameraState:\(cameraState)")
            //    #endif
            //    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, status) })
            //}
        case .BAC_RESULT:  // 酒精测试结果, 固件会主动发送
            
            if !isReply && bleKeyFlag == .UPDATE {
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                
                let bacs: [BleBAC] = BleReadable.ofArray(data, BleBAC.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onCameraResponse BAC_RESULT -> bacs:\(bacs)")
                
                notifyHandlers({ $0.onUpdateBAC?(bacs)})
            }
        case .AVG_HEART_RATE:
            if bleKeyFlag == .READ && isReply {
                
                let avgHeartRates: [BleAvgHeartRate] = BleReadable.ofArray(data, BleAvgHeartRate.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                
                bleLog("BleConnector handleData onReadAvgHeartRate -> \(avgHeartRates)")
                dataCount = avgHeartRates.count
                if mSupportFilterEmpty {
                    if !avgHeartRates.isEmpty {
                        notifyHandlers({ $0.onReadAvgHeartRate?(avgHeartRates) })
                    }
                } else {
                    notifyHandlers({ $0.onReadAvgHeartRate?(avgHeartRates) })
                }
            }
            
        case .LOVE_TAP:  // 发送LoveTap 消息
            if (!isReply) {
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                    return
                }
                
                _ = sendData(bleKey, bleKeyFlag, nil, true)
                let loveTap: BleLoveTap = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                
                bleLog("handleData onLoveTapUpdate -> \(loveTap)")
                notifyHandlers({$0.onLoveTapUpdate?(loveTap)})
            }
        case .LOVE_TAP_USER:  //LoveTap 联系人
            if isReply {
                if bleKeyFlag == .READ {
                    
                    let loveTapUsers: [BleLoveTapUser] = BleReadable.ofArray(data, BleLoveTapUser.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("handleData onReadLoveTapUser -> \(loveTapUsers)")
                        
                    //更加协议商定, 查的时候只支持查所有, 所以直接覆盖
                    BleCache.shared.putArray(bleKey, loveTapUsers)
                    notifyHandlers({$0.onReadLoveTapUser?(loveTapUsers)})
                }
            } else {
                if bleKeyFlag == .UPDATE {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    
                    let newLoveTapUser: BleLoveTapUser = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    
                    var loveTapUsers: [BleLoveTapUser] = BleCache.shared.getArray(bleKey)
                    if let index = loveTapUsers.firstIndex(where: { $0.mId == newLoveTapUser.mId }) {
                        loveTapUsers[index] = newLoveTapUser
                    }
                    
                    BleCache.shared.putArray(bleKey, loveTapUsers)
                    bleLog("handleData onLoveTapUserUpdate -> \(newLoveTapUser)")
                    notifyHandlers({$0.onLoveTapUserUpdate?(newLoveTapUser)})
                } else if bleKeyFlag == .DELETE {
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                        return
                    }
                    
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    
                    let id = data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 1)
                    var loveTapUsers: [BleLoveTapUser] = BleCache.shared.getArray(bleKey)
                    if id == ID_ALL {
                        loveTapUsers.removeAll()
                    } else {
                        if let index = loveTapUsers.firstIndex(where: { $0.mId == id }) {
                            loveTapUsers.remove(at: index)
                        }
                    }
                    
                    BleCache.shared.putArray(bleKey, loveTapUsers)
                    bleLog("handleData onLoveTapUserDelete -> \(id)")
                    notifyHandlers({$0.onLoveTapUserDelete?(id)})
                }
            }
            
        case .MEDICATION_REMINDER:  // 吃药提醒设置
            if isReply {
                if bleKeyFlag == .READ {
                    let medicationReminders: [BleMedicationReminder] = BleReadable.ofArray(data, BleMedicationReminder.ITEM_LENGTH, MessageFactory.LENGTH_BEFORE_DATA)
                    bleLog("handleData onReadMedicationReminder -> \(medicationReminders.count)")
                    
                    //更加协议商定, 查的时候只支持查所有, 所以直接覆盖
                    BleCache.shared.putArray(bleKey, medicationReminders)
                    notifyHandlers({$0.onReadMedicationReminder?(medicationReminders)})
                } else {
                    bleLog("BleConnector handleData MEDICATION_REMINDER onCommandReply -> \(bleKey), \(bleKeyFlag), true")
                    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true) })
                    return // 注意一定要return, 否则会执行2次rawValue方法
                }
            } else {
                if bleKeyFlag == .UPDATE {
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    
                    let newMedicationReminder: BleMedicationReminder = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                    
                    var medicationReminders: [BleMedicationReminder] = BleCache.shared.getArray(bleKey)
                    if let index = medicationReminders.firstIndex(where: { $0.mId == newMedicationReminder.mId }) {
                        medicationReminders[index] = newMedicationReminder
                    }
                    
                    BleCache.shared.putArray(bleKey, medicationReminders)
                    bleLog("handleData onMedicationReminderUpdate -> \(newMedicationReminder)")
                    notifyHandlers({$0.onMedicationReminderUpdate?(newMedicationReminder)})
                } else if bleKeyFlag == .DELETE {
                    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
                        return
                    }
                    
                    _ = sendData(bleKey, bleKeyFlag, nil, true)
                    
                    let id = data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 1)
                    var medicationReminders: [BleMedicationReminder] = BleCache.shared.getArray(bleKey)
                    if id == ID_ALL {
                        medicationReminders.removeAll()
                    } else {
                        if let index = medicationReminders.firstIndex(where: { $0.mId == id }) {
                            medicationReminders.remove(at: index)
                        }
                    }
                    
                    BleCache.shared.putArray(bleKey, medicationReminders)
                    bleLog("handleData onMedicationReminderDelete -> \(id)")
                    notifyHandlers({$0.onMedicationReminderDelete?(id)})
                }
            }
        case .HR_MONITORING:  // 定时心率设置

            if isReply && bleKeyFlag == .READ {
                
                let hrMonitoringSet: BleHrMonitoringSettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                bleLog("BleConnector handleData onReadHrMonitoringSettings -> \(hrMonitoringSet)")
                mBleCache.putObject(bleKey, hrMonitoringSet)
                
                // 设备返回当前 定时心率设置状态时触发。
                notifyHandlers({ $0.onReadHrMonitoringSettings?(hrMonitoringSet) })

            }
            //else if isReply && bleKeyFlag == .UPDATE {
            //
            //    if data.count <= MessageFactory.LENGTH_BEFORE_DATA {
            //        bleLog("BleConnector handleData HR_MONITORING error  data.count = \(data.count)")
            //        return
            //    }
            //
            //    let status = data[MessageFactory.LENGTH_BEFORE_DATA] == BLE_OK
            //    bleLog("nandleData onCommandReply -> bleKey:\(bleKey) bleKeyFlag:\(bleKeyFlag) status:\(status)")
            //    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, status) })
            //}
            
        case .UNIT_SETTIMG:  // 单位设置, 公制英制设置 0: 公制  1: 英制
            
            if isReply && bleKeyFlag == .READ {
                
                if (data.count < MessageFactory.LENGTH_BEFORE_DATA + 1) {
                    bleLog("READ 单位设置 返回的数据格式, 不合法")
                    break
                }
                
                let value = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
                bleLog("BleConnector handleData onReadUnit 单位设置 收到通知value:\(value)")
                mBleCache.putInt(bleKey, value)
                
                // 设备的单位设置
                notifyHandlers({ $0.onReadUnit?(value)})
            }
        case .PACKAGE_STATUS:  // 获取手表字库/UI/语言包状态信息
            if bleKeyFlag == .READ && isReply {
                
                let packageStatus: BlePackageStatus = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                
                bleLog("BleConnector handleData onReadPackageStatus -> \(packageStatus)")
                
                BleCache.shared.putObject(bleKey, packageStatus)
                notifyHandlers({ $0.onReadPackageStatus?(packageStatus) })
            }
        case .ALIPAY_SET:  // 支付宝版本信息
            if (isReply && bleKeyFlag == .READ) {
                
                let alipaySettings: BleAlipaySettings = BleReadable.ofObject(data, MessageFactory.LENGTH_BEFORE_DATA)
                
                bleLog("BleConnector handleData onReadAlipaySettings -> \(alipaySettings)")
                BleCache.shared.putObject(bleKey, alipaySettings)
                notifyHandlers({ $0.onReadAlipaySettings?(alipaySettings) })
            }
            //else if (isReply && bleKeyFlag == .UPDATE) {
            //    
            //    if data.count < MessageFactory.LENGTH_BEFORE_DATA + 1 {
            //        return
            //    }
            //    
            //    let status = Int(data[MessageFactory.LENGTH_BEFORE_DATA])
            //    
            //    bleLog("BleConnector handleData ALIPAY_SET status-> \(status)")
            //    notifyHandlers({ $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, status) })
            //}
        case .CALORIES_GOAL:
            if isReply && bleKeyFlag == .READ {
                
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 4 {
                    return
                }
                
                let calGoal = data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 4)
                bleLog("BleConnector handleData onReadCaloriesGoal -> \(calGoal)")
                
                notifyHandlers({ $0.onReadCaloriesGoal?(calGoal) })
            }
            
        case .DISTANCE_GOAL:
            if isReply && bleKeyFlag == .READ {
                
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 4 {
                    return
                }
                
                let disGoal = data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 4)
                bleLog("BleConnector handleData onReadDistanceGoal -> \(disGoal)")
                
                notifyHandlers({ $0.onReadDistanceGoal?(disGoal) })
            }
        case .SLEEP_GOAL:
            if isReply && bleKeyFlag == .READ {
                
                if data.count < MessageFactory.LENGTH_BEFORE_DATA + 2 {
                    return
                }
                
                let sleepGoal = data.getUInt(MessageFactory.LENGTH_BEFORE_DATA, 2)
                bleLog("BleConnector handleData onReadSleepGoal -> \(sleepGoal)")
                
                notifyHandlers({ $0.onReadSleepGoal?(sleepGoal) })
            }
            
            
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
            
            // 比赛记录一条数据比较大, 读一次只能返回一条
            let completedCount = (bleKey == BleKey.MATCH_RECORD2) ? 0:1
            if dataCount <= completedCount { // 该类型数据已同步完成
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
        } else if bleKeyFlag == .UPDATE {
            
            // 统一返回UPDATE指令状态, 之前调用这个方法的处理, 注释掉. 一些特殊处理需要调用onCommandReply的方法需要注意, 记得加上return
            // Uniformly return the status of the UPDATE command, before calling this method, comment it out. Some special processing needs to call the method of onCommandReply, you need to pay attention, remember to add return
            notifyHandlers({
                $0.onCommandReply?(bleKey.rawValue, bleKeyFlag.rawValue, true)
            })
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
            
            if let tempPer = self.mPeripheral {
                notifyHandlers({ $0.onDeviceConnected?(tempPer) })
            }
            mStreamProgressTotal = -1
            mStreamProgressCompleted = -1
        } else {
            bleLog("flage = 001, BleConnector onSessionStateChange -> false")
            mBleState = BleState.DISCONNECTED
            notifyHandlers({ $0.onSessionStateChange?(false) })
            if !mDataKeys.isEmpty {
                notifySyncState(SyncState.DISCONNECTED, mDataKeys[0])
                mDataKeys.removeAll()
                removeSyncTimeout()
            }
            if mBleStream != nil {
                bleLog("告知用户, 断开连接")
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

    // 这里发送绑定指令
    func didUpdateNotification(_ characteristicUuid: String) {
        mBleState = BleState.READY
        if let deviceInfo = mBleCache.mDeviceInfo {
            login(deviceInfo.mId)
        } else {
            bind()
        }
    }
}
