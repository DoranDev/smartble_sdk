//
//  BleMedicationReminder.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/12/1.
//  Copyright © 2022 CodingIOT. All rights reserved.
//

import UIKit

/// 吃药提醒 类型, 片剂, 胶囊, 滴
enum BleMedicationType: Int {
    /// 片剂 tablet
    case TYPE_TABLET = 0
    /// 胶囊 capsule
    case TYPE_CAPSULE = 1
    /// 滴 drops
    case TYPE_DROPS = 2
    /// Cream
    case TYPE_CREAM = 3
    /// Spray
    case TYPE_SPRAY = 4
    /// Solution
    case TYPE_SOLUTION = 5
    /// Injectable
    case TYPE_INJECTABLE = 6
}

/// 吃药提醒 单位, 片剂, 胶囊, 滴
enum BleMedicationUNIT: Int {
    /// 毫克 milligram
    case UNIT_MILLIGRAM = 0
    /// 微克 microgram
    case UNIT_MICROGRAM = 1
    /// 克 gram
    case UNIT_GRAM = 2
    /// 毫升 milliliter
    case UNIT_MILLILITER = 3
    /// 百分比 percentage
    case UNIT_PERCENTAGE = 4
    /// 片 piece
    case UNIT_PIECE = 5
    /// 国际单位 international
    case UNIT_INTERNATIONAL = 6
    /// 毫居里 millicurie
    case UNIT_MILLICURIE = 7
    /// 毫当量 milliequivalent
    case UNIT_MILLIEQUIVALENT = 8
}


/// 吃药提醒
class BleMedicationReminder: BleIdObject {
    
    var mType: Int = 0 //药物类型, 取值参考 BleMedicationType 枚举
    var mUnit: Int = 0 //药物单位，片、粒等 取值参考 BleMedicationUNIT 枚举
    var mDosage: Int = 0 //药物剂量根据药物单位来定
    var mRepeat: Int = 0 //重复提醒位Bit 0:6分别代表周一到周日
    var mRemindTimes: Int = 0//提醒的次数
    var mRemindTime1: BleHmTime = BleHmTime()//第1次提醒时间
    var mRemindTime2: BleHmTime = BleHmTime()//第2次提醒时间
    var mRemindTime3: BleHmTime = BleHmTime()//第3次提醒时间
    var mRemindTime4: BleHmTime = BleHmTime()//第4次提醒时间
    var mRemindTime5: BleHmTime = BleHmTime()//第5次提醒时间
    var mRemindTime6: BleHmTime = BleHmTime()//第6次提醒时间
    var mStartYear: Int = 0 //提醒开始日期
    var mStartMonth: Int = 0
    var mStartDay: Int = 0
    var mEndYear: Int = 0 //结束开始日期
    var mEndMonth: Int = 0
    var mEndDay: Int = 0
    var mName: String = "" //药物名称，UTF-8编码
    var mLabel: String = "" //药物说明标签(UTF8编码)
    
    
    private static let NAME_LENGTH = 24
    private static let LABLE_LENGTH = 21
    static var ITEM_LENGTH: Int {
        get {
            return 27 + BleMedicationReminder.NAME_LENGTH + BleMedicationReminder.LABLE_LENGTH
        }
    }
    
     
    override var mLengthToWrite: Int {
        return BleMedicationReminder.ITEM_LENGTH
    }
    
    override func encode() {
        super.encode()

        writeInt8(mId)
        writeInt8(mType)
        writeInt8(mUnit)
        writeInt32(mDosage, ByteOrder.LITTLE_ENDIAN)
        writeInt8(mRepeat)
        writeInt8(mRemindTimes)
        writeObject(mRemindTime1)
        writeObject(mRemindTime2)
        writeObject(mRemindTime3)
        writeObject(mRemindTime4)
        writeObject(mRemindTime5)
        writeObject(mRemindTime6)
        writeInt8(mStartYear - 2000)
        writeInt8(mStartMonth)
        writeInt8(mStartDay)
        writeInt8(mEndYear - 2000)
        writeInt8(mEndMonth)
        writeInt8(mEndDay)
        writeStringWithFix(mName, BleMedicationReminder.NAME_LENGTH)
        writeStringWithFix(mLabel, BleMedicationReminder.LABLE_LENGTH)
    }
    
    override func decode() {
        super.decode()
        
        mId = Int(readUInt8())
        mType = Int(readUInt8())
        mUnit = Int(readUInt8())
        mDosage = Int(readUInt32(ByteOrder.LITTLE_ENDIAN))
        mRepeat = Int(readUInt8())
        mRemindTimes = Int(readUInt8())
        mRemindTime1 = readObject(BleHmTime.ITEM_LENGTH)
        mRemindTime2 = readObject(BleHmTime.ITEM_LENGTH)
        mRemindTime3 = readObject(BleHmTime.ITEM_LENGTH)
        mRemindTime4 = readObject(BleHmTime.ITEM_LENGTH)
        mRemindTime5 = readObject(BleHmTime.ITEM_LENGTH)
        mRemindTime6 = readObject(BleHmTime.ITEM_LENGTH)
        mStartYear = Int(readUInt8()) + 2000
        mStartMonth = Int(readUInt8())
        mStartDay = Int(readUInt8())
        mEndYear = Int(readUInt8()) + 2000
        mEndMonth = Int(readUInt8())
        mEndDay = Int(readUInt8())
        mName = readString(BleMedicationReminder.NAME_LENGTH)
        mLabel = readString(BleMedicationReminder.LABLE_LENGTH)
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleMedicationReminder{

        let newModel = BleMedicationReminder()
        if dic.keys.isEmpty {
            return newModel
        }
        newModel.mId = dic["mId"] as? Int ?? 0
        newModel.mType = dic["mType"] as? Int ?? 0
        newModel.mUnit = dic["mUnit"] as? Int ?? 0
        newModel.mDosage = dic["mDosage"] as? Int ?? 0
        newModel.mRepeat = dic["mRepeat"] as? Int ?? 0
        newModel.mRemindTimes = dic["mRemindTimes"] as? Int ?? 0
        
        
        let dic1 : [String:Any] = dic["mRemindTime1"] as? [String:Any] ?? [:]
        newModel.mRemindTime1 = BleHmTime().dictionaryToObjct(dic1)
        
        let dic2 : [String:Any] = dic["mRemindTime2"] as? [String:Any] ?? [:]
        newModel.mRemindTime2 = BleHmTime().dictionaryToObjct(dic2)

        let dic3 : [String:Any] = dic["mRemindTime3"] as? [String:Any] ?? [:]
        newModel.mRemindTime3 = BleHmTime().dictionaryToObjct(dic3)
        
        let dic4 : [String:Any] = dic["mRemindTime4"] as? [String:Any] ?? [:]
        newModel.mRemindTime4 = BleHmTime().dictionaryToObjct(dic4)
        
        let dic5 : [String:Any] = dic["mRemindTime5"] as? [String:Any] ?? [:]
        newModel.mRemindTime5 = BleHmTime().dictionaryToObjct(dic5)

        let dic6 : [String:Any] = dic["mRemindTime6"] as? [String:Any] ?? [:]
        newModel.mRemindTime6 = BleHmTime().dictionaryToObjct(dic6)
        
        newModel.mStartYear = dic["mStartYear"] as? Int ?? 0
        newModel.mStartMonth = dic["mStartMonth"] as? Int ?? 0
        newModel.mStartDay = dic["mStartDay"] as? Int ?? 0
        
        newModel.mEndYear = dic["mEndYear"] as? Int ?? 0
        newModel.mEndMonth = dic["mEndMonth"] as? Int ?? 0
        newModel.mEndDay = dic["mEndDay"] as? Int ?? 0
        
        newModel.mName = dic["mName"] as? String ?? ""
        newModel.mLabel = dic["mLabel"] as? String ?? ""
        
        return newModel
    }
    
    func toDictionary()->[String:Any]{
        
        let dic : [String : Any] = [
            "mId": mId,
            "mType":mType,
            "mUnit":mUnit,
            "mDosage":mDosage,
            "mRepeat":mRepeat,
            "mRemindTimes":mRemindTimes,
            
            "mRemindTime1":mRemindTime1.toDictionary(),
            "mRemindTime2":mRemindTime2.toDictionary(),
            "mRemindTime3":mRemindTime3.toDictionary(),
            "mRemindTime4":mRemindTime4.toDictionary(),
            "mRemindTime5":mRemindTime5.toDictionary(),
            "mRemindTime6":mRemindTime6.toDictionary(),
            
            "mStartYear":mStartYear,
            "mStartMonth":mStartMonth,
            "mStartDay":mStartDay,

            "mEndYear":mEndYear,
            "mEndMonth":mEndMonth,
            "mEndDay":mEndDay,
            
            "mName":mName,
            "mLabel":mLabel,
            
        ]
        return dic
    }
    
    override var description: String {
        
        "BleMedicationReminder(mId=\(mId), " +
        "mType=\(mType), mUnit=\(mUnit), mDosage=\(mDosage), " +
        "mRepeat=\(mRepeat), mRemindTimes=\(mRemindTimes), \n" +
        "mRemindTime1=\(mRemindTime1), \n" +
        "mRemindTime2=\(mRemindTime2), \n" +
        "mRemindTime3=\(mRemindTime3), \n" +
        "mRemindTime4=\(mRemindTime4), \n" +
        "mRemindTime5=\(mRemindTime5), \n" +
        "mRemindTime6=\(mRemindTime6), \n" +
        "mStartYear=\(mStartYear), mStartMonth=\(mStartMonth), mStartDay=\(mStartDay), \n" +
        "mEndYear=\(mEndYear), mEndMonth=\(mEndMonth), mEndDay=\(mEndDay), \n" +
        "mName='\(mName)', mLabel='\(mLabel)')"
    }
    
    
}
