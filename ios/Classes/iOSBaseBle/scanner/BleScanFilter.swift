//
//  BleScanFilter.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/16.
//  Copyright © 2019 szabh. All rights reserved.
//

import Foundation

// 用来过滤扫描结果
protocol BleScanFilter {

    // true -> 会被添加到扫描结果，即会触发BleScanDelegate.onDeviceFound
    // false -> 不会添加到扫描结果，即不会触发BleScanDelegate.onDeviceFound
    func match(_ bleDevice: BleDevice) -> Bool
}

// 根据设备identifier来过滤扫描结果, 不区分大小写
class IdentifierFilter: BleScanFilter {
    
    var mIdentifier: String
    var mConnecType = BleConnectorType.systemUUID
    
    init(_ identifier: String, _ mConnecType: BleConnectorType) {
        self.mIdentifier = identifier
        self.mConnecType = mConnecType
    }

    func match(_ bleDevice: BleDevice) -> Bool {
        if self.mConnecType == .systemUUID {
            return mIdentifier.compare(bleDevice.mPeripheral.identifier.uuidString, options: .caseInsensitive) == .orderedSame
        } else {
            return mIdentifier.compare(bleDevice.address, options: .caseInsensitive) == .orderedSame
        }
    }
}
