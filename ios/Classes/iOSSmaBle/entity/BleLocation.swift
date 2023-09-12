//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleLocation: BleReadable {
    static let ITEM_LENGTH = 16

    var mTime: Int = 0 // 距离当地2000/1/1 00:00:00的秒数
    var mActivityMode: Int = 0
    var mAltitude: Int = 0 // m
    var mLongitude: Float = 0.0
    var mLatitude: Float = 0.0

    override func decode() {
        super.decode()
        mTime = Int(readInt32())
        mActivityMode = Int(readUInt8())
        skip(8)
        mAltitude = Int(readInt16())
        mLongitude = readFloat()
        mLatitude = readFloat()
    }

    override var description: String {
        "BleLocation(mTime: \(mTime), mActivityMode: \(mActivityMode), mAltitude: \(mAltitude), mLongitude: \(mLongitude), mLatitude: \(mLatitude))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":mTime,
                                    "mActivityMode":mActivityMode,
                                    "mAltitude":mAltitude,
                                    "mLongitude":mLongitude,
                                    "mLatitude":mLatitude]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleLocation{

        let newModel = BleLocation()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mActivityMode = dic["mActivityMode"] as? Int ?? 0
        newModel.mAltitude = dic["mAltitude"] as? Int ?? 0
        newModel.mLongitude = dic["mLongitude"] as? Float ?? 0
        newModel.mLatitude = dic["mLatitude"] as? Float ?? 0
        return newModel
    }
}
