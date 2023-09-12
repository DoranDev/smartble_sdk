//
//  BleScanDelegate.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/16.
//  Copyright © 2019 szabh. All rights reserved.
//

import Foundation

protocol BleScanDelegate {

    // 当开启扫描时，如果蓝牙不为CBManagerState.poweredOn，会触发该方法
    // 注意：当蓝牙状态切换成poweredOff时并不会触发该方法
    func onBluetoothDisabled()

    // 当蓝牙状态切换成poweredOn时触发
    func onBluetoothEnabled()

    // 扫描开启或停止时触发
    func onScan(_ scan: Bool)

    // 扫描到设备时触发
    func onDeviceFound(_ bleDevice: BleDevice)
}
