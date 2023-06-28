//
//  BleBloodOxygen.swift
//  SmartV3
//
//  Created by SMA on 2021/1/21.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class BleBloodOxygen: BleReadable {
    static let ITEM_LENGTH = 6
    
    var mTime: Int = 0 // 距离当地2000/1/1 00:00:00的秒数
    var mValue: Int = 0 //血氧值

    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mValue = Int(readUInt8())
       
    }

    override var description: String {
        "BleBloodOxygen(mTime: \(mTime), mValue:\(mValue))"
    }
    
    func toDictionary() -> [String:Any] {
        let dic = [
            "mTime":mTime,
            "mValue":mValue
        ]
        // [String : Any]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleBloodOxygen{

        let newModel = BleBloodOxygen()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mValue = dic["mValue"] as? Int ?? 0
        return newModel
    }
}
