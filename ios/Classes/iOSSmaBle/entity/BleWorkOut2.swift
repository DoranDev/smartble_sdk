//
//  BleWorkOut2.swift
//  SmartV3
//
//  Created by SMA on 2021/10/15.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation
//汇总式的锻炼数据
class BleWorkOut2:  BleReadable{
    static let ITEM_LENGTH = 128

    var startTime = 0 // 距离当地2000/1/1 00:00:00的秒数
    var endTime   = 0 // 距离当地2000/1/1 00:00:00的秒数
    var mDuration  = 0 // 运动持续时长，数据以秒为单位
    var mAltitude  = 0 // 海拔高度，数据以米为单位
    var mAirPressure = 0 // 气压，数据以 kPa 为单位
    var mSmp = 0  //平均步频
    var mModeSport = 0 //运动类型，与 BleActivity 中的 mMode 定义一致
    var mStep = 0      //步数，与 BleActivity 中的 mStep 定义一致
    var mDistance = 0 //米，以米为单位，例如接收到的数据为56045，则代表 56045 米 约等于 56.045 Km
    var mCalories = 0 //卡，以卡为单位，例如接收到的数据为56045，则代表 56.045 Kcal 约等于 56 Kcal
    var mSpeed = 0    //速度，接收到的数据以 米/小时 为单位
    var mPace = 0  //平均配速，接收到的数据以 秒/千米 为单位
    var mAvgBpm = 0  //平均心率
    var mMaxBpm = 0  //最大心率
    var mMinBpm = 0  //最小心率
    var mUndefined = 0 //占位符,字节对齐预留
    var mMaxSpm = 0 //最大步频
    var mMinSpm = 0 //最小步频
    var mMaxPace = 0 //最大配速
    var mMinPace = 0 //最小配速


    override func decode() {
        super.decode()
        startTime    = Int(readInt32())
        endTime      = Int(readInt32())
        mDuration    = Int(readUInt16())
        mAltitude    = Int(readInt16())
        mAirPressure = Int(readUInt16())
        mSmp         = Int(readUInt8())
        mModeSport   = Int(readUInt8())
        mStep        = Int(readInt32())
        mDistance    = Int(readInt32())
        mCalories    = Int(readInt32())
        mSpeed       = Int(readInt32())
        mPace        = Int(readInt32())
        mAvgBpm      = Int(readUInt8())
        mMaxBpm      = Int(readUInt8())
        mMinBpm      = Int(readUInt8())
        mUndefined   = Int(readUInt8())
        mMaxSpm      = Int(readUInt16())
        mMinSpm      = Int(readUInt16())
        mMaxPace     = Int(readUInt32())
        mMinPace     = Int(readUInt32())
    }

    override var description: String {
        "BleWorkOut2(startTime: \(startTime), endTime: \(endTime), mDuration: \(mDuration)," +
            " mAltitude: \(mAltitude), mAirPressure: \(mAirPressure), mSmp: \(mSmp), mModeSport: \(mModeSport)," +
            " mStep: \(mStep), mDistance: \(mDistance), mCalories: \(mCalories), mSpeed: \(mSpeed)," +
            " mPace: \(mPace), mAvgBpm: \(mAvgBpm), mMaxBpm: \(mMaxBpm)), mMinBpm:\(mMinBpm)" +
            " mMaxSpm: \(mMaxSpm), mMinSpm: \(mMinSpm), mMaxPace: \(mMaxPace)), mMinPace:\(mMinPace)"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["startTime":startTime,
                                    "endTime":endTime,
                                    "mDuration":mDuration,
                                    "mAltitude":mAltitude,
                                    "mSmp":mSmp,
                                    "mModeSport":mModeSport,
                                    "mStep":mStep,
                                    "mDistance":mDistance,
                                    "mCalories":mCalories,
                                    "mSpeed":mSpeed,
                                    "mPace":mPace,
                                    "mAvgBpm":mAvgBpm,
                                    "mMaxBpm":mMaxBpm,
                                    "mMinBpm":mMinBpm,
                                    "mMaxSpm":mMaxSpm,
                                    "mMinSpm":mMinSpm,
                                    "mMaxPace":mMaxPace,
                                    "mMinPace":mMinPace]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleWorkOut2{
        let newModel = BleWorkOut2()
        if dic.keys.count<1{
            return newModel
        }
        newModel.startTime = dic["startTime"] as? Int ?? 0
        newModel.endTime = dic["endTime"] as? Int ?? 0
        newModel.mDuration = dic["mDuration"] as? Int ?? 0
        newModel.mAltitude = dic["mAltitude"] as? Int ?? 0
        newModel.mSmp = dic["mSmp"] as? Int ?? 0
        newModel.mModeSport = dic["mModeSport"] as? Int ?? 0
        newModel.mDistance = dic["mDistance"] as? Int ?? 0
        newModel.mCalories = dic["mCalories"] as? Int ?? 0
        newModel.mSpeed = dic["mSpeed"] as? Int ?? 0
        newModel.mPace = dic["mPace"] as? Int ?? 0
        newModel.mAvgBpm = dic["mAvgBpm"] as? Int ?? 0
        newModel.mMaxBpm = dic["mMaxBpm"] as? Int ?? 0
        newModel.mMinBpm = dic["mMinBpm"] as? Int ?? 0
        newModel.mMaxSpm = dic["mMaxSpm"] as? Int ?? 0
        newModel.mMinSpm = dic["mMinSpm"] as? Int ?? 0
        newModel.mMaxPace = dic["mMaxPace"] as? Int ?? 0
        newModel.mMinPace = dic["mMinPace"] as? Int ?? 0
        return newModel
    }
}
