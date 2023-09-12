//
// Created by Best Mafen on 2019/9/19.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 简化和转发CBPeripheralDelegate的回调。
 */
protocol BleConnectorDelegate {

    // 连接状态改变
    func didConnectionChange(_ connected: Bool)
    
    // 正在连接状态改变
    func didConnectingChange(_ connected: Bool)

    // Read
    func didCharacteristicRead(_ characteristicUuid: String, _ data: Data, _ text: String)

    // Write
    func didCharacteristicWrite(_ characteristicUuid: String)

    // Change
    func didCharacteristicChange(_ characteristicUuid: String, _ data: Data)

    // Notify
    func didUpdateNotification(_ characteristicUuid: String)
}
