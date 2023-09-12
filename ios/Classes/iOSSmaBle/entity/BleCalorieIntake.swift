//
//  BleCalorieIntake.swift
//  blesdk3
//
//  Created by 叩鼎科技 on 2022/12/30.
//  Copyright © 2022 szabh. All rights reserved.
//

import UIKit

class BleCalorieIntake: BleReadable {

    /// 距离当地2000/1/1 00:00:00 的秒数
    var mTime: Int = 0
    /// 那一餐, 参考: CategoryType取值
    var mMealCategoryFlag: Int = 0
    /// 摄入的卡路量，1/10000千卡，例如接收到的数据为56045，则代表 5.6045 Kcal 约等于 5.6 Kcal
    var mCalorie: Int = 0
    
    static let ITEM_LENGTH = 12
    
    override func decode() {
        super.decode()
        
        mTime = Int(readInt32())
        mMealCategoryFlag = Int(readInt8())
        mCalorie = Int(readUInt32())
    }
    
    /// 那一餐类型
    enum CategoryType: Int {
        /// 早餐
        case breakFast = 0
        /// 午餐
        case lunch
        /// 晚餐
        case dinner
        /// 点心
        case snack
    }
    
    override var description: String {
        "BleCalorieIntake(mTime:\(mTime), mMealCategoryFlag:\(mMealCategoryFlag), mCalorie:\(mCalorie))"
    }
}
