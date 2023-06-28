//
// Created by Best Mafen on 2019/9/18.
// Copyright (c) 2019 szabh. All rights reserved.
//

import UIKit
import CoreBluetooth

/// 连接类型, 因为客户有些是扫码链接, 有些客户是UUID连接, 这两个方式需要处理的方式不一样
/// 如果是mac连接, 需要比对参照广播的自定义数据
/// 如果是UUID连接, 那就是外设的UUID比对即可
enum BleConnectorType {
    case macAddress     // 通过MAC地址方式比对设备
    case systemUUID     // 通过UUID地址方式比对设备
}

/**
 * CBPeripheral的包装类，代表与一个蓝牙设备的连接。
 * 1.在指定连接目标后会一直重连，直到连接成功。
 * 2.重连时会先查找系统已连接的设备，如果未找到，则扫描附近的设备。
 * 3.当检测到手机蓝牙开启时，如果之前有指定连接目标，会重新进行连接。
 * 4.连接成功后自动执行发现服务、开启通知和设置MTU。
 */
class BaseBleConnector: NSObject {
    static let RECONNECTION_PERIOD = 40.0 // 重连间隔（单位：秒）
    static let DELAY_CONNECT = 4.0 // 蓝牙开启时连接的延时时间（单位：秒）

    var mPeripheral: CBPeripheral? // 连接的外围设备

    var mTargetIdentifier: String? // 外围设备的identifier
    var mBleConnectorDelegate: BleConnectorDelegate!
    var mReconnectTimer: Timer?
    var mDelayConnectTimer: Timer? // 蓝牙打开后，延时连接的定时器

    /**
     * 因为重连时如果在系统已连接的设备未查找到目标设备，需要扫描附近设备，所以声明一个扫描器对象。
     */
    var mBleScanner = BleScanner()

    /**
     * 用于指定匹配规则为设备的地址是mTargetIdentifier。
     */
    let mScanFilter = IdentifierFilter("", .systemUUID)

    /**
     * 是否正在进行连接。
     */
    var isConnecting = false {
        didSet {
            mBleConnectorDelegate.didConnectingChange(isConnecting)
        }
    }

    /**
    * 是否已连接。
    */
    var isConnected = false

    /**
     * 服务的UUID
     */
    var mServiceUuid = ""

    /**
     * 通知的UUID
     */
    var mNotifyUuid = ""
    var mBaseBleMessenger: BaseBleMessenger! = nil
    var mBleParserDelegate: BleParserDelegate! = nil

    init(_ serviceUuid: String, _ notifyUuid: String, _ baseBleMessenger: BaseBleMessenger,
         _ bleParserDelegate: BleParserDelegate) {
        super.init()
        mBleScanner.mCentralManagerDelegate = self

        mServiceUuid = serviceUuid
        mNotifyUuid = notifyUuid
        mBaseBleMessenger = baseBleMessenger
        mBaseBleMessenger.setTargetConnector(self)
        mBleParserDelegate = bleParserDelegate

        mBleScanner.mScanDuration = BaseBleConnector.RECONNECTION_PERIOD / 2.0
        mBleScanner.mBleScanFilter = self.mScanFilter
        mBleScanner.mBleScanDelegate = self
    }

    // MARK: - Public Method
    /**
     * 设置连接目标。
     */
    func setTargetIdentifier(_ identifier: String, _ mConnecType: BleConnectorType) {
        mTargetIdentifier = identifier
        mScanFilter.mIdentifier = identifier
        mScanFilter.mConnecType = mConnecType
    }

    /**
     * 设置连接目标。
     */
    //func setTargetDevice(_ bleDevice: BleDevice, _ mConnecType: BleConnectorType = .systemUUID) {
    func setTargetDevice(_ bleDevice: BleDevice, _ mConnecType: BleConnectorType) {
        setTargetIdentifier(bleDevice.mPeripheral.identifier.uuidString, mConnecType)
    }
    
    /**
     * 通过mac方式, 设置连接目标
     */
    /// 通过mac方式, 设置连接目标
    func setTargetDevice(_ macAddrress: String, _ mConnecType: BleConnectorType) {
        setTargetIdentifier(macAddrress, BleConnectorType.macAddress)
    }


    /**
     * 开始或停止连接。
     */
    func connect(_ connect: Bool) {
        bleLog("BaseBleConnector connect \(connect) -> isConnecting=\(isConnecting)")
        if isConnecting == connect {
            return
        }

        isConnecting = connect
        if connect {
            if mPeripheral != nil {
                mBleScanner.mCentralManager.cancelPeripheralConnection(mPeripheral!)
                mPeripheral = nil
            }
            if !shouldConnect() {
                isConnecting = false
                return
            }

            mReconnectTimer = Timer.scheduledTimer(withTimeInterval: BaseBleConnector.RECONNECTION_PERIOD,
                repeats: true, block: { _ in
                let connectedPeripherals = self.mBleScanner.mCentralManager.retrieveConnectedPeripherals(
                    withServices: [CBUUID(string: self.mServiceUuid)])
//                bleLog("BaseBleConnector connectedPeripherals=\(connectedPeripherals)")
                for peripheral in connectedPeripherals {
                    if peripheral.identifier.uuidString == self.mTargetIdentifier {
                        bleLog("BaseBleConnector connect directly")
                        self.connect(peripheral)
                        return
                    }
                }

                bleLog("BaseBleConnector connect scan")
                self.mBleScanner.scan(true)
            })
            mReconnectTimer?.fire()
        } else {
            mBleScanner.scan(false)
            self.mReconnectTimer?.invalidate()
            self.mReconnectTimer = nil
            cancelDelayConnect()
        }
    }

    /**
     * 关闭当前连接。
     * @param stopReconnecting 是否停止重连
     */
    func closeConnection(_ stopReconnecting: Bool) {
        bleLog("BaseBleConnector closeConnection -> stopReconnecting=\(stopReconnecting)")
        mBaseBleMessenger.reset()
        mBleParserDelegate.reset()
        cancelDelayConnect();
        if isConnected {
            if stopReconnecting {
                mBleConnectorDelegate.didConnectionChange(false)
            }
            isConnected = false
        }
        if mPeripheral != nil {
            mBleScanner.mCentralManager.cancelPeripheralConnection(mPeripheral!)
        }

        if stopReconnecting {
            mTargetIdentifier = nil
            connect(false)
        }
    }

    /**
     * 根据服务的UUID和特征的UUID获取CBCharacteristic。
     */
    func getCharacteristic(_ serviceUuid: String, _ characteristicUuid: String) -> CBCharacteristic? {
        if mPeripheral == nil {
            return nil
        }

        let service = mPeripheral?.services?.first(where: { $0.uuid.uuidString == serviceUuid })
        return service?.characteristics?.first(where: { $0.uuid.uuidString == characteristicUuid })
    }

    // MARK: - Private Method
    private func connect(_ peripheral: CBPeripheral) {
        mPeripheral = peripheral
        mPeripheral?.delegate = self
        mBleScanner.mCentralManager.connect(mPeripheral!)
    }

    /**
     取消蓝牙打开时的延时连接
     */
    private func cancelDelayConnect() {
        mDelayConnectTimer?.invalidate()
        mDelayConnectTimer = nil
    }

    /**
     * 是否有必要进行连接，只有在手机蓝牙已开启，并且已指定连接目标时才需要发起连接操作。
     */
    private func shouldConnect() -> Bool {
        mBleScanner.mCentralManager.state == .poweredOn && mTargetIdentifier != nil
    }
}

extension BaseBleConnector: CBCentralManagerDelegate {

    /**
     * 监听手机蓝牙的状态。
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if mTargetIdentifier == nil {
            return
        }

        if mBleScanner.mCentralManager.state == .poweredOn { // 当手机蓝牙开启时，如果已指定连接目标，重新进行连接。
            mDelayConnectTimer = Timer.scheduledTimer(withTimeInterval: BaseBleConnector.DELAY_CONNECT,
                repeats: false, block: { _ in
                self.connect(true)
            })
        } else {
            cancelDelayConnect()
            if central.state == .poweredOff { // 当手机蓝牙关闭时，并且设备已连接，触发连接断开的代理回调
                if isConnected {
                    mBleConnectorDelegate.didConnectionChange(false)
                    isConnected = false
                }
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        bleLog("BaseBleConnector didConnect -> peripheral=\(peripheral)")
        isConnected = true
        mBaseBleMessenger.reset()
        mBleParserDelegate.reset()
        peripheral.discoverServices(nil)
        connect(false)
        mBleConnectorDelegate.didConnectionChange(true)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        bleLog("BaseBleConnector didFailToConnect -> peripheral=\(peripheral), error:\(String(describing: error))")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        bleLog("BaseBleConnector -> didDisconnectPeripheral, error:\(String(describing: error))")
        mPeripheral = nil
        mBaseBleMessenger.reset()
        mBleParserDelegate.reset()
        connect(true)
        if isConnected {
            mBleConnectorDelegate.didConnectionChange(false)
            isConnected = false
        }
    }
}

extension BaseBleConnector: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        bleLog("BaseBleConnector -> didDiscoverServices")
        peripheral.services?.forEach({
            peripheral.discoverCharacteristics(nil, for: $0)
        })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        bleLog("BaseBleConnector -> didDiscoverCharacteristics, service=\(service.uuid.uuidString)")
        if service.uuid.uuidString == mServiceUuid {
            mBaseBleMessenger.enqueueMessage(NotifyMessage(mServiceUuid, mNotifyUuid, true))
            // withResponse为512
            // withoutResponse为20
            let maximumWriteValueLength = peripheral.maximumWriteValueLength(for: .withoutResponse)
            bleLog("BaseBleConnector -> maximumWriteValueLength for withoutResponse: \(maximumWriteValueLength)")
            mBaseBleMessenger.mPacketSize = maximumWriteValueLength
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        bleLog("BaseBleConnector didUpdateNotificationStateFor -> \(characteristic.uuid.uuidString) error:\(String(describing: error))")
        mBaseBleMessenger.dequeueMessage()
        mBleConnectorDelegate.didUpdateNotification(characteristic.uuid.uuidString)
    }

    // Read, Change
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == mNotifyUuid { // onChange
            if let value = characteristic.value {
                #if DEBUG
                bleLog("BaseBleConnector didCharacteristicChange -> \(characteristic.uuid.uuidString)"
                       + ", \(value.mHexString), error:\(String(describing: error))")
                #else
                /**
                 压缩log写入text日志，中间件升级UI包写入100M日志
                 */
                if value.mHexString.count < 150 {
                    bleLog("BaseBleConnector didCharacteristicChange -> \(characteristic.uuid.uuidString)"
                           + ", data=\(value.mHexString)")
                } else if value.count < 80 {
                    // 为了方便知道哪个数据错误, 打印下日志
                    bleLog("BaseBleConnector didCharacteristicChange -> uuidString:\(characteristic.uuid.uuidString)")
                    bleLog("BaseBleConnector didCharacteristicChange -> data=\(value.mHexString)")
                } else {
                    bleLog("BaseBleConnector didCharacteristicChange -> \(characteristic.uuid.uuidString)"
                        + ", dataCount=\(value.mHexString.count)")
                }
                #endif
                if let data = mBleParserDelegate.onReceive(value) {
                    mBleConnectorDelegate.didCharacteristicChange(characteristic.uuid.uuidString, data)
                }
            }
        } else { // onRead
            mBaseBleMessenger.dequeueMessage()
            if let data = characteristic.value {
                let text = String(data: data, encoding: .utf8) ?? ""

                #if DEBUG
                bleLog("BaseBleConnector didCharacteristicRead -> \(characteristic.uuid.uuidString)"
                    + ", data=\(data.mHexString), text=\(text)")
                #else
                if data.mHexString.count < 150 {
                    bleLog("BaseBleConnector didCharacteristicRead -> \(characteristic.uuid.uuidString)"
                        + ", data=\(data.mHexString), text=\(text)")
                } else {
                    bleLog("BaseBleConnector didCharacteristicRead -> \(characteristic.uuid.uuidString)"
                        + ", dataCount=\(data.mHexString.count), text=\(text)")
                }
                #endif
                mBleConnectorDelegate.didCharacteristicRead(characteristic.uuid.uuidString, data, text)
            }
        }
    }

    // onWrite
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        bleLog("BaseBleConnector didCharacteristicWrite -> \(characteristic.uuid.uuidString)"
            + ", \(error?.localizedDescription ?? "OK")")
        mBaseBleMessenger.dequeueWritePacket()
        mBleConnectorDelegate.didCharacteristicWrite(characteristic.uuid.uuidString)
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        bleLog("BaseBleConnector peripheralIsReady")
        self.mBaseBleMessenger.dequeueWritePacket()
    }
}

extension BaseBleConnector: BleScanDelegate {

    func onBluetoothDisabled() {
    }

    func onBluetoothEnabled() {
    }

    func onScan(_ scan: Bool) {
    }

    func onDeviceFound(_ device: BleDevice) {
        
        // 在iOS中, 最终都是使用UUID来连接设备的,
        // 如果外界传入的是mac地址, 在连接时候, 需要更改下我们这里的配置,
        // 更改为UUID连接, 目的就是为了下次重连设备, 否则已经绑定配对了设备, 再次使用mac地址连接, 那就连接不上的
        if mScanFilter.mConnecType == .macAddress {
            let uuid = device.mPeripheral.identifier.uuidString
            setTargetIdentifier(uuid, .systemUUID)
        }
        
        mBleScanner.scan(false)
        connect(device.mPeripheral)
    }
}
