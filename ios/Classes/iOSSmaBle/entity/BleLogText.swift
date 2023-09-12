//
//  BleLogText.swift
//  SmartV3
//
//  Created by SMA on 2021/7/24.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation

class BleLogText: BleReadable {
    static let ITEM_LENGTH = 64
    var mContent :String = ""
    
    override func decode() {
        super.decode()
        if mData!.count>0 && mData!.isEmpty == false {
            let end = mData?.index(0, offsetBy: 1)
            if end == -1{
                mContent = String.init(data: mData!, encoding: .utf8)!
            }else{
                let bytes = [UInt8](mData!)
                if mContent == String(bytes: bytes, encoding: .utf8) {
                    mContent = String(bytes: bytes, encoding: .utf8)!
                    bleLog("BleLogText - \(mContent)")
                } else {
                    bleLog("BleLogText not a valid UTF-8 sequence \n\n\(String(describing: mData?.mHexString))\n\n")
                }
            }
        }
    }
}
