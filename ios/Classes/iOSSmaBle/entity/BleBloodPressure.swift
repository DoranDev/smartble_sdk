//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleBloodPressure: BleReadable {
    static let ITEM_LENGTH = 6

    var mTime: Int = 0 // 距离当地2000/1/1 00:00:00的秒数
    var mSystolic: Int = 0
    var mDiastolic: Int = 0

    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mSystolic = Int(readUInt8())
        mDiastolic = Int(readUInt8())
    }

    override var description: String {
        "BleBloodPressure(mTime: \(mTime), mSystolic: \(mSystolic), mDiastolic: \(mDiastolic))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":mTime,
                                    "mSystolic":mSystolic,
                                    "mDiastolic":mDiastolic]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleBloodPressure{

        let newModel = BleBloodPressure()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mSystolic = dic["mSystolic"] as? Int ?? 0
        newModel.mDiastolic = dic["mDiastolic"] as? Int ?? 0
        return newModel
    }
}
