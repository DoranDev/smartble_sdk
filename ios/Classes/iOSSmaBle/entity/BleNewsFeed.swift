//
//  BleNewsFeed.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/12/1.
//  Copyright © 2022 CodingIOT. All rights reserved.
//

import UIKit

class BleNewsFeed: BleWritable {
    
    var mCategory: Int = 0
    var mUid: Int = 0 //unique identifier
    var mTime: Int = 0 // ms
    var mTitle: String = ""
    var mContent: String = ""
    
    // 字节数
    private let TITLE_LENGTH = 32
    private lazy var CONTENT_MAX_LENGTH: Int = {
       return 512 - TITLE_LENGTH - (1 + 3 + 6) // 内容最大长度，字节数
    }()
    
    override var mLengthToWrite: Int {
        // mContent.toByteArray().size
        let byteCount = mContent.data(using: .utf8)?.count ?? 0
        return 1 + 3 + 6 + TITLE_LENGTH + min(byteCount, CONTENT_MAX_LENGTH)
    }
    
    
    override func encode() {
        super.encode()
        
        writeInt8(mCategory)
        writeInt24(mUid, .LITTLE_ENDIAN)
        writeObject(BleTime.ofLocal(mTime))
        writeStringWithFix(mTitle, TITLE_LENGTH)
        writeStringWithLimit(mContent, CONTENT_MAX_LENGTH)
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleNewsFeed{

        let newModel = BleNewsFeed()
        if dic.keys.isEmpty {
            return newModel
        }
        newModel.mCategory = dic["mCategory"] as? Int ?? 0
        newModel.mUid = dic["mUid"] as? Int ?? 0
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mTitle = dic["mTitle"] as? String ?? ""
        newModel.mContent = dic["mContent"] as? String ?? ""

        return newModel
    }
    
    override var description: String {
        return "BleNotification(mCategory=\(mCategory), mUid=\(mUid), mTime=\(mTime), mTitle='\(mTitle)', mContent='\(mContent)')"
    }
    
    
}
