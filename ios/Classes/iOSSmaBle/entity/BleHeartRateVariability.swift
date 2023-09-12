//
//  BleHeartRateVariability.swift
//  SmartV3
//
//  Created by SMA on 2021/1/21.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class BleHeartRateVariability: BleReadable {
    static let ITEM_LENGTH = 6
    
    var mTime: Int = 0 // 距离当地2000/1/1 00:00:00的秒数
    var mHRVValue: Int = 0 //最近一次测量hrv值
    var mAvgHRVValue: Int = 0
    
    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mHRVValue = Int(readUInt8())
        mAvgHRVValue = Int(readUInt8())
       
    }

    override var description: String {
        "BleHeartRateVariability(mTime: \(mTime), mHRVValue: \(mHRVValue), mAvgHRVValue: \(mAvgHRVValue))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":mTime,
                                    "mHRVValue":mHRVValue,
                                    "mAvgHRVValue":mAvgHRVValue]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleHeartRateVariability{

        let newModel = BleHeartRateVariability()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mHRVValue = dic["mHRVValue"] as? Int ?? 0
        newModel.mAvgHRVValue = dic["mAvgHRVValue"] as? Int ?? 0
        return newModel
    }
}
