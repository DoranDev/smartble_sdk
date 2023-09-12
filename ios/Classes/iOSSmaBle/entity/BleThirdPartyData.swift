//
//  BleThirdPartyData.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/12/23.
//  Copyright © 2022 CodingIOT. All rights reserved.
//

import UIKit

enum BleThirdPartyType: Int {
    case ALIPAY = 0x01
}

class BleThirdPartyData: BleWritable {

    /// 第三方类型, 1: 支付宝
    var mType = 0
    /// 第三方数据长度
    var mSize = 0
    /// 索引, 数据太大需要拆包
    var mIndex = 0
    /// 第三方数据, 注意属性名称, 父类有一个mData,  不要重名了
    var mSubData: Data?
    
    override var mLengthToWrite: Int {
        return 1 + 4 + 4 + (mData?.count ?? 0)
    }
    

    override func encode() {
        super.encode()
        
        writeInt8(mType)
        writeInt32(mSize)
        writeInt32(mIndex)
        writeData(self.mSubData)
    }
    
    override func decode() {
        super.decode()
        
        mType = Int(readInt8())
        mSize = Int(readInt32())
        mIndex = Int(readInt32())
        
        // mData为父类属性
        if let mData = self.mData, mData.count > 9 {
            mSubData =  readData(mData.count - 9)
        }
    }
    
    override var description: String {
        
        return "BleThirdPartyData(mType=\(mType), mSize=\(mSize), mIndex=\(mIndex), mSubData=\(self.mSubData?.count ?? 0))"
    }
}
