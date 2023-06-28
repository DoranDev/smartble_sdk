//
//  BleBloodGlucose.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/11/11.
//  Copyright © 2022 KingHuang. All rights reserved.
//

import UIKit

/// 血糖
class BleBloodGlucose: BleReadable {

    static let ITEM_LENGTH = 6
    
    /// 距离当地2000/1/1 00:00:00 的秒数
    var mTime: Int = 0
    /// 0.1  mmol/L
    var mValue: Int = 0
    
    override func decode() {
        super.decode()
        
        mTime = Int(readInt32())
        mValue = Int(readInt16())
    }
    
    override var description: String {
        "BleBloodGlucose(mTime: \(mTime), mValue: \(mValue))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":mTime,
                                    "mValue":mValue]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) -> BleBloodGlucose{
        let newModel = BleBloodGlucose()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mValue = dic["mValue"] as? Int ?? 0
        return newModel
    }
}
