//
//  BleDevice.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/17.
//  Copyright © 2019 szabh. All rights reserved.
//

import CoreBluetooth

class BleDevice: NSObject {
    var mPeripheral: CBPeripheral
    var mAdvertisementData: [String: Any]
    var mRssi: Int

    var name: String {
        mPeripheral.name ?? ""
    }

    var identifier: String {
        mPeripheral.identifier.uuidString
    }

    var address: String {
        //解析mac地址
        if let manufactureData = mAdvertisementData["kCBAdvDataManufacturerData"] {
            let data: Data = manufactureData as! Data
            if data.count > 15{
                //杰里广播mac地址
                if data[14] == 0x43 && data[15] == 0x44{
                    return String(format: "%02X:%02X:%02X:%02X:%02X:%02X",
                        data[16], data[17], data[18], data[19], data[20], data[21])
                }
            }
            if data.count >= 8 {
                return String(format: "%02X:%02X:%02X:%02X:%02X:%02X",
                    data[2], data[3], data[4], data[5], data[6], data[7])
            }
        }

        return identifier
    }

    init(_ peripheral: CBPeripheral, _ advertisementData: [String: Any], _ RSSI: NSNumber) {
        mPeripheral = peripheral
        mAdvertisementData = advertisementData
        mRssi = RSSI.intValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if object == nil || !(object! is BleDevice) {
            return false
        }

        return identifier == (object as! BleDevice).identifier
    }

    override var description: String {
        "BleDevice(name: \(name), identifier: \(identifier), address:\(address), mRssi: \(mRssi)), mAdvertisementData: \(mAdvertisementData))"
    }
    
    
    // 这个是之前的方法, 注意返回的 mAddress 值
    //func toDictionary()->[String:Any]{
    //    let dic : [String : Any] = [
    //        "mName":name,
    //        "mAddress":identifier,
    //        "mRssi":mRssi,
    //        "mMac":self.address
    //    ]
    //    return dic
    //}
    /// 返回JSON数据, 这里一定需要注意mAddress 有些客户是根据mac地址连接, 有些客户要求使用uuid连接, 这里需要作区分返回不同的数据
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = [
            "mName":name,
            "mAddress":self.address,  // 千万注意这个数据值
            "identifier":identifier,
            "mRssi":mRssi
        ]
        return dic
    }
}
