//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleTemperature: BleReadable {
    static let ITEM_LENGTH = 6

    var mTime: Int = 0 // 距离当地2000/1/1 00:00:00的秒数
    var mTemperature: Int = 0 // 0.1摄氏度

    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mTemperature = Int(readInt16())
    }

    override var description: String {
        "BleTemperature(mTime: \(mTime), mTemperature: \(mTemperature))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":mTime,
                                    "mTemperature":mTemperature]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleTemperature{
        let newModel = BleTemperature()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mTemperature = dic["mTemperature"] as? Int ?? 0
        return newModel
    }
}
