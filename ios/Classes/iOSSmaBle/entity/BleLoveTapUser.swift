//
//  BleLoveTapUser.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/11/30.
//  Copyright © 2022 CodingIOT. All rights reserved.
//

import UIKit

class BleLoveTapUser: BleIdObject {

    private static let NAME_LENGTH = 24
    static var ITEM_LENGTH: Int {
        get {
            return 4 + BleLoveTapUser.NAME_LENGTH
        }
    }

    override var mLengthToWrite: Int {
        return BleLoveTapUser.ITEM_LENGTH
    }
    
    /// 用户名称
    var mName = ""
    
    init( _ mId: Int, _ mName: String = "") {
        super.init()
        self.mId = mId
        self.mName = mName
    }
    
    
    override func encode() {
        super.encode()
        
        writeInt8(mId)
        writeInt24(0)
        writeStringWithFix(mName, BleLoveTapUser.NAME_LENGTH)
    }
    
    override func decode() {
        super.decode()
        
        mId = Int(readUInt8())
        _ = readUInt24()  // reserved
        mName = readString(BleLoveTapUser.NAME_LENGTH)
    }
    

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mId = try container.decode(Int.self, forKey: .mId)
        mName = try container.decode(String.self, forKey: .mName)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mId, forKey: .mId)
        try container.encode(mName, forKey: .mName)
    }

    private enum CodingKeys: String, CodingKey {
        case mId, mName
    }

    override var description: String {
        "BleLoveTapUser(mId: \(mId), mName: \(mName))"
    }
    
    func toDictionary()->[String:Any]{
        let dic: [String : Any] = [
            "mId":mId,
            "mName":mName
        ]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleLoveTapUser{

        let newModel = BleLoveTapUser()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mId = dic["mId"] as? Int ?? 0
        newModel.mName = dic["mName"] as? String ?? ""
        return newModel
    }
}
