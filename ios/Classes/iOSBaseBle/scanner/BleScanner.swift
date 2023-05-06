//
//  BleScanner.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/17.
//  Copyright © 2019 szabh. All rights reserved.
//

import UIKit
import CoreBluetooth
import os.log

let SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"

class BleScanner: NSObject, CBCentralManagerDelegate {
    static let DEFAULT_DURATION = 10.0 // 秒

    var mServiceUuids: [CBUUID]? = nil // 扫描时指定的服务

    var mCentralManager: CBCentralManager! = nil
    var mCentralManagerDelegate: CBCentralManagerDelegate? = nil
    var isScanning = false // 当前是否正在扫描

    // 扫描持续时间（单位：秒），到期后扫描会自动停止，并触发BleScanDelegate.onScan(false)
    var mScanDuration = DEFAULT_DURATION

    var mStopScanTimer: Timer? = nil // 扫描开启后，到期时自动停止的定时器

    var mBleScanDelegate: BleScanDelegate? = nil // 扫描事件回调
    var mBleScanFilter: BleScanFilter? = nil // 扫描过滤器

    init(_ serviceUuids: [CBUUID]? = nil) {
        super.init()
        mCentralManager = CBCentralManager.init(delegate: self, queue: nil)
        mServiceUuids = serviceUuids
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleLog("BleScanner(\(mIdentifier) centralManagerDidUpdateState -> state=\(central.state.mDescription)")
        if central.state == .poweredOn {
            mBleScanDelegate?.onBluetoothEnabled()
        }else if central.state == .unauthorized{
            bleLog("Bluetooth authorization is not turned on")
        }
        mCentralManagerDelegate?.centralManagerDidUpdateState(central)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
//        bleLog("BleScanner(\(mIdentifier)) didDiscover -> \(peripheral)")
        let bleDevice = BleDevice(peripheral, advertisementData, RSSI)
        if RSSI != 127 && (mBleScanFilter == nil || mBleScanFilter!.match(bleDevice)) {
            bleLog("BleScanner(\(mIdentifier)) onDeviceFound -> \(bleDevice))")
            mBleScanDelegate?.onDeviceFound(bleDevice)
        }
        mCentralManagerDelegate?.centralManager?(central, didDiscover: peripheral, advertisementData: advertisementData,
            rssi: RSSI)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        mCentralManagerDelegate?.centralManager?(central, didConnect: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        mCentralManagerDelegate?.centralManager?(central, didFailToConnect: peripheral, error: error)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        mCentralManagerDelegate?.centralManager?(central, didDisconnectPeripheral: peripheral, error: error)
    }

    // MARK: - Public Method
    func scan(_ scan: Bool) {
        bleLog("BleScanner(\(mIdentifier)) scan \(scan) -> isScanning=\(isScanning), state=\(mCentralManager.state.mDescription)")
        if isScanning == scan {
            return
        }

        if scan {
            if mCentralManager.state != .poweredOn {
                mBleScanDelegate?.onBluetoothDisabled()
                return
            }

            mCentralManager.scanForPeripherals(withServices: mServiceUuids, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            stopScanDelay()
        } else {
            mCentralManager.stopScan()
            removeStop()
        }
        isScanning = scan
        mBleScanDelegate?.onScan(isScanning)
    }

    func exit() {
        scan(false)
        mBleScanDelegate = nil
    }

    // MARK: - Private Method
    private func stopScanDelay() {
        bleLog("BleScanner(\(mIdentifier)) -> stopScanDelay")
        mStopScanTimer = Timer.scheduledTimer(withTimeInterval: mScanDuration, repeats: false, block: { _ in
            self.scan(false)
        })
    }

    private func removeStop() {
        bleLog("BleScanner(\(mIdentifier)) -> removeStop")
        mStopScanTimer?.invalidate()
        mStopScanTimer = nil
    }

    func getConnectedDevices() -> [BleDevice] {
        var devices = [BleDevice]()
        let connectedPeripherals = mCentralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: SERVICE_UUID)])
        for peripheral in connectedPeripherals {
            devices.append(BleDevice(peripheral, ["": ""], -10))
        }
        return devices
    }
}
