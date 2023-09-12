//
//  BlePackageStatus.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/3/3.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

class BlePackageStatus: BleReadable {

    /// 字库状态信息 0:有效, 1无效
    var mFontPackageStatus: Int = 0
    /// UI状态信息 0:有效, 1无效
    var mUIPackageStatus: Int = 0
    /// 语言包状态信息 0:有效, 1无效
    var mLanguagePackageStatus: Int = 0
    /// 调试数据, 父类有了mData变量, 为了区分, 这里修改下
    var mByte: Data?
    
    
    override func decode() {
        super.decode()
        
        mFontPackageStatus = Int(readInt8())
        mUIPackageStatus = Int(readInt8())
        mLanguagePackageStatus = Int(readInt8())
        let _ = readInt8()
        let _ = readInt32()
        if let dataCount = mData?.count, dataCount > 8 {
            mByte = readData(dataCount - 8)
        }
    }
    
    
    override var description: String {
        return "BlePackageStatus(mFontPackageStatus=\(mFontPackageStatus), mUIPackageStatus=\(mUIPackageStatus), mLanguagePackageStatus=\(mLanguagePackageStatus), mByte='\(mByte?.mHexString ?? "")')"
    }
    
}
