//
//  BleFoodBalance.swift
//  blesdk3
//
//  Created by 叩鼎科技 on 2022/12/30.
//  Copyright © 2022 szabh. All rights reserved.
//

import UIKit

class BleFoodBalance: BleReadable {

    /// 距离当地2000/1/1 00:00:00 的秒数
    var mTime: Int = 0
    
    var mMealCategoryFlag:Int = 0 // 哪一餐
    var mRiceAmount:Int = 0 // 谷类数量
    var mFishAmount:Int = 0 // 鱼数量
    var mMeatAmount:Int = 0 // 肉数量
    var mVegetableAmount:Int = 0 // 蔬菜数量
    var mLiquorAmount:Int = 0 // 酒类数量
    
    
    // MARK: mMealCategoryFlag常量
    static let CATEGORY_BREAKFAST = 0 //早餐
    static let CATEGORY_LUNCH = 1//午餐
    static let CATEGORY_DINNER = 2//晚餐
    static let CATEGORY_SNACK = 3 //点心
    
    
    // MARK: 摄入的饮食常量 mRiceAmount mFishAmount mMeatAmount mVegetableAmount mLiquorAmount 共用下面的数据
    static let AMOUNT_NONE = 0
    static let AMOUNT_A_LITTLE = 1
    static let AMOUNT_NORMAL = 2
    static let AMOUNT_A_LOT = 3
    
    
    static let ITEM_LENGTH = 12
    
    
    override func decode() {
        super.decode()
        
        mTime = Int(readInt32())
        mMealCategoryFlag = Int(readInt8())
        mRiceAmount = Int(readInt8())
        mFishAmount = Int(readInt8())
        mMeatAmount = Int(readInt8())
        mVegetableAmount = Int(readInt8())
        mLiquorAmount = Int(readInt8())
    }
    
    override var description: String {
        "BleFoodBalance(mTime:\(mTime), mMealCategoryFlag:\(mMealCategoryFlag), mRiceAmount:\(mRiceAmount), mFishAmount:\(mFishAmount), mMeatAmount:\(mMeatAmount), mVegetableAmount:\(mVegetableAmount), mLiquorAmount:\(mLiquorAmount))"
    }
}
