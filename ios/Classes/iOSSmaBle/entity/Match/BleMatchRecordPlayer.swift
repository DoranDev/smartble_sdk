//
//  BleMatchRecordPlayer.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2023/4/14.
//  Copyright © 2023 CodingIOT. All rights reserved.
//

import UIKit

class BleMatchRecordPlayer: BleReadable {
    static let NAME_LENGTH = 26

    /// 球员名字utf8编码
    var mName = ""
    /// 球员号码
    var mNum = 0
    

    override func decode() {
        super.decode()
        
        mName = readString(BleMatchRecordPlayer.NAME_LENGTH)
        mNum = Int(readInt8())
    }
    
    override var description: String {
        "BleMatchRecordPlayer(mName:\(mName), mNum:\(mNum))"
    }
}
